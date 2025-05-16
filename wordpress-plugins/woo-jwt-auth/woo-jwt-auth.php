<?php
/**
 * Plugin Name: Woo JWT Auth
 * Description: Simple JWT Authentication for WooCommerce Mobile App
 * Version: 1.0.0
 * Author: Your Name
 * Text Domain: woo-jwt-auth
 */

// If this file is called directly, abort.
if (!defined('WPINC')) {
    die;
}

class Woo_JWT_Auth {
    private $jwt_secret_option = 'woo_jwt_auth_secret';
    private $jwt_expire = 24 * HOUR_IN_SECONDS; // 24 hours

    public function __construct() {
        // Generate secret key if not exists
        if (empty(get_option($this->jwt_secret_option))) {
            $this->generate_secret_key();
        }

        // Add REST API endpoints
        add_action('rest_api_init', array($this, 'register_routes'));
        
        // Add admin menu
        add_action('admin_menu', array($this, 'add_admin_menu'));
        
        // Handle AJAX requests
        add_action('wp_ajax_regenerate_jwt_secret', array($this, 'ajax_regenerate_secret'));
    }

    // Generate a secure random secret key
    private function generate_secret_key() {
        $key = bin2hex(openssl_random_pseudo_bytes(64));
        update_option($this->jwt_secret_option, $key);
        return $key;
    }

    // Get the current secret key
    public function get_secret_key() {
        return get_option($this->jwt_secret_option);
    }

    // Register REST API routes
    public function register_routes() {
        // Login endpoint
        register_rest_route('woo-jwt-auth/v1', '/login', array(
            'methods' => 'POST',
            'callback' => array($this, 'handle_login'),
            'permission_callback' => '__return_true',
        ));

        // Validate token endpoint
        register_rest_route('woo-jwt-auth/v1', '/validate', array(
            'methods' => 'GET',
            'callback' => array($this, 'validate_token'),
            'permission_callback' => '__return_true',
        ));
    }

    // Handle login request
    public function handle_login($request) {
        $username = $request->get_param('username');
        $password = $request->get_param('password');

        // Validate credentials
        $user = wp_authenticate($username, $password);

        if (is_wp_error($user)) {
            return new WP_REST_Response(
                array('success' => false, 'message' => 'Invalid credentials'),
                401
            );
        }

        // Generate JWT token
        $token = $this->generate_jwt_token($user->ID);

        return array(
            'success' => true,
            'token' => $token,
            'user' => array(
                'id' => $user->ID,
                'email' => $user->user_email,
                'display_name' => $user->display_name,
                'roles' => $user->roles,
            )
        );
    }

    // Generate JWT token
    private function generate_jwt_token($user_id) {
        $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
        $payload = json_encode([
            'user_id' => $user_id,
            'exp' => time() + $this->jwt_expire
        ]);

        $base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
        $base64UrlPayload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));
        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, $this->get_secret_key(), true);
        $base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

        return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
    }

    // Validate JWT token
    public function validate_token($request) {
        $auth_header = $request->get_header('authorization');
        
        if (empty($auth_header)) {
            return new WP_Error('no_auth_header', 'Authorization header missing', array('status' => 401));
        }

        $token = str_replace('Bearer ', '', $auth_header);
        
        // Verify token format
        $token_parts = explode('.', $token);
        if (count($token_parts) !== 3) {
            return new WP_Error('invalid_token', 'Invalid token format', array('status' => 401));
        }

        // Verify signature
        $signature = hash_hmac('sha256', $token_parts[0] . "." . $token_parts[1], $this->get_secret_key(), true);
        $base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));
        
        if ($base64UrlSignature !== $token_parts[2]) {
            return new WP_Error('invalid_signature', 'Invalid token signature', array('status' => 401));
        }

        // Verify expiration
        $payload = json_decode(base64_decode($token_parts[1]));
        if (time() > $payload->exp) {
            return new WP_Error('token_expired', 'Token has expired', array('status' => 401));
        }

        // Get user data
        $user = get_user_by('id', $payload->user_id);
        if (!$user) {
            return new WP_Error('user_not_found', 'User not found', array('status' => 404));
        }

        return array(
            'success' => true,
            'user' => array(
                'id' => $user->ID,
                'email' => $user->user_email,
                'display_name' => $user->display_name,
                'roles' => $user->roles,
            )
        );
    }

    // Add admin menu
    public function add_admin_menu() {
        add_menu_page(
            'Woo JWT Auth',
            'Woo JWT Auth',
            'manage_options',
            'woo-jwt-auth',
            array($this, 'render_admin_page'),
            'dashicons-lock',
            30
        );
    }

    // Render admin page
    public function render_admin_page() {
        $secret_key = $this->get_secret_key();
        $site_url = site_url();
        
        ?>
        <div class="wrap">
            <h1>Woo JWT Auth Settings</h1>
            
            <div class="card">
                <h2>JWT Secret Key</h2>
                <p>This key is used to sign and verify JWT tokens for your mobile app.</p>
                
                <div style="margin: 20px 0;">
                    <input type="text" id="jwt-secret" value="<?php echo esc_attr($secret_key); ?>" readonly 
                           style="width: 100%; max-width: 600px; padding: 8px; font-family: monospace;">
                    <p>
                        <button id="copy-secret" class="button button-primary">Copy to Clipboard</button>
                        <button id="regenerate-secret" class="button button-secondary">Regenerate Key</button>
                        <span id="copy-success" style="margin-left: 10px; color: green; display: none;">Copied!</span>
                    </p>
                </div>
                
                <div class="notice notice-info">
                    <p>Add this to your Flutter app's <code>.env</code> file:</p>
                    <pre>JWT_SECRET=<?php echo esc_html($secret_key); ?>
JWT_BASE_URL=<?php echo esc_url($site_url); ?>/wp-json/woo-jwt-auth/v1</pre>
                </div>
                
                <h3>API Endpoints</h3>
                <table class="wp-list-table widefat fixed striped">
                    <thead>
                        <tr>
                            <th>Endpoint</th>
                            <th>Method</th>
                            <th>Description</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><code>/wp-json/woo-jwt-auth/v1/login</code></td>
                            <td>POST</td>
                            <td>Authenticate user with username/password</td>
                        </tr>
                        <tr>
                            <td><code>/wp-json/woo-jwt-auth/v1/validate</code></td>
                            <td>GET</td>
                            <td>Validate JWT token</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            
            <script>
            jQuery(document).ready(function($) {
                // Copy to clipboard
                $('#copy-secret').on('click', function() {
                    var secretInput = document.getElementById('jwt-secret');
                    secretInput.select();
                    document.execCommand('copy');
                    
                    $('#copy-success').fadeIn().delay(2000).fadeOut();
                });
                
                // Regenerate secret key
                $('#regenerate-secret').on('click', function() {
                    if (confirm('Are you sure you want to regenerate the JWT secret key? This will invalidate all existing tokens.')) {
                        var $button = $(this);
                        $button.prop('disabled', true).text('Regenerating...');
                        
                        $.ajax({
                            url: ajaxurl,
                            type: 'POST',
                            data: {
                                action: 'regenerate_jwt_secret',
                                nonce: '<?php echo wp_create_nonce('regenerate_jwt_secret'); ?>'
                            },
                            success: function(response) {
                                if (response.success) {
                                    $('#jwt-secret').val(response.data.secret_key);
                                    alert('New JWT secret key has been generated. Update your app configuration.');
                                } else {
                                    alert('Error: ' + (response.data || 'Failed to regenerate key'));
                                }
                            },
                            error: function() {
                                alert('Error: Failed to regenerate key');
                            },
                            complete: function() {
                                $button.prop('disabled', false).text('Regenerate Key');
                            }
                        });
                    }
                });
            });
            </script>
        </div>
        <?php
    }
    
    // Handle AJAX request to regenerate secret key
    public function ajax_regenerate_secret() {
        check_ajax_referer('regenerate_jwt_secret', 'nonce');
        
        if (!current_user_can('manage_options')) {
            wp_send_json_error('Permission denied');
        }
        
        $new_secret = $this->generate_secret_key();
        
        wp_send_json_success(array(
            'secret_key' => $new_secret
        ));
    }
}

// Initialize the plugin
new Woo_JWT_Auth();

// Activation hook
register_activation_hook(__FILE__, function() {
    // Ensure our option is added when plugin is activated
    if (!get_option('woo_jwt_auth_secret')) {
        $plugin = new Woo_JWT_Auth();
        $plugin->generate_secret_key();
    }
});
