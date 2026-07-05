<?php
/**
 * Art Blog Theme Customizer
 *
 * @package Art Blog
 */

function art_blog_customize_register( $wp_customize ) {
	$wp_customize->get_setting( 'blogname' )->transport         = 'postMessage';
	$wp_customize->get_setting( 'blogdescription' )->transport  = 'postMessage';
	$wp_customize->get_setting( 'header_textcolor' )->transport = 'postMessage';

	if ( isset( $wp_customize->selective_refresh ) ) {
		$wp_customize->selective_refresh->add_partial(
			'blogname',
			array(
				'selector'        => '.site-title a',
				'render_callback' => 'Art_Blog_Customize_partial_blogname',
			)
		);
		$wp_customize->selective_refresh->add_partial(
			'blogdescription',
			array(
				'selector'        => '.site-description',
				'render_callback' => 'Art_Blog_Customize_partial_blogdescription',
			)
		);
	}

	/*
    * Theme Options Panel
    */
	$wp_customize->add_panel('art_blog_panel', array(
		'priority' => 25,
		'capability' => 'edit_theme_options',
		'title' => __('Art Blog Theme Options', 'art-blog'),
	));

	/*
	* Customizer main header section
	*/

	$wp_customize->add_setting(
		'art_blog_site_title_text',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => 1,
			'sanitize_callback' => 'art_blog_sanitize_checkbox',
		)
	);

	$wp_customize->add_control(
		'art_blog_site_title_text',
		array(
			'label'       => __('Enable Title', 'art-blog'),
			'description' => __('Enable or Disable Title from the site', 'art-blog'),
			'section'     => 'title_tagline',
			'type'        => 'checkbox',
		)
	);

	$wp_customize->add_setting(
		'art_blog_site_tagline_text',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => 0,
			'sanitize_callback' => 'art_blog_sanitize_checkbox',
		)
	);

	$wp_customize->add_control(
		'art_blog_site_tagline_text',
		array(
			'label'       => __('Enable Tagline', 'art-blog'),
			'description' => __('Enable or Disable Tagline from the site', 'art-blog'),
			'section'     => 'title_tagline',
			'type'        => 'checkbox',
		)
	);

		$wp_customize->add_setting(
		'art_blog_logo_width',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => '150',
			'sanitize_callback' => 'sanitize_text_field',
		)
	);

	$wp_customize->add_control(
		'art_blog_logo_width',
		array(
			'label'       => __('Logo Width in PX', 'art-blog'),
			'section'     => 'title_tagline',
			'type'        => 'number',
			'input_attrs' => array(
	            'min' => 100,
	             'max' => 300,
	             'step' => 1,
	         ),
		)
	);

	/* WooCommerce custom settings */

	$wp_customize->add_section('woocommerce_custom_settings', array(
		'priority'       => 5,
		'capability'     => 'edit_theme_options',
		'theme_supports' => '',
		'title'          => __('WooCommerce Custom Settings', 'art-blog'),
		'panel'       => 'woocommerce',
	));

	$wp_customize->add_setting(
		'art_blog_per_columns',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => '3',
			'sanitize_callback' => 'sanitize_text_field',
		)
	);

	$wp_customize->add_control(
		'art_blog_per_columns',
		array(
			'label'       => __('Product Per Single Row', 'art-blog'),
			'section'     => 'woocommerce_custom_settings',
			'type'        => 'number',
			'input_attrs' => array(
	            'min' => 1,
	             'max' => 4,
	             'step' => 1,
	         ),
		)
	);

	$wp_customize->add_setting(
		'art_blog_product_per_page',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => '6',
			'sanitize_callback' => 'sanitize_text_field',
		)
	);

	$wp_customize->add_control(
		'art_blog_product_per_page',
		array(
			'label'       => __('Product Per One Page', 'art-blog'),
			'section'     => 'woocommerce_custom_settings',
			'type'        => 'number',
			'input_attrs' => array(
	            'min' => 1,
	             'max' => 12,
	             'step' => 1,
	         ),
		)
	);

	/*Related Products Enable Option*/
	$wp_customize->add_setting(
		'art_blog_enable_related_product',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => 1,
			'sanitize_callback' => 'art_blog_sanitize_checkbox',
		)
	);

	$wp_customize->add_control(
		'art_blog_enable_related_product',
		array(
			'label'       => __('Enable Related Product', 'art-blog'),
			'description' => __('Checked to show Related Product', 'art-blog'),
			'section'     => 'woocommerce_custom_settings',
			'type'        => 'checkbox',
		)
	);

	$wp_customize->add_setting(
		'custom_related_products_number',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => '3',
			'sanitize_callback' => 'sanitize_text_field',
		)
	);

	$wp_customize->add_control(
		'custom_related_products_number',
		array(
			'label'       => __('Related Product Count', 'art-blog'),
			'section'     => 'woocommerce_custom_settings',
			'type'        => 'number',
			'input_attrs' => array(
	            'min' => 1,
	             'max' => 20,
	             'step' => 1,
	         ),
		)
	);

	$wp_customize->add_setting(
		'custom_related_products_number_per_row',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => '3',
			'sanitize_callback' => 'sanitize_text_field',
		)
	);

	$wp_customize->add_control(
		'custom_related_products_number_per_row',
		array(
			'label'       => __('Related Product Per Row', 'art-blog'),
			'section'     => 'woocommerce_custom_settings',
			'type'        => 'number',
			'input_attrs' => array(
	            'min' => 1,
	             'max' => 4,
	             'step' => 1,
	         ),
		)
	);

	/*Archive Product layout*/
	$wp_customize->add_setting('art_blog_archive_product_layout',array(
        'default' => 'layout-1',
        'sanitize_callback' => 'art_blog_sanitize_choices'
	));
	$wp_customize->add_control('art_blog_archive_product_layout',array(
        'type' => 'select',
        'label' => esc_html__('Archive Product Layout','art-blog'),
        'section' => 'woocommerce_custom_settings',
        'choices' => array(
            'layout-1' => esc_html__('Sidebar On Right','art-blog'),
            'layout-2' => esc_html__('Sidebar On Left','art-blog'),
			'layout-3' => esc_html__('Full Width Layout','art-blog')
        ),
	) );

	/*Single Product layout*/
	$wp_customize->add_setting('art_blog_single_product_layout',array(
        'default' => 'layout-1',
        'sanitize_callback' => 'art_blog_sanitize_choices'
	));
	$wp_customize->add_control('art_blog_single_product_layout',array(
        'type' => 'select',
        'label' => esc_html__('Single Product Layout','art-blog'),
        'section' => 'woocommerce_custom_settings',
        'choices' => array(
            'layout-1' => esc_html__('Sidebar On Right','art-blog'),
            'layout-2' => esc_html__('Sidebar On Left','art-blog'),
			'layout-3' => esc_html__('Full Width Layout','art-blog')
        ),
	) );

	$wp_customize->add_setting('art_blog_woocommerce_product_sale',array(
		'capability'        => 'edit_theme_options',
		'transport'         => 'refresh',
        'default'           => 'Right',
        'sanitize_callback' => 'art_blog_sanitize_choices'
    ));
    $wp_customize->add_control('art_blog_woocommerce_product_sale',array(
        'label'       => esc_html__( 'Woocommerce Product Sale Positions','art-blog' ),
        'type' => 'select',
        'section' => 'woocommerce_custom_settings',
        'choices' => array(
            'Right' => __('Right','art-blog'),
            'Left' => __('Left','art-blog'),
            'Center' => __('Center','art-blog')
        ),
    ) );

	/*Additional Options*/
	$wp_customize->add_section('art_blog_additional_section', array(
		'priority'       => 5,
		'capability'     => 'edit_theme_options',
		'theme_supports' => '',
		'title'          => __('Additional Options', 'art-blog'),
		'panel'       => 'art_blog_panel',
	));

	/*Main Slider Enable Option*/
	$wp_customize->add_setting(
		'art_blog_enable_preloader',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => 0,
			'sanitize_callback' => 'art_blog_sanitize_checkbox',
		)
	);

	$wp_customize->add_control(
		'art_blog_enable_preloader',
		array(
			'label'       => __('Enable Preloader', 'art-blog'),
			'description' => __('Checked to show preloader', 'art-blog'),
			'section'     => 'art_blog_additional_section',
			'type'        => 'checkbox',
		)
	);
	
	/*Breadcrumbs Enable Option*/
	$wp_customize->add_setting(
		'art_blog_enable_breadcrumbs',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => 1,
			'sanitize_callback' => 'art_blog_sanitize_checkbox',
		)
	);

	$wp_customize->add_control(
		'art_blog_enable_breadcrumbs',
		array(
			'label'       => __('Enable Breadcrumbs', 'art-blog'),
			'description' => __('Checked to show Breadcrumbs', 'art-blog'),
			'section'     => 'art_blog_additional_section',
			'type'        => 'checkbox',
		)
	);

	/*Post layout*/
	$wp_customize->add_setting('art_blog_archive_layout',array(
        'default' => 'layout-1',
        'sanitize_callback' => 'art_blog_sanitize_choices'
	));
	$wp_customize->add_control('art_blog_archive_layout',array(
        'type' => 'select',
        'label' => esc_html__('Posts Layout','art-blog'),
        'section' => 'art_blog_additional_section',
        'choices' => array(
            'layout-1' => esc_html__('Sidebar On Right','art-blog'),
            'layout-2' => esc_html__('Sidebar On Left','art-blog'),
			'layout-3' => esc_html__('Full Width Layout','art-blog')
        ),
	) );

	/*single post layout*/
	$wp_customize->add_setting('art_blog_post_layout',array(
        'default' => 'layout-1',
        'sanitize_callback' => 'art_blog_sanitize_choices'
	));
	$wp_customize->add_control('art_blog_post_layout',array(
        'type' => 'select',
        'label' => esc_html__('Single Post Layout','art-blog'),
        'section' => 'art_blog_additional_section',
        'choices' => array(
            'layout-1' => esc_html__('Sidebar On Right','art-blog'),
            'layout-2' => esc_html__('Sidebar On Left','art-blog'),
			'layout-3' => esc_html__('Full Width Layout','art-blog')
        ),
	) );

	/*single page layout*/
	$wp_customize->add_setting('art_blog_page_layout',array(
        'default' => 'layout-1',
        'sanitize_callback' => 'art_blog_sanitize_choices'
	));
	$wp_customize->add_control('art_blog_page_layout',array(
        'type' => 'select',
        'label' => esc_html__('Single Page Layout','art-blog'),
        'section' => 'art_blog_additional_section',
        'choices' => array(
            'layout-1' => esc_html__('Sidebar On Right','art-blog'),
            'layout-2' => esc_html__('Sidebar On Left','art-blog'),
			'layout-3' => esc_html__('Full Width Layout','art-blog')
        ),
	) );

	/*Archive Post Options*/
	$wp_customize->add_section('art_blog_blog_post_section', array(
		'priority'       => 5,
		'capability'     => 'edit_theme_options',
		'theme_supports' => '',
		'title'          => __('Blog Page Options', 'art-blog'),
		'panel'       => 'art_blog_panel',
	));

	$wp_customize->add_setting('art_blog_enable_blog_post_title',array(
		'capability'        => 'edit_theme_options',
		'transport'         => 'refresh',
		'default'           => 1,
		'sanitize_callback' => 'art_blog_sanitize_checkbox',
	));
	$wp_customize->add_control('art_blog_enable_blog_post_title',array(
		'label'       => __('Enable Blog Post Title', 'art-blog'),
		'description' => __('Checked To Show Blog Post Title', 'art-blog'),
		'section'     => 'art_blog_blog_post_section',
		'type'        => 'checkbox',
	));

	$wp_customize->add_setting('art_blog_enable_blog_post_meta',array(
		'capability'        => 'edit_theme_options',
		'transport'         => 'refresh',
		'default'           => 1,
		'sanitize_callback' => 'art_blog_sanitize_checkbox',
	));
	$wp_customize->add_control('art_blog_enable_blog_post_meta',array(
		'label'       => __('Enable Blog Post Meta', 'art-blog'),
		'description' => __('Checked To Show Blog Post Meta Feilds', 'art-blog'),
		'section'     => 'art_blog_blog_post_section',
		'type'        => 'checkbox',
	));

	$wp_customize->add_setting('art_blog_enable_blog_post_tags',array(
		'capability'        => 'edit_theme_options',
		'transport'         => 'refresh',
		'default'           => 1,
		'sanitize_callback' => 'art_blog_sanitize_checkbox',
	));
	$wp_customize->add_control('art_blog_enable_blog_post_tags',array(
		'label'       => __('Enable Blog Post Tags', 'art-blog'),
		'description' => __('Checked To Show Blog Post Tags', 'art-blog'),
		'section'     => 'art_blog_blog_post_section',
		'type'        => 'checkbox',
	));

	$wp_customize->add_setting('art_blog_enable_blog_post_image',array(
		'capability'        => 'edit_theme_options',
		'transport'         => 'refresh',
		'default'           => 1,
		'sanitize_callback' => 'art_blog_sanitize_checkbox',
	));
	$wp_customize->add_control('art_blog_enable_blog_post_image',array(
		'label'       => __('Enable Blog Post Image', 'art-blog'),
		'description' => __('Checked To Show Blog Post Image', 'art-blog'),
		'section'     => 'art_blog_blog_post_section',
		'type'        => 'checkbox',
	));

	$wp_customize->add_setting('art_blog_enable_blog_post_content',array(
		'capability'        => 'edit_theme_options',
		'transport'         => 'refresh',
		'default'           => 1,
		'sanitize_callback' => 'art_blog_sanitize_checkbox',
	));
	$wp_customize->add_control('art_blog_enable_blog_post_content',array(
		'label'       => __('Enable Blog Post Content', 'art-blog'),
		'description' => __('Checked To Show Blog Post Content', 'art-blog'),
		'section'     => 'art_blog_blog_post_section',
		'type'        => 'checkbox',
	));

	$wp_customize->add_setting('art_blog_enable_blog_post_button',array(
		'capability'        => 'edit_theme_options',
		'transport'         => 'refresh',
		'default'           => 1,
		'sanitize_callback' => 'art_blog_sanitize_checkbox',
	));
	$wp_customize->add_control('art_blog_enable_blog_post_button',array(
		'label'       => __('Enable Blog Post Read More Button', 'art-blog'),
		'description' => __('Checked To Show Blog Post Read More Button', 'art-blog'),
		'section'     => 'art_blog_blog_post_section',
		'type'        => 'checkbox',
	));

	/*Blog post Content layout*/
	$wp_customize->add_setting('art_blog_blog_Post_content_layout',array(
        'default' => 'Left',
        'sanitize_callback' => 'art_blog_sanitize_choices'
	));
	$wp_customize->add_control('art_blog_blog_Post_content_layout',array(
        'type' => 'select',
        'label' => esc_html__('Blog Post Content Layout','art-blog'),
        'section' => 'art_blog_blog_post_section',
        'choices' => array(
            'Left' => esc_html__('Left','art-blog'),
            'Center' => esc_html__('Center','art-blog'),
            'Right' => esc_html__('Right','art-blog')
        ),
	) );

	/*Excerpt*/
    $wp_customize->add_setting(
		'art_blog_excerpt_limit',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => '25',
			'sanitize_callback' => 'sanitize_text_field',
		)
	);

	$wp_customize->add_control(
		'art_blog_excerpt_limit',
		array(
			'label'       => __('Excerpt Limit', 'art-blog'),
			'section'     => 'art_blog_blog_post_section',
			'type'        => 'number',
			'input_attrs' => array(
	            'min' => 2,
	             'max' => 50,
	             'step' => 2,
	         ),
		)
	);

	/*Archive Button Text*/
	$wp_customize->add_setting(
		'art_blog_read_more_text',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => 'Continue Reading....',
			'sanitize_callback' => 'sanitize_text_field',
		)
	);

	$wp_customize->add_control(
		'art_blog_read_more_text',
		array(
			'label'       => __('Edit Button Text ', 'art-blog'),
			'section'     => 'art_blog_blog_post_section',
			'type'        => 'text',
		)
	);

	/*Single Post Options*/
	$wp_customize->add_section('art_blog_single_post_section', array(
		'priority'       => 5,
		'capability'     => 'edit_theme_options',
		'theme_supports' => '',
		'title'          => __('Single Post Options', 'art-blog'),
		'panel'       => 'art_blog_panel',
	));

	$wp_customize->add_setting('art_blog_enable_single_blog_post_title',array(
		'capability'        => 'edit_theme_options',
		'transport'         => 'refresh',
		'default'           => 1,
		'sanitize_callback' => 'art_blog_sanitize_checkbox',
	));
	$wp_customize->add_control('art_blog_enable_single_blog_post_title',array(
		'label'       => __('Enable Single Post Title', 'art-blog'),
		'description' => __('Checked To Show Single Blog Post Title', 'art-blog'),
		'section'     => 'art_blog_single_post_section',
		'type'        => 'checkbox',
	));

	$wp_customize->add_setting('art_blog_enable_single_blog_post_meta',array(
		'capability'        => 'edit_theme_options',
		'transport'         => 'refresh',
		'default'           => 1,
		'sanitize_callback' => 'art_blog_sanitize_checkbox',
	));
	$wp_customize->add_control('art_blog_enable_single_blog_post_meta',array(
		'label'       => __('Enable Single Post Meta', 'art-blog'),
		'description' => __('Checked To Show Single Blog Post Meta Feilds', 'art-blog'),
		'section'     => 'art_blog_single_post_section',
		'type'        => 'checkbox',
	));

	$wp_customize->add_setting('art_blog_enable_single_blog_post_tags',array(
		'capability'        => 'edit_theme_options',
		'transport'         => 'refresh',
		'default'           => 1,
		'sanitize_callback' => 'art_blog_sanitize_checkbox',
	));
	$wp_customize->add_control('art_blog_enable_single_blog_post_tags',array(
		'label'       => __('Enable Single Post Tags', 'art-blog'),
		'description' => __('Checked To Show Single Blog Post Tags', 'art-blog'),
		'section'     => 'art_blog_single_post_section',
		'type'        => 'checkbox',
	));

	$wp_customize->add_setting('art_blog_enable_single_post_image',array(
		'capability'        => 'edit_theme_options',
		'transport'         => 'refresh',
		'default'           => 1,
		'sanitize_callback' => 'art_blog_sanitize_checkbox',
	));
	$wp_customize->add_control('art_blog_enable_single_post_image',array(
		'label'       => __('Enable Single Post Image', 'art-blog'),
		'description' => __('Checked To Show Single Post Image', 'art-blog'),
		'section'     => 'art_blog_single_post_section',
		'type'        => 'checkbox',
	));

	$wp_customize->add_setting('art_blog_enable_single_blog_post_content',array(
		'capability'        => 'edit_theme_options',
		'transport'         => 'refresh',
		'default'           => 1,
		'sanitize_callback' => 'art_blog_sanitize_checkbox',
	));
	$wp_customize->add_control('art_blog_enable_single_blog_post_content',array(
		'label'       => __('Enable Single Post Content', 'art-blog'),
		'description' => __('Checked To Show Single Blog Post Content', 'art-blog'),
		'section'     => 'art_blog_single_post_section',
		'type'        => 'checkbox',
	));

	/*Related Post Enable Option*/
	$wp_customize->add_setting(
		'art_blog_enable_related_post',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => 1,
			'sanitize_callback' => 'art_blog_sanitize_checkbox',
		)
	);

	$wp_customize->add_control(
		'art_blog_enable_related_post',
		array(
			'label'       => __('Enable Related Post', 'art-blog'),
			'description' => __('Checked to show Related Post', 'art-blog'),
			'section'     => 'art_blog_single_post_section',
			'type'        => 'checkbox',
		)
	);

	/*Related post Edit Text*/
	$wp_customize->add_setting(
		'art_blog_related_post_text',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => 'Related Post',
			'sanitize_callback' => 'sanitize_text_field',
		)
	);

	$wp_customize->add_control(
		'art_blog_related_post_text',
		array(
			'label'       => __('Edit Related Post Text ', 'art-blog'),
			'section'     => 'art_blog_single_post_section',
			'type'        => 'text',
		)
	);	

	/*Related Post Per Page*/
	$wp_customize->add_setting(
		'art_blog_related_post_count',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => '3',
			'sanitize_callback' => 'sanitize_text_field',
		)
	);

	$wp_customize->add_control(
		'art_blog_related_post_count',
		array(
			'label'       => __('Related Post Count', 'art-blog'),
			'section'     => 'art_blog_single_post_section',
			'type'        => 'number',
			'input_attrs' => array(
	            'min' => 1,
	             'max' => 9,
	             'step' => 1,
	         ),
		)
	);

		/*
	* Customizer Global COlor
	*/

	/*Global Color Options*/
	$wp_customize->add_section('art_blog_global_color_section', array(
		'priority'       => 1,
		'capability'     => 'edit_theme_options',
		'theme_supports' => '',
		'title'          => __('Global Color Options', 'art-blog'),
		'panel'       => 'art_blog_panel',
	));

	$wp_customize->add_setting( 'art_blog_primary_color',
		array(
		'default'           => '#58BCB3',
		'capability'        => 'edit_theme_options',
		'sanitize_callback' => 'sanitize_hex_color',
		)
	);
	$wp_customize->add_control( 
		new WP_Customize_Color_Control( 
		$wp_customize, 
		'art_blog_primary_color',
		array(
			'label'      => esc_html__( 'Primary Color', 'art-blog' ),
			'section'    => 'art_blog_global_color_section',
			'settings'   => 'art_blog_primary_color',
		) ) 
	);

	/*
	* Customizer main slider section
	*/
	/*Main Slider Options*/
	$wp_customize->add_section('art_blog_slider_section', array(
		'priority'       => 5,
		'capability'     => 'edit_theme_options',
		'theme_supports' => '',
		'title'          => __('Main Slider Options', 'art-blog'),
		'panel'       => 'art_blog_panel',
	));

	/*Main Slider Enable Option*/
	$wp_customize->add_setting(
		'art_blog_enable_slider',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => 0,
			'sanitize_callback' => 'art_blog_sanitize_checkbox',
		)
	);

	$wp_customize->add_control(
		'art_blog_enable_slider',
		array(
			'label'       => __('Enable Main Slider', 'art-blog'),
			'description' => __('Checked to show the main slider', 'art-blog'),
			'section'     => 'art_blog_slider_section',
			'type'        => 'checkbox',
		)
	);

	for ($i=1; $i <= 3; $i++) { 

		/*Main Slider Image*/
		$wp_customize->add_setting(
			'art_blog_slider_image'.$i,
			array(
				'capability'    => 'edit_theme_options',
		        'default'       => '',
		        'transport'     => 'postMessage',
		        'sanitize_callback' => 'esc_url_raw',
	    	)
	    );

		$wp_customize->add_control( 
			new WP_Customize_Image_Control( $wp_customize, 
				'art_blog_slider_image'.$i, 
				array(
			        'label' => __('Edit Slider Image ', 'art-blog') .$i,
			        'description' => __('Edit the slider image.', 'art-blog'),
			        'section' => 'art_blog_slider_section',
				)
			)
		);

		/*Main Slider Heading*/
		$wp_customize->add_setting(
			'art_blog_slider_heading'.$i,
			array(
				'capability'        => 'edit_theme_options',
				'transport'         => 'refresh',
				'default'           => '',
				'sanitize_callback' => 'sanitize_text_field',
			)
		);

		$wp_customize->add_control(
			'art_blog_slider_heading'.$i,
			array(
				'label'       => __('Edit Heading Text ', 'art-blog') .$i,
				'description' => __('Edit the slider heading text.', 'art-blog'),
				'section'     => 'art_blog_slider_section',
				'type'        => 'text',
			)
		);

		/*Main Slider Content*/
		$wp_customize->add_setting(
			'art_blog_slider_text'.$i,
			array(
				'capability'        => 'edit_theme_options',
				'transport'         => 'refresh',
				'default'           => '',
				'sanitize_callback' => 'sanitize_text_field',
			)
		);

		$wp_customize->add_control(
			'art_blog_slider_text'.$i,
			array(
				'label'       => __('Edit Content Text ', 'art-blog') .$i,
				'description' => __('Edit the slider content text.', 'art-blog'),
				'section'     => 'art_blog_slider_section',
				'type'        => 'text',
			)
		);

		/*Main Slider Button1 Text*/
		$wp_customize->add_setting(
			'art_blog_slider_button1_text'.$i,
			array(
				'capability'        => 'edit_theme_options',
				'transport'         => 'refresh',
				'default'           => '',
				'sanitize_callback' => 'sanitize_text_field',
			)
		);
		$wp_customize->add_control(
			'art_blog_slider_button1_text'.$i,
			array(
				'label'       => __('Edit Button #1 Text ', 'art-blog') .$i,
				'description' => __('Edit the slider button text.', 'art-blog'),
				'section'     => 'art_blog_slider_section',
				'type'        => 'text',
			)
		);

		/*Main Slider Button1 URL*/
		$wp_customize->add_setting(
			'art_blog_slider_button1_link'.$i,
			array(
				'capability'        => 'edit_theme_options',
				'transport'         => 'refresh',
				'default'           => '',
				'sanitize_callback' => 'esc_url_raw',
			)
		);

		$wp_customize->add_control(
			'art_blog_slider_button1_link'.$i,
			array(
				'label'       => __('Edit Button #1 URL ', 'art-blog') .$i,
				'description' => __('Edit the slider button url.', 'art-blog'),
				'section'     => 'art_blog_slider_section',
				'type'        => 'url',
			)
		);

	}

	/*
	* Customizer feature bike section
	*/
	/*Project Options*/
	$wp_customize->add_section('art_blog_project_section', array(
		'priority'       => 5,
		'capability'     => 'edit_theme_options',
		'theme_supports' => '',
		'title'          => __('Our Bestseller Section', 'art-blog'),
		'panel'       => 'art_blog_panel',
	));

	/*Project Enable Option*/
	$wp_customize->add_setting(
		'art_blog_enable_product_section',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => 0,
			'sanitize_callback' => 'art_blog_sanitize_checkbox',
		)
	);

	$wp_customize->add_control(
		'art_blog_enable_product_section',
		array(
			'label'       => __('Enable Our Bestseller Section', 'art-blog'),
			'description' => __('Checked to show Our Bestseller section', 'art-blog'),
			'section'     => 'art_blog_project_section',
			'type'        => 'checkbox',
		)
	);

	$wp_customize->add_setting(
    	'art_blog_section_short_title',
    	array(
			'default' => '',
			'sanitize_callback' => 'sanitize_text_field',
		)
	);	
	$wp_customize->add_control( 
		'art_blog_section_short_title',
		array(
		    'label'   		=> __('Add Short Title','art-blog'),
		    'section'		=> 'art_blog_project_section',
			'type' 			=> 'text',
		)
	);

	$wp_customize->add_setting(
    	'art_blog_section_title',
    	array(
			'default' => '',
			'sanitize_callback' => 'sanitize_text_field',
		)
	);	
	$wp_customize->add_control( 
		'art_blog_section_title',
		array(
		    'label'   		=> __('Add Title','art-blog'),
		    'section'		=> 'art_blog_project_section',
			'type' 			=> 'text',
		)
	);

	$wp_customize->add_setting(
    	'art_blog_section_product_content',
    	array(
			'default' => '',
			'sanitize_callback' => 'sanitize_text_field',
		)
	);	
	$wp_customize->add_control( 
		'art_blog_section_product_content',
		array(
		    'label'   		=> __('Add Content','art-blog'),
		    'section'		=> 'art_blog_project_section',
			'type' 			=> 'text',
		)
	);

	/*Main Header Button Text*/
	$wp_customize->add_setting(
		'art_blog_view_more_button_text',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => 'VIEW ALL PRODUCTS',
			'sanitize_callback' => 'sanitize_text_field',
		)
	);
	$wp_customize->add_control(
		'art_blog_view_more_button_text',
		array(
			'label'       => __('Edit Button Text ', 'art-blog'),
			'section'     => 'art_blog_project_section',
			'type'        => 'text',
		)
	);

	/*Main Header Button Link*/
	$wp_customize->add_setting(
		'art_blog_view_more_button_link',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => '',
			'sanitize_callback' => 'esc_url_raw',
		)
	);
	$wp_customize->add_control(
		'art_blog_view_more_button_link',
		array(
			'label'       => __('Edit Button Link ', 'art-blog'),
			'section'     => 'art_blog_project_section',
			'type'        => 'url',
		)
	);

    $args = array(
       'type'      => 'product',
        'taxonomy' => 'product_cat'
    );
	$categories = get_categories($args);
		$cat_posts = array();
			$art_blog_i = 0;
			$cat_posts[]='Select';
		foreach($categories as $category){
			if($art_blog_i==0){
			$default = $category->slug;
			$art_blog_i++;
		}
		$cat_posts[$category->slug] = $category->name;
	}

	$wp_customize->add_setting('art_blog_product_category',array(
		'sanitize_callback' => 'art_blog_sanitize_choices',
	));
	$wp_customize->add_control('art_blog_product_category',array(
		'type'    => 'select',
		'choices' => $cat_posts,
		'label' => __('Select Product Category','art-blog'),
		'section' => 'art_blog_project_section',
	));

	/*
	* Customizer Footer Section
	*/
	/*Footer Options*/
	$wp_customize->add_section('art_blog_footer_section', array(
		'priority'       => 5,
		'capability'     => 'edit_theme_options',
		'theme_supports' => '',
		'title'          => __('Footer Options', 'art-blog'),
		'panel'       => 'art_blog_panel',
	));

	/*Footer Enable Option*/
	$wp_customize->add_setting(
		'art_blog_enable_footer',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => 1,
			'sanitize_callback' => 'art_blog_sanitize_checkbox',
		)
	);
	$wp_customize->add_control(
		'art_blog_enable_footer',
		array(
			'label'       => __('Enable Footer', 'art-blog'),
			'description' => __('Checked to show Footer', 'art-blog'),
			'section'     => 'art_blog_footer_section',
			'type'        => 'checkbox',
		)
	);

	/*Footer bg image Option*/
	$wp_customize->add_setting('art_blog_footer_bg_image',array(
		'capability'        => 'edit_theme_options',
		'transport'         => 'refresh',
        'default'           => '',
        'sanitize_callback' => 'esc_url_raw',
    ));
    $wp_customize->add_control( new WP_Customize_Image_Control($wp_customize,'art_blog_footer_bg_image',array(
        'label' => __('Footer Background Image','art-blog'),
        'section' => 'art_blog_footer_section',
        'priority' => 1,
    )));

	/*Footer Social Menu Option*/
	$wp_customize->add_setting(
		'art_blog_footer_social_menu',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => 1,
			'sanitize_callback' => 'art_blog_sanitize_checkbox',
		)
	);

	$wp_customize->add_control(
		'art_blog_footer_social_menu',
		array(
			'label'       => __('Enable Footer Social Menu', 'art-blog'),
			'description' => __('Checked to show the footer social menu. Go to Dashboard >> Appearance >> Menus >> Create New Menu >> Add Custom Link >> Add Social Menu >> Checked Social Menu >> Save Menu.', 'art-blog'),
			'section'     => 'art_blog_footer_section',
			'type'        => 'checkbox',
		)
	);	

	/*Go To Top Option*/
	$wp_customize->add_setting(
		'art_blog_enable_go_to_top_option',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => 1,
			'sanitize_callback' => 'art_blog_sanitize_checkbox',
		)
	);

	$wp_customize->add_control(
		'art_blog_enable_go_to_top_option',
		array(
			'label'       => __('Enable Go To Top', 'art-blog'),
			'description' => __('Checked to enable Go To Top option.', 'art-blog'),
			'section'     => 'art_blog_footer_section',
			'type'        => 'checkbox',
		)
	);

	$wp_customize->add_setting('art_blog_go_to_top_position',array(
        'capability'        => 'edit_theme_options',
		'transport'         => 'refresh',
		'default'           => 'Right',
        'sanitize_callback' => 'art_blog_sanitize_choices'
    ));
    $wp_customize->add_control('art_blog_go_to_top_position',array(
        'type' => 'select',
        'section' => 'art_blog_footer_section',
        'label' => esc_html__('Go To Top Positions','art-blog'),
        'choices' => array(
            'Right' => __('Right','art-blog'),
            'Left' => __('Left','art-blog'),
            'Center' => __('Center','art-blog')
        ),
    ) );

	/*Footer Copyright Text Enable*/
	$wp_customize->add_setting(
		'art_blog_copyright_option',
		array(
			'capability'        => 'edit_theme_options',
			'transport'         => 'refresh',
			'default'           => '',
			'sanitize_callback' => 'sanitize_text_field',
		)
	);

	$wp_customize->add_control(
		'art_blog_copyright_option',
		array(
			'label'       => __('Edit Copyright Text', 'art-blog'),
			'description' => __('Edit the Footer Copyright Section.', 'art-blog'),
			'section'     => 'art_blog_footer_section',
			'type'        => 'text',
		)
	);
}
add_action( 'customize_register', 'art_blog_customize_register' );

/**
 * Render the site title for the selective refresh partial.
 *
 * @return void
 */
function Art_Blog_Customize_partial_blogname() {
	bloginfo( 'name' );
}

/**
 * Render the site tagline for the selective refresh partial.
 *
 * @return void
 */
function Art_Blog_Customize_partial_blogdescription() {
	bloginfo( 'description' );
}

/**
 * Binds JS handlers to make Theme Customizer preview reload changes asynchronously.
 */
function Art_Blog_Customize_preview_js() {
	wp_enqueue_script( 'art-blog-customizer', get_template_directory_uri() . '/js/customizer.js', array( 'customize-preview' ), ART_BLOG_VERSION, true );
}
add_action( 'customize_preview_init', 'Art_Blog_Customize_preview_js' );

/**
 * Singleton class for handling the theme's customizer integration.
 *
 * @since  1.0.0
 * @access public
 */
final class Art_Blog_Customize {

	/**
	 * Returns the instance.
	 *
	 * @since  1.0.0
	 * @access public
	 * @return object
	 */
	public static function get_instance() {

		static $art_blog_instance = null;

		if ( is_null( $art_blog_instance ) ) {
			$art_blog_instance = new self;
			$art_blog_instance->setup_actions();
		}

		return $art_blog_instance;
	}

	/**
	 * Constructor method.
	 *
	 * @since  1.0.0
	 * @access private
	 * @return void
	 */
	private function __construct() {}

	/**
	 * Sets up initial actions.
	 *
	 * @since  1.0.0
	 * @access private
	 * @return void
	 */
	private function setup_actions() {

		// Register panels, sections, settings, controls, and partials.
		add_action( 'customize_register', array( $this, 'sections' ) );

		// Register scripts and styles for the controls.
		add_action( 'customize_controls_enqueue_scripts', array( $this, 'enqueue_control_scripts' ), 0 );
	}

	/**
	 * Sets up the customizer sections.
	 *
	 * @since  1.0.0
	 * @access public
	 * @param  object  $art_blog_manager
	 * @return void
	*/
	public function sections( $art_blog_manager ) {
		// Load custom sections.
		load_template( trailingslashit( get_template_directory() ) . '/revolution/inc/section-pro.php' );

		// Register custom section types.
		$art_blog_manager->register_section_type( 'Art_Blog_Customize_Section_Pro' );

		// Register sections.
		$art_blog_manager->add_section( new Art_Blog_Customize_Section_Pro( $art_blog_manager,'art_blog_go_pro', array(
			'priority'   => 1,
			'title'    => esc_html__( 'Art Blog Pro', 'art-blog' ),
			'pro_text' => esc_html__( 'Buy Pro', 'art-blog' ),
			'pro_url'    => esc_url( ART_BLOG_BUY_NOW ),
		) )	);

	}

	/**
	 * Loads theme customizer CSS.
	 *
	 * @since  1.0.0
	 * @access public
	 * @return void
	 */
	public function enqueue_control_scripts() {

		wp_enqueue_script( 'art-blog-customize-controls', trailingslashit( get_template_directory_uri() ) . '/revolution/assets/js/customize-controls.js', array( 'customize-controls' ) );

		wp_enqueue_style( 'art-blog-customize-controls', trailingslashit( get_template_directory_uri() ) . '/revolution/assets/css/customize-controls.css' );
	}
}

// Doing this customizer thang!
Art_Blog_Customize::get_instance();