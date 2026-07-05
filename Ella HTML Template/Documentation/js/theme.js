(function($) {
    var $body = $('body'),
        $doc = $(document),
        $html = $('html'),
        $win = $(window),
        w = $win.width();

    window.onload = function() {
        halo.init();
    }

    var halo = {
        init: function() {
            this.initScrollTop();
            this.initLinkScroll();
            this.initMenuMobile();
        },

        initScrollTop: function () {
            var backToTop = $('#back-top');
    
            $win.scroll(function () {
                if ($(this).scrollTop() > 220) {
                    backToTop.fadeIn(1200);
                } else {
                    backToTop.fadeOut(1200);
                };
            });
    
            backToTop.off('click.scrollTop').on('click.scrollTop', function (e) {
                e.preventDefault();
                e.stopPropagation();
    
                $('html, body').animate({
                    scrollTop: 0
                }, 0);
                return false;
            });
        },

        initLinkScroll: function () {
            $(".nav li a").on('click', function(event) {
              if (this.hash !== "") {
                event.preventDefault();
                var hash = this.hash;
                $('html, body').animate({
                  scrollTop: $(hash).offset().top
                }, 0);
              } // End if
            });
          },

        initMenuMobile: function() {
            var iconMenu = $('[data-mobile-menu]'),
                btnClose = $(".background-overlay, .halo-sidebar-close, .halo-sidebar_menu .nav li a");
                itemMenu = $('.halo-sidebar_menu .nav li a');

            if (iconMenu.length) {
                iconMenu.on('click', (event) => {
                    event.preventDefault();
                    event.stopPropagation();

                    $body.addClass('menu-sidebar_show');
                });

                btnClose.on('click', (event) => {
                    // event.preventDefault();
                    // event.stopPropagation();
                    if ($body.hasClass('menu-sidebar_show')) {
                        $body.removeClass('menu-sidebar_show');
                    }
                });

            }
        }
    }

    

})(jQuery);