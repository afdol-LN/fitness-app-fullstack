const e = require("express");
const pool = require("../libs/db_pool");

module.exports = {
  getActivityByUserId: async (userId) => {
    var conn;
    var response;

    try {
      conn = await pool.getConnection();

      var sql =
        "SELECT usa.account_id, act.act_id, act.ex_id, exc.ex_name, " +
        "DATE_FORMAT(act.act_date, '%d-%m-%Y %H:%i:%s') AS act_date, " +
        "act.kcal_expense " +
        "FROM activities act " +
        "JOIN exercises exc ON act.ex_id = exc.ex_id " +
        "JOIN user_accounts usa ON usa.account_id = act.account_id " +
        "WHERE act.account_id = ?";

      var result = await conn.query(sql, [userId]);
      if (result.length == 0) {
        response = {
          isError: true,
          errorMessage: "no data found",
        };
      } else {
        response = {
          isError: false,
          data: result,
        };
      }
    } catch (error) {
      response = {
        isError: true,
        errorMessage: "เกิดข้อผิดพลาดในการ query",
      };
    } finally {
      if (conn) conn.release();
      return response;
    }
  },
  getActivityByExerciseId: async (accountId, exerciseId) => {
    let conn;
    let result;

    try {
      conn = await pool.getConnection();
      const query =
        "select act.act_id, act.ex_id, ex.ex_name, " +
        "DATE_FORMAT(act.act_date, '%d-%m-%Y %H:%i:%s') AS act_date, " +
        "act.kcal_expense " +
        "FROM activities act " +
        "JOIN exercises ex ON act.ex_id = ex.ex_id " +
        "WHERE act.account_id = ? " +
        "AND act.ex_id = ?";
      const row = await conn.query(query, [accountId, exerciseId]);
      result = {
        isError: false,
        data: row,
        errorMessage: "",
      };
    } catch (error) {
      result = {
        isError: true,
        data: "",
        errorMessage: error.message,
      };
    } finally {
      if (conn) {
        conn.release();
      }
      return result;
    }
  },

  createActivity: async (accountId, exerciseId, activityDate, kcalExpense) => {
    let conn;
    let result;
    try {
      conn = await pool.getConnection();

      var sql =
        "INSERT INTO activities (ex_id, act_date, kcal_expense, account_id) " +
        "VALUES(?, STR_TO_DATE(?, '%d-%m-%Y %H:%i:%s'), ?, ?)";

      await conn.query(sql, [exerciseId, activityDate, kcalExpense, accountId]);

      result = {
        isError: false,
        data: "",
        errorMessage: "",
      };
    } catch (error) {
      result = {
        isError: true,
        data: "",
        errorMessage: error.message,
      };
    } finally {
      if (conn) {
        conn.release();
      }
      return result;
    }
  },
  getActivityByid: async (activityId) => {
    var response;
    var conn;
    try {
      conn = await pool.getConnection();
      const sql =
        "select act.act_id AS activityId, act.ex_id AS exerciseid, " +
        "ex.ex_name AS exerciseName, " +
        "DATE_FORMAT(act.act_date, '%d-%m-%Y %H:%i:%s') AS activityDate, " +
        "act.kcal_expense AS kcalExpense " +
        "FROM activities act " +
        "JOIN exercises ex ON act.ex_id = ex.ex_id " +
        "WHERE act.act_id = ? ";
      const rows = await conn.query(sql, [activityId]);
      if (rows.length != 0) {
        response = {
          isError: false,
          data: rows,
          errorMessage: "",
        };
      } else {
        response = {
          isError: true,
          data: "",
          errorMessage: "data is not found",
        };
      }
    } catch (error) {
      response = {
        isError: true,
        data: "",
        errorMessage: error.message,
      };
    } finally {
      if (conn) {
        conn.release();
      }
      return response;
    }
  },

  updateActivity: async (activityId, activityDate, kcalExpense) => {
    var conn;
    var response;

    try {
      conn = await pool.getConnection();

      const sql =
        "UPDATE activities SET " +
        "act_date = STR_TO_DATE(?, '%d-%m-%Y %H:%i:%s'), " +
        "kcal_expense = ? " +
        "WHERE act_id = ?";

      await conn.query(sql, [activityDate, kcalExpense, activityId]);

      response = {
        isError: false,
        data: "Update complete",
        errorMessage: "",
      };
    } catch (error) {
      response = {
        isError: true,
        data: "",
        errorMessage: error.message,
      };
    } finally {
      if (conn) {
        conn.release();
      }
      return response;
    }
  },

  deleteactivity: async (activityId) => {
    var conn;
    var response;

    try {
      conn = await pool.getConnection();
      const sql = "DELETE FROM activities WHERE act_id = ?";
      await conn.query(sql, [activityId]);

      response = {
        isError: false,
        data: "delete complete",
        errorMessage: "",
      };
    } catch (error) {
      response = {
        isError: true,
        data: "",
        errorMessage: error.message,
      };
    } finally {
      if (conn) {
        conn.release();
      }
      return response;
    }
  },

  getSumKCalByExercise: async (account_id) => {
    let conn;
    let resposne;

    try {
      conn = await pool.getConnection();
      const sql =
        "SELECT " +
        "b.ex_id, " +
        "b.ex_name, " +
        "SUM(a.kcal_expense) AS sum_kcal " +
        "FROM " +
        "activities a " +
        "JOIN exercises b ON a.ex_id = b.ex_id " +
        "WHERE " +
        "a.account_id = ? " +
        "GROUP BY b.ex_id";
      const result = await conn.query(sql, [account_id]);

      resposne = {
        isError: false,
        data: result,
        errorMessage: '',
      };
    } catch (error) {
      resposne = {
        isError: true,
        data: "",
        errorMessage: error.message,
      };
    } finally {
      if (conn) {
        conn.release();
      }
      return resposne;
    }
  },
};
