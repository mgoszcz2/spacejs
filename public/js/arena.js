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
  alert(data);
  window.location.pathname = '/rooms.html';
});

/*User - user management*/
arena.on('joined', function(data){ plist.push(data); });
arena.on('left', function(data){
  plist = array.filter(function(i){
    return i.username == data.username;
  });
});


/*Turn based stuff*/
var code;

//DRY
function startTurn(){
  eval(code);
}
function handleData(data){
  console.log(data);
}
$('#ready').click(function(){
  arena.emit('join', {'roomn': window.location.hash});
  code = $('#code').val();
  $('#read').remove();
  $('#code').remove();
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
  log(0, str);
}

ship.move = function(num){
  if(!num) num = 1;
  queue.move = {'action': 'forward', 'value': num};
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

/*GUI logger*/
function log(){
  var args = $.makeArray(arguments);
  var lvl = args.shift();
  var msg = args.join(' ');

  $('#logger').append(["Info", "Warn", "Error", "Debug"][lvl]+": "+msg+"<br>");
}
