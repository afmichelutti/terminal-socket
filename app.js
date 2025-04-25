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

// Adicionar depois das importações e antes da função main()

// Monitor de saúde para auto recuperação
function setupHealthMonitor() {
    let lastActivityTime = Date.now();
    let isReconnecting = false;

    // Registrar atividade inicial
    logger.info('Monitor de saúde iniciado');

    // Interceptar método executeQuery para monitorar atividade
    const originalExecuteQuery = database.executeQuery;
    database.executeQuery = async function (query) {
        try {
            const result = await originalExecuteQuery.apply(this, arguments);
            // Registrar atividade bem-sucedida
            lastActivityTime = Date.now();
            return result;
        } catch (error) {
            // Também registrar atividade em caso de erro (para não acionar o timeout)
            lastActivityTime = Date.now();
            throw error; // Repassar o erro original
        }
    };

    // Adicionar método de reconexão ao banco se não existir
    if (!database.reconnect) {
        database.reconnect = async function () {
            try {
                logger.info('Tentando reconexão ao banco de dados...');
                await database.close();
                await database.initialize();
                logger.info('Reconectado ao banco de dados com sucesso');
                return true;
            } catch (error) {
                logger.error(`Falha na reconexão ao banco: ${error.message}`);
                return false;
            }
        };
    }

    // Adicionar método de reconexão ao websocket se não existir
    if (!websocket.reconnect) {
        websocket.reconnect = async function () {
            try {
                logger.info('Tentando reconexão ao websocket...');
                await websocket.disconnect();

                // Reinicializar websocket com os handlers existentes e token
                websocket.initialize(terminal, {
                    onStatus: handleStatusRequest,
                    onQuery: handleQueryRequest
                });

                websocket.connect();
                logger.info('Reconectado ao websocket com sucesso');
                return true;
            } catch (error) {
                logger.error(`Falha na reconexão ao websocket: ${error.message}`);
                return false;
            }
        };
    }

    // Verificar regularmente se o sistema está respondendo
    const healthCheckInterval = setInterval(async () => {
        // Se já estiver reconectando, pular esta verificação
        if (isReconnecting) return;

        const inactiveTime = Date.now() - lastActivityTime;

        // Após 3 minutos inativo, tentar reconexão
        if (inactiveTime > 3 * 60 * 1000) {
            isReconnecting = true;
            logger.warn(`Aplicação inativa por ${Math.round(inactiveTime / 1000 / 60)} minutos. Possível travamento detectado.`);

            try {
                // Tentar reconectar banco e websocket
                const dbReconnected = await database.reconnect();
                const wsReconnected = await websocket.reconnect();

                if (dbReconnected && wsReconnected) {
                    logger.info("Serviços reconectados com sucesso após inatividade");
                    lastActivityTime = Date.now();
                } else {
                    logger.error("Falha na reconexão de pelo menos um serviço. Forçando reinício.");
                    // Registrar estado antes de reiniciar
                    logger.error(`Estado do sistema antes do reinício forçado:
                        - Tempo inativo: ${Math.round(inactiveTime / 1000)} segundos
                        - DB reconectado: ${dbReconnected}
                        - WS reconectado: ${wsReconnected}
                    `);

                    // Aguardar 5 segundos para completar o log
                    setTimeout(() => {
                        process.exit(1);  // PM2 reiniciará automaticamente
                    }, 5000);
                    return;
                }
            } catch (error) {
                logger.error(`Erro durante recuperação: ${error.message}. Reinício forçado.`);
                setTimeout(() => {
                    process.exit(1);  // PM2 reiniciará automaticamente
                }, 5000);
                return;
            } finally {
                isReconnecting = false;
            }
        }

        // A cada 10 minutos, registrar um heartbeat (para saber que o monitor está funcionando)
        else if (inactiveTime > 10 * 60 * 1000) {
            logger.info(`Heartbeat: Sistema ativo, ${Math.round(inactiveTime / 1000 / 60)} minutos desde última atividade`);
            // Não atualizar lastActivityTime para não interferir com monitoramento real
        }

    }, 30000); // Verificar a cada 30 segundos

    // Garantir que o interval seja limpo em caso de encerramento
    process.on('beforeExit', () => {
        clearInterval(healthCheckInterval);
    });
}

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

        setupHealthMonitor(); // Configurar monitor de saúde para auto recuperação

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
                api_message: 'sucess', // Alterado para manter compatibilidade com API Delphi
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