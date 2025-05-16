# WooCommerce Flutter App

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![WooCommerce](https://img.shields.io/badge/WooCommerce-96588A?style=for-the-badge&logo=WooCommerce&logoColor=white)](https://woocommerce.com/)

A modern, high-performance Flutter mobile application that integrates seamlessly with WooCommerce to deliver a premium shopping experience.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- WooCommerce store with JWT Authentication plugin installed

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/woocommerce_flutter_app.git
   cd woocommerce_flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   - Copy `.env.example` to `.env`
   - Update the following variables in `.env`:
     ```
     WOOCOMMERCE_CONSUMER_KEY=your_consumer_key
     WOOCOMMERCE_CONSUMER_SECRET=your_consumer_secret
     WOOCOMMERCE_SITE_URL=https://your-woocommerce-site.com
     JWT_SECRET=your_jwt_secret
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔐 Authentication

The app uses JWT (JSON Web Tokens) for secure authentication with your WooCommerce store. Make sure to:

1. Install and activate the [JWT Authentication for WP REST API](https://wordpress.org/plugins/jwt-authentication-for-wp-rest-api/) plugin on your WordPress site.
2. Configure the JWT secret in your WordPress configuration.
3. Set the same JWT secret in your `.env` file.

### Features
- Secure JWT-based authentication
- User registration and login
- Persistent login sessions
- Password reset functionality

## ✨ Features

### Current Features
- 🏠 **Home Screen**
  - Featured products carousel
  - Category grid view
  - New arrivals section
  - Promotional banners

- 🛍️ **Product Browsing**
  - Product grid and list views
  - Category-based filtering
  - Product search functionality
  - Product details with image gallery

- 🎨 **UI/UX**
  - Responsive design for all screen sizes
  - Smooth animations and transitions
  - Loading states with shimmer effects
  - Dark/light theme support

### Coming Soon
- 🔐 User authentication
- 🛒 Shopping cart
- 💳 Checkout process
- 📦 Order tracking
- 📊 Wishlists

## 🛠️ Technical Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Networking**: http package
- **Local Storage**: SharedPreferences
- **Image Caching**: cached_network_image
- **UI Components**:
  - flutter_staggered_grid_view
  - flutter_carousel_widget
  - shimmer
  - badges

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- WooCommerce store with REST API enabled
- Android Studio / Xcode (for building to device)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Catskill909/woocommerce-store.git
   cd woocommerce-store/woocommerce_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   - Copy `.env.example` to `.env`
   - Update the WooCommerce API credentials

4. **Run the app**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
lib/
├── main.dart              # App entry point
├── config/               # Configuration files
├── models/               # Data models
├── providers/            # State management
├── screens/              # App screens
├── services/             # API and business logic
├── theme/                # App theming
└── widgets/              # Reusable widgets
```

## 🔄 Development Workflow

1. Create a new feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and test thoroughly

3. Run the linter:
   ```bash
   flutter analyze
   ```

4. Format your code:
   ```bash
   flutter format .
   ```

5. Commit your changes with a descriptive message

6. Push your branch and create a pull request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) to get started.

## 📞 Support

For support, please open an issue in the repository or contact the maintainers.
   ```

3. Install dependencies
   ```
   flutter pub get
   ```

4. Run the app
   ```
   flutter run
   ```

## Configuration

To connect to your own WooCommerce store, update the API credentials in `lib/services/api_service.dart`:

```dart
final String baseUrl = 'https://your-store-url.com/wp-json/wc/v3';
final String consumerKey = 'your_consumer_key';
final String consumerSecret = 'your_consumer_secret';
```

## Screenshots

[Add screenshots of your app here]

## License

This project is licensed under the MIT License - see the LICENSE file for details.
