<?php
/**
 * Plugin Name: Woo JWT Manager
 * Description: Manages JWT authentication for WooCommerce mobile app
 * Version: 1.0.0
 * Author: Your Name
 * Text Domain: woo-jwt-manager
 */

// If this file is called directly, abort.
if (!defined('WPINC')) {
    die;
}

class Woo_JWT_Manager {
    private $option_name = 'woo_jwt_secret';
    private $settings_page_slug = 'woo-jwt-settings';

    public function __construct() {
        add_action('admin_menu', array($this, 'add_admin_menu'));
        add_action('admin_init', array($this, 'setup_sections'));
        add_action('admin_init', array($this, 'setup_fields'));
        
        // Generate a secret key if one doesn't exist
        $this->maybe_generate_secret_key();
    }

    public function add_admin_menu() {
        add_options_page(
            'Woo JWT Settings',
            'Woo JWT',
            'manage_options',
            $this->settings_page_slug,
            array($this, 'settings_page_content')
        );
    }

    public function settings_page_content() {
        ?>
        <div class="wrap">
            <h1>Woo JWT Manager</h1>
            <p>Manage JWT authentication for your WooCommerce mobile app.</p>
            
            <div class="card">
                <h2>JWT Secret Key</h2>
                <p>This key is used to authenticate requests from your mobile app.</p>
                
                <?php
                $current_secret = $this->get_secret_key();
                $regenerate_nonce = wp_create_nonce('regenerate_jwt_secret');
                ?>
                
                <div class="jwt-secret-container">
                    <input type="text" id="jwt-secret" value="<?php echo esc_attr($current_secret); ?>" readonly class="large-text" />
                    <button type="button" id="copy-secret" class="button">Copy to Clipboard</button>
                </div>
                
                <p class="description">
                    <strong>Important:</strong> Keep this key secret and don't share it publicly.
                    If you suspect this key has been compromised, generate a new one.
                </p>
                
                <form method="post" action="">
                    <?php wp_nonce_field('regenerate_jwt_secret', 'jwt_security'); ?>
                    <input type="hidden" name="action" value="regenerate_jwt_secret">
                    <?php submit_button('Regenerate Secret Key', 'secondary', 'regenerate-secret', false); ?>
                </form>
                
                <div class="app-config">
                    <h3>App Configuration</h3>
                    <p>Add this to your app's <code>.env</code> file:</p>
                    <pre>WOOCOMMERCE_SITE_URL=<?php echo esc_url(home_url('/')); ?>
JWT_SECRET=<?php echo esc_html($current_secret); ?></pre>
                </div>
            </div>
            
            <style>
                .jwt-secret-container {
                    display: flex;
                    gap: 10px;
                    margin: 15px 0;
                }
                #jwt-secret {
                    background: #f1f1f1;
                    font-family: monospace;
                }
                .app-config {
                    margin-top: 30px;
                    padding: 15px;
                    background: #f9f9f9;
                    border-left: 4px solid #2271b1;
                }
                .app-config pre {
                    background: #1e1e1e;
                    color: #f1f1f1;
                    padding: 15px;
                    border-radius: 4px;
                    overflow-x: auto;
                }
            </style>
            
            <script>
            jQuery(document).ready(function($) {
                // Copy to clipboard functionality
                $('#copy-secret').on('click', function() {
                    var secretInput = document.getElementById('jwt-secret');
                    secretInput.select();
                    document.execCommand('copy');
                    
                    var $button = $(this);
                    var originalText = $button.text();
                    $button.text('Copied!');
                    
                    setTimeout(function() {
                        $button.text(originalText);
                    }, 2000);
                });
                
                // Handle regenerate confirmation
                $('form').on('submit', function(e) {
                    if ($(this).find('input[name="action"]').val() === 'regenerate_jwt_secret') {
                        if (!confirm('Are you sure you want to regenerate the JWT secret? This will invalidate all existing tokens.')) {
                            e.preventDefault();
                            return false;
                        }
                    }
                    return true;
                });
            });
            </script>
        </div>
        <?php
    }

    public function setup_sections() {
        add_settings_section(
            'jwt_settings_section',
            'JWT Authentication Settings',
            array($this, 'section_callback'),
            $this->settings_page_slug
        );
    }

    public function section_callback($arguments) {
        echo 'Configure JWT authentication settings for your WooCommerce mobile app.';
    }

    public function setup_fields() {
        // No fields needed for now, but keeping the structure for future use
    }

    private function maybe_generate_secret_key() {
        if (empty($this->get_secret_key())) {
            $this->generate_secret_key();
        }
    }

    public function get_secret_key() {
        return get_option($this->option_name, '');
    }

    public function generate_secret_key() {
        $secret_key = bin2hex(openssl_random_pseudo_bytes(32));
        update_option($this->option_name, $secret_key);
        return $secret_key;
    }

    public function handle_regenerate_secret() {
        if (!isset($_POST['jwt_security']) || !wp_verify_nonce($_POST['jwt_security'], 'regenerate_jwt_secret')) {
            wp_die('Security check failed');
        }

        if (!current_user_can('manage_options')) {
            wp_die('You do not have sufficient permissions to perform this action.');
        }

        $new_secret = $this->generate_secret_key();
        
        // Add admin notice
        add_settings_error(
            'woo_jwt_messages',
            'woo_jwt_message',
            'JWT secret key has been regenerated. Update your app configuration with the new key.',
            'updated'
        );
        
        // Redirect back to the settings page
        wp_redirect(admin_url('options-general.php?page=' . $this->settings_page_slug));
        exit;
    }
}

// Initialize the plugin
$woo_jwt_manager = new Woo_JWT_Manager();

// Handle form submissions
if (is_admin() && isset($_POST['action']) && $_POST['action'] === 'regenerate_jwt_secret') {
    $woo_jwt_manager->handle_regenerate_secret();
}

// Add a direct function to get the JWT secret from other plugins/themes
if (!function_exists('woo_jwt_get_secret')) {
    function woo_jwt_get_secret() {
        return get_option('woo_jwt_secret', '');
    }
}

// Add settings link on plugin page
add_filter('plugin_action_links_' . plugin_basename(__FILE__), 'woo_jwt_add_settings_link');
function woo_jwt_add_settings_link($links) {
    $settings_link = '<a href="' . admin_url('options-general.php?page=woo-jwt-settings') . '">' . __('Settings') . '</a>';
    array_unshift($links, $settings_link);
    return $links;
}
