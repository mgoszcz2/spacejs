rooms = require '../models/room'
utils = require '../libs/utils'

module.exports = (io, rooms) ->
  rooms.events.on 'change', ->
    io.emit 'update', rooms.jsonify()
  io.on 'connection', (socket) ->
    socket.emit 'update', rooms.jsonify()
