# WooCommerce Flutter App

A modern Flutter mobile application that integrates with WooCommerce to provide a seamless shopping experience.

## Features

- Browse products by category
- View product details including images, descriptions, and prices
- Search functionality
- Responsive UI with loading animations
- Product carousels and grid views
- Category navigation

## Technical Details

- Built with Flutter
- Connects to WooCommerce REST API
- Uses Provider for state management
- Implements modern UI patterns with custom widgets

## Getting Started

### Prerequisites

- Flutter SDK (2.17.0 or higher)
- Dart SDK (2.17.0 or higher)
- A WooCommerce store with REST API enabled

### Installation

1. Clone the repository
   ```
   git clone https://github.com/Catskill909/woocommerce-store.git
   ```

2. Navigate to the project directory
   ```
   cd woocommerce-store/woocommerce_app
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
