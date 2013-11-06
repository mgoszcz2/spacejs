var config = require('../config');
var utils = require('../libs/utils');

var roomCache = config.roomCache;
var roomSize = config.roomSize;
var startPos = config.startPos;
var maxMove = config.maxMove;

var cache = {};
var rooms = {};

//Note to self: io is io.of('/arena');
//Make sure socket contains name
module.exports = function(io){
  io.on('connection', function(socket){

    function getXY(xy, dist, angle){
      var radin = angle * (Math.PI/180);
      return {
        'x': (Math.sin(radin) * dist) + xy.x,
        'y': (Math.cos(radin) * dist) + xy.y
      };
    }

    function hitWall(pos){
      var x = pos.x - 50;
      var y = pos.y - 50;

      if(x <= 0 || x >= roomSize.x || y <= 0 || y >= roomSize.y) return true;
      else return false;
    }

    /*Ship updater*/
    //TODO - Handle timeouts
    function shipdo(e){
      var userdata = rooms[socket.roomn].user[socket.handshake.username];
      //Handle actions
      if(e.turn){
        if(e.turn.value >= 0 && e.turn.value <= 360)
          userdata.angle = e.turn.value;
      }

      userdata.pos = getXY(
          userdata.pos,
          e.move.value <= maxMove ? e.move.value : maxMove,
          userdata.angle
        );

      userdata.hitwall = hitWall(userdata.pos);

      //Check has everyone finished their move
      rooms[socket.roomn].done += 1;
      if(rooms[socket.roomn].done == rooms[socket.roomn].limit){
        rooms[socket.roomn].done = 0;
        io.in(socket.roomn).emit('update',rooms[socket.roomn].user);
      }
    }

    /*Kick user nicely*/
    function smallKick(str){
      socket.emit('no_room', str);
      socket.disconnect();
    }

    /*Place a new robot*/
    function placeRobot(username, room){
      if(!rooms[room]) rooms[room] = {
        'count': 0,
        'done': 0,
        'limit': cache[socket.roomn].limit,
        'user': {}
      };
      rooms[room].user[username] = {
        'count': rooms[room].count + 1,
        'angle': 0,
        'hitwall': false,
        'pos': startPos[rooms[room].count],
      };
      rooms[room].count += 1;
    }

    socket.on('join', function(data, fn){
      //Make sure roomn is defined
      fn(socket.handshake.username);

      if(!data.roomn || !utils.iss(data.roomn) || !cache[data.roomn.substring(1)])
        smallKick("Room doesn't exit")
      else {
        //Remove hash from url hash and make sure room isn't full
        data.roomn = data.roomn.substring(1);
        socket.roomn = data.roomn;

        if(io.clients(socket.roomn).length == cache[socket.roomn].limit)
          return smallKick("Room is full");

        socket.join(socket.roomn);

        io.in(socket.roomn).emit('joined', {'username': socket.handshake.username});
        placeRobot(socket.handshake.username, socket.roomn);

        if(io.clients(socket.roomn).length == cache[socket.roomn].limit)
          io.in(socket.roomn).emit('start');
      }
    });

    socket.on('sevent', shipdo);//Ship event

    socket.on('disconnect', function(){
      socket.leave(socket.roomn);
      io.in(socket.roomn).emit('left', {'username': socket.handshake.username});
    });
  });
};

/*Update rooms every 'interval' settings*/
setInterval(function(){
  //Gets around me using rooms as an important variable
  require('../models/room').listRooms(function(result){
    var _cache = {};
    result.forEach(function(i){
      delete i._id;
      _cache[i.name] = i;
    });
    cache = _cache;
  });
}, roomCache);
