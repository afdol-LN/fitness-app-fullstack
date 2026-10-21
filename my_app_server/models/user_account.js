const pool = require("../libs/db_pool");
const dateUtils = require("../libs/data_utils");
module.exports = {
    


    checkAuthenRequest: async (authenRequest) => {
        let conn;
        let result;

        try {
            conn = await pool.getConnection();

            const sql = "SELECT account_id, account_username, account_image_url FROM user_accounts WHERE " +
                "SHA2(CONCAT(account_username, '&', ?), 256) = ?";
            const rows = await conn.query(sql, [dateUtils.getCurrentDateForToken(), authenRequest]);

            if (rows.length === 0) {
                result = {
                    isError: true,
                    errorMessage: "ไม่พบบัญชีในระบบ"
                };
            } else {
                result = {
                    isError: false,
                    data: rows
                };
            }
        } catch (err) {
            result = {
                isError: true,
                errorMessage: err.message
            };
        } finally {
            if (conn) conn.release();
            return result;
        }
    },

    checkAccessRequest: async (authenSignature, authenToken) => {
        let conn;
        let result;

        try {
            conn = await pool.getConnection();

            const sql = "SELECT account_id, account_username, account_image_url FROM user_accounts WHERE " +
                "SHA2(CONCAT(account_username, '&', account_password, '&', ?), 256) = ?";

            const rows = await conn.query(sql, [authenToken, authenSignature]);

            if (rows.length === 0) {
                result = {
                    isError: true,
                    errorMessage: "ไม่พบบัญชีในระบบ"
                };
            } else {
                result = {
                    isError: false,
                    data: rows
                };
            }
        } catch (err) {
            result = {
                isError: true,
                errorMessage: err.message
            };
        } finally {
            if (conn) conn.release();
            return result;
        }
    },

    updateProfileName: async (accountId, fileName) => {
        let conn;
        let result;

        try{
            conn = await pool.getConnection();

            var sql = "UPDATE user_accounts SET account_image_url = ? "
            + "WHERE account_id = ?"

            await conn.query(sql,[fileName, accountId]);

            result = {
                isError : false,
                data: fileName,
                errorMessage: ""
            }
        }catch(error){
            result = {
                isError : true,
                data : "",
                errorMessage: error.message
            }
        }
        finally{
            if(conn){
                conn.release();
                return result;
            }
        }
    }
};
