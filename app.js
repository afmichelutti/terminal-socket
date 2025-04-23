// Arquivo principal da aplicação
require('dotenv').config();
console.log('FB_DATABASE:', process.env.FB_DATABASE);
const path = require('path');
const logger = require('./utils/logger');
const websocket = require('./services/websocket');
const database = require('./services/database');
const httpServer = require('./services/http-server');
const config = require('./config/config');

// Variáveis globais (similar ao código Delphi)
let terminal = '';

async function main() {
    try {
        // Inicializar banco de dados
        await database.initialize();
        logger.info('Conexão com banco de dados inicializada');

        // Obter o token do terminal - ADICIONANDO RETRY E VALIDAÇÃO
        terminal = await getValidTerminalToken();
        logger.info('Terminal: ' + terminal);

        // Somente continuar se tivermos um token válido
        if (!terminal) {
            throw new Error('Não foi possível obter um token válido do terminal');
        }

        // Inicializar servidor HTTP com token
        httpServer.start(terminal);

        // Inicializar WebSocket com token e handlers
        websocket.initialize(terminal, {
            onStatus: handleStatusRequest,
            onQuery: handleQueryRequest
        });

        // Conectar ao WebSocket
        websocket.connect();

    } catch (error) {
        logger.error(`Erro ao inicializar aplicação: ${error.message}`);
    }
}

// Função para obter um token válido com retry
async function getValidTerminalToken(maxRetries = 3) {
    let retries = 0;
    let token = '';

    while (!token && retries < maxRetries) {
        // Tentar obter token
        token = await database.getTerminalToken();

        // Se obteve token, retornar
        if (token) {
            return token;
        }

        // Se não obteve, logar e tentar novamente
        logger.warn(`Tentativa ${retries + 1}/${maxRetries}: Token do terminal vazio, tentando novamente...`);
        retries++;

        // Aguardar 1 segundo antes de tentar novamente
        await new Promise(resolve => setTimeout(resolve, 1000));
    }

    // Se chegou aqui, não conseguiu obter token
    logger.error('Falha ao obter token do terminal após várias tentativas');
    return '';
}

// Manipuladores de requisições (similar às funções do código Delphi)
async function handleStatusRequest(message) {
    try {
        const systemInfo = require('./services/system-info');
        const data = {
            api_status: 1,
            api_message: 'running',
            data: [{
                system: await systemInfo.getWindowsInfo(),
                cpu: await systemInfo.getCPUSpeed(),
                ip: await systemInfo.getIP(),
                name: await systemInfo.getHostName(),
                domain: await systemInfo.getDomain(),
                username: await systemInfo.getUsername(),
                memory: await systemInfo.getMemory(),
                database: {
                    server: process.env.FB_SERVER,
                    database: process.env.FB_DATABASE,
                    user: process.env.FB_USER,
                    port: process.env.FB_PORT
                }
            }]
        };
        return JSON.stringify(data);
    } catch (error) {
        logger.error(`Erro ao processar status: ${error.message}`);
        return JSON.stringify({
            api_status: 0,
            api_message: error.message
        });
    }
}

async function handleQueryRequest(message) {
    try {
        const post = JSON.parse(message);
        if (post.content && post.content.query) {
            const result = await database.executeQuery(post.content.query);
            return JSON.stringify({
                api_status: 1,
                api_message: 'success',
                data: result
            });
        }
        return JSON.stringify({
            api_status: 0,
            api_message: 'Query não fornecida'
        });
    } catch (error) {
        logger.error(`Erro ao executar query: ${error.message}`);
        return JSON.stringify({
            api_status: 0,
            api_message: error.message
        });
    }
}

// Tratamento de encerramento gracioso
process.on('SIGTERM', async () => {
    logger.info('Serviço está sendo encerrado...', 'Auditoria');
    await websocket.disconnect();
    await database.close();
    httpServer.stop();
    process.exit(0);
});

process.on('uncaughtException', (error) => {
    logger.error(`Erro não tratado: ${error.message}`);
});

// Iniciar a aplicação
main().catch(error => {
    logger.error(`Falha ao iniciar aplicação: ${error.message}`);
    process.exit(1);
});