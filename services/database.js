const Firebird = require('node-firebird'); // Alterado para node-firebird
const { promisify } = require('util');
const logger = require('../utils/logger');
const config = require('../config/config');
const iconv = require('iconv-lite');

let dbConfig = {
    host: process.env.FB_SERVER || 'localhost',
    database: process.env.FB_DATABASE || 'database.fdb',
    user: process.env.FB_USER || 'SYSDBA',
    password: process.env.FB_PASSWORD || 'masterkey',
    port: parseInt(process.env.FB_PORT || '3050', 10)
};

let dbPool = null;

// Modificar a função initialize para usar apenas conexões dedicadas
async function initialize() {
    try {
        await config.load();

        // Configurar dbConfig como antes
        dbConfig = {
            host: process.env.FB_SERVER || config.read('Database', 'server') || 'localhost',
            database: process.env.FB_DATABASE || config.read('Database', 'database') || 'database.fdb',
            user: process.env.FB_USER || config.read('Database', 'user') || 'SYSDBA',
            password: process.env.FB_PASSWORD || config.read('Database', 'password') || 'masterkey',
            port: parseInt(process.env.FB_PORT || config.read('Database', 'port') || '3050', 10),
            lowercase_keys: true,
            charset: 'ISO8859_1',
            encoding: 'latin1',
            blobAsText: true
        };

        // Teste de conexão
        const testConnection = await getDedicatedConnection();
        testConnection.detach();

        logger.info('Conexão com banco de dados estabelecida (modo sem pool)', 'Auditoria');
        return true;
    } catch (error) {
        logger.error(`Erro ao inicializar conexão com banco de dados: ${error.message}`);
        throw error;
    }
}

// Função para tentar decodificar usando Buffer
// Substituir a função decodeWin1252 atual
function decodeWin1252(text) {
    if (typeof text !== 'string') {
        return text;
    }

    // Mapeamento direto de caracteres específicos problemáticos
    const characterMap = {
        'FAC��O': 'FACÇÃO',
        '��': 'ÇÕ',
        '�': 'Ç',
        'Servico': 'Serviço',
        'Producao': 'Produção',
        'FACO': 'FACÇÃO',
        'OBSERVACOES': 'OBSERVAÇÕES',
        'CAMISETE FEMININO': 'CAMISETE FEMININO',
        'FILETE NAS MANGAS': 'FILETE NAS MANGAS',
        'BOTAO': 'BOTÃO',
        'PATE': 'PATÊ',
        'PE DE GOLA': 'PÉ DE GOLA'
    };

    // Primeiro tentar substituições específicas para strings completas
    for (const [original, corrected] of Object.entries(characterMap)) {
        if (text.includes(original)) {
            text = text.replace(new RegExp(original, 'g'), corrected);
        }
    }

    // Se o texto ainda contiver caracteres problemáticos, tente decodificação
    try {
        // Tenta criar um buffer e decodificar como ISO-8859-1
        const buffer = Buffer.from(text, 'binary');
        const decodedLatin1 = buffer.toString('latin1');

        // Se a decodificação produziu algo diferente e sem caracteres inválidos
        if (decodedLatin1 !== text && !decodedLatin1.includes('�')) {
            return decodedLatin1;
        }
    } catch (e) {
        logger.warn(`Erro ao decodificar texto: ${e.message}`);
    }

    return text;
}

function sanitizeResultEncoding(result) {
    if (!Array.isArray(result)) {
        return result;
    }

    // Adicionar logging para verificar os tipos reais que estão chegando
    if (result.length > 0) {
        const firstRow = result[0];
        logger.info(`=== TIPOS ANTES DA SANITIZAÇÃO ===`);
        for (const key in firstRow) {
            const value = firstRow[key];
            logger.info(`Campo: ${key}, Valor: ${value}, Tipo: ${typeof value}`);
        }
    }

    return result.map(row => {
        const newRow = {};
        for (const key in row) {
            let value = row[key];

            if (typeof value === 'string') {
                // Usar a função convertEncoding para uma abordagem mais consistente
                value = convertEncoding(value);

                // Verificar se campo é um tamanho (tam##) e está vazio ou null
                if (key.toLowerCase().match(/^tam\d+$/) && (!value || value.trim() === '')) {
                    newRow[key] = ''; // Garantir string vazia para campos tam vazios
                } else {
                    newRow[key] = value;
                }
            } else if (value === null) {
                // Valores nulos tratados de acordo com o padrão do campo
                if (key.toLowerCase().match(/^tam\d+$/)) {
                    newRow[key] = ''; // Campo tam## nulo vira string vazia
                } else if (key.toLowerCase().match(/^e\d+$/)) {
                    newRow[key] = 0;  // Campo e## nulo vira número zero
                } else {
                    newRow[key] = '';  // Default para outros campos
                }
            } else {
                // Se campo de tamanho não é string, converter para string
                if (key.toLowerCase().match(/^tam\d+$/)) {
                    newRow[key] = String(value);
                } else if (key.toLowerCase().match(/^e\d+$/) && typeof value !== 'number') {
                    // Se campo de estoque não é número, converter para número
                    const num = parseFloat(value);
                    newRow[key] = isNaN(num) ? 0 : num;
                } else {
                    newRow[key] = value;
                }
            }
        }

        return newRow;
    });
}

// Adicione esta função ao database.js
function extractSelectFields(query) {
    try {
        // Normalizar a query (remover quebras de linha, múltiplos espaços)
        const normalizedQuery = query.replace(/\s+/g, ' ').trim();

        // Extrair a parte SELECT da query (até o FROM)
        const selectPart = normalizedQuery.match(/select\s+(.*?)\s+from/i)?.[1];
        if (!selectPart) {
            logger.warn('Não foi possível extrair a parte SELECT da query');
            return [];
        }

        // Array para armazenar os nomes das colunas com seus aliases
        const columns = [];

        // Processa cada parte da cláusula SELECT
        let currentPos = 0;
        let inFunction = 0;
        let start = 0;
        let insideQuotes = false;

        for (let i = 0; i < selectPart.length; i++) {
            const char = selectPart[i];

            // Trata strings entre aspas como um bloco
            if (char === "'" && selectPart[i - 1] !== '\\') {
                insideQuotes = !insideQuotes;
            }

            // Não processa separadores dentro de funções ou strings
            if (insideQuotes) continue;

            // Controla parênteses de funções
            if (char === '(') inFunction++;
            else if (char === ')') inFunction--;

            // Identifica separadores de colunas (vírgulas fora de funções)
            if (char === ',' && inFunction === 0) {
                columns.push(selectPart.substring(start, i).trim());
                start = i + 1;
            }
        }

        // Adiciona a última coluna
        columns.push(selectPart.substring(start).trim());

        // Extrai os nomes/aliases finais
        return columns.map(col => {
            // Procura por alias explicito (as nome)
            const aliasMatch = col.match(/\s+as\s+(\w+)$/i);
            if (aliasMatch) {
                return aliasMatch[1].toLowerCase();
            }

            // Se não tem alias, usa o nome da coluna
            // Primeiro verifica caso de função (como count(*))
            if (col.includes('(')) {
                // Extrai o último token após o último espaço como possível nome
                const lastToken = col.trim().split(/\s+/).pop();
                return lastToken.toLowerCase();
            }

            // Para colunas simples, pega o nome após o último ponto
            const simpleName = col.includes('.') ?
                col.split('.').pop().toLowerCase() :
                col.toLowerCase();

            return simpleName;
        });
    } catch (error) {
        logger.error(`Erro ao extrair campos da query: ${error.message}`);
        return [];
    }
}

// Adicione esta função para inferir tipos a partir dos valores e estrutura
function inferFieldTypes(query, result) {
    const typeMap = new Map();

    // Lista de campos que devem ser forçados como string, independente da inferência
    const forceStringFields = ['id_produto'];

    // Lista de padrões de campos que devem ser consistentes
    const fieldPatterns = [
        { pattern: /^tam\d+$/, type: 'string' },  // Todos os campos tam01, tam02...
        { pattern: /^e\d+$/, type: 'number' },    // Todos os campos e01, e02...
        { pattern: /^quant_\d+$/, type: 'number' } // Campos quant_01, quant_02...
    ];

    // Primeiro inferir tipos a partir dos dados reais (prioridade máxima)
    if (result && result.length > 0) {
        for (const row of result) {
            for (const key in row) {
                const keyLower = key.toLowerCase();
                const value = row[key];

                // Se é um dos campos que devemos forçar como string, definir e pular
                if (forceStringFields.includes(keyLower)) {
                    typeMap.set(keyLower, 'string');
                    continue;
                }

                // Se já determinamos o tipo, não precisamos verificar novamente
                if (typeMap.has(keyLower)) {
                    continue;
                }

                // Determinar tipo baseado no valor real dos dados
                if (typeof value === 'number') {
                    typeMap.set(keyLower, 'number');
                } else if (value instanceof Date) {
                    typeMap.set(keyLower, 'date');
                } else if (typeof value === 'string') {
                    // Verificar se a string parece um número
                    if (!isNaN(value) && value.trim() !== '') {
                        const numVal = Number(value);
                        // Se parece um ID ou código (começa com zeros), tratar como string
                        if (value.startsWith('0') && value.length > 1) {
                            typeMap.set(keyLower, 'string');
                        } else {
                            typeMap.set(keyLower, 'number');
                        }
                    } else {
                        typeMap.set(keyLower, 'string');
                    }
                } else {
                    typeMap.set(keyLower, 'string'); // default para outros tipos
                }
            }
        }
    }

    // Aplicar heurísticas baseadas nos nomes de campos apenas para campos não determinados
    if (result && result.length > 0) {
        const firstRow = result[0];
        for (const key in firstRow) {
            const keyLower = key.toLowerCase();

            // Pular campos já determinados ou na lista de forçados
            if (typeMap.has(keyLower) || forceStringFields.includes(keyLower)) {
                continue;
            }

            // Heurísticas baseadas na estrutura da query
            const queryLower = query.toLowerCase();

            // Verificar se é parte de uma expressão matemática
            const mathPattern = new RegExp(`[(\\s]${keyLower}\\s*[+\\-*/]|[+\\-*/]\\s*${keyLower}[\\s)]`, 'i');
            if (queryLower.match(mathPattern)) {
                typeMap.set(keyLower, 'number');
                continue;
            }

            // Verificar se é parte de uma função de agregação
            const aggPattern = new RegExp(`(sum|count|avg|min|max)\\s*\\(\\s*${keyLower}\\s*\\)`, 'i');
            if (queryLower.match(aggPattern)) {
                typeMap.set(keyLower, 'number');
                continue;
            }

            // Verificar sufixos e prefixos comuns para campos numéricos
            // Remova '_id' da lista se id_produto deve sempre ser string
            const numericSuffixes = ['_num', '_qtd', '_count', '_total', '_valor'];
            const isLikelyNumeric = numericSuffixes.some(suffix => keyLower.endsWith(suffix)) ||
                ['num_'].some(prefix => keyLower.startsWith(prefix));

            if (isLikelyNumeric) {
                typeMap.set(keyLower, 'number');
            }
        }
    }

    // NOVA ETAPA: Garantir consistência entre campos do mesmo padrão
    for (const { pattern, type } of fieldPatterns) {
        // Encontrar todos os campos que correspondem ao padrão
        const matchingFields = Array.from(typeMap.keys())
            .filter(field => pattern.test(field));

        // Se encontramos campos que correspondem ao padrão, forçamos todos para o mesmo tipo
        if (matchingFields.length > 0) {
            matchingFields.forEach(field => {
                if (typeMap.get(field) !== type) {
                    logger.info(`Padronizando campo '${field}' para tipo '${type}'`);
                    typeMap.set(field, type);
                }
            });
        }
    }

    return typeMap;
}

// Modifique a função sanitizeQueryCompletely para corrigir a conversão de datas
function sanitizeQueryCompletely(query) {
    let sanitized = query;

    // 1. CORRIGIR: Substituir formatos de data DD/MM/YYYY por YYYY-MM-DD
    sanitized = sanitized.replace(/'(\d{2})\/(\d{2})\/(\d{4})'/g, (match, day, month, year) => {
        // Verificar se os valores são dias/meses válidos
        const dayNum = parseInt(day);
        const monthNum = parseInt(month);

        // Se o primeiro valor é maior que 12, assume formato DD/MM/YYYY
        if (dayNum > 12) {
            // Formato DD/MM/YYYY - primeiro é dia, segundo é mês
            return `'${year}-${month}-${day}'`;
        }
        // Se o segundo valor é maior que 12, assume formato MM/DD/YYYY
        else if (monthNum > 12) {
            // Formato MM/DD/YYYY - primeiro é mês, segundo é dia
            return `'${year}-${day}-${month}'`;
        }
        // Caso ambíguo (exemplo: 10/11/1899), assume DD/MM/YYYY por ser padrão brasileiro
        else {
            return `'${year}-${month}-${day}'`;
        }
    });

    // Substituição específica para a data problemática 12/30/1899
    sanitized = sanitized.replace(/'12\/30\/1899'/g, "'1899-12-30'");
    sanitized = sanitized.replace(/'1899-30-12'/g, "'1899-12-30'");

    // 2. Remover COALESCE(..., 0) ou COALESCE(..., '') para simplificar
    sanitized = sanitized.replace(/coalesce\(([^,]+),\s*0\)/gi, '$1');
    sanitized = sanitized.replace(/coalesce\(([^,]+),\s*''\)/gi, '$1');

    // 3. Simplificar CASE para acentos (se necessário, mas pode ser tratado na decodificação)
    // Exemplo: case tipo_ordem when 'C' then 'Corte' -> case tipo_ordem when 'C' then 'Corte'
    // Por enquanto, não faremos substituições aqui, focando na decodificação

    // 4. Remover comentários SQL (se houver)
    sanitized = sanitized.replace(/--.*$/gm, ''); // Remove comentários de linha
    sanitized = sanitized.replace(/\/\*[\s\S]*?\*\//g, ''); // Remove comentários de bloco

    // 5. Normalizar espaços
    sanitized = sanitized.replace(/\s+/g, ' ').trim();

    // Log da query antes e depois da sanitização completa
    if (query !== sanitized) {
        logger.info(`Query original: ${query}`);
        logger.info(`Query completamente sanitizada: ${sanitized}`);
    }

    return sanitized;
}

async function executeQuery(query) {
    let connection = null;
    try {
        // Extrair campos da query original
        const expectedFields = extractSelectFields(query);

        // Usar conexão dedicada em vez do pool
        connection = await getDedicatedConnection();

        const sanitizedQuery = sanitizeQueryCompletely(query);
        logger.info(`Executando query sanitizada (conexão dedicada): ${sanitizedQuery}`);

        // Criar promisified query
        const queryAsync = promisify(connection.query).bind(connection);

        // Execute a consulta
        let result = await queryAsync(sanitizedQuery);

        // Processar o resultado
        if (!Array.isArray(result)) {
            logger.info(`Resultado não é um array, convertendo: ${JSON.stringify(result)}`);
            if (result && typeof result === 'object') {
                result = [result];
            } else {
                result = [];
            }
        }

        // Verificar se temos resultados antes de continuar
        if (result.length === 0) {
            logger.info('Consulta não retornou resultados');
            return [];
        }

        // Verificar quais campos vieram e inferir tipos
        if (result && result.length > 0) {
            const returnedFields = Object.keys(result[0]).map(f => f.toLowerCase());
            logger.info(`Campos retornados: ${returnedFields.join(', ')}`);
        }

        // Inferir tipos para todos os campos
        const typeMap = inferFieldTypes(query, result);

        if (result && result.length > 0) {
            // Verificar se a consulta é especificamente sobre a tabela produto
            const isProductQuery = /from\s+produto\b|from\s+produto\s+p\b/i.test(query);

            // Verificar se é uma consulta de tabela relacionada que inclui produto.id
            const hasProductIdJoin = /join\s+produto\b.*?\bid\b|p\.id\b/i.test(query);

            // Se é consulta específica de produto ou tem join com o id do produto
            if ((isProductQuery || hasProductIdJoin) && 'id' in result[0]) {
                // Verificar se o ID é realmente da tabela produto
                // Se a consulta tem alias 'p' para produto, verificamos p.id
                const hasProductAlias = /produto\s+p\b/i.test(query);

                if (hasProductAlias && query.toLowerCase().includes('p.id')) {
                    typeMap.set('id', 'string');
                    logger.info('Campo produto.id (p.id) forçado como string');
                }
                // Se não tem alias mas seleciona produto.id ou apenas id da tabela produto
                else if (query.toLowerCase().includes('produto.id') ||
                    (isProductQuery && query.toLowerCase().includes('id'))) {
                    typeMap.set('id', 'string');
                    logger.info('Campo produto.id forçado como string');
                }
            }
        }

        // Tratar id_produto explicitamente como string
        if (typeMap.has('id_produto')) {
            typeMap.set('id_produto', 'string');
        }

        // Log dos tipos inferidos para debug
        typeMap.forEach((type, field) => {
            logger.info(`Tipo inferido para ${field}: ${type}`);
        });

        // Processar os resultados
        const formattedResult = result.map(row => {
            const newRow = {};

            for (const key in row) {
                const lowerKey = key.toLowerCase();
                let value = row[key];
                const inferredType = typeMap.get(lowerKey);

                // Tratar valores nulos baseado no tipo inferido
                if (value === null) {
                    value = inferredType === 'number' ? 0 : '';
                }
                // IMPORTANTE: Garantir que campos string sejam strings
                else if (inferredType === 'string' && typeof value !== 'string') {
                    // Converter explicitamente para string
                    value = String(value);
                }
                // Converter strings que deveriam ser números 
                else if (inferredType === 'number' && typeof value === 'string') {
                    if (value.trim() === '') {
                        value = 0;
                    } else {
                        const numValue = parseFloat(value);
                        if (!isNaN(numValue)) {
                            value = numValue;
                        } else {
                            // Se não puder converter para número, use 0
                            value = 0;
                            logger.warn(`Valor '${value}' não pôde ser convertido para número no campo '${lowerKey}'`);
                        }
                    }
                }

                // Formatação de datas
                if (value instanceof Date) {
                    value = value.toISOString().split('T')[0];
                }

                newRow[lowerKey] = value;
            }

            // Adicionar campos ausentes
            expectedFields.forEach(field => {
                const fieldLower = field.toLowerCase();
                if (!(fieldLower in newRow)) {
                    const inferredType = typeMap.get(fieldLower);
                    newRow[fieldLower] = inferredType === 'number' ? 0 : '';
                }
            });

            return newRow;
        });

        const sanitizedResult = sanitizeResultEncoding(formattedResult);

        if (sanitizedResult && sanitizedResult.length > 0) {
            // Verificação final específica para o nome GONÇALVES
            for (const row of sanitizedResult) {
                if (row.nome && typeof row.nome === 'string' && row.nome.includes('GON') && row.nome.includes('ALVES')) {
                    logger.info(`===VERIFICAÇÃO FINAL===`);
                    logger.info(`Nome com GONÇALVES encontrado: "${row.nome}"`);
                    logger.info(`Bytes do nome: [${[...Buffer.from(row.nome)].join(', ')}]`);

                    // Substituição forçada e final
                    row.nome = row.nome.replace(/GON.{1}ALVES/g, 'GONÇALVES');
                    logger.info(`Nome após última correção: "${row.nome}"`);

                    // Verificar se ainda tem algum caractere problemático
                    if (row.nome.includes('�') || [...Buffer.from(row.nome)].includes(239)) {
                        logger.error(`ALERTA: Ainda há caracteres problemáticos após todas as correções!`);
                    }
                }
            }
        }

        // DEPOIS que temos o resultado sanitizado, fazer validações adicionais
        for (const row of sanitizedResult) {
            Object.keys(row).forEach(key => {
                if (typeof row[key] === 'string') {
                    // Garante que a string é UTF-8 válida uma última vez
                    row[key] = ensureValidUTF8(row[key]);

                    // Verifica se ainda existem caracteres problemáticos
                    if (row[key].includes('�')) {
                        logger.warn(`ALERTA: Caractere inválido encontrado em '${key}': ${row[key]}`);
                        // Remover caracteres inválidos como último recurso
                        row[key] = row[key].replace(/�/g, '');
                    }
                }
            });
        }

        // Garantir tipos específicos para campos especiais
        sanitizedResult.forEach(row => {
            // Forçar campos tam## a serem strings
            Object.keys(row).forEach(key => {
                if (key.match(/^tam\d+$/i)) {
                    if (typeof row[key] !== 'string') {
                        row[key] = row[key] === null ? '' : String(row[key]);
                    }
                }
                // Forçar campos e## a serem números
                else if (key.match(/^e\d+$/i)) {
                    if (typeof row[key] !== 'number') {
                        const num = parseFloat(row[key] || '0');
                        row[key] = isNaN(num) ? 0 : num;
                    }
                }
            });
        });

        // Adicionar log de verificação final
        if (sanitizedResult.length > 0) {
            logger.info(`=== VERIFICAÇÃO FINAL DE TIPOS ===`);
            const checkRow = sanitizedResult[0];
            for (const key in checkRow) {
                logger.info(`Final: ${key}, Tipo: ${typeof checkRow[key]}, Valor: ${JSON.stringify(checkRow[key])}`);
            }
        }

        return sanitizedResult;
    } catch (error) {
        logger.error(`Erro ao executar consulta: ${error.message}`);
        throw error;
    } finally {
        // IMPORTANTE: Fechar a conexão para evitar vazamentos
        if (connection) {
            try {
                connection.detach();
                logger.debug('Conexão dedicada fechada após executeQuery');
            } catch (e) {
                logger.error(`Erro ao fechar conexão: ${e.message}`);
            }
        }
    }
}

// Executar comando SQL (sem retorno de dados)
async function executeCommand(command) {
    let connection = null;
    try {
        connection = await getDedicatedConnection();

        // Promisify a função de query
        const queryAsync = promisify(connection.query).bind(connection);

        // Executar comando
        await queryAsync(command);

        return true;
    } catch (error) {
        logger.error(`Erro ao executar comando: ${error.message}`);
        throw error;
    } finally {
        if (connection) {
            try {
                connection.detach();
                logger.debug('Conexão dedicada fechada após executeCommand');
            } catch (e) {
                logger.error(`Erro ao fechar conexão: ${e.message}`);
            }
        }
    }
}

// Obter token do terminal (similar ao código Delphi)
async function getTerminalToken() {
    let connection = null;
    try {
        connection = await getDedicatedConnection();

        // Promisify a função de query
        const queryAsync = promisify(connection.query).bind(connection);

        // Log para debug
        console.log('Executando consulta para obter token do terminal');

        // Executar consulta para obter token
        const result = await queryAsync("SELECT FIRST 1 SECURE_TOKEN FROM parametro WHERE SECURE_TOKEN IS NOT NULL AND SECURE_TOKEN <> ''");
        console.log('Resultado da consulta de token:', result);

        if (result && result.length > 0) {
            // Usar secure_token em minúsculas em vez de SECURE_TOKEN
            const token = result[0].secure_token || '';
            console.log('Token recuperado do banco:', token);
            return token;
        }

        console.log('Nenhum token encontrado no banco de dados');
        return '';
    } catch (error) {
        logger.error(`Erro ao obter token do terminal: ${error.message}`);
        throw error;
    } finally {
        if (connection) {
            try {
                connection.detach();
                logger.debug('Conexão dedicada fechada após getTerminalToken');
            } catch (e) {
                logger.error(`Erro ao fechar conexão: ${e.message}`);
            }
        }
    }
}

// Adicione esta função no arquivo
async function testarQueryPorPartes(query) {
    let connection = null;
    try {
        connection = await getDedicatedConnection();
        const queryAsync = promisify(connection.query).bind(connection);

        // Testes simples para verificar a conexão básica
        logger.info("===== INICIANDO TESTES DE DIAGNÓSTICO =====");

        try {
            const test1 = await queryAsync("SELECT CURRENT_DATE FROM RDB$DATABASE");
            logger.info("✅ Teste básico OK");
        } catch (err) {
            logger.error(`❌ Falha no teste básico: ${err.message}`);
        }

        // Testando texto com acento
        try {
            const test2 = await queryAsync("SELECT 'Teste' FROM RDB$DATABASE");
            logger.info("✅ Teste com texto simples OK");
        } catch (err) {
            logger.error(`❌ Falha no teste com texto simples: ${err.message}`);
        }

        // Testando especificamente a parte com acentos
        try {
            const test3 = await queryAsync("SELECT case 'C' when 'C' then 'Corte' when 'P' then 'Producao' end FROM RDB$DATABASE");
            logger.info("✅ Teste com CASE sem acentos OK");
        } catch (err) {
            logger.error(`❌ Falha no teste com CASE sem acentos: ${err.message}`);
        }

        // Testando com acentos
        try {
            const test4 = await queryAsync("SELECT 'Produção' FROM RDB$DATABASE");
            logger.info("✅ Teste com texto acentuado OK");
        } catch (err) {
            logger.error(`❌ Falha no teste com texto acentuado: ${err.message}`);
        }

        // Testando formato de data
        try {
            const test5 = await queryAsync("SELECT CAST('2023-06-01' AS DATE) FROM RDB$DATABASE");
            logger.info("✅ Teste com data OK");
        } catch (err) {
            logger.error(`❌ Falha no teste com data: ${err.message}`);
        }

        logger.info("===== FIM DOS TESTES DE DIAGNÓSTICO =====");
        return "Testes concluídos";

    } catch (error) {
        logger.error(`Erro geral nos testes: ${error.message}`);
        throw error;
    } finally {
        if (connection) {
            try {
                connection.detach();
                logger.debug('Conexão dedicada fechada após testarQueryPorPartes');
            } catch (e) {
                logger.error(`Erro ao fechar conexão: ${e.message}`);
            }
        }
    }
}

// Fechar pool de conexões
async function close() {
    if (dbPool) {
        // Não há método direto para fechar o pool no firebird,
        // mas podemos definir como null para que novas conexões não sejam feitas
        dbPool = null;
    }
}

async function getDedicatedConnection() {
    return new Promise((resolve, reject) => {
        Firebird.attach(dbConfig, (err, db) => {
            if (err) {
                logger.error(`Erro ao criar conexão dedicada: ${err.message}`);
                reject(err);
            } else {
                logger.info(`Nova conexão dedicada criada`);
                resolve(db);
            }
        });
    });
}

function ensureValidUTF8(value) {
    if (typeof value !== 'string') {
        return value;
    }

    // Mapeamento específico de caracteres problemáticos conhecidos
    const charMap = {
        'Ã‡': 'Ç', // GON�ALVES
        'Ã§': 'ç',
        'Ãƒâ€š': 'Ç',
        '�': 'Ç',
        'Ã£': 'ã',
        'Ã¢': 'â',
        'Ã©': 'é',
        'Ã‰': 'É',
        'Ãª': 'ê',
        'Ã"': 'Ó',
        'Ã³': 'ó',
        'Ãº': 'ú',
        'Ã­': 'í'
    };

    // Substituir caracteres específicos
    Object.entries(charMap).forEach(([bad, good]) => {
        if (value.includes(bad)) {
            value = value.replace(new RegExp(bad, 'g'), good);
        }
    });

    // Substituir qualquer caractere de substituição Unicode (�) ou bytes inválidos
    value = value.replace(/[\uFFFD\uFFFE\uFFFF]/g, '');

    try {
        // Tentativa de normalização Unicode
        if (typeof value.normalize === 'function') {
            value = value.normalize('NFC');
        }

        // Teste final - garante que podemos codificar e decodificar sem problemas
        const encoded = Buffer.from(value, 'utf8').toString('utf8');
        return encoded;
    } catch (e) {
        // Se falhar, remova todos os caracteres não-ASCII
        return value.replace(/[^\x00-\x7F]/g, '');
    }
}

// Uma função mais inteligente para corrigir caracteres especiais
function fixSpecialCharacters(text) {
    if (typeof text !== 'string') {
        return text;
    }

    // Substituir caracteres problemáticos diretamente
    return text
        // Substituir caractere de substituição Unicode e outros códigos problemáticos 
        .replace(/\uFFFD|�/g, 'Ç')  // Substitui � por Ç

        // Detectar Ç mal codificado em várias formas
        .replace(/GON.{1}ALVES/g, 'GONÇALVES')  // Casos específicos conhecidos
        .replace(/Ã‡|Ãƒâ€š/g, 'Ç')              // Substituições de Ç maiúsculo
        .replace(/Ã§/g, 'ç')                     // Substituições de ç minúsculo

        // Outros caracteres acentuados comuns em português
        .replace(/Ã£/g, 'ã')
        .replace(/Ã¢/g, 'â')
        .replace(/Ã©/g, 'é')
        .replace(/Ã‰/g, 'É')
        .replace(/Ãª/g, 'ê')
        .replace(/Ã"/g, 'Ó')
        .replace(/Ã³/g, 'ó')
        .replace(/Ãº/g, 'ú')
        .replace(/Ã­/g, 'í');
}

function convertEncoding(text) {
    if (typeof text !== 'string') {
        return text;
    }

    // Verificar se contém GONÇALVES
    if (text.includes('GON') && text.includes('ALVES')) {
        logger.info(`===DEPURAÇÃO GONÇALVES===`);
        logger.info(`Texto original: "${text}"`);
        logger.info(`Bytes originais: [${[...Buffer.from(text)].join(', ')}]`);
    }

    try {
        // Considerar o texto como Latin1 (ISO-8859-1) e converter para UTF-8
        const buffer = Buffer.from(text, 'binary');
        const decoded = iconv.decode(buffer, 'latin1');

        // Log para caso específico de GONÇALVES
        if (text.includes('GON') && text.includes('ALVES')) {
            logger.info(`Após iconv: "${decoded}"`);
            logger.info(`Bytes após iconv: [${[...Buffer.from(decoded)].join(', ')}]`);

            // Correção forçada para este caso específico
            const forçado = decoded.replace(/GON.{1}ALVES/g, 'GONÇALVES');
            logger.info(`Após correção forçada: "${forçado}"`);
            return forçado;
        }

        return decoded;
    } catch (e) {
        logger.warn(`Erro na conversão iconv: ${e.message}`);
        // Fallback para substituições simples se a conversão falhar
        const fixed = fixSpecialCharacters(text);

        // Log para depuração
        if (text.includes('GON') && text.includes('ALVES')) {
            logger.info(`Após fixSpecialCharacters: "${fixed}"`);
        }

        return fixed;
    }
}

// Adicione um interceptador de JSON.stringify para verificar o resultado final
const originalStringify = JSON.stringify;
JSON.stringify = function (value, replacer, space) {
    // Verificar se temos o caso problemático no resultado final
    function verificarGonçalves(obj) {
        if (typeof obj === 'string' && obj.includes('GON') && obj.includes('ALVES')) {
            logger.info(`===STRINGIFICAÇÃO JSON===`);
            logger.info(`String com GONÇALVES: "${obj}"`);
            logger.info(`Bytes: [${[...Buffer.from(obj)].join(', ')}]`);

            // Último recurso: substituição forçada
            return obj.replace(/GON.{1}ALVES/g, 'GONÇALVES');
        }

        if (obj !== null && typeof obj === 'object') {
            if (Array.isArray(obj)) {
                return obj.map(verificarGonçalves);
            } else {
                const newObj = {};
                for (const key in obj) {
                    if (key === 'nome' && typeof obj[key] === 'string' &&
                        obj[key].includes('GON') && obj[key].includes('ALVES')) {
                        logger.info(`===CAMPO NOME COM GONÇALVES===`);
                        logger.info(`Valor original: "${obj[key]}"`);
                        newObj[key] = obj[key].replace(/GON.{1}ALVES/g, 'GONÇALVES');
                        logger.info(`Valor corrigido: "${newObj[key]}"`);
                    } else {
                        newObj[key] = verificarGonçalves(obj[key]);
                    }
                }
                return newObj;
            }
        }

        return obj;
    }

    // Aplicar verificações antes da stringificação
    const sanitized = verificarGonçalves(value);
    return originalStringify(sanitized, replacer, space);
};


module.exports = {
    initialize,
    executeQuery,
    executeCommand,
    getTerminalToken,
    close,
    testarQueryPorPartes
};
