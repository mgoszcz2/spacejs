var editor = ace.edit('code');
editor.setTheme('ace/theme/monokai');
editor.setHighlightActiveLine(false);
editor.setShowPrintMargin(false);
editor.getSession().setUseWorker(false);
editor.getSession().setMode('ace/mode/javascript');
editor.insert("//Fight with your robot and have fun\nship.move(20)\nship.ready()");
editor.setReadOnly(true);
$('#code').css('font-size', '16px');
