<?php 
	$art_blog_custom_css ='';

    /*----------------Related Product show/hide -------------------*/

    $art_blog_enable_related_product = get_theme_mod('art_blog_enable_related_product',1);

    if($art_blog_enable_related_product == 0){
        $art_blog_custom_css .='.related.products{';
            $art_blog_custom_css .='display: none;';
        $art_blog_custom_css .='}';
    }

    /*----------------blog post content alignment -------------------*/

    $art_blog_blog_Post_content_layout = get_theme_mod( 'art_blog_blog_Post_content_layout','Left');
    if($art_blog_blog_Post_content_layout == 'Left'){
        $art_blog_custom_css .='.ct-post-wrapper .card-item {';
            $art_blog_custom_css .='text-align:start;';
        $art_blog_custom_css .='}';
    }else if($art_blog_blog_Post_content_layout == 'Center'){
        $art_blog_custom_css .='.ct-post-wrapper .card-item {';
            $art_blog_custom_css .='text-align:center;';
        $art_blog_custom_css .='}';
    }else if($art_blog_blog_Post_content_layout == 'Right'){
        $art_blog_custom_css .='.ct-post-wrapper .card-item {';
            $art_blog_custom_css .='text-align:end;';
        $art_blog_custom_css .='}';
    }

    /*--------------------------- Footer background image -------------------*/

    $art_blog_footer_bg_image = get_theme_mod('art_blog_footer_bg_image');
    if($art_blog_footer_bg_image != false){
        $art_blog_custom_css .='.footer-top{';
            $art_blog_custom_css .='background: url('.esc_attr($art_blog_footer_bg_image).');';
        $art_blog_custom_css .='}';
    }

    /*--------------------------- Go to top positions -------------------*/

    $art_blog_go_to_top_position = get_theme_mod( 'art_blog_go_to_top_position','Right');
    if($art_blog_go_to_top_position == 'Right'){
        $art_blog_custom_css .='.footer-go-to-top{';
            $art_blog_custom_css .='right: 20px;';
        $art_blog_custom_css .='}';
    }else if($art_blog_go_to_top_position == 'Left'){
        $art_blog_custom_css .='.footer-go-to-top{';
            $art_blog_custom_css .='left: 20px;';
        $art_blog_custom_css .='}';
    }else if($art_blog_go_to_top_position == 'Center'){
        $art_blog_custom_css .='.footer-go-to-top{';
            $art_blog_custom_css .='right: 50%;left: 50%;';
        $art_blog_custom_css .='}';
    }

    /*--------------------------- Woocommerce Product Sale Positions -------------------*/

    $art_blog_product_sale = get_theme_mod( 'art_blog_woocommerce_product_sale','Right');
    if($art_blog_product_sale == 'Right'){
        $art_blog_custom_css .='.woocommerce ul.products li.product .onsale{';
            $art_blog_custom_css .='left: auto; ';
        $art_blog_custom_css .='}';
    }else if($art_blog_product_sale == 'Left'){
        $art_blog_custom_css .='.woocommerce ul.products li.product .onsale{';
            $art_blog_custom_css .='right: auto;left:0;';
        $art_blog_custom_css .='}';
    }else if($art_blog_product_sale == 'Center'){
        $art_blog_custom_css .='.woocommerce ul.products li.product .onsale{';
            $art_blog_custom_css .='right: 50%; left: 50%; ';
        $art_blog_custom_css .='}';
    }


    /*-------------------- Primary Color -------------------*/

	$art_blog_primary_color = get_theme_mod('art_blog_primary_color', '#58BCB3'); // Add a fallback if the color isn't set

	if ($art_blog_primary_color) {
		$art_blog_custom_css .= ':root {';
		$art_blog_custom_css .= '--primary-color: ' . esc_attr($art_blog_primary_color) . ';';
		$art_blog_custom_css .= '}';
	}	


	/*--------------------------- slider-------------------*/

    $art_blog_enable_slider = get_theme_mod('art_blog_enable_slider', 0);
    if($art_blog_enable_slider != 1){
        $art_blog_custom_css .='.page-template-revolution-home .header-menu-box{';
            $art_blog_custom_css .='position:static;';
        $art_blog_custom_css .='}';
        $art_blog_custom_css .='.page-template-revolution-home .header-menu-box{';
            $art_blog_custom_css .='border-bottom:1px solid #ccc;';
        $art_blog_custom_css .='}';
    }

    /*----------------Enable/Disable Breadcrumbs -------------------*/

    $art_blog_enable_breadcrumbs = get_theme_mod('art_blog_enable_breadcrumbs',1);

    if($art_blog_enable_breadcrumbs == 0){
        $art_blog_custom_css .='.art-blog-breadcrumbs, nav.woocommerce-breadcrumb{';
            $art_blog_custom_css .='display: none;';
        $art_blog_custom_css .='}';
    }