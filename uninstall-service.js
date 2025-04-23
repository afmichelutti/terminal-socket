// Script para desinstalação do serviço Windows
const Service = require('node-windows').Service;
const path = require('path');
const EventLogger = require('node-windows').EventLogger;
const logger = new EventLogger('TerminalSocket');

// Configurar o serviço
const svc = new Service({
    name: 'TerminalSocket',
    script: path.join(__dirname, 'app.js')
});

// Eventos do serviço
svc.on('uninstall', function () {
    logger.info('Serviço desinstalado.');
    console.log('Serviço desinstalado com sucesso.');
});

svc.on('error', function (error) {
    logger.error('Erro ao desinstalar serviço: ' + error);
    console.error('Erro ao desinstalar serviço:', error);
});

// Desinstalar o serviço
console.log('Desinstalando serviço...');
svc.uninstall();