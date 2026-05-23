const { Router } = require("express");
const { getAllItems, getItemById } = require("../controllers/item.controller");

const router = Router();

router.get("/", getAllItems);
router.get("/:itemId", getItemById);

module.exports = router;
