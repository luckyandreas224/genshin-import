const { Router } = require("express");
const { getAllItems, getItemById, createItem } = require("../controllers/item.controller");

const router = Router();

router.get("/", getAllItems);
router.get("/:itemId", getItemById);
router.post("/", createItem);

module.exports = router;
