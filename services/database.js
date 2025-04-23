// Conexão e operações com banco de dados Firebird
const Firebird = require('node-firebird'); // Alterado para node-firebird
const { promisify } = require('util');
const logger = require('../utils/logger');
const config = require('../config/config');

let dbConfig = {
    host: process.env.FB_SERVER || 'localhost',
    database: process.env.FB_DATABASE || 'database.fdb',
    user: process.env.FB_USER || 'SYSDBA',
    password: process.env.FB_PASSWORD || 'masterkey',
    port: parseInt(process.env.FB_PORT || '3050', 10)
};

let dbPool = null;

// Inicializar pool de conexões
async function initialize() {
    try {
        // Carregar configurações do INI
        await config.load();

        // Usar as configurações do ambiente, com fallback para o INI
        dbConfig = {
            host: process.env.FB_SERVER || config.read('Database', 'server') || 'localhost',
            database: process.env.FB_DATABASE || config.read('Database', 'database') || 'database.fdb',
            user: process.env.FB_USER || config.read('Database', 'user') || 'SYSDBA',
            password: process.env.FB_PASSWORD || config.read('Database', 'password') || 'masterkey',
            port: parseInt(process.env.FB_PORT || config.read('Database', 'port') || '3050', 10),
            lowercase_keys: true,
            pageSize: 4096,
            charset: 'UTF8' // Adicione esta linha
        };

        // Log para depuração
        // console.log('Configuração do banco:', JSON.stringify(dbConfig, null, 2));

        // Criar pool de conexões
        dbPool = Firebird.pool(5, dbConfig);

        // Teste de conexão
        const connection = await getConnection();
        await releaseConnection(connection);

        logger.info('Conexão com banco de dados estabelecida', 'Auditoria');
        return true;
    } catch (error) {
        logger.error(`Erro ao inicializar conexão com banco de dados: ${error.message}`);
        throw error;
    }
}

// Obter uma conexão do pool
async function getConnection() {
    return new Promise((resolve, reject) => {
        if (!dbPool) {
            return reject(new Error('Pool de conexões não inicializado'));
        }

        dbPool.get((err, db) => {
            if (err) {
                return reject(err);
            }
            resolve(db);
        });
    });
}

// Liberar uma conexão de volta para o pool
async function releaseConnection(connection) {
    if (connection) {
        connection.detach();
    }
}

// Executar uma consulta SQL
async function executeQuery(query) {
    try {
        // Para consultas complexas que estavam falhando
        if (query.includes('case tipo_ordem when') || query.length > 500) {
            logger.info("Detectada consulta complexa, usando estratégia alternativa");
            return await executeLargeQuery(query);
        }

        // Para consultas simples, método normal
        let connection = null;
        try {
            connection = await getConnection();

            // Substituir caracteres acentuados na query para evitar problemas de encoding
            const sanitizedQuery = sanitizeQuery(query);

            const queryAsync = promisify(connection.query).bind(connection);
            const result = await queryAsync(sanitizedQuery);

            // Converter nomes de colunas para lowercase
            const formattedResult = result.map(row => {
                const newRow = {};
                for (const key in row) {
                    newRow[key.toLowerCase()] = row[key];
                }
                return newRow;
            });

            return formattedResult;
        } finally {
            if (connection) {
                await releaseConnection(connection);
            }
        }
    } catch (error) {
        logger.error(`Erro ao executar consulta: ${error.message}`);
        throw error;
    }
}

// Função para sanitizar a query
function sanitizeQuery(query) {
    // Converter datas de MM/DD/YYYY para YYYY-MM-DD
    const dateRegex = /'(\d{1,2})\/(\d{1,2})\/(\d{4})'/g;
    let sanitized = query.replace(dateRegex, (match, month, day, year) => {
        const formattedMonth = month.padStart(2, '0');
        const formattedDay = day.padStart(2, '0');
        return `'${year}-${formattedMonth}-${formattedDay}'`;
    });

    // Remover acentos ou substituir caracteres problemáticos
    sanitized = sanitized
        .replace(/Produção/g, 'Producao')
        .replace(/Serviço/g, 'Servico');

    logger.info(`Query original: ${query}`);
    logger.info(`Query sanitizada: ${sanitized}`);

    return sanitized;
}

// Executar comando SQL (sem retorno de dados)
async function executeCommand(command) {
    let connection = null;
    try {
        connection = await getConnection();

        // Promisify a função de query
        const queryAsync = promisify(connection.query).bind(connection);

        // Executar comando
        await queryAsync(command);

        return true;
    } catch (error) {
        logger.error(`Erro ao executar comando: ${error.message}`);
        throw error;
    } finally {
        if (connection) {
            await releaseConnection(connection);
        }
    }
}

// Obter token do terminal (similar ao código Delphi)
async function getTerminalToken() {
    let connection = null;
    try {
        connection = await getConnection();

        // Promisify a função de query
        const queryAsync = promisify(connection.query).bind(connection);

        // Log para debug
        console.log('Executando consulta para obter token do terminal');

        // Executar consulta para obter token
        const result = await queryAsync("SELECT FIRST 1 SECURE_TOKEN FROM parametro WHERE SECURE_TOKEN IS NOT NULL AND SECURE_TOKEN <> ''");
        console.log('Resultado da consulta de token:', result);

        if (result && result.length > 0) {
            // Usar secure_token em minúsculas em vez de SECURE_TOKEN
            const token = result[0].secure_token || '';
            console.log('Token recuperado do banco:', token);
            return token;
        }

        console.log('Nenhum token encontrado no banco de dados');
        return '';
    } catch (error) {
        logger.error(`Erro ao obter token do terminal: ${error.message}`);
        throw error;
    } finally {
        if (connection) {
            await releaseConnection(connection);
        }
    }
}

// Adicione esta função no arquivo
async function testarQueryPorPartes(query) {
    let connection = null;
    try {
        connection = await getConnection();
        const queryAsync = promisify(connection.query).bind(connection);

        // Testes simples para verificar a conexão básica
        logger.info("===== INICIANDO TESTES DE DIAGNÓSTICO =====");

        try {
            const test1 = await queryAsync("SELECT CURRENT_DATE FROM RDB$DATABASE");
            logger.info("✅ Teste básico OK");
        } catch (err) {
            logger.error(`❌ Falha no teste básico: ${err.message}`);
        }

        // Testando texto com acento
        try {
            const test2 = await queryAsync("SELECT 'Teste' FROM RDB$DATABASE");
            logger.info("✅ Teste com texto simples OK");
        } catch (err) {
            logger.error(`❌ Falha no teste com texto simples: ${err.message}`);
        }

        // Testando especificamente a parte com acentos
        try {
            const test3 = await queryAsync("SELECT case 'C' when 'C' then 'Corte' when 'P' then 'Producao' end FROM RDB$DATABASE");
            logger.info("✅ Teste com CASE sem acentos OK");
        } catch (err) {
            logger.error(`❌ Falha no teste com CASE sem acentos: ${err.message}`);
        }

        // Testando com acentos
        try {
            const test4 = await queryAsync("SELECT 'Produção' FROM RDB$DATABASE");
            logger.info("✅ Teste com texto acentuado OK");
        } catch (err) {
            logger.error(`❌ Falha no teste com texto acentuado: ${err.message}`);
        }

        // Testando formato de data
        try {
            const test5 = await queryAsync("SELECT CAST('2023-06-01' AS DATE) FROM RDB$DATABASE");
            logger.info("✅ Teste com data OK");
        } catch (err) {
            logger.error(`❌ Falha no teste com data: ${err.message}`);
        }

        logger.info("===== FIM DOS TESTES DE DIAGNÓSTICO =====");
        return "Testes concluídos";

    } catch (error) {
        logger.error(`Erro geral nos testes: ${error.message}`);
        throw error;
    } finally {
        if (connection) {
            await releaseConnection(connection);
        }
    }
}

// Adicione esta função no arquivo
async function executeLargeQuery(query) {
    logger.info("Executando consulta complexa usando estratégia alternativa");

    let connection = null;
    try {
        connection = await getConnection();

        // Remover a formatação de datas que já está funcionando
        const dateRegex = /'(\d{1,2})\/(\d{1,2})\/(\d{4})'/g;
        let processedQuery = query.replace(dateRegex, (match, month, day, year) => {
            const formattedMonth = month.padStart(2, '0');
            const formattedDay = day.padStart(2, '0');
            return `'${year}-${formattedMonth}-${formattedDay}'`;
        });

        // Em vez de substituir acentos, vamos usar uma estratégia diferente:
        // Criar uma VIEW temporária para a consulta

        // Nome único para a view temporária
        const viewName = `TEMP_VIEW_${Date.now().toString().substring(5)}`;
        const createViewSql = `CREATE OR ALTER VIEW ${viewName} AS ${processedQuery}`;

        // Executar criação da view
        const queryAsync = promisify(connection.query).bind(connection);
        await queryAsync(createViewSql);
        logger.info(`View temporária ${viewName} criada com sucesso`);

        // Executar consulta na view (mais simples, sem acentos na própria consulta)
        const result = await queryAsync(`SELECT * FROM ${viewName}`);
        logger.info(`Consulta executada com sucesso via view temporária`);

        // Remover a view temporária
        await queryAsync(`DROP VIEW ${viewName}`);
        logger.info(`View temporária ${viewName} removida`);

        // Formatar resultado
        const formattedResult = result.map(row => {
            const newRow = {};
            for (const key in row) {
                newRow[key.toLowerCase()] = row[key];
            }
            return newRow;
        });

        return formattedResult;
    } catch (error) {
        logger.error(`Erro ao usar estratégia alternativa: ${error.message}`);
        throw error;
    } finally {
        if (connection) {
            await releaseConnection(connection);
        }
    }
}

// Formatar consulta SQL
function formatQuery(query) {
    // Apenas tratar as datas, sem mexer em outras partes da string
    const dateRegex = /'(\d{1,2})\/(\d{1,2})\/(\d{4})'/g;
    let formattedQuery = query.replace(dateRegex, (match, month, day, year) => {
        const formattedMonth = month.padStart(2, '0');
        const formattedDay = day.padStart(2, '0');
        return `'${year}-${formattedMonth}-${formattedDay}'`;
    });

    // Remover o processamento de aspas que pode estar causando problemas

    logger.info(`Query original: ${query}`);
    logger.info(`Query formatada: ${formattedQuery}`);

    return formattedQuery;
}

// Fechar pool de conexões
async function close() {
    if (dbPool) {
        // Não há método direto para fechar o pool no firebird,
        // mas podemos definir como null para que novas conexões não sejam feitas
        dbPool = null;
    }
}

module.exports = {
    initialize,
    executeQuery,
    executeCommand,
    getTerminalToken,
    close,
    testarQueryPorPartes,
    executeLargeQuery
};