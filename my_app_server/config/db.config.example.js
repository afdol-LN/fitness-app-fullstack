// Copy this file to db.config.js and put your own database settings in it.
// db.config.js is in .gitignore so the password is never pushed.
const dbConfig = {
    host: 'localhost',
    user: 'root',
    password: 'YOUR_DB_PASSWORD',
    database: 'my_fitness',
    port: 3306
};

module.exports = dbConfig;
