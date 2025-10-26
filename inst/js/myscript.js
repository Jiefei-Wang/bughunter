// Initialize Ace Editor event handlers when Shiny is connected
$(document).on("shiny:connected", function() {
  // Wait for Ace Editor to be initialized
  setTimeout(function() {
    var editor = ace.edit("code_editor");
    
    if (editor) {
      // Bind Ctrl+Enter command
      editor.commands.addCommand({
        name: "executeCode",
        bindKey: {win: "Ctrl-Enter", mac: "Cmd-Enter"},
        exec: function(editor) {
          var selectedText = editor.getSelectedText();
          var cursorPosition = editor.getCursorPosition();
          
          Shiny.setInputValue("code_editor_key", {
            key: "Ctrl-Enter",
            selection: selectedText,
            cursor: cursorPosition
          }, {priority: "event"});
        }
      });
      
      // Track cursor position for getting current line
      editor.getSession().selection.on("changeCursor", function() {
        var cursor = editor.getCursorPosition();
        Shiny.setInputValue("code_editor_cursor", cursor);
      });
      
      // Track selection changes
      editor.getSession().selection.on("changeSelection", function() {
        var selectedText = editor.getSelectedText();
        Shiny.setInputValue("code_editor_selection", selectedText);
      });
    }
  }, 100);
});

// Handle custom messages for Ace Editor
Shiny.addCustomMessageHandler("aceEditor_clearAnnotations", function(editorId) {
  var editor = window.ace.edit(editorId);
  if (editor) {
    editor.getSession().clearAnnotations();
    editor.getSession().clearBreakpoints();
    
    // Remove marker if exists
    if (editor._currentMarker) {
      editor.getSession().removeMarker(editor._currentMarker);
      editor._currentMarker = null;
    }
  }
});

Shiny.addCustomMessageHandler("aceEditor_setAnnotations", function(data) {
  var editor = window.ace.edit(data.editorId);
  if (editor) {
    // Remove previous marker
    if (editor._currentMarker) {
      editor.getSession().removeMarker(editor._currentMarker);
    }
    
    editor.getSession().setAnnotations(data.annotations);
    
    // Add background highlight for the line
    var Range = ace.require("ace/range").Range;
    var range = new Range(data.annotations[0].row, 0, data.annotations[0].row, 1);
    var markerId = editor.getSession().addMarker(range, "hl-line", "fullLine");
    
    // Store marker ID to remove later
    editor._currentMarker = markerId;
  }
});

Shiny.addCustomMessageHandler("aceEditor_gotoLine", function(data) {
  var editor = window.ace.edit(data.editorId);
  if (editor) {
    // Remove previous marker
    if (editor._currentMarker) {
      editor.getSession().removeMarker(editor._currentMarker);
    }
    
    editor.gotoLine(data.line, data.column, true);
    editor.focus();
  }
});