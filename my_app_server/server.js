const http = require("http");
const express = require("express");
const bp = require("body-parser");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

const hostname = "127.0.0.1";
const port = 3000;

const app = express();
const dateUtils = require("./libs/data_utils");
const jwt = require("./libs/jwt.js");
const appConfig = require("./config/appConfig.js");

// const model
const userAccountModel = require("./models/user_account");
const exerciseModel = require("./models/exercise.js");
const activitiesModel = require("./models/activities.js");

const cors = require("cors");
const { authMiddleware } = require("./middleware/auth_middleware.js");
const activities = require("./models/activities.js");

app.use(bp.urlencoded({ extended: true }));
app.use(bp.json());

app.use(cors());

app.get("/", (req, res) => {
  var response = {
    data: "hello",
  };
  res.send(JSON.stringify(response));
});
app.get("/api/users", (req, res) => {
  var response = {
    isError: true,
    errotMessege: "You are not log in for this data",
  };

  res.send(JSON.stringify(response));
});

app.post("/api/multiple_by_2", (req, res) => {
  var response = {
    isError: false,
    data: {
      no_1: req.body.no_1 * 2,
      no_2: req.body.no_2 * 2,
    },
  };

  res.send(JSON.stringify(response));
});

app.post("/api/authen/authen_request", async (req, res) => {
  const authenRequest = req.body.authenRequest;
  const result = await userAccountModel.checkAuthenRequest(authenRequest);

  if (result.isError) {
    response = {
      isError: true,
      authenToken: null,
      errorMessage: result.errorMessage,
    };
    res.status(401).json(response);
  } else {
    var payload = { username: result.data[0].account_username };
    const authenToken = jwt.sign(payload);
    response = {
      isError: false,
      authenToken: authenToken,
      errorMessage: "",
    };

    res.status(200).json(response);
  }
});

app.post("/api/authen/access_request", async (req, res) => {
  const authenSignature = req.body.authenSignature;
  const authenToken = req.body.authenToken;

  var decoded = jwt.verify(authenToken);

  let response;

  if (decoded) {
    const result = await userAccountModel.checkAccessRequest(
      authenSignature,
      authenToken,
    );

    if (result.isError) {
      response = {
        isError: true,
        accessToken: "",
        imageUrl: "",
        errorMessage: result.errorMessage,
      };
      res.status(200).json(response);
    } else {
      var payload = {
        user_id: result.data[0].account_id,
        username: result.data[0].account_username,
        image_url: result.data[0].account_image_url,
        date: dateUtils.getCurrentDateForToken(),
      };

      const accessToken = jwt.sign(payload);
      response = {
        isError: false,
        accessToken: accessToken,
        imageUrl: result.data[0].account_image_url,
        errorMessage: "",
      };

      res.status(200).json(response);
    }
  } else {
    response = {
      isError: true,
      accessToken: "",
      imageUrl: "",
      errorMessage: "ข้อมูลไม่ถูกต้อง",
    };

    res.status(200).json(response);
  }
});
const uploadDir = path.join(__dirname, "uploads");
fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname);
    cb(null, uniqueSuffix + "-" + req.user.username + ext);
  },
});

const upload = multer({ storage: storage });
app.use("/api/exercise/getAll", authMiddleware, async (req, res) => {
  const response = await exerciseModel.getAllExercise();
  console.log(response);
  res.send(response);
});

app.use(
  `${appConfig.baseURL}/activity/getActivityByUserId`,
  authMiddleware,
  async (req, res) => {
    console.log(req.user);

    const userId = req.user.user_id;
    const result = await activitiesModel.getActivityByUserId(userId);
    // if (result.isError) {
    //   console.log(result.errorMessage);
    // } else {
    //   console.log("is work result : ", result);
    // }
    res.json(result);
  },
);

app.use(
  `${appConfig.baseURL}/activity/get_by_exerciseId/:exerciseId`,
  authMiddleware,
  async (req, res) => {
    const accountId = req.user.user_id;
    const exerciseId = req.params.exerciseId;
    const response = await activities.getActivityByExerciseId(
      accountId,
      exerciseId,
    );
    res.json(response);
  },
);

app.use("/profile_images", express.static(uploadDir));

app.post(
  `${appConfig.baseURL}/activity/create`,
  authMiddleware,
  async (req, res) => {
    const accountId = req.user.user_id;
    const exerciseId = req.body.exercise_id;
    const activityDate = req.body.activity_date;
    const kcalExpense = req.body.kcal_expense;

    const response = await activities.createActivity(
      accountId,
      exerciseId,
      activityDate,
      kcalExpense,
    );
    res.json(response);
  },
);

app.get(
  `${appConfig.baseURL}/activity/sum_kcal_by_exercise`,
  authMiddleware,
  async (req, res) => {
    const userId = req.user.user_id;
    const response = await activities.getSumKCalByExercise(userId);
    // console.log(response)
    res.json(response);
  },
);
  
app.get(
  `${appConfig.baseURL}/activity/:id`,
  authMiddleware,
  async (req, res) => {
    const activityId = req.params.id;
    const response = await activities.getActivityByid(activityId);
    res.json(response);
  },
);

app.post(
  `${appConfig.baseURL}/activity/update`,
  authMiddleware,
  async (req, res) => {
    const activityDate = req.body.activity_date;
    const activityId = req.body.activity_id;
    const kcalExpense = req.body.kcal_expense;

    const response = await activities.updateActivity(
      activityId,
      activityDate,
      kcalExpense,
    );
    console.log(response);
    res.json(response);
  },
);

app.post(
  `${appConfig.baseURL}/activity/delete`,
  authMiddleware,
  async (req, res) => {
    const activityId = req.body.activity_id;
    const response = await activities.deleteactivity(activityId);
    // console.log(response)
    res.json(response);
  },
);

app.post(
  "/api/upload",
  authMiddleware,
  upload.single("file"),
  async (req, res) => {
    const response = await userAccountModel.updateProfileName(
      req.user.user_id,
      req.file.filename,
    );
    res.json(response);
  },
);

app.listen(port, () => {
  console.log(`server is listen at http://${hostname}:${port}`);
});
