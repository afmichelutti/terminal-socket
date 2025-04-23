// Script para instalação do serviço Windows
const Service = require('node-windows').Service;
const path = require('path');
const EventLogger = require('node-windows').EventLogger;
const logger = new EventLogger('TerminalSocket');

// Configurar o serviço
const svc = new Service({
    name: 'TerminalSocket',
    description: 'Cliente terminal socket para comunicação com servidor remoto e acesso ao banco de dados Firebird',
    script: path.join(__dirname, 'app.js'),
    nodeOptions: [
        '--harmony',
        '--max_old_space_size=4096'
    ],
    workingDirectory: __dirname,
    allowServiceLogon: true
});

// Eventos do serviço
svc.on('install', function () {
    logger.info('Serviço instalado com sucesso.');
    console.log('Serviço instalado com sucesso.');
    svc.start();
});

svc.on('start', function () {
    logger.info('Serviço iniciado com sucesso.');
    console.log('Serviço iniciado com sucesso.');
});

svc.on('stop', function () {
    logger.info('Serviço parado.');
    console.log('Serviço parado.');
});

svc.on('error', function (error) {
    logger.error('Erro no serviço: ' + error);
    console.error('Erro no serviço:', error);
});

// Instalar o serviço
console.log('Instalando serviço...');
svc.install();