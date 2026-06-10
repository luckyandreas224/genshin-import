# Genshin Import Project Documentation

## 🖥️ Frontend (Flutter)

### 📄 Pages
- **Login Page** `login_page.dart`: Allows users to log in to their account.
- **Register Page** `register_page.dart`: Allows new users to create an account.
- **Market Page** `market_page.dart`: Displays a marketplace for items.
- **Profile Page** `profile_page.dart`: Shows user profile and details.
- **Item Detail Page** `item_detail.dart`: Shows detailed information about a specific item.
- **Shell Page** `shell_page.dart`: The main application shell/scaffold for navigation.
- **Splash Screen** `splash_screen.dart`: The initial loading screen of the app.
- **Admin Pages**: Includes `admin_loadout_page.dart`, `admin_profile_page.dart`, and `admin_shell_page.dart` under the `admin/` directory for administrative tasks.

### 🧩 Components (Widgets)
- **Custom Button** `custom_button.dart`: A reusable button component.
- **Custom Navigation Bar** `custom_navigation_bar.dart`: The bottom navigation bar.
- **Custom Search Bar** `custom_search_bar.dart`: A reusable search input component.
- **Custom Text Field** `custom_text_field.dart`: A reusable text input field.
- **Custom Toast** `custom_toast.dart`: For displaying toast notifications.
- **Item Card** `item_card.dart`: Displays an item's summary in a card layout.
- **Primogem Chip** `primogem_chip.dart`: A chip component displaying primogem currency.
- **Stat Card** `stat_card.dart`: A card component for displaying statistics.

---

## ⚙️ Backend (Node.js / Express)

### 🔌 Endpoints

#### Authentication (`/api/auth`)
- `POST /register`: Register a new user.
- `POST /login`: Log in an existing user.
- `POST /google`: Log in or register using Google OAuth.

#### Items (`/api/items`)
- `GET /`: Retrieve a list of all items.
- `GET /:itemId`: Retrieve details of a specific item.
- `POST /:itemId/buy`: Buy a specific item (Requires User authentication).
- `POST /`: Create a new item with an image (Requires Admin authentication).
- `PUT /:itemId`: Update an existing item with an image (Requires Admin authentication).
- `DELETE /:itemId`: Delete an item (Requires Admin authentication).

#### Users (`/api/users`)
- `GET /me`: Retrieve the currently authenticated user's profile.

---

## 🚀 How to Run

### Backend
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Ensure you have your `.env` file configured.
4. Start the development server:
   ```bash
   npm run dev
   ```

### Frontend
1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```
