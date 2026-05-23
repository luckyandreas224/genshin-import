const { Router } = require("express");
const { authenticate, authorize } = require("../middlewares/auth.middleware");
const { getAllItems, getItemById, createItem, updateItem, deleteItem, buyItem } = require("../controllers/item.controller");

const router = Router();

router.get("/", getAllItems);
router.get("/:itemId", getItemById);
router.post("/", authenticate, authorize("admin"), createItem);
router.put("/:itemId", authenticate, authorize("admin"), updateItem);
router.delete("/:itemId", authenticate, authorize("admin"), deleteItem);
router.post("/:itemId/buy", authenticate, authorize("user"), buyItem);
module.exports = router;
