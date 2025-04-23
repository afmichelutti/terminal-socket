// Cliente WebSocket
const WebSocket = require('ws');
const logger = require('../utils/logger');

let ws = null;
let terminalToken = '';
let reconnectTimeout = null;

// Adicionar esta variável para rastrear o token gerado pelo servidor
let serverGeneratedToken = '';

let handlers = {
    onStatus: null,
    onQuery: null,
    onCommand: null
};

// Inicializar cliente WebSocket
function initialize(token, eventHandlers) {
    terminalToken = token;

    if (eventHandlers) {
        handlers = {
            ...handlers,
            ...eventHandlers
        };
    }

    logger.info('Cliente WebSocket inicializado', 'Auditoria');
}

// Conectar ao servidor WebSocket
function connect() {
    try {
        // Limpar timeout de reconexão existente
        if (reconnectTimeout) {
            clearTimeout(reconnectTimeout);
            reconnectTimeout = null;
        }

        // Criar nova conexão
        const socketUrl = process.env.SOCKET_URL || '138.204.224.235:9090';
        ws = new WebSocket(`ws://${socketUrl}`);

        // Manipulador de conexão aberta
        ws.on('open', () => {
            logger.info('Conectado ao WebSocket', 'Auditoria');
            console.log('Enviando token para registro:', terminalToken);

            // Enviar mensagem inicial com o token do terminal
            const initialMessage = JSON.stringify({
                type: 'initial',
                uuid: terminalToken || '' // Garantir que não seja undefined
            });

            ws.send(initialMessage);
        });

        // Manipulador de mensagens
        ws.on('message', async (data) => {
            try {
                const message = data.toString();
                console.log('Resposta do servidor:', message);

                // Parse da mensagem
                const packet = JSON.parse(message);

                // Capturar o token gerado pelo servidor
                if (packet.type === 'uuid') {
                    serverGeneratedToken = packet.uuid;
                    console.log('Token gerado pelo servidor:', serverGeneratedToken);

                    // Se nosso token estava vazio, usar o gerado pelo servidor
                    if (!terminalToken) {
                        terminalToken = serverGeneratedToken;
                        console.log('Token atualizado para:', terminalToken);
                    }
                }

                let response = null;

                // Processar diferentes tipos de mensagens (similar ao código Delphi)
                if (packet.type === 'query' && handlers.onQuery) {
                    response = await handlers.onQuery(message);
                } else if (packet.type === 'status' && handlers.onStatus) {
                    response = await handlers.onStatus(message);
                } else if (packet.type === 'command' && handlers.onCommand) {
                    response = await handlers.onCommand(message);
                }

                // Enviar resposta se disponível
                if (response && ws.readyState === WebSocket.OPEN) {
                    ws.send(response);
                }
            } catch (error) {
                console.error('Erro ao processar mensagem:', error);
                logger.error(`Erro ao processar mensagem WebSocket: ${error.message}`);
            }
        });

        // Manipulador de erro
        ws.on('error', (error) => {
            logger.error(`Erro no WebSocket: ${error.message}`);
        });

        // Manipulador de fechamento da conexão
        ws.on('close', () => {
            logger.info('Desconectado do WebSocket', 'Auditoria');
            scheduleReconnect();
        });

        return true;
    } catch (error) {
        logger.error(`Erro ao conectar WebSocket: ${error.message}`);
        scheduleReconnect();
        return false;
    }
}

// Agendar reconexão (similar ao código Delphi)
function scheduleReconnect() {
    if (!reconnectTimeout) {
        reconnectTimeout = setTimeout(() => {
            logger.info('Tentando reconectar WebSocket', 'Auditoria');
            connect();
        }, 5000); // 5 segundos, mesmo valor do código Delphi
    }
}

// Verificar se WebSocket está conectado
function isConnected() {
    return ws && ws.readyState === WebSocket.OPEN;
}

// Desconectar WebSocket
async function disconnect() {
    try {
        if (reconnectTimeout) {
            clearTimeout(reconnectTimeout);
            reconnectTimeout = null;
        }

        if (ws) {
            ws.close();
            ws = null;
        }

        logger.info('WebSocket desconectado', 'Auditoria');
        return true;
    } catch (error) {
        logger.error(`Erro ao desconectar WebSocket: ${error.message}`);
        return false;
    }
}

// Enviar mensagem pelo WebSocket
function send(message) {
    try {
        if (!isConnected()) {
            throw new Error('WebSocket não está conectado');
        }

        ws.send(message);
        return true;
    } catch (error) {
        logger.error(`Erro ao enviar mensagem WebSocket: ${error.message}`);
        return false;
    }
}

// Função para obter o token atual (adicionar esta função)
function getToken() {
    // Retornar o token do terminal ou o gerado pelo servidor
    return terminalToken || serverGeneratedToken || '';
}

module.exports = {
    initialize,
    connect,
    disconnect,
    isConnected,
    send,
    getToken  // Exportar a nova função
};