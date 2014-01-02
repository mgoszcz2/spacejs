config = require '../config'
utils = require '../libs/utils'
_ = require 'lodash'
EventEmitter = require('events').EventEmitter

# Prepare exports
storage = {}
module.exports = storage

# Check is something undefined TODO: Now use the ? operator
isDef = (value) -> value isnt undefined

# Just in case, PI becomes 4 (or something)
ROAUND_ANGLE = 360

# Make angle a non nagative value beetwen 0 and ROUND_ANGLE
makeValidAngle = (angle) -> Math.abs(angle) % ROAUND_ANGLE

# Check wether something is a nice number
isNiceNumber = (num) -> _.isFinite(num) and _.isNumber(num)

# Calc new postion from current postion assuimg angle and distance
calcNewPositon = (position, angle, dist) ->
    radAngle = makeValidAngle(angle) * (Math.PI / 180) #Make into radians
    position.x = (Math.sin(radAngle) * dist) + position.x
    position.y = (Math.cos(radAngle) * dist) + position.y
    return position

getDist = (a, b) ->
  Math.sqrt Math.pow(b.x - a.x, 2) + Math.pow(b.y - a.y, 2)

# Stores a new ship event (called sevent from scoket.io side)
class storage.Event
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
class storage.Userdata
  # Construct Userdata: 'count' is current user count: used to get start
  # position for the robot and possibly as uid. startPos contain start
  # positions for ceratin counts
  constructor: (@position, @avatarSize) ->
    @angle = 0
    @hitWall = no
    @done = no
    @dead = no
    @life = config.defaultLive

  # Update userdata using the ShipEvent event
  update: (event, roomSize) ->
    # Keep old data..
    oldPosition = _.cloneDeep @position
    oldHitWall = @hitWall

    # Allow user to move..
    @_turn event.getTurn() if event.hasTurn()
    @_move event.getMove() if event.hasMove()
    @hitWall = @_hasHitWall roomSize

    # Jump back if hit wall but only if you waren't there already
    # this allosw to get to the wall in the first place
    @position = oldPosition if @hitWall and oldHitWall

  #Take away life for event string as specfied in the config
  handleHit: (event) ->
    @life -= config.hitValues[event]
    @dead = yes if @life <= 0

  setDone: -> @done = yes
  unsetDone: -> @done = no
  isDone: -> @done

  # Turn by 'turn'
  _turn: (turn) ->
    @angle = makeValidAngle @angle + turn

  # Move dist far using current angle
  _move: (dist) ->
    realDist = if dist < config.maxMove and dist >= 0 then dist else config.maxMove
    @position = calcNewPositon @position, @angle, realDist

  # Update 'hitWall' property
  _hasHitWall: (roomSize) ->
    return yes if @position.x + @avatarSize.x >= roomSize.x
    return yes if @position.y + @avatarSize.y >= roomSize.y

    # Left and top edges
    # No need to play with @avatarSize - already top left conrer of the avatar
    return yes if @position.y <= 0
    return yes if @position.x  <= 0

    # Nothing happend here
    return no

  # Used few places in the code
  getPosition: -> @position
  getAngle: -> @angle
  getOriginPosition: ->
    {
      x: (@avatarSize.x / 2) + @position.x
      y: (@avatarSize.y / 2) + @position.y
    }
  # Leave here just in case
  getFrontTipPositon: ->
    pos = calcNewPositon @getOriginPosition(), @angle, (@avatarSize.y / 2)
    {
      x: pos.x
      y: pos.y
    }

  # Check wether dead
  isDead: -> @dead

  getAvatarSize: -> @avatarSize

  # Get a JSON of userdata
  jsonify: ->
    {
    angle: @angle
    hitWall: @hitWall
    dead: @dead
    life: @life
    pos:
      x: @position.x
      y: @position.y
    }




class storage.Bullet
  constructor: (@userName, @position, @angle, @id) ->
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

  hasHit: (pos, avatarSize) ->
    if getDist(@position, pos) <= (avatarSize.x / 2)
      return yes
    return no

  getUserName: -> @userName
  getID: -> @id
  getPosition: -> @position

  jsonify: ->
    {
      angle: @angle
      name: @userName
      id: @id
      pos:
        x: @position.x
        y: @position.y
    }




# Store and manage a room
class storage.Room
  # Set a room with limit
  constructor: (@limit, @roomSize, @startPos) ->
    @count = 0
    @pleft = @limit
    @started = no
    @users = {}
    @bullets = []
    @lastID = -1
    @died = []

  # Checking wether done
  hasLastUser: -> @started and @pleft is 1

  # Rooms get user from room
  getUser: (userName) ->
    @users[userName]

  # Add a user to a room
  addUser: (userName, avatarSize) ->
    # Each user gets their own unique copy
    @users[userName] = new storage.Userdata _.cloneDeep(@startPos[@count]), avatarSize
    @count += 1

  hasUser: (userName) -> @users[userName]?

  # Make user leave the room
  leaveUser: (userName) ->
    delete @users[userName]
    @pleft -= 1
    # If this was the last player ready the room
    if @pleft is 0
      @count = 0
      @users = {}
      @bullets = []
      @pleft = @limit

  getUserCount: -> Object.keys(@users).length

  # Check is room full
  isFull: -> @limit is @count

  # Manage done state
  allDone: ->
    doneCount = 0
    doneCount += 1 for n, userdata of @users when userdata.isDone()

    done = doneCount is @pleft #Amount of players left
    @started = yes if done unless @started
    return done #F*** make sure we still return the status

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

    for bullet in @bullets
      bullet = bullet.jsonify()
      bullet.type = 'bullet'
      #Dash is not in valid username regex: /^\w{2,32}$/g
      bullet.name = "-bullet-#{bullet.id}"
      data.push bullet

    # 'zombie-bullet' entity! show bullet's to be deleted
    # Thanks. Alice Barrett for the suggesestion
    for bullet in @died
      bullet = bullet.jsonify()
      bullet.type = 'zombie-bullet'
      # Name stays the same so it can be removed
      bullet.name = "-bullet-#{bullet.id}"
      data.push bullet

    return data

  addBullet: (userName, pos, angle) ->
    @bullets.push new storage.Bullet(userName, pos, angle, @lastID += 1)

  updateBullets: ->
    # No bullets have died... until this point
    @died = []

    # Update all the positions
    newBullets = []
    for bullet in @bullets
      bullet.update @roomSize

      for name, userdata of @users when bullet.getUserName() isnt name
        if bullet.hasHit userdata.getOriginPosition(), userdata.getAvatarSize()
          userdata.handleHit 'bullet'
          bullet.setGoneMark yes

      if bullet.isGone @roomSize
        @died.push bullet
      else
        # Cheating... jsonify() also returns 'pos'
        newBullets.push bullet

    # Now with Gone stuff removed!
    @bullets = newBullets




# Manage all the rooms using a pseudo singelton
class storage.Rooms
  constructor: ->
    @rooms = {}
    @cache = []
    @events = new EventEmitter()

  # Update to add new rooms
  updateData: (data, logUpdate = yes) ->
    # Let us know we did it
    if logUpdate
      utils.infoLog "Room data updated: #{data.length} enteries"

    for r in data
      unless @rooms[r.name]?
        @rooms[r.name] = new storage.Room r.limit, config.roomSize, config.startPos
    @jsonify yes

  # We should invalidate cache and broadcast 'change' event
  hasChanged: ->
    # Freakin! Jsonify before emitting the event
    @jsonify yes
    @events.emit 'change'

  # Get a room with name
  get: (name) -> @rooms[name]
  has: (name) -> isDef @rooms[name]

  # This functions needs to be cached! It's used on each new /rooms.html requst
  jsonify: (force = no) ->
    return @cache unless force

    newCache = []
    for name, room of @rooms
      newCache.push
        name: name
        limit: room.getLimit()
        taken: room.getCount()

    @cache =  newCache
