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
//= require masonry
//= require jquery.flexslider-min
//= require dataTables/jquery.dataTables

//= require main
//= require_tree .



$(document).ready(function() {
    $(".tabs").hide();
    $(".fa-caret-down").hide();
    $(".header_col").click(function(){
        $(this).next().children(".tabs").slideToggle(500);
        $(this).find(".fa-caret-right, .fa-caret-down").toggle();
    });
    var $container = $('#container');
// initialize
    $container.masonry({
        columnWidth: 200,
        itemSelector: '.box'
    });
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
    $('.flexslider .slides li').hover(function(){
        $(".slider_content").animate({
            opacity: "1"
        }, {
            queue: false
        });
    }, function () {
        $(".slider_content").animate({
            opacity: "0"
        }, {
            queue: false
        });
    });

});
