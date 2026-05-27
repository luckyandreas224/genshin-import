const multer = require("multer");

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },
  filename: (req, file, cb) => {
    const normalizedName = `${Date.now()}-${file.originalname.replace(/\s+/g, "-")}`;
    cb(null, normalizedName);
  },
});

const upload = multer({ storage });

module.exports = { upload };
