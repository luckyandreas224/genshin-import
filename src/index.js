require("dotenv").config();

const express = require("express");
const cors = require("cors");
const authRoutes = require("./routes/auth.route");
const itemRoutes = require("./routes/item.route");
const userRoutes = require("./routes/user.route");

const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/items", itemRoutes);
app.use("/api/users", userRoutes);

app.listen(process.env.PORT, () => {
  console.log(`Server is running on port ${process.env.PORT}`);
});
