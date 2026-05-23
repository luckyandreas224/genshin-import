const { Router } = require("express");
const { authenticate, authorize } = require("../middlewares/auth.middleware");
const { getAllItems, getItemById, createItem, updateItem } = require("../controllers/item.controller");

const router = Router();

router.get("/", getAllItems);
router.get("/:itemId", getItemById);
router.post("/", authenticate, authorize(["ADMIN"]), createItem);
router.put("/:itemId", authenticate, authorize(["ADMIN"]), updateItem);

module.exports = router;
