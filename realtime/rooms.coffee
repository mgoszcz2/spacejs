rooms = require('../models/room')
config = require('../config')
cache = []
roomCache = config.roomCache

#Note to self: io is io.of('/chat');
module.exports = (io) ->
  updateRooms = ->
    rooms.listRooms (result) ->
      result.forEach (i) ->
        delete result._id

      cache = result
      io.emit 'update', cache

  io.on 'connection', (socket) ->
    socket.volatile.emit 'update', cache

  setInterval updateRooms, roomCache
