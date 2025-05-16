=== Woo JWT Auth ===
Contributors: yourname
Donate link: 
Tags: jwt, authentication, api, rest, woocommerce, mobile
Requires at least: 5.0
Tested up to: 6.0
Stable tag: 1.0.0
License: GPLv2 or later
License URI: http://www.gnu.org/licenses/gpl-2.0.html

A simple and secure JWT authentication solution for WooCommerce mobile apps.

== Description ==

Woo JWT Auth provides a simple way to authenticate users with your WooCommerce store using JSON Web Tokens (JWT). It's designed specifically for mobile apps and provides a secure way to handle user authentication.

== Features ==

* Secure JWT token generation and validation
* User authentication via username/password
* Token validation endpoint
* Admin interface to manage JWT secret key
* Easy integration with mobile apps

== Installation ==

1. Upload the `woo-jwt-auth` folder to the `/wp-content/plugins/` directory
2. Activate the plugin through the 'Plugins' menu in WordPress
3. Go to Woo JWT Auth in the admin menu to view your JWT secret key
4. Add the JWT secret key to your app's configuration

== Frequently Asked Questions ==

= How do I get started? =

1. Install and activate the plugin
2. Go to Woo JWT Auth in the admin menu
3. Copy the JWT secret key
4. Use the provided API endpoints in your mobile app

= How do I use the API? =

**Login Endpoint**
`POST /wp-json/woo-jwt-auth/v1/login`

Parameters:
- `username`: The user's username
- `password`: The user's password

**Validate Token Endpoint**
`GET /wp-json/woo-jwt-auth/v1/validate`

Headers:
- `Authorization: Bearer YOUR_JWT_TOKEN`

== Changelog ==

= 1.0.0 =
* Initial release

== Upgrade Notice ==

= 1.0.0 =
Initial release
