config = require '../config'
utils = require '../libs/utils'
storage = require './storage'
_ = require 'lodash'

maxMove = config.maxMove

# Export set up
arena = {}
module.exports = arena




# Data in the socket object:
# socket
#   roomn
#   handshake
#     username
#   tryleave
arena.main = (io, rooms) ->
  io.on "connection", (socket) ->
    roomName = socket.roomn #Ignore if not set we will re-set it anyway if so
    userName = socket.handshake.username #Change to camel case later

    socket.tryLeave = no #We haven't joined

    kick = (reason) ->
      utils.log "Kicking user #{userName}, reason: #{reason}"
      socket.emit 'kick', reason
      socket.disconnect()


    socket.on "isFull", (roomName, response) ->
      if rooms.has(roomName)
        response rooms.get(roomName).isFull()
      else
        kick "Invalid room name"


    socket.on "join", (data, acknowledge) ->
      acknowledge userName
      roomName = socket.roomn = data.roomn

      utils.extraLog 'USER', "#{userName} attempting to join #{roomName}", 'cyan'

      return kick "Invalid room name" unless rooms.has(roomName)
      return kick "Room is full" if rooms.get(roomName).isFull()

      currentRoom = rooms.get(roomName)
      return kick "You already joined" if currentRoom.hasUser(userName)

      currentRoom.addUser userName, config.avatarSize #Join the Room
      rooms.hasChanged() #Notify things chnaged in rooms
      socket.join roomName #Join this socket.io room
      io.in(roomName).emit "joined", {userName: userName} #Say he/she joined

      socket.tryLeave = yes #Try to leave
      joinedFraction = "#{currentRoom.getCount()}/#{currentRoom.getLimit()}"
      utils.extraLog 'USER', "#{userName} joined #{roomName} (#{joinedFraction})", 'cyan'

      # Update is a like old 'start'
      if rooms.get(roomName).isFull()
        utils.infoLog "Game in #{roomName} started!"
        io.in(roomName).emit "update", rooms.get(socket.roomn).getAllUserData() 


    socket.on 'sevent', (event) -> #Ship event
      room = rooms.get roomName
      user = room.getUser userName

      #Dont' to anything if done already
      return if user.isDone()

      # Update user...
      updateData = new storage.Event(event)
      user.update updateData, config.roomSize
      user.setDone()

      # and bullet data
      if updateData.hasFire()
        room.addBullet new storage.Bullet(userName, _.cloneDeep(user.getPosition()), updateData.getFire())

      # Check has everyone finished their move
      if room.allDone()
        room.resetDone()
        room.updateBullets()
        io.in(roomName).emit "update", room.getAllUserData()


    socket.on "disconnect", ->
      utils.extraLog 'USER', "Kicked #{userName}", 'cyan'

      # Do no try to leave a room with a kicked user
      # TODO: Make a special case when the user is confirmed to have been in a room
      if socket.tryLeave
        utils.extraLog 'USER', "#{userName} left #{roomName}", 'cyan'

        rooms.get(roomName).leaveUser userName #Leave the Room
        rooms.hasChanged() #Notify things chnaged in rooms
        socket.leave roomName # Leave socket.io room
        io.in(roomName).emit "left", {userName: userName} # Say he/she left
