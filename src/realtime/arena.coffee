config = require '../config'
utils = require '../libs/utils'
_ = require 'lodash'

maxMove = config.maxMove

# Export set up
arena = {}
module.exports = arena



# Just in case, PI becomes 4 (or something)
ROAUND_ANGLE = 360

# Make angle a non nagative value beetwen 0 and ROUND_ANGLE
makeValidAngle = (angle) -> Math.abs(angle) % ROAUND_ANGLE

# Check is something undefined
isDef = (value) -> value isnt undefined

# Check wether something is a nice number
isNiceNumber = (num) -> _.isFinite(num) and _.isNumber(num)

# Calc new postion from current postion assuimg angle and distance
calcNewPositon = (position, angle, dist) ->
    radAngle = makeValidAngle(angle) * (Math.PI / 180) #Make into radians
    position.x = (Math.sin(radAngle) * dist) + position.x
    position.y = (Math.cos(radAngle) * dist) + position.y
    return position


# Stores a new ship event (called sevent from scoket.io side)
class arena.Event
  # Construct Event accpets an object with the following struture
  # event = {
  #   turn: {value: N},
  #   move: {value: N}
  #   }
  constructor: (event) ->
    # Close call: God knows what could have happend if event.turn.value wasn't
    # a number
    if isDef(event.turn) and isDef(event.turn.value) and isNiceNumber(event.turn.value)
      @turn = event.turn.value
    if isDef(event.move) and isDef(event.move.value) and isNiceNumber(event.move.value)
      @move = event.move.value
    if isDef(event.fire) and isDef(event.fire.value) and isNiceNumber(event.fire.value)
      @fire = event.fire.value

  # Check wether properties exist
  hasTurn: -> isDef @turn
  hasMove: -> isDef @move
  hasFire: -> isDef @fire

  # Return properties
  getTurn: -> @turn
  getMove: -> @move
  getFire: -> @fire




# Data about ship postion known by the user
class arena.Userdata
  # Construct Userdata: 'count' is current user count: used to get start
  # position for the robot and possibly as uid. startPos contain start
  # positions for ceratin counts
  constructor: (@position, @avatarSize) ->
    @angle = 0
    @hitWall = no
    @done = no
    @dead = no
    @live = config.defaultLive

  # Update userdata using the ShipEvent event
  update: (event, roomSize) ->
    @_turn event.getTurn() if event.hasTurn()
    @_move event.getMove() if event.hasMove()
    @_hasHitWall roomSize

  #Take away life for event string as specfied in the config
  handleHit: (event) ->
    @live -= config.hitValues[event]
    @dead = yes if @live <= 0

  setDone: -> @done = yes
  unsetDone: -> @done = no
  isDone: -> @done

  # Turn by 'turn'
  _turn: (turn) ->
    @angle = makeValidAngle @angle + turn

  # Move dist far using current angle
  _move: (dist) ->
    realDist = if dist < maxMove and dist >= 0 then dist else maxMove
    @position = calcNewPositon @position, @angle, realDist

  # Update 'hitWall' property
  _hasHitWall: (roomSize) ->
    x = @position.x - (@avatarSize.x / 2)
    y = @position.y - (@avatarSize.y / 2)
    @hitWall = x <= 0 or x >= roomSize.x or y <= 0 or y >= roomSize.y

  # Used few places in the code
  getPosition: -> @position

  # Check wether dead
  isDead: -> @dead

  # Get a JSON of userdata
  jsonify: ->
    {
    angle: @angle
    hitWall: @hitWall
    dead: @dead
    pos:
      x: @position.x
      y: @position.y
    }




class arena.Bullet
  constructor: (@userName, @position, @angle) ->
    @turnSpanLeft = config.turnSpan
    @goneMark = no
    @hitWall = no

  setGoneMark: (value) ->
    @goneMark = value

  # Bullets are small: no need to care about the avatar size if it's close it hit the wall
  _hasHitWall: (roomSize) ->
    x = @position.x
    y = @position.y
    x <= 0 or x >= roomSize.x or y <= 0 or y >= roomSize.y

  update: (roomSize) ->
    @turnSpanLeft -= 1 if @turnSpanLeft isnt -1 #We took one turn
    @position = calcNewPositon @position, @angle, config.bulletMaxMove #Update the postion
    @_hasHitWall roomSize

  isGone: (roomSize) ->
    return yes if @turnSpanLeft is 0
    return yes if @goneMark
    return yes if @_hasHitWall roomSize
    return no

  hasHit: (pos) -> no #TODO: Add code

  jsonify: ->
    {
      angle: @angle
      pos:
        x: @position.x
        y: @position.y
    }




# Store and manage a room
class arena.Room
  # Set a room with limit
  constructor: (@limit, @roomSize, @startPos) ->
    @count = 0
    @users = {}
    @bullets = []

  # Rooms get user from room
  getUser: (userName) ->
    @users[userName]

  # Add a user to a room
  addUser: (userName, avatarSize) ->
    # Each user gets their own unique copy
    @users[userName] = new arena.Userdata _.cloneDeep(@startPos[@count]), avatarSize
    @count += 1

  # Make user leave the room
  leaveUser: (userName) ->
    delete @users[userName]
    @count -= 1

  # Check is room full
  isFull: -> @limit is @count

  # Manage done state
  allDone: ->
    doneCount = 0
    doneCount += 1 for n, userdata of @users when userdata.isDone()
    doneCount is @limit

  resetDone: ->
    userdata.unsetDone() for n, userdata of @users

  # Get stuff
  getCount: -> @count
  getLimit: -> @limit
  getRoomSize: -> @roomSize

  # Return nice JSON ready data for radar
  getAllUserData: ->
    data = []

    for name, userdata of @users
      userdata = userdata.jsonify()
      userdata.type = 'ship'
      userdata.name = name
      data.push userdata

    i = 0
    for bullet in @bullets
      bullet = bullet.jsonify()
      bullet.type = 'bullet'
      #Dash is not in valid username regex: /^\w{2,32}$/g
      bullet.name = "-bullet-#{i += 1}"
      data.push bullet

    return data

  addBullet: (bullet) ->
    @bullets.push bullet

  updateBullets: ->
    # Update all the positions
    newBullets = []
    for bullet in @bullets
      bullet.update @roomSize

      for name, userdata of @users
        if bullet.hasHit userdata.getPosition()
          userdata.handleHit 'bullet'
          bullet.setGoneMark yes

      newBullets.push bullet unless bullet.isGone @roomSize

    # Now with Gone stuff removed!
    @bullets = newBullets




# Manage all the rooms using a pseudo singelton
class arena.Rooms
  constructor: (@roomSize, @startPos) ->
    @rooms = {}

  # Update to add new rooms
  updateData: (@data, logUpdate = yes) ->
    # Let us know we did it
    if logUpdate
      utils.infoLog "Room data updated: #{@data.length} enteries"

    for r in @data
      unless isDef @rooms[r.name]
        @rooms[r.name] = new arena.Room r.limit, @roomSize, @startPos

  # Get a room with name
  get: (name) -> @rooms[name]
  has: (name) -> isDef @rooms[name]



# Data in the socket object:
# socket
#   roomn
#   handshake
#     username
#   tryleave
arena.main = (io) ->
  # Create singelton and update the info
  rooms = new arena.Rooms config.roomSize, config.startPos
  # Do not remove the function - bad things will happen
  require('../models/room').listRooms (data) -> rooms.updateData data #FTFY WTF?

  io.on "connection", (socket) ->
    roomName = socket.roomn #Ignore if not set we will re-set it anyway if so
    userName = socket.handshake.username #Change to camel case later

    socket.tryLeave = no #We haven't joined


    kick = (reason) ->
      utils.log "Kicking user #{userName}, reason: #{reason}"
      socket.emit "no_room", reason
      socket.disconnect()


    socket.on "isFull", (roomName, response) ->
      if rooms.has(roomName)
        response rooms.get(roomName).isFull()
      else
        kick "Invalid room name"


    socket.on "join", (data, acknowledge) ->
      acknowledge userName
      roomName = socket.roomn = data.roomn

      utils.log "#{userName} attempting to join #{roomName}"

      return kick "Invalid room name" unless rooms.has(roomName)
      return kick "Room is full" if rooms.get(roomName).isFull()

      currentRoom = rooms.get(roomName)
      currentRoom.addUser userName, config.avatarSize #Join the Room
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
      updateData = new arena.Event(event)
      user.update updateData, config.roomSize
      user.setDone()

      # and bullet data
      if updateData.hasFire()
        room.addBullet new arena.Bullet(userName, _.cloneDeep(user.getPosition()), updateData.getFire())

      # Check has everyone finished their move
      if room.allDone()
        room.resetDone()
        room.updateBullets()
        io.in(roomName).emit "update", room.getAllUserData()


    socket.on "disconnect", ->
      utils.extraLog 'USER', "Kicked #{userName}", 'cyan'

      # Do no try to leave a room with a kicked user
      # TODO: Make a special case when the user is confirmed to have been in a room
      if socket.tryleave
        utils.extraLog 'USER', "#{userName} left", 'cyan'

        rooms.get(roomName).leaveUser userName #Leave the Room
        socket.leave roomName # Leave socket.io room
        io.in(roomName).emit "left", {userName: userName} # Say he/she left
