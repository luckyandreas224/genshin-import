const { Router } = require("express");
const { authenticate } = require("../middlewares/auth.middleware");
const { register, login, googleLogin } = require("../controllers/auth.controller");

const router = Router();

router.post("/register", register);
router.post("/login", login);
router.post("/google", googleLogin);

module.exports = router;
