config = require("../config")
utils = require("../libs/utils")
roomCache = config.roomCache
roomSize = config.roomSize
startPos = config.startPos
maxMove = config.maxMove
cache = {}
rooms = {}

#Note to self: io is io.of('/arena');
#Make sure socket contains name
module.exports = (io) ->
  io.on "connection", (socket) ->
    getXY = (xy, dist, angle) ->
      radin = angle * (Math.PI / 180)
      x: (Math.sin(radin) * dist) + xy.x
      y: (Math.cos(radin) * dist) + xy.y
    hitWall = (pos) ->
      x = pos.x - 50
      y = pos.y - 50
      if x <= 0 or x >= roomSize.x or y <= 0 or y >= roomSize.y
        true
      else
        false

    #TODO - Handle timeouts
    shipdo = (e) ->
      userdata = rooms[socket.roomn].user[socket.handshake.username]

      #Handle actions

      #TODO fix overflow
      userdata.angle = e.turn.value  if e.turn and e.turn.value >= 1 and e.turn.value <= 360
      userdata.pos = getXY(userdata.pos, (if e.move.value <= maxMove then e.move.value else maxMove), userdata.angle)
      userdata.hitwall = hitWall(userdata.pos)

      #Check has everyone finished their move
      rooms[socket.roomn].done += 1
      if rooms[socket.roomn].done is rooms[socket.roomn].limit
        rooms[socket.roomn].done = 0
        io.in(socket.roomn).emit "update", rooms[socket.roomn].user
    smallKick = (str) ->
      socket.emit "no_room", str
      socket.disconnect()
    placeRobot = (username, room) ->
      unless rooms[room]
        rooms[room] =
          count: 0
          done: 0
          limit: cache[socket.roomn].limit
          user: {}
      rooms[room].user[username] =
        count: rooms[room].count + 1
        angle: 0
        hitwall: false
        pos: startPos[rooms[room].count]

      rooms[room].count += 1
    socket.on "join", (data, fn) ->

      #Make sure roomn is defined
      fn socket.handshake.username
      unless not data.roomn or not utils.iss(data.roomn) or not cache[data.roomn.substring(1)]

        #Remove hash from url hash and make sure room isn't full
        data.roomn = data.roomn.substring(1)
        socket.roomn = data.roomn
        return smallKick("Room is full")  if io.clients(socket.roomn).length is cache[socket.roomn].limit
        socket.join socket.roomn
        io.in(socket.roomn).emit "joined",
          username: socket.handshake.username

        placeRobot socket.handshake.username, socket.roomn
        io.in(socket.roomn).emit "start"  if io.clients(socket.roomn).length is cache[socket.roomn].limit

    socket.on "sevent", shipdo #Ship event
    socket.on "disconnect", ->
      socket.leave socket.roomn
      io.in(socket.roomn).emit "left",
        username: socket.handshake.username

setInterval (->

  #Gets around me using rooms as an important variable
  require("../models/room").listRooms (result) ->
    _cache = {}
    result.forEach (i) ->
      delete i._id

      _cache[i.name] = i

    cache = _cache

), roomCache
