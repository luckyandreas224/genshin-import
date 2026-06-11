
CREATE DATABASE IF NOT EXISTS genshin_import;
USE genshin_import;

CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(100) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NULL,
  role ENUM('ADMIN', 'USER') NOT NULL DEFAULT 'USER',
  currency DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  type ENUM('WEAPON', 'ARTIFACT') NOT NULL,
  description TEXT,
  stock INT NOT NULL DEFAULT 0,
  price DECIMAL(10, 2) NOT NULL,
  image VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE user_items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  item_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  UNIQUE KEY unique_user_item (user_id, item_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
);

INSERT INTO users (username, email, password, role, currency) VALUES
('admin', 'admin@gi.com', '$2a$10$qmlt/pD.S5vraxYrW828tOaoOSpxmmIyWOqzbg9KJFnn4dZjc21mq', 'ADMIN', 9999.00);

INSERT INTO users (username, email, password, role, currency) VALUES
('traveler', 'traveler@gi.com', '$2b$10$4UY8TIkExG5WdKPzGl3mMuwr.K2twuoM62R8o/k7RXECEodlEUJrq', 'USER', 9999.00);
