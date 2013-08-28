var rooms = require('../models/room');
var config = require('../config');

var cache = [];
var roomCache = config.roomCache;

//Note to self: io is io.of('/chat');
module.exports = function(io){
  io.on('connection', function(socket){
    socket.volatile.emit('update', cache);
  });

  function updateRooms(){
    rooms.listRooms(function(result){
      result.forEach(function(i){ delete result._id; });
      cache = result;
      io.emit('update', cache);
    });
  }

  setInterval(updateRooms, roomCache);
};
