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



# Stores a new ship event (called sevent from scoket.io side)
class arena.Event
  # Construct Event accpets an object with the following struture
  # event = {
  #   turn: {value: N},
  #   move: {value: N}
  #   }
  constructor: (event) ->
    @turn = event.turn.value if isDef(event.turn) and isDef(event.turn.value)
    @move = event.move.value if isDef(event.move) and isDef(event.move.value)

  # Check wether properties exist
  hasTurn: ->
    @turn isnt null and isDef @turn
  hasMove: ->
    @move isnt null and isDef @move

  # Return properties
  getTurn: -> @turn
  getMove: -> @move


# Data about ship postion known by the user
class arena.Userdata
  # Construct Userdata: 'count' is current user count: used to get start
  # position for the robot and possibly as uid. startPos contain start
  # positions for ceratin counts
  constructor: (@position, @avatarSize) ->
    @angle = 0
    @hitWall = no
    @done = no

  # Update userdata using the ShipEvent event
  update: (event, roomSize) ->
    @_turn event.getTurn() if event.hasTurn()
    @_move event.getMove() if event.hasMove()
    @_hasHitWall roomSize

  setDone: -> @done = yes
  unsetDone: -> @done = no
  isDone: -> @done

  # Turn by 'turn'
  _turn: (turn) ->
    @angle = makeValidAngle turn

  # Move dist far using current angle
  _move: (dist) ->
    realDist = if dist < maxMove and dist >= 0 then dist else maxMove
    radAngle = @angle * (Math.PI / 180) #Make into radians
    @position.x = (Math.sin(radAngle) * dist) + @position.x
    @position.y = (Math.cos(radAngle) * dist) + @position.y

  # Update 'hitWall' property
  _hasHitWall: (roomSize) ->
    x = @position.x - (@avatarSize.x / 2)
    y = @position.y - (@avatarSize.y / 2)
    @hitWall = x <= 0 or x >= roomSize.x or y <= 0 or y >= roomSize.y

  # Get a JSON of userdata
  jsonify: ->
    {
      angle: @angle
      hitWall: @hitWall
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

  # Rooms get user from room
  getUser: (username) ->
    @users[username]

  # Add a user to a room
  addUser: (username, avatarSize) ->
    # Each user gets their own unique copy
    @users[username] = new arena.Userdata _.cloneDeep(@startPos[@count]), avatarSize
    @count += 1

  # Make user leave the room
  leaveUser: (username) ->
    delete @users[username]
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
    data = {}
    for name, userdata of @users
      data[name] = userdata.jsonify()
    return data





# Manage all the rooms using a pseudo singelton
class arena.Rooms
  constructor: (@roomSize, @startPos) ->
    @rooms = {}

  # Update to add new rooms
  updateData: (@data, logUpdate = yes) ->
    # Let us know we did it
    if logUpdate
      utils.log "realtime.Rooms#updateData", "Room data updated: #{@data.length} enteries"

    for r in @data
      unless isDef @rooms[r.name]
        @rooms[r.name] = new arena.Room r.limit, @roomSize, @startPos

  # Get a room with name
  get: (name) -> @rooms[name]
  has: (name) -> isDef @rooms[name]




arena.main = (io) ->
  # Create singelton and update the info
  rooms = new arena.Rooms config.roomSize, config.startPos
  # Do not remove the function - bad things will happen
  require('../models/room').listRooms (data) -> rooms.updateData data #FTFY WTF?

  io.on "connection", (socket) ->
    roomName = socket.roomn #Ignore if not set we will re-set it anyway if so
    username = socket.handshake.username


    kick = (str) ->
      socket.emit "no_room", str
      socket.disconnect()


    socket.on "join", (data, acknowledge) ->
      uitls.log "realtime/arena#main (on join)", "#{username} joined"
      acknowledge socket.handshake.username
      roomName = socket.roomn = data.roomn.substring 1 #Remove hash from url

      return kick "Invalid room name" unless rooms.has(roomName)
      return kick "Room is full" if rooms.get(roomName).isFull()

      rooms.get(roomName).addUser username, config.avatarSize #Join the Room
      socket.join roomName #Join this socket.io room
      io.in(roomName).emit "joined", {username: username} #Say he/she joined

      io.in(roomName).emit "start" if rooms.get(roomName).isFull()


    socket.on 'sevent', (event) -> #Ship event
      user = rooms.get(roomName).getUser(username)
      user.update new arena.Event(event), config.roomSize
      user.setDone()

      # Check has everyone finished their move
      if rooms.get(roomName).allDone()
        rooms.get(roomName).resetDone()
        io.in(roomName).emit "update", rooms.get(socket.roomn).getAllUserData()


    socket.on "disconnect", ->
      rooms.get(roomName).leaveUser username #Leave the Room
      socket.leave roomName # Leave socket.io room
      io.in(roomName).emit "left", {username: username} # Say he/she left
