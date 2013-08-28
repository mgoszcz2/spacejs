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
arena.on('no_room', function(){
  alert('No room');
  window.location.pathname = '/rooms.html';
});

/*User - user magnament*/
arena.on('joined', function(data){ plist.push(data); });
arena.on('left', function(data){
  plist = array.filter(function(i){
    return i.username == data.username;
  });
});

/*Emit join event when user clicked Ready! button*/
var code;
$('#ready').click(function(){
  arena.emit('join', {'roomn': window.location.hash});
  code = $('#code').val();
  $(this).remove();
  $('#code').remove();
});
arena.on('start', function(data){ eval(code); });

/*Freindrish utils*/
var utils = {};
utils.print = function(str){
  alert(str)
}
var ship = {}
ship.forward = function(num, callback){
  if(!num) num = 1;
  if(!callback) callback = new Function();

  console.log("Moving", num, "forward");
  arena.emit("sevent", {'action': 'forward', 'value': num}, callback);
}
ship.rotate = function(num, callback){
  if(!num) num = 1;
  if(!callback) callback = new Function();

  console.log("Rotating", num, "deg");
  arena.emit("sevent", {'action': 'rotate', 'value': num}, callback);
}
