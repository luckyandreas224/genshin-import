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



module.exports = {
  getAllItems,
};