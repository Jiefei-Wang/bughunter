$(document).on('click', '#file_menu', function(e) {
e.stopPropagation();
Shiny.setInputValue('show_file_menu', !Shiny.shinyapp.$inputValues.show_file_menu, {priority: 'event'});
});
$(document).on('click', function(e) {
if (!$(e.target).closest('#file_menu').length) {
    Shiny.setInputValue('show_file_menu', false, {priority: 'event'});
}
});
// Expandable error message on hover
$(document).on('mouseenter', '.error-message-box', function() {
$(this).css({
    'max-height': 'none',
    'white-space': 'normal',
    'z-index': '1000',
    'position': 'relative',
    'box-shadow': '0 2px 8px rgba(0,0,0,0.15)'
});
});
$(document).on('mouseleave', '.error-message-box', function() {
$(this).css({
    'max-height': '28px',
    'white-space': 'nowrap',
    'z-index': 'auto',
    'position': 'static',
    'box-shadow': 'none'
});
});