const { Router } = require("express");
const { getAllItems } = require("../controllers/item.controller");

const router = Router();

router.get("/", getAllItems);

module.exports = router;
