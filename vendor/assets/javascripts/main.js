	$(document).ready(function() {
    $(".tabs").hide();
    $(".fa-caret-down").hide();
    $(".header_col").click(function(){
            $(this).next(".tabs").slideToggle(500);
            $(this).find(".fa-caret-right, .fa-caret-down").toggle();
    });
});
