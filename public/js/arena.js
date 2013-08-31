/*Stack Overflow!*/
jQuery.fn.rotate = function(degrees) {
  $(this).css({'-webkit-transform' : 'rotate('+ degrees +'deg)',
    '-moz-transform' : 'rotate('+ degrees +'deg)',
    '-ms-transform' : 'rotate('+ degrees +'deg)',
    'transform' : 'rotate('+ degrees +'deg)'});
  return this;
};

var arena = io.connect('http://localhost/arena',{
  'sync disconnect on unload': true
});
var user;

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
arena.on('joined', function(data){ log.log(data+" joined", 3); });
arena.on('left', function(data){ log.log(data+" left", 3); });

/*Set up ace*/
var editor = ace.edit('code');
editor.setTheme('ace/theme/monokai');
editor.setHighlightActiveLine(false);
editor.setShowPrintMargin(false);
editor.getSession().setUseWorker(false);
editor.getSession().setMode('ace/mode/javascript');
editor.insert(localStorage.code ? localStorage.code: "//Write your program here");
$('#code').css('font-size', '16px');

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
var turnData;

//DRY
function startTurn(){
  try{
    eval(code);
  }catch(e){
    log.log(e, 2);
  }
}

/*Data handling*/
function handleData(data){
  turnData = data;
  $('#arena').empty();
  for(i in data){
    if(i == user){
      ship.angle = data[i].angle;
      ship.hitWall = function(){ return data[i].hitwall; };
    }
    var i = data[i];
    console.log(i);
    $('<div>', {
      'class': 'robot'
    }).css({
      'top': i.pos.y,
      'left': i.pos.x,
    }).appendTo('#arena').rotate(i.angle);
  }
}

$('#ready').click(function(){
  arena.emit('join', {'roomn': window.location.hash}, function(data){
    user = data;  
  });
  code = editor.getValue();
  localStorage.code = code;
  codeOff();
});
arena.on('start', function(data){ startTurn(); });

arena.on('update', function(data){
  handleData(data);
  startTurn();
});

/*Friend-ish utils*/
var utils = {};
var ship = {'angle': 0, 'hitWall': new Function()};
var gun = {};
var queue = {};
var radar = {};

utils.print = function(str){
  if(typeof str == "string")
    log.log(str, 0);
  else
    log.log(JSON.stringify(str), 0);
}

utils.getDist = function(a, b){
  return Math.sqrt( Math.pow(b.x - a.x, 2) + Math.pow(b.x - a.x, 2));
}

utils.getAngle = function(a, b){
  var deltaY = b.y - a.y;
  var deltaX = a.x - a.x;
  return Math.atan2(deltaY, deltaX) * 180 / Math.Pi;
}

utils.makeRelative = function(pos){
  return (pos + ship.angle) % 360;
}

ship.move = function(num){
  if(!num) num = 1;
  queue.move = {'value': num};
}

ship.turn = function(num){
  if(!num) num = 1;
  queue.turn = {'value': num};
}

ship.turnBy = function(num){
  if(!num) num = 1;
  queue.turn = {'value': num + ship.angle};
}

gun.turn = new Function();
gun.fire = new Function();

ship.ready = function(){
  arena.emit('sevent', queue);
  queue = {};
}

radar.scan = function(dist){
  if(!dist) dist = 1;

  var res = [];
  for(i in turnData) res.push(turnData[i]);
  return res;
}

/*Logging util*/
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
