# Woo JWT Manager

A WordPress plugin to manage JWT authentication for your WooCommerce mobile app. This plugin provides a simple interface to generate, view, and regenerate JWT secret keys for your mobile app authentication.

## Features

- Generate a secure JWT secret key
- View the current JWT secret key
- Regenerate the JWT secret key when needed
- Copy the JWT secret key to clipboard with one click
- View app configuration instructions

## Installation

1. Download the `woo-jwt-manager` folder
2. Upload it to your WordPress plugins directory (`/wp-content/plugins/`)
3. Activate the plugin through the 'Plugins' menu in WordPress
4. Go to Settings > Woo JWT to view your JWT secret key

## Usage

1. After activating the plugin, navigate to **Settings > Woo JWT**
2. You'll see your current JWT secret key
3. Use the "Copy to Clipboard" button to copy the key
4. Add the key to your app's `.env` file:
   ```
   JWT_SECRET=your_jwt_secret_here
   ```
5. If you suspect your key has been compromised, click "Regenerate Secret Key"

## Security

- The JWT secret key is stored securely in the WordPress options table
- Only administrators can view or regenerate the key
- The key is never displayed in plain text in the database
- Always use HTTPS for your WordPress site to ensure secure transmission of the key

## Requirements

- WordPress 5.0 or higher
- PHP 7.4 or higher
- WooCommerce (recommended)

## Support

For support, please open an issue in the GitHub repository.

## License

GPL v2 or later

## Changelog

### 1.0.0
* Initial release
