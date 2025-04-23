// Servidor HTTP
const express = require('express');
const logger = require('../utils/logger');

const app = express();
let server = null;
let terminalToken = '';

// Iniciar servidor HTTP
function start(token) {
    try {
        terminalToken = token;
        const port = process.env.API_PORT || 7778;

        // Configurar middleware para JSON
        app.use(express.json());

        // Rota principal (igual ao código Delphi)
        app.get('/', (req, res) => {
            const responseObj = {
                timestamp: new Date(),
                status: 'running',
                terminal: terminalToken
            };

            res.json(responseObj);
        });

        // Iniciar servidor
        server = app.listen(port, () => {
            logger.info(`Servidor HTTP rodando na porta ${port}`, 'Auditoria');
        });

        return true;
    } catch (error) {
        logger.error(`Erro ao iniciar servidor HTTP: ${error.message}`);
        return false;
    }
}

// Parar servidor HTTP
function stop() {
    try {
        if (server) {
            server.close();
            server = null;
            logger.info('Servidor HTTP parado', 'Auditoria');
        }

        return true;
    } catch (error) {
        logger.error(`Erro ao parar servidor HTTP: ${error.message}`);
        return false;
    }
}

module.exports = {
    start,
    stop
};