var arena = io.connect('http://localhost/arena',{
  'sync disconnect on unload': true
});
var plist = [];

/*Connection boilerplate*/
arena.socket.on('error', function (reason){
  console.error('Unable to connect to the server:', reason);
});
arena.on('connect', function(){ });
/*No room error*/
arena.on('no_room', function(data){
  log.log(data, 2);
  window.location.pathname = '/rooms.html';
});

/*User - user management*/
arena.on('joined', function(data){ plist.push(data); });
arena.on('left', function(data){
  plist = array.filter(function(i){
    return i.username == data.username;
  });
});

/*Set up ace*/
var editor = ace.edit('code');
editor.setTheme('ace/theme/monokai');
editor.setHighlightActiveLine(false);
editor.setShowPrintMargin(false);
editor.getSession().setUseWorker(false);
editor.getSession().setMode('ace/mode/javascript');
editor.insert("//Your code goes here");

/*Ace hiding*/
function codeOff(){
  $('#ready').hide();
  $('#code').animate({
    'height': '0%'
  }, 500, function(){
    $('#logger').animate({
      'height': '30%'
    }, 500, function(){
      log.log("Logger started", 3);
    });
  });
}

/*Turn based stuff*/
var code;

//DRY
function startTurn(){
  try{
    eval(code);
  }catch(e){
    log.log(e, 2);
  }
}
function handleData(data){
  artisan.clearCanvas('arena');
  for(i in data){
    var i = data[i];
    artisan.rotateCanvas('arena', i.angle);
    artisan.drawRectangle(
      'arena',
      i.pos.x,
      i.pos.y,
      20,
      20,
      '#ff0000'
    );
    artisan.rotateCanvas('arena', -i.angle);
  }
}

$('#ready').click(function(){
  arena.emit('join', {'roomn': window.location.hash});
  code = editor.getValue();
  codeOff();
});
arena.on('start', function(data){ startTurn(); });

arena.on('update', function(data){
  handleData(data);
  startTurn();
});

/*Friend-ish utils*/
var utils = {};
var ship = {'gun': {}};
var queue = {};

utils.print = function(str){
  log.log(str, 0);
}

ship.move = function(num){
  if(!num) num = 1;
  queue.move = {'action': 'move', 'value': num};
}

ship.turn = function(num){
  if(!num) num = 1;
  queue.turn = {'action': 'turn', 'value': num};
}

ship.gun.turn = new Function();
ship.gun.fire = new Function();

ship.ready = function(){
  arena.emit('sevent', queue);
  queue = {};
}

/*Loggin util*/
var log = {};
log.log = function(str, lvl){
  $('<div>', {
    'class': ["log-info", "log-warn", "log-err", "log-ok"][lvl],
    'text': str
  }).prependTo('#logger');
}

log.clear = function(){
  $('#logger').empty();
}
