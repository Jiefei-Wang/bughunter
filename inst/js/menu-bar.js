$(document).on('click', '#file_menu', function(e) {
e.stopPropagation();
Shiny.setInputValue('show_file_menu', !Shiny.shinyapp.$inputValues.show_file_menu, {priority: 'event'});
});
$(document).on('click', function(e) {
if (!$(e.target).closest('#file_menu').length) {
    Shiny.setInputValue('show_file_menu', false, {priority: 'event'});
}
});