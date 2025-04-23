// Gerenciador de configurações
const fs = require('fs');
const path = require('path');
const ini = require('ini');
const logger = require('../utils/logger');

const iniFilePath = path.join(__dirname, 'terminal.ini');

// Configurações padrão
const defaultConfig = {
    Database: {
        driverid: process.env.FB_DRIVER || 'firebird',
        server: process.env.FB_SERVER || 'localhost',
        database: process.env.FB_DATABASE || 'database.fdb',
        user: process.env.FB_USER || 'SYSDBA',
        password: process.env.FB_PASSWORD || 'masterkey',
        port: process.env.FB_PORT || '3050'
    }
};

// Carregar configurações
async function load() {
    try {
        // Se o arquivo não existir, criar com configurações padrão
        if (!fs.existsSync(iniFilePath)) {
            await write(defaultConfig);
            logger.info('Arquivo INI criado com configurações padrão', 'Auditoria');
            return defaultConfig;
        }

        // Ler arquivo INI
        const content = fs.readFileSync(iniFilePath, 'utf-8');
        const config = ini.parse(content);

        // Mesclar com valores do .env
        if (process.env.FB_DRIVER) config.Database.driverid = process.env.FB_DRIVER;
        if (process.env.FB_SERVER) config.Database.server = process.env.FB_SERVER;
        if (process.env.FB_DATABASE) config.Database.database = process.env.FB_DATABASE;
        if (process.env.FB_USER) config.Database.user = process.env.FB_USER;
        if (process.env.FB_PASSWORD) config.Database.password = process.env.FB_PASSWORD;
        if (process.env.FB_PORT) config.Database.port = process.env.FB_PORT;

        return config;
    } catch (error) {
        logger.error(`Erro ao carregar configurações: ${error.message}`);
        return defaultConfig;
    }
}

// Ler valor do arquivo INI
function read(section, key) {
    try {
        if (!fs.existsSync(iniFilePath)) {
            return '';
        }

        const content = fs.readFileSync(iniFilePath, 'utf-8');
        const config = ini.parse(content);

        if (config[section] && config[section][key] !== undefined) {
            return config[section][key];
        }

        return '';
    } catch (error) {
        logger.error(`Erro ao ler configuração ${section}.${key}: ${error.message}`);
        return '';
    }
}

// Escrever valor no arquivo INI
async function write(config) {
    try {
        // Se o arquivo já existir, ler primeiro para mesclar as configurações
        if (fs.existsSync(iniFilePath)) {
            const existingContent = fs.readFileSync(iniFilePath, 'utf-8');
            const existingConfig = ini.parse(existingContent);

            // Mesclar as configurações
            config = { ...existingConfig, ...config };
        }

        // Converter para formato INI e salvar
        const content = ini.stringify(config);
        fs.writeFileSync(iniFilePath, content, 'utf-8');

        return true;
    } catch (error) {
        logger.error(`Erro ao escrever configuração: ${error.message}`);
        return false;
    }
}

// Escrever um valor específico
function writeValue(section, key, value) {
    try {
        let config = {};

        // Se o arquivo já existir, ler primeiro
        if (fs.existsSync(iniFilePath)) {
            const existingContent = fs.readFileSync(iniFilePath, 'utf-8');
            config = ini.parse(existingContent);
        }

        // Garantir que a seção existe
        if (!config[section]) {
            config[section] = {};
        }

        // Definir o valor
        config[section][key] = value;

        // Salvar o arquivo
        const content = ini.stringify(config);
        fs.writeFileSync(iniFilePath, content, 'utf-8');

        return true;
    } catch (error) {
        logger.error(`Erro ao escrever configuração ${section}.${key}: ${error.message}`);
        return false;
    }
}

module.exports = {
    load,
    read,
    write,
    writeValue
};