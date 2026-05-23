const db = require("../config/db.config");

const getAllItems = async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT id, name, type, description, stock, price, image, created_at, updated_at FROM items"
    );

    return res.status(200).json({
      success: true,
      data: rows,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

const getItemById = async (req, res) => {
  try {
    const { itemId } = req.params;

    const [rows] = await db.query(
      "SELECT id, name, type, description, stock, price, image, created_at, updated_at FROM items WHERE id = ?",
      [itemId]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Item not found",
      });
    }

    const item = {
      ...rows[0],
      type: rows[0].type.toUpperCase(),
    };

    return res.status(200).json({
      success: true,
      data: item,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};


module.exports = {
  getAllItems,
  getItemById,
};