<?php
/**
 * Template Name: Home Page
 */
get_header();
?>

<main id="primary">
    <?php 
    $art_blog_main_slider_wrap = absint(get_theme_mod('art_blog_enable_slider', 0));
    if($art_blog_main_slider_wrap == 1): 
    ?>
        <section id="main-slider-wrap">
            <div class="owl-carousel">
                <?php for ($art_blog_main_i=1; $art_blog_main_i <= 3; $art_blog_main_i++): ?>
                    <?php if ($art_blog_slider_image = get_theme_mod('art_blog_slider_image'.$art_blog_main_i)): ?>
                        <div class="main-slider-inner-box">
                            <img src="<?php echo esc_url($art_blog_slider_image); ?>" alt="<?php echo esc_attr( get_theme_mod('art_blog_slider_heading'.$art_blog_main_i) ); ?>">
                            <div class="main-slider-content-box">
                                <?php if ($art_blog_heading = get_theme_mod('art_blog_slider_heading' . $art_blog_main_i)): ?>
                                    <h1><?php echo esc_html($art_blog_heading); ?></h1>
                                <?php endif; ?>

                                <?php if ($art_blog_text = get_theme_mod('art_blog_slider_text'.$art_blog_main_i)): ?>
                                    <p class="slider-content"><?php echo esc_html($art_blog_text); ?></p>
                                <?php endif; ?>
                                <div class="main-slider-button">
                                    <?php if ( get_theme_mod('art_blog_slider_button1_link'.$art_blog_main_i) ||  get_theme_mod('art_blog_slider_button1_text'.$art_blog_main_i )) : ?><a class="slide-btn-1" href="<?php echo esc_url( get_theme_mod('art_blog_slider_button1_link'.$art_blog_main_i) ); ?>"><?php echo esc_html( get_theme_mod('art_blog_slider_button1_text'.$art_blog_main_i) ); ?><span class="btn-icon"><i class="fas fa-chevron-right"></i></span></a><?php endif; ?>
                                </div>
                            </div>
                        </div>
                    <?php endif; ?>
                <?php endfor; ?>
            </div>
        </section>
    <?php endif; ?>

   <?php 
    $art_blog_main_expert_wrap = absint(get_theme_mod('art_blog_enable_product_section', 0));
    if($art_blog_main_expert_wrap == 1){ 
    ?>
        <section id="main-expert-wrap">
            <div class="container">
                <div class="flex-row">
                    <?php
                    $art_blog_has_short_title   = get_theme_mod('art_blog_section_short_title');
                    $art_blog_has_main_title    = get_theme_mod('art_blog_section_title');
                    $art_blog_has_content       = get_theme_mod('art_blog_section_product_content');
                    $art_blog_has_button_text   = get_theme_mod('art_blog_view_more_button_text','VIEW ALL PRODUCTS');
                    $art_blog_has_button_link   = get_theme_mod('art_blog_view_more_button_link');

                    if ( $art_blog_has_short_title || $art_blog_has_main_title || $art_blog_has_content || ($art_blog_has_button_link && $art_blog_has_button_text) ) :
                    ?>
                        <div class="feature-left">
                            <div class="serv-head"> 
                                <?php if ( $art_blog_has_short_title || $art_blog_has_main_title ) : ?>
                                    <span class="top-icon"><i class="far fa-image"></i></span>
                                <?php endif; ?>

                                <?php if ( $art_blog_has_short_title ) : ?>
                                    <p class="short-title"><?php echo esc_html( $art_blog_has_short_title ); ?></p>
                                <?php endif; ?> 

                                <?php if ( $art_blog_has_main_title ) : ?>
                                    <h2 class="section-title"><?php echo esc_html( $art_blog_has_main_title ); ?></h2>
                                <?php endif; ?> 

                                <?php if ( $art_blog_has_content ) : ?>
                                    <p class="product-content">
                                        <?php echo esc_html( wp_trim_words( $art_blog_has_content, 35, '...' ) ); ?>
                                    </p>
                                <?php endif; ?>
                            </div>  

                            <?php if ( $art_blog_has_button_link && $art_blog_has_button_text ) : ?>
                                <span class="view-more-button">
                                    <a href="<?php echo esc_url( $art_blog_has_button_link ); ?>">
                                        <?php echo esc_html( $art_blog_has_button_text ); ?>
                                    </a>
                                </span>
                            <?php endif; ?>
                        </div>
                    <?php endif; ?>
                    <div class="feature-right">
                        <div class="owl-carousel owl-theme art-blog-product-carousel">
                            <?php if ( class_exists( 'WooCommerce' ) ) {
                                $args = array( 
                                    'post_type' => 'product',
                                    'product_cat' => get_theme_mod( 'art_blog_product_category' ),
                                    'order' => 'ASC',
                                    'posts_per_page' => 10
                                );
                                $loop = new WP_Query( $args );
                                while ( $loop->have_posts() ) : $loop->the_post(); global $product; ?>         
                                    <div class="product-box item"> <!-- owl item -->
                                        <div class="product-box-content">
                                            <div class="product-outer">
                                                <div class="product-image">
                                                    <?php 
                                                        if ( has_post_thumbnail() ) {
                                                            echo get_the_post_thumbnail( get_the_ID(), 'shop_catalog' );
                                                        } else {
                                                            echo '<img src="' . esc_url( wc_placeholder_img_src() ) . '" alt="Placeholder" />';
                                                        }
                                                    ?>
                                                </div>
                                            </div>
                                            <div class="main-pro-content">
                                                <h3 class="product-heading-text">
                                                    <a href="<?php echo esc_url( get_permalink() ); ?>"><?php the_title(); ?></a>
                                                </h3>
                                                 <p class="product-price">
                                                    <?php 
                                                    if ( $product->is_on_sale() ) {
                                                        // Get regular and sale prices
                                                        $art_blog_regular_price = $product->get_regular_price();
                                                        $art_blog_sale_price = $product->get_sale_price();
                                                        echo '<span class="sale-price">' . wc_price( $art_blog_sale_price ) . '</span> ';
                                                        echo '<span class="regular-price" style="text-decoration: line-through; color: rgb(131 131 145 / 60%);">' . wc_price( $art_blog_regular_price ) . '</span>';
                                                    } else {
                                                        echo '<span class="product-price">' . wp_kses_post( $product->get_price_html() ) . '</span>';
                                                    }
                                                    ?>
                                                </p>
                                                <div class="cart-button align-items-center justify-content-center">
                                                  <?php if( $product->is_type( 'simple' ) ){ ?>
                                                    <?php woocommerce_template_loop_add_to_cart( $loop->post, $product ); ?>
                                                <?php } ?>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                <?php endwhile; wp_reset_postdata(); ?>
                            <?php } ?>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    <?php } ?>  
</main>
<?php
get_footer();
?>