const db = require("../config/db.config");

const getMe = async (req, res) => {
  const userId = req.user.id;

  try {
    const [rows] = await db.query("SELECT id, username, email FROM users WHERE id = ?", [userId]);

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    const [userItems] = await db.query(
      `SELECT
        i.id, i.name, i.type, i.image, i.price, ui.quantity
       FROM user_items ui
       JOIN items i ON i.id = ui.item_id
       WHERE ui.user_id = ?`,
      [userId],
    );

    const [loadout] = await db.query(
      `SELECT
        SUM(CASE WHEN i.type = 'weapon' THEN ui.quantity ELSE 0 END) AS total_weapons,
        SUM(CASE WHEN i.type = 'artifact' THEN ui.quantity ELSE 0 END) AS total_artifacts
       FROM user_items ui
       JOIN items i ON i.id = ui.item_id
       WHERE ui.user_id = ?`,
      [userId],
    );

    return res.status(200).json({
      success: true,
      data: {
        ...rows[0],
        totalWeapons: parseInt(loadout[0].total_weapons) || 0,
        totalArtifacts: parseInt(loadout[0].total_artifacts) || 0,
        items: userItems,
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
};

module.exports = { getMe };
