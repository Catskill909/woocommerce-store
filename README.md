# WooCommerce Mobile App

A modern, feature-rich Flutter mobile application for WooCommerce stores. This app connects to the WooCommerce REST API to provide a seamless shopping experience on mobile devices.

## Features

### Implemented Features
- **Beautiful UI**: Modern, clean interface with smooth animations and transitions
- **Product Browsing**: Browse products with high-quality images and details
- **Product Categories**: View products organized by categories
- **Product Details**: Detailed product pages with images, descriptions, and pricing
- **Search Functionality**: Search for products across the store
- **Responsive Design**: Works on various screen sizes and orientations

### Planned Features
- User Authentication (Login/Register)
- Shopping Cart functionality
- Checkout process
- Order history and tracking
- Wishlist management
- Push notifications for order updates
- Product reviews and ratings
- Multi-language support
- Theme customization

## Architecture

The app follows a clean architecture approach with separation of concerns:

- **Models**: Data models representing WooCommerce entities (Product, Category, etc.)
- **Services**: API services for communicating with the WooCommerce REST API
- **Screens**: UI screens for different parts of the application
- **Widgets**: Reusable UI components used across multiple screens

## Dependencies

- **http**: For API requests to the WooCommerce REST API
- **provider**: For state management
- **flutter_carousel_widget**: For image carousels and sliders
- **cached_network_image**: For efficient image loading and caching
- **shimmer**: For loading animations
- **flutter_rating_bar**: For product ratings display
- **badges**: For notification badges (e.g., cart items count)

## Setup and Configuration

### Prerequisites
- Flutter SDK (2.17.0 or higher)
- WooCommerce store with REST API enabled
- WooCommerce API keys (Consumer Key and Consumer Secret)

### Configuration
1. Update the API credentials in `lib/services/api_service.dart`:
   ```dart
   final String consumerKey = 'your_consumer_key';
   final String consumerSecret = 'your_consumer_secret';
   ```
2. Update the base URL to point to your WooCommerce store:
   ```dart
   final String baseUrl = 'https://your-store-url.com/wp-json/wc/v3';
   ```

## Development Roadmap

### Phase 1 (Current)
- Basic product browsing and viewing
- Category navigation
- Product search

### Phase 2
- User authentication
- Shopping cart functionality
- Basic checkout process

### Phase 3
- Order history and management
- User profile management
- Wishlist functionality

### Phase 4
- Push notifications
- Advanced filters and sorting
- Performance optimizations
- Analytics integration

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
