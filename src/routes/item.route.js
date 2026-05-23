const { Router } = require("express");
const { authenticate, authorize } = require("../middlewares/auth.middleware");
const { getAllItems, getItemById, createItem, updateItem, deleteItem } = require("../controllers/item.controller");

const router = Router();

router.get("/", getAllItems);
router.get("/:itemId", getItemById);
router.post("/", authenticate, authorize(["ADMIN"]), createItem);
router.put("/:itemId", authenticate, authorize(["ADMIN"]), updateItem);
router.delete("/:itemId", authenticate, authorize(["ADMIN"]), deleteItem);
module.exports = router;
