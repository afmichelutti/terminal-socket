// Sistema de logs
const fs = require('fs');
const path = require('path');
const EventLogger = require('node-windows').EventLogger;
const windowsLogger = new EventLogger('TerminalSocket');

// Obter caminho do arquivo de log
const logFile = path.join(process.cwd(), 'log_terminal.txt');

// Níveis de log
const LOG_LEVELS = {
    debug: 0,
    info: 1,
    warn: 2,
    error: 3
};

// Obter nível mínimo de log configurado
const configuredLevel = (process.env.LOG_LEVEL || 'info').toLowerCase();
const MINIMUM_LEVEL = LOG_LEVELS[configuredLevel] || LOG_LEVELS.info;

// Escrever no arquivo de log (similar ao código Delphi)
function writeToFile(message, type = 'Erro') {
    try {
        const now = new Date();
        const timestamp = now.toLocaleString('pt-BR');
        const logLine = `${timestamp} - ${type} : ${message}\n`;

        fs.appendFileSync(logFile, logLine);
        return true;
    } catch (error) {
        console.error(`Erro ao escrever no arquivo de log: ${error.message}`);
        return false;
    }
}

// Log de debug
function debug(message, type = 'Debug') {
    if (LOG_LEVELS.debug < MINIMUM_LEVEL) return;

    console.debug(`DEBUG: ${message}`);
    writeToFile(message, type);
}

// Log de informação
function info(message, type = 'Info') {
    if (LOG_LEVELS.info < MINIMUM_LEVEL) return;

    console.info(`INFO: ${message}`);
    writeToFile(message, type);

    // Registrar também no Event Viewer do Windows
    windowsLogger.info(message);
}

// Log de aviso
function warn(message, type = 'Aviso') {
    if (LOG_LEVELS.warn < MINIMUM_LEVEL) return;

    console.warn(`WARN: ${message}`);
    writeToFile(message, type);

    // Registrar também no Event Viewer do Windows
    windowsLogger.warn(message);
}

// Log de erro
function error(message, type = 'Erro') {
    if (LOG_LEVELS.error < MINIMUM_LEVEL) return;

    console.error(`ERROR: ${message}`);
    writeToFile(message, type);

    // Registrar também no Event Viewer do Windows
    windowsLogger.error(message);
}

// Exportar funções
module.exports = {
    debug,
    info,
    warn,
    error
};