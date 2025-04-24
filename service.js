// Script para instalação do serviço Windows
const Service = require('node-windows').Service;
const path = require('path');
const EventLogger = require('node-windows').EventLogger;
const logger = new EventLogger('TerminalSocket');

// Configurar o serviço com o caminho COMPLETO e correto
const svc = new Service({
    name: 'TerminalSocket',
    description: 'Cliente terminal socket para comunicação com servidor remoto e acesso ao banco de dados Firebird',
    script: path.resolve(__dirname, 'app.js'), // Usar path.resolve para caminho absoluto
    nodeOptions: [
        '--harmony',
        '--max_old_space_size=4096'
    ],
    workingDirectory: __dirname, // Isso será o caminho correto d:\node\blink\terminal-socket
    allowServiceLogon: true
});

// Eventos do serviço
svc.on('install', function () {
    logger.info('Serviço instalado com sucesso.');
    console.log('Serviço instalado com sucesso.');
    console.log('Diretório de trabalho:', __dirname);
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

svc.on('alreadyinstalled', function () {
    console.log('Serviço já está instalado. Desinstalando para reinstalar...');
    svc.uninstall();
});

svc.on('uninstall', function () {
    console.log('Serviço desinstalado. Reinstalando...');
    setTimeout(function () {
        svc.install();
    }, 2000);
});

// Instalar o serviço
console.log('Instalando serviço...');
console.log('Diretório atual:', __dirname);
svc.install();