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
const { uploadSingle } = require("../middlewares/upload.middleware");

const router = Router();

router.get("/", getAllItems);
router.get("/:itemId", getItemById);
router.post("/:itemId/buy", authenticate, authorize("user"), buyItem);
router.post("/", authenticate, authorize("admin"), uploadSingle("image"), createItem);
router.put("/:itemId", authenticate, authorize("admin"), uploadSingle("image"), updateItem);
router.delete("/:itemId", authenticate, authorize("admin"), deleteItem);


module.exports = router;
