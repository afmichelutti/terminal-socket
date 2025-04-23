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

// Adicione esta função
function formatQuery(query) {
    // Tratamento de datas
    const dateRegex = /'(\d{1,2})\/(\d{1,2})\/(\d{4})'/g;
    let formattedQuery = query.replace(dateRegex, (match, month, day, year) => {
        const formattedMonth = month.padStart(2, '0');
        const formattedDay = day.padStart(2, '0');
        return `'${year}-${formattedMonth}-${formattedDay}'`;
    });

    // Escapa aspas simples dentro de strings (para evitar problemas de SQL injection)
    formattedQuery = formattedQuery.replace(/'([^']*)'/g, (match, content) => {
        // Substituir aspas simples por duplas dentro da string
        const escapedContent = content.replace(/'/g, "''");
        return `'${escapedContent}'`;
    });

    // Log para depuração
    logger.info(`Query original: ${query}`);
    logger.info(`Query formatada: ${formattedQuery}`);

    return formattedQuery;
}

// Executar uma consulta SQL
async function executeQuery(query) {
    let connection = null;
    try {
        connection = await getConnection();
        const formattedQuery = formatQuery(query);

        // Promisify a função de query
        const queryAsync = promisify(connection.query).bind(connection);

        try {
            // Executar consulta com a query formatada
            const result = await queryAsync(formattedQuery);

            // Converter nomes de colunas para lowercase
            const formattedResult = result.map(row => {
                const newRow = {};
                for (const key in row) {
                    newRow[key.toLowerCase()] = row[key];
                }
                return newRow;
            });

            return formattedResult;
        } catch (queryError) {
            // Log detalhado do erro específico da consulta
            logger.error(`Erro de SQL: ${queryError.message}`);
            logger.error(`Query que causou o erro: ${formattedQuery}`);
            throw queryError;
        }
    } catch (error) {
        logger.error(`Erro ao executar consulta: ${error.message}`);
        throw error;
    } finally {
        if (connection) {
            await releaseConnection(connection);
        }
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
    close
};