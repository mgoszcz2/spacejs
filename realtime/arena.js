var rooms = require('../models/room');
var config = require('../config');
var utils = require('../libs/utils');

var cache = {};
var roomCache = config.roomCache;

function shipdo(e, fn){
  console.log(e);
  fn();
}

//Note to self: io is io.of('/arena');
//Make sure socket contains name
module.exports = function(io){
  io.on('connection', function(socket){
    socket.on('join', function(data){
      //Make sure roomn is defined
      if(!data.roomn || !utils.iss(data.roomn) || !cache[data.roomn.substring(1)]){
        socket.emit('no_room');
        socket.disconnect();
      }else{
        //Remove hash from url hash
        data.roomn = data.roomn.substring(1);
        socket.roomn = data.roomn;
        socket.join(socket.roomn);
        io.in(socket.roomn).emit('joined', {'username': socket.username});

        if(io.clients(socket.roomn).length == cache[socket.roomn].limit){
          io.in(socket.roomn).emit('start');
        }
      }
    });

    socket.on('sevent', shipdo);//Ship event

    socket.on('disconnect', function(){
      socket.leave(socket.roomn);
      io.in(socket.roomn).emit('left', {'username': socket.username});
    });
  });
};

/*Update rooms every 'interval' settings*/
setInterval(function(){
  rooms.listRooms(function(result){
    var _cache = {};
    result.forEach(function(i){
      delete i._id;
      _cache[i.name] = i;
    });
    cache = _cache;
  });
}, roomCache);
