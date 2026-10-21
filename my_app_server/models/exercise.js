const pool = require('../libs/db_pool')

module.exports = {
    getAllExercise : async ()=>{
        var conn;
        var result;
        var response;
        try{
            conn = pool.getConnection();
            const sql = "SELECT * FROM exercises"
            result = await conn.query(sql)
            if(result.length == 0){
                response = {
                    isError : true,
                    errorMessage : "หาข้อมูลไม่เจอ ม่ายยยยยย!!"
                }
            }
            else{
                response = {
                    isError : false,
                    data : result
                }
            }
        }
        catch(error){
            response = {
                isError: true,
                errorMessage: error.message
            }
        }
        finally{
            if(conn) conn.release(0)

            return response;
        }
    },

}