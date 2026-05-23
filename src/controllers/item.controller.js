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

const createItem = async (req, res) => {
  try {
    const { name, type, description, stock, price, image } = req.body;

    if (!name || !type || stock === undefined || !price) {
      return res.status(400).json({
        success: false,
        message: "Fields 'name', 'type', 'stock', and 'price' are required",
      });
    }

    const normalizedType = type.toLowerCase();
    if (!["weapon", "artifact"].includes(normalizedType)) {
      return res.status(400).json({
        success: false,
        message: "Field 'type' must be 'weapon' or 'artifact'",
      });
    }

    if (stock < 0) {
      return res.status(400).json({
        success: false,
        message: "Field 'stock' must be >= 0",
      });
    }

    if (price <= 0) {
      return res.status(400).json({
        success: false,
        message: "Field 'price' must be > 0",
      });
    }

    const [result] = await db.query(
      "INSERT INTO items (name, type, description, stock, price, image) VALUES (?, ?, ?, ?, ?, ?)",
      [name, normalizedType, description || null, stock, price, image || null]
    );

    const [newItem] = await db.query("SELECT * FROM items WHERE id = ?", [
      result.insertId,
    ]);

    return res.status(201).json({
      success: true,
      data: {
        ...newItem[0],
        type: newItem[0].type.toUpperCase(),
      },
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
  createItem,
};