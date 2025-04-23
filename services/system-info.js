// Funções para obter informações do sistema
const os = require('os');
const { exec } = require('child_process');
const { promisify } = require('util');
const systeminformation = require('systeminformation');
const logger = require('../utils/logger');

const execAsync = promisify(exec);

// Obter informações do Windows (similar ao código Delphi)
async function getWindowsInfo() {
    try {
        const { stdout } = await execAsync('wmic os get Caption, Version, BuildNumber');

        // Processar saída para extrair informações
        const lines = stdout.split('\n').filter(line => line.trim().length > 0);
        if (lines.length >= 2) {
            const parts = lines[1].trim().split(/\s+/);

            // Construir string semelhante ao retorno do código Delphi
            let caption = '';
            let version = '';
            let buildNumber = '';

            if (parts.length >= 3) {
                caption = parts.slice(0, parts.length - 2).join(' ');
                version = parts[parts.length - 2];
                buildNumber = parts[parts.length - 1];
            }

            return `${caption} - ${version} - ${buildNumber}`;
        }

        // Fallback para informações do Node.js
        return `${os.type()} - ${os.release()} - ${os.version()}`;
    } catch (error) {
        logger.error(`Erro ao obter informações do Windows: ${error.message}`);
        return `${os.type()} - ${os.release()} - ${os.version()}`;
    }
}

// Obter velocidade da CPU (similar ao código Delphi)
async function getCPUSpeed() {
    try {
        const cpuData = await systeminformation.cpu();
        return cpuData.speed.toFixed(3);
    } catch (error) {
        logger.error(`Erro ao obter velocidade da CPU: ${error.message}`);
        return '0.000';
    }
}

// Obter endereço IP (similar ao código Delphi)
async function getIP() {
    try {
        const networkInterfaces = os.networkInterfaces();

        // Procurar pela primeira interface que não seja de loopback e tenha IPv4
        for (const [name, interfaces] of Object.entries(networkInterfaces)) {
            for (const iface of interfaces) {
                if (iface.family === 'IPv4' && !iface.internal) {
                    return iface.address;
                }
            }
        }

        return '127.0.0.1';
    } catch (error) {
        logger.error(`Erro ao obter endereço IP: ${error.message}`);
        return '127.0.0.1';
    }
}

// Obter nome do host (similar ao código Delphi)
async function getHostName() {
    try {
        return os.hostname();
    } catch (error) {
        logger.error(`Erro ao obter nome do host: ${error.message}`);
        return '';
    }
}

// Obter domínio (similar ao código Delphi)
async function getDomain() {
    try {
        // No Windows, tentar obter o domínio usando comando externo
        if (os.platform() === 'win32') {
            try {
                const { stdout } = await execAsync('wmic computersystem get domain');
                const lines = stdout.split('\n').filter(line => line.trim().length > 0);
                if (lines.length >= 2) {
                    return lines[1].trim();
                }
            } catch (e) {
                // Silenciar erro e tentar método alternativo
            }
        }

        // Método alternativo: verificar se o hostname tem um domínio
        const hostname = os.hostname();
        const parts = hostname.split('.');

        if (parts.length > 1) {
            return parts.slice(1).join('.');
        }

        return '';
    } catch (error) {
        logger.error(`Erro ao obter domínio: ${error.message}`);
        return '';
    }
}

// Obter nome do usuário (similar ao código Delphi)
async function getUsername() {
    try {
        return os.userInfo().username;
    } catch (error) {
        logger.error(`Erro ao obter nome do usuário: ${error.message}`);
        return '';
    }
}

// Obter quantidade de memória (similar ao código Delphi)
async function getMemory() {
    try {
        const totalMemoryBytes = os.totalmem();

        // Formatar como no código Delphi (#0,000)
        return new Intl.NumberFormat('pt-BR', {
            useGrouping: true,
            maximumFractionDigits: 0
        }).format(totalMemoryBytes);
    } catch (error) {
        logger.error(`Erro ao obter quantidade de memória: ${error.message}`);
        return '0';
    }
}

module.exports = {
    getWindowsInfo,
    getCPUSpeed,
    getIP,
    getHostName,
    getDomain,
    getUsername,
    getMemory
};