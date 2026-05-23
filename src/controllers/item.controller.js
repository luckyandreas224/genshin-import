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

const updateItem = async (req, res) => {
  try {
    const { itemId } = req.params;
    const { name, type, description, stock, price, image } = req.body;

    const [existing] = await db.query("SELECT * FROM items WHERE id = ?", [
      itemId,
    ]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Item not found",
      });
    }

    if (type !== undefined) {
      const normalizedType = type.toLowerCase();
      if (!["weapon", "artifact"].includes(normalizedType)) {
        return res.status(400).json({
          success: false,
          message: "Field 'type' must be 'weapon' or 'artifact'",
        });
      }
    }

    if (stock !== undefined && stock < 0) {
      return res.status(400).json({
        success: false,
        message: "Field 'stock' must be >= 0",
      });
    }

    if (price !== undefined && price <= 0) {
      return res.status(400).json({
        success: false,
        message: "Field 'price' must be > 0",
      });
    }

    const updatedFields = {
      name: name ?? existing[0].name,
      type: type ? type.toLowerCase() : existing[0].type,
      description:
        description !== undefined ? description : existing[0].description,
      stock: stock ?? existing[0].stock,
      price: price ?? existing[0].price,
      image: image !== undefined ? image : existing[0].image,
    };

    await db.query(
      "UPDATE items SET name = ?, type = ?, description = ?, stock = ?, price = ?, image = ? WHERE id = ?",
      [
        updatedFields.name,
        updatedFields.type,
        updatedFields.description,
        updatedFields.stock,
        updatedFields.price,
        updatedFields.image,
        itemId,
      ]
    );

    const [updated] = await db.query("SELECT * FROM items WHERE id = ?", [
      itemId,
    ]);

    return res.status(200).json({
      success: true,
      data: {
        ...updated[0],
        type: updated[0].type.toUpperCase(),
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

const deleteItem = async (req, res) => {
  try {
    const { itemId } = req.params;

    const [existing] = await db.query("SELECT * FROM items WHERE id = ?", [
      itemId,
    ]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Item not found",
      });
    }

    await db.query("DELETE FROM items WHERE id = ?", [itemId]);

    return res.status(200).json({
      success: true,
      data: {
        ...existing[0],
        type: existing[0].type.toUpperCase(),
      },
      message: "Item deleted successfully",
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

const buyItem = async (req, res) => {
  const connection = await db.getConnection();

  try {
    await connection.beginTransaction();

    const { itemId } = req.params;
    const userId = req.user.id;
    const quantity = parseInt(req.body.quantity) || 1;

    if (quantity <= 0) {
      await connection.rollback();
      connection.release();
      return res.status(400).json({
        success: false,
        message: "Field 'quantity' must be >= 1",
      });
    }

    const [items] = await connection.query(
      "SELECT * FROM items WHERE id = ? FOR UPDATE",
      [itemId]
    );

    if (items.length === 0) {
      await connection.rollback();
      connection.release();
      return res.status(404).json({
        success: false,
        message: "Item not found",
      });
    }

    const item = items[0];

    if (item.stock < quantity) {
      await connection.rollback();
      connection.release();
      return res.status(400).json({
        success: false,
        message: `Insufficient stock. Available: ${item.stock}, requested: ${quantity}`,
      });
    }

    await connection.query(
      "UPDATE items SET stock = stock - ? WHERE id = ?",
      [quantity, itemId]
    );

    await connection.query(
      `INSERT INTO user_items (user_id, item_id, quantity)
       VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity)`,
      [userId, itemId, quantity]
    );

    await connection.commit();
    connection.release();

    const [updatedItem] = await db.query(
      "SELECT id, name, type, stock, price FROM items WHERE id = ?",
      [itemId]
    );

    const [userItem] = await db.query(
      "SELECT quantity FROM user_items WHERE user_id = ? AND item_id = ?",
      [userId, itemId]
    );

    return res.status(200).json({
      success: true,
      data: {
        item: {
          ...updatedItem[0],
          type: updatedItem[0].type.toUpperCase(),
        },
        purchased_quantity: quantity,
        total_owned: userItem[0].quantity,
      },
    });
  } catch (error) {
    await connection.rollback();
    connection.release();
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
  updateItem,
  deleteItem,
  buyItem
};
