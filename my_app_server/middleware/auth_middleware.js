const jwt = require('../libs/jwt');


const authMiddleware = (req, res, next) =>{
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.split(' ')[1]; // "Beaere <token>"" -> ["Bearer", "<token>"]
    console.log('token na : ', token)
    if (!token) return res.status(401).json({ error: 'No token provided' });

    jwt.verify(token)
    .then((decoded) => {
        req.user = decoded;
        next();
    },(error)=>{
        res.json({
            isError: false,
            result: false,
            errorMessage: "ยังไม่เข่าสู่ระบบ"
        })
    })
}

module.exports = {
    authMiddleware
}