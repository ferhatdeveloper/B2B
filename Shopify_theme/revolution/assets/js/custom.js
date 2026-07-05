jQuery(document).ready(function ($) {

    // Preloader
    jQuery('#preloader').delay(1500).fadeOut();
    jQuery('#loader').delay(1500).fadeOut("slow");

    // Scroll to Top Button
    if ($('.go-to-top').length) {
        var scrollTrigger = $('body').position(); // px
        var goToTop = function () {
            var scrollTop = $(window).scrollTop();
            if (scrollTop > 150) {
                $('.footer-go-to-top').addClass('show');
            } else {
                $('.footer-go-to-top').removeClass('show');
            }
        };
        goToTop();
        $(window).on('scroll', function () {
            goToTop();
        });
        $('.go-to-top').on('click', function (e) {
            e.preventDefault();
            $('html, body').animate({
                scrollTop: scrollTrigger.top
            }, 700);
        });
    }

    // Mobile Menu Focus
    $(window).resize(art_blog_navTrapp);

    function art_blog_navTrapp() {
        var width = $(window).width();
        if (width < 992) {
            $('.main-navigation').on('keydown', function (e) {
                if ($('.main-navigation').hasClass('toggled')) {
                    var focusableEls = $('.main-navigation a[href]:not([disabled]), .main-navigation button');
                    var firstFocusableEl = focusableEls[0];
                    var lastFocusableEl = focusableEls[focusableEls.length - 1];
                    var KEYCODE_TAB = 9;
                    var KEYCODE_ESC = 27;
                    if (e.key === 'Tab' || e.keyCode === KEYCODE_TAB) {
                        if (e.shiftKey) { // shift + tab
                            if (document.activeElement === firstFocusableEl) {
                                lastFocusableEl.focus();
                                e.preventDefault();
                            }
                        } else { // tab
                            if (document.activeElement === lastFocusableEl) {
                                firstFocusableEl.focus();
                                e.preventDefault();
                            }
                        }
                    }
                    if (e.keyCode === KEYCODE_ESC) {
                        $('.main-navigation').removeClass('toggled');
                        return;
                    }
                }
            });
        }
    }

    art_blog_navTrapp();

    // Main Slider
    var owl = jQuery('#main-slider-wrap .owl-carousel');
    owl.owlCarousel({
        margin: 20,
        nav: true,
        autoplay: false,
        lazyLoad: false,
        autoplayTimeout: 2000,
        loop: true,
        rtl: $('html').attr('dir') === 'rtl',  // Set RTL based on HTML direction
        dots: true,
        responsive: {
            0: {
                items: 1
            },
            600: {
                items: 1
            },
            1000: {
                items: 1
            }
        },
        autoplayHoverPause: true,
        mouseDrag: true
    });
});

jQuery(document).ready(function($) {
    $('.art-blog-product-carousel').owlCarousel({
        loop: true,
        margin: 0,
        nav: true,
        dots: false,
        responsive: {
            0: {
                items: 1
            },
            600: {
                items: 2
            },
            1000: {
                items: 3
            }
        }
    });
});