const db = require("../config/db.config");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");

const register = async (req, res) => {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    return res.status(400).json({ success: false, message: "Username, email, and password required" });
  }

  try {
    const [existing] = await db.query("SELECT id FROM users WHERE email = ? OR username = ?", [email, username]);
    if (existing.length > 0) {
      return res.status(409).json({ success: false, message: "Email or username already taken" });
    }

    const hashed = await bcrypt.hash(password, 10);
    const [result] = await db.query("INSERT INTO users (username, email, password) VALUES (?, ?, ?)", [
      username,
      email,
      hashed,
    ]);

    return res.status(201).json({
      success: true,
      message: "User registered",
      data: { id: result.insertId, username, email, role: "USER" },
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
};

const login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ success: false, message: "Email and password required" });
  }

  try {
    const [rows] = await db.query("SELECT * FROM users WHERE email = ?", [email]);

    const user = rows[0];
    if (!user) {
      return res.status(401).json({ success: false, message: "Invalid credentials" });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ success: false, message: "Invalid credentials" });
    }

    // prettier-ignore
    const token = jwt.sign(
      { id: user.id, role: user.role, username: user.username },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    return res.status(200).json({ success: true, data: { token } });
  } catch (err) {
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
};

module.exports = { register, login };
