const { Router } = require("express");
const { authenticate, authorize } = require("../middlewares/auth.middleware");
const {
  buyItem,
  createItem,
  deleteItem,
  getAllItems,
  getItemById,
  updateItem,
} = require("../controllers/item.controller");

const router = Router();

router.get("/", getAllItems);
router.get("/:itemId", getItemById);
router.post("/:itemId/buy", authenticate, authorize("user"), buyItem);
router.post("/", authenticate, authorize("admin"), createItem);
router.put("/:itemId", authenticate, authorize("admin"), updateItem);
router.delete("/:itemId", authenticate, authorize("admin"), deleteItem);

module.exports = router;
