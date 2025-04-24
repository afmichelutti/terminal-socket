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

// Modificar a função initialize para usar conexão direta
async function initialize() {
    try {
        await config.load();

        // Usar as configurações do ambiente, com fallback para o INI
        dbConfig = {
            host: process.env.FB_SERVER || config.read('Database', 'server') || 'localhost',
            database: process.env.FB_DATABASE || config.read('Database', 'database') || 'database.fdb',
            user: process.env.FB_USER || config.read('Database', 'user') || 'SYSDBA',
            password: process.env.FB_PASSWORD || config.read('Database', 'password') || 'masterkey',
            port: parseInt(process.env.FB_PORT || config.read('Database', 'port') || '3050', 10),
            lowercase_keys: true,
            charset: 'WIN1252',
            blobAsText: true
        };

        // Teste de conexão direta
        const testConnection = await new Promise((resolve, reject) => {
            Firebird.attach(dbConfig, (err, db) => {
                if (err) reject(err);
                else {
                    db.detach();
                    resolve(true);
                }
            });
        });

        // Criar pool só depois do teste
        dbPool = Firebird.pool(5, dbConfig);

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

// Adicione esta nova função para restaurar acentos
function restoreAccents(text) {
    // Dicionário reverso para restaurar os acentos nos resultados
    const valueMap = {
        'Producao': 'Produção',
        'Servico': 'Serviço',
        'Codigo': 'Código',
        'Descricao': 'Descrição',
        'Observacao': 'Observação',
        'Numero': 'Número',
        'nao': 'não'
    };

    // Verificar se o texto exato existe no mapa
    if (valueMap[text]) {
        return valueMap[text];
    }

    // Se não for um texto exato, procurar por substituições dentro do texto
    let restoredText = text;
    for (const [plain, accented] of Object.entries(valueMap)) {
        // Usar regex para substituir apenas palavras completas
        const regex = new RegExp(`\\b${plain}\\b`, 'g');
        restoredText = restoredText.replace(regex, accented);
    }

    return restoredText;
}

// Nova função para sanitização completa
function sanitizeQueryCompletely(query) {
    // Log da query original para referência
    logger.info(`Query original: ${query}`);

    // 1. Converter datas de MM/DD/YYYY para YYYY-MM-DD
    const dateRegex = /'(\d{1,2})\/(\d{1,2})\/(\d{4})'/g;
    let sanitized = query.replace(dateRegex, (match, month, day, year) => {
        const formattedMonth = month.padStart(2, '0');
        const formattedDay = day.padStart(2, '0');
        return `'${year}-${formattedMonth}-${formattedDay}'`;
    });

    // 3. Substituir COALESCE e preservar aliases
    sanitized = sanitized.replace(
        /coalesce\s*\(\s*([^,]+)\s*,\s*'[^']*'\s*\)(\s+as\s+\w+)/gi,
        "$1$2"
    );

    sanitized = sanitized.replace(
        /coalesce\s*\(\s*([^,]+)\s*,\s*0\s*\)(\s+as\s+\w+)/gi,
        "$1$2"
    );

    // 4. Substituir CASE WHEN e preservar aliases
    sanitized = sanitized.replace(
        /case\s+when\s+([^\s]+)\s+is\s+null\s+then\s+(?:'[^']*'|null|0)\s+else\s+([^\s]+)\s+end(\s+as\s+\w+)/gi,
        "$2$3"
    );

    // 6. Remover todos os acentos restantes usando um mapa de caracteres
    const accentMap = {
        'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
        'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
        'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
        'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
        'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
        'ç': 'c',
        'Á': 'A', 'À': 'A', 'Â': 'A', 'Ã': 'A', 'Ä': 'A',
        'É': 'E', 'È': 'E', 'Ê': 'E', 'Ë': 'E',
        'Í': 'I', 'Ì': 'I', 'Î': 'I', 'Ï': 'I',
        'Ó': 'O', 'Ò': 'O', 'Ô': 'O', 'Õ': 'O', 'Ö': 'O',
        'Ú': 'U', 'Ù': 'U', 'Û': 'U', 'Ü': 'U',
        'Ç': 'C'
    };

    for (const accent in accentMap) {
        sanitized = sanitized.replace(new RegExp(accent, 'g'), accentMap[accent]);
    }

    // Log da query sanitizada para debug
    logger.info(`Query completamente sanitizada: ${sanitized}`);

    return sanitized;
}

// Adicione esta função ao database.js
function extractSelectFields(query) {
    try {
        // Normalizar a query (remover quebras de linha, múltiplos espaços)
        const normalizedQuery = query.replace(/\s+/g, ' ').trim();

        // Extrair a parte SELECT da query (até o FROM)
        const selectPart = normalizedQuery.match(/select\s+(.*?)\s+from/i)?.[1];
        if (!selectPart) {
            logger.warn('Não foi possível extrair a parte SELECT da query');
            return [];
        }

        // Array para armazenar os nomes das colunas com seus aliases
        const columns = [];

        // Processa cada parte da cláusula SELECT
        let currentPos = 0;
        let inFunction = 0;
        let start = 0;
        let insideQuotes = false;

        for (let i = 0; i < selectPart.length; i++) {
            const char = selectPart[i];

            // Trata strings entre aspas como um bloco
            if (char === "'" && selectPart[i - 1] !== '\\') {
                insideQuotes = !insideQuotes;
            }

            // Não processa separadores dentro de funções ou strings
            if (insideQuotes) continue;

            // Controla parênteses de funções
            if (char === '(') inFunction++;
            else if (char === ')') inFunction--;

            // Identifica separadores de colunas (vírgulas fora de funções)
            if (char === ',' && inFunction === 0) {
                columns.push(selectPart.substring(start, i).trim());
                start = i + 1;
            }
        }

        // Adiciona a última coluna
        columns.push(selectPart.substring(start).trim());

        // Extrai os nomes/aliases finais
        return columns.map(col => {
            // Procura por alias explicito (as nome)
            const aliasMatch = col.match(/\s+as\s+(\w+)$/i);
            if (aliasMatch) {
                return aliasMatch[1].toLowerCase();
            }

            // Se não tem alias, usa o nome da coluna
            // Primeiro verifica caso de função (como count(*))
            if (col.includes('(')) {
                // Extrai o último token após o último espaço como possível nome
                const lastToken = col.trim().split(/\s+/).pop();
                return lastToken.toLowerCase();
            }

            // Para colunas simples, pega o nome após o último ponto
            const simpleName = col.includes('.') ?
                col.split('.').pop().toLowerCase() :
                col.toLowerCase();

            return simpleName;
        });
    } catch (error) {
        logger.error(`Erro ao extrair campos da query: ${error.message}`);
        return [];
    }
}

// Modifique a função executeQuery para usar os campos extraídos
async function executeQuery(query) {
    try {
        let connection = null;
        try {
            // Extrair campos da query original
            const expectedFields = extractSelectFields(query);
            logger.info(`Campos esperados da query: ${expectedFields.join(', ')}`);

            connection = await getConnection();
            const sanitizedQuery = sanitizeQueryCompletely(query);
            logger.info(`Executando query sanitizada: ${sanitizedQuery}`);

            const queryAsync = promisify(connection.query).bind(connection);
            const result = await queryAsync(sanitizedQuery);

            // Verificar quais campos vieram no resultado
            if (result && result.length > 0) {
                const returnedFields = Object.keys(result[0]).map(f => f.toLowerCase());
                logger.info(`Campos retornados: ${returnedFields.join(', ')}`);

                // Identificar campos ausentes
                const missingFields = expectedFields.filter(f =>
                    !returnedFields.includes(f.toLowerCase())
                );

                if (missingFields.length > 0) {
                    logger.warn(`Campos ausentes: ${missingFields.join(', ')}`);
                }
            }

            // Resto do seu código para processamento dos resultados...
            const formattedResult = result.map(row => {
                const newRow = {};

                // Primeiro adicionar campos que vieram no resultado
                for (const key in row) {
                    const lowerKey = key.toLowerCase();
                    let value = row[key];

                    // Seu código atual de processamento
                    if (value === null) {
                        if (typeof value === 'number') {
                            value = 0;
                        } else {
                            value = '';
                        }
                    }

                    // Formatar datas no estilo da API legada (YYYY-MM-DD)
                    if (value instanceof Date) {
                        value = value.toISOString().split('T')[0];
                    }

                    // Remover espaços extras e restaurar acentos
                    if (typeof value === 'string') {
                        value = value.trim();
                        value = restoreAccents(value);
                    }

                    newRow[lowerKey] = value;
                }

                // Adicionar campos esperados que estão ausentes
                for (const field of expectedFields) {
                    const fieldLower = field.toLowerCase();
                    if (!(fieldLower in newRow)) {
                        // Inferir tipo baseado no nome do campo
                        const isNumeric = fieldLower.includes('id') ||
                            fieldLower.includes('quantidade') ||
                            fieldLower === 'dias' ||
                            fieldLower === 'pedido' ||
                            fieldLower.includes('preco');

                        newRow[fieldLower] = isNumeric ? 0 : '';
                        logger.info(`Adicionado campo ausente: ${fieldLower}`);
                    }
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
    testarQueryPorPartes
};