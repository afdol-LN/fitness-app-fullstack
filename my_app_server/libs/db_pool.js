const mariadb = require('mariadb');
const dbConfig = require('../config/db.config.js');
const pool = mariadb.createPool({
    ...dbConfig,
    connectionLimit: 5
});

module.exports = pool;
