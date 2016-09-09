// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require data_table
//= require best_in_place
//= require bootstrap.min
//= require tinymce
//= require tinymce-jquery
//= require jquery.timer
//= require best_in_place.jquery-ui
//= require jquery.flexslider-min
//= require dataTables/jquery.dataTables
//= require jquery.inview.min
//= require select
//= require jquery.steps.min
//= require highstock
//= require main
//= require jquery-bootstrap-pagination
//= require jquery.bootstrap-duallistbox
//= require ckeditor/init
//= require_tree .


window.location.hash="";
window.location.hash="";//again because google chrome don't insert first hash into history
window.onhashchange=function(){window.location.hash="";}

$(document).ready(function() {
    $("select.select").select2();

    $(".tabs").hide();
    $(".fa-caret-down").hide();
    $(".header_col").click(function(){
        $(this).next().children(".tabs").slideToggle(500);
        $(this).find(".fa-caret-right, .fa-caret-down").toggle();
    });
    $('.mobil_btn').click( function(){
        $('.nav').slideToggle('fast')
        $('#sidebar-wrapper').slideToggle('fast')
    })
//    var $container = $('#container');
//// initialize
//    $container.masonry({
//        columnWidth: 200,
//        itemSelector: '.box'
//    });
    $(function(){
        //SyntaxHighlighter.all();
    });
    $(window).load(function(){
        $('.flexslider').flexslider({
            animation: "slide",
            start: function(slider){
                $('body').removeClass('loading');
            }
        });
    });
    //$('.flexslider .slides li').hover(function(){
    //  $(".slider_content").animate({
    //    opacity: "1"
    //}, {
    //  queue: false
    //});
    //}, function () {
    //  $(".slider_content").animate({
    //    opacity: "0"
    //}, {
    //  queue: false
    //});
    //});
    //
    //$('.mobil_btn').click( function(){
    //    $('.nav_mobile').slideToggle('fast')
    //})

    $('.mobil_btn').click(
        function () {
            //show its submenu
            $('.nav_mobile', this).stop().fadeIn(200);

        },
        function () {
            //hide its submenu
            $('.nav_mobile', this).stop().fadeOut(250);
        }
    );
});

$(document).ready(function() {
    //Animated Progress
    $('.progress-bar').bind('inview', function(event, visible, visiblePartX, visiblePartY) {
        if (visible) {
            $(this).css('width', $(this).data('width') + '%');
            $(this).unbind('inview');
        }
    });

    //Animated Number
    $.fn.animateNumbers = function(stop, commas, duration, ease) {
        return this.each(function() {
            var $this = $(this);
            var start = parseInt($this.text().replace(/,/g, ""));
            commas = (commas === undefined) ? true : commas;
            $({value: start}).animate({value: stop}, {
                duration: duration == undefined ? 1000 : duration,
                easing: ease == undefined ? "swing" : ease,
                step: function() {
                    $this.text(Math.floor(this.value));
                    if (commas) { $this.text($this.text().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,")); }
                },
                complete: function() {
                    if (parseInt($this.text()) !== stop) {
                        $this.text(stop);
                        if (commas) { $this.text($this.text().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,")); }
                    }
                }
            });
        });
    };

    $('.animated-number').bind('inview', function(event, visible, visiblePartX, visiblePartY) {
        var $this = $(this);
        if (visible) {
            $this.animateNumbers($this.data('digit'), false, $this.data('duration'));
            $this.unbind('inview');
        }
    });
});