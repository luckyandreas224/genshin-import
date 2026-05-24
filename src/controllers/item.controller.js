const db = require("../config/db.config");

const getAllItems = async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT id, name, type, description, stock, price, image, created_at, updated_at FROM items",
    );

    return res.status(200).json({
      success: true,
      message: "Items retrieved successfully",
      data: rows,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
};

const getItemById = async (req, res) => {
  const { itemId } = req.params;

  try {
    const [rows] = await db.query(
      "SELECT id, name, type, description, stock, price, image, created_at, updated_at FROM items WHERE id = ?",
      [itemId],
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: "Item not found" });
    }

    return res.status(200).json({
      success: true,
      message: "Item retrieved successfully",
      data: { ...rows[0], type: rows[0].type.toUpperCase() },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
};

const createItem = async (req, res) => {
  const { name, type, description, stock, price } = req.body;
  const image = req.file ? `/uploads/${req.file.filename}` : null;

  if (!name || !type || !stock || !price) {
    return res.status(400).json({ success: false, message: "Name, type, stock, and price required" });
  }

  const normalizedType = type.toLowerCase();
  if (!["weapon", "artifact"].includes(normalizedType)) {
    return res.status(400).json({ success: false, message: "Type must be 'weapon' or 'artifact'" });
  }

  if (stock < 1) {
    return res.status(400).json({ success: false, message: "Stock must be at least 1" });
  }

  if (price < 1) {
    return res.status(400).json({ success: false, message: "Price must be at least 1" });
  }

  try {
    const [result] = await db.query(
      "INSERT INTO items (name, type, description, stock, price, image) VALUES (?, ?, ?, ?, ?, ?)",
      [name, normalizedType, description || null, stock, price, image || null],
    );
    const [newItem] = await db.query("SELECT * FROM items WHERE id = ?", [result.insertId]);

    return res.status(201).json({
      success: true,
      message: "Item created successfully",
      data: { ...newItem[0], type: newItem[0].type.toUpperCase() },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
};

const updateItem = async (req, res) => {
  const { itemId } = req.params;
  const { name, type, description, stock, price } = req.body;
  const image = req.file ? `/uploads/${req.file.filename}` : undefined;

  if (type && !["weapon", "artifact"].includes(type.toLowerCase())) {
    return res.status(400).json({ success: false, message: "Type must be 'weapon' or 'artifact'" });
  }

  if (stock && stock < 1) {
    return res.status(400).json({ success: false, message: "Stock must be at least 1" });
  }

  if (price && price < 1) {
    return res.status(400).json({ success: false, message: "Price must be at least 1" });
  }

  try {
    const [existing] = await db.query("SELECT * FROM items WHERE id = ?", [itemId]);
    if (existing.length === 0) {
      return res.status(404).json({ success: false, message: "Item not found" });
    }

    const updatedFields = {
      name: name ?? existing[0].name,
      type: type ? type.toLowerCase() : existing[0].type,
      description: description !== undefined ? description : existing[0].description,
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
      ],
    );

    const [updated] = await db.query("SELECT * FROM items WHERE id = ?", [itemId]);

    return res.status(200).json({
      success: true,
      message: "Item updated successfully",
      data: { ...updated[0], type: updated[0].type.toUpperCase() },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
};

const deleteItem = async (req, res) => {
  const { itemId } = req.params;

  try {
    const [existing] = await db.query("SELECT * FROM items WHERE id = ?", [itemId]);
    if (existing.length === 0) {
      return res.status(404).json({ success: false, message: "Item not found" });
    }

    await db.query("DELETE FROM items WHERE id = ?", [itemId]);

    return res.status(200).json({
      success: true,
      message: "Item deleted successfully",
      data: { ...existing[0], type: existing[0].type.toUpperCase() },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
};

const buyItem = async (req, res) => {
  const { itemId } = req.params;
  const userId = req.user.id;
  const quantity = parseInt(req.body.quantity);

  if (!quantity || quantity < 1) {
    return res.status(400).json({ success: false, message: "Quantity must be at least 1" });
  }

  const connection = await db.getConnection();

  try {
    await connection.beginTransaction();

    const [items] = await connection.query("SELECT * FROM items WHERE id = ? FOR UPDATE", [itemId]);
    if (items.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: "Item not found" });
    }

    const item = items[0];
    const totalCost = item.price * quantity;

    if (item.stock < quantity) {
      await connection.rollback();
      return res.status(400).json({ success: false, message: `Item insufficient stock` });
    }

    const [userRows] = await connection.query("SELECT currency FROM users WHERE id = ? FOR UPDATE", [userId]);

    if (userRows[0].currency < totalCost) {
      await connection.rollback();
      return res.status(400).json({ success: false, message: `User insufficient currency` });
    }

    await connection.query("UPDATE items SET stock = stock - ? WHERE id = ?", [quantity, itemId]);
    await connection.query("UPDATE users SET currency = currency - ? WHERE id = ?", [totalCost, userId]);
    await connection.query(
      `INSERT INTO user_items (user_id, item_id, quantity)
       VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity)`,
      [userId, itemId, quantity],
    );

    await connection.commit();

    const [updatedItem] = await connection.query("SELECT id, name, type, stock, price FROM items WHERE id = ?", [itemId]);
    const [userItem] = await connection.query("SELECT quantity FROM user_items WHERE user_id = ? AND item_id = ?", [
      userId,
      itemId,
    ]);

    return res.status(200).json({
      success: true,
      message: "Item purchased successfully",
      data: {
        item: { ...updatedItem[0], type: updatedItem[0].type.toUpperCase() },
        purchased_quantity: quantity,
        total_owned: userItem[0].quantity,
        remaining_currency: userRows[0].currency - totalCost,
      },
    });
  } catch (error) {
    await connection.rollback();
    return res.status(500).json({ success: false, message: "Internal server error" });
  } finally {
    connection.release();
  }
};

module.exports = {
  getAllItems,
  getItemById,
  createItem,
  updateItem,
  deleteItem,
  buyItem,
};
