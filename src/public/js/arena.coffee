# Position data
# use {x, y}
# or as n, n
class Position
  constructor: (pos, other = null) ->
    if other is null
      {@x, @y} = pos
    else
      @x = pos
      @y = other
  getX: -> @x
  getY: -> @y
  jsonify: ->
    {
    x: @x
    y: @y
    }




# Single unit of data
class Shipdata
  constructor: (@name, @data) ->
    @position = new Position @data.pos
  getName: -> @name
  getAngle: -> @data.angle
  getPosition: -> @position
  hasHitWall: -> @data.hitWall #TODO: We could do this on the client side




# Keep track of current turn
class Queue
  constructor: ->
    @_turn = 0
    @_move = 0

  reset: ->
    @_turn = 0
    @_move = 0

  resetTurn: -> @_turn = 0

  turn: (deg) -> @_turn += deg
  move: (steps) -> @_move += steps

  jsonify: ->
    {
    move: {value: @_move}
    turn: {value: @_turn}
    }




# Try to send disconnect signal on unload
arena = io.connect 'http://localhost/arena', 'sync disconnect on unload': true

# Queue singleton
queue = new Queue



# jQuery selectors for common elements
arenaSelector = '#arena'
logSelector = '#logger'
codeSelector = '#code'
loggerSelector = '#logger'




$ ->
  editor.prepareEditor() # Set ACE up

  # Notify nicely if room is full
  arena.emit 'isFull', getRoomName(), (isFull) ->
    alert "Room is Full!" if isFull


revalCode = (code) ->
  try
    eval code
  catch e
    log.log "#{e.message}:\n#{e.stack}", 2

# Get room name
getRoomName = -> window.location.hash.substring 1





# jQuery rotate plugin
jQuery.fn.rotate = (degrees) ->
  $(this).css
    '-webkit-transform': 'rotate(' + degrees + 'deg)'
    '-moz-transform': 'rotate(' + degrees + 'deg)'
    '-ms-transform': 'rotate(' + degrees + 'deg)'
    transform: 'rotate(' + degrees + 'deg)'

  return this

user = null


editor =
  instance: ace.edit('code')

  prepareEditor: ->
    ed = editor.instance
    ed.setTheme 'ace/theme/monokai'
    ed.setHighlightActiveLine false
    ed.setShowPrintMargin false
    ed.getSession().setUseWorker false
    ed.getSession().setMode 'ace/mode/javascript'
    ed.insert(if localStorage.code then localStorage.code else '//Write your program here')

  getValue: ->
    editor.instance.getValue()


  disableEditor: ->
    $(codeSelector).animate height: '0%', 500, ->
      $(loggerSelector).animate height: '30%', 500, ->
        log.log 'Logger started', 3

$('#ready').click ->
  arena.emit 'join',
    roomn: getRoomName()
  , (data) ->
    user = data

  code = editor.getValue()

  # UI stuff
  localStorage.code = code
  $('#ready').hide()
  editor.disableEditor()

  revalCode code




# Socket event
arena.socket.on 'error', (reason) ->
  console.error 'Unable to connect to the server:', reason

# General USER events
arena.on 'joined', (data) ->
  log.log "#{data} joined", 3
arena.on 'left', (data) ->
  log.log "#{data} left", 3

# Make this nicer
arena.on 'no_room', (data) ->
  console.log data, 2
  window.location.pathname = '/rooms.html'

# Board changed
arena.on 'update', (data) ->
  $(arenaSelector).empty()

  for name, value of data
    iship = new Shipdata name, value
    if iship.getName() is user
      ship.angle = iship.getAngle()
      ship.hitWall = iship.hasHitWall()
      ship.position = iship.getPosition()

    $('<div>',
      class: 'robot'
    ).css(
      top: iship.getPosition().getY()
      left: iship.getPosition().getX()
    ).appendTo('#arena').rotate iship.getAngle()

  revalCode editor.getValue()




# General utilities
utils =
  print: (str) ->
    if typeof str is 'string'
      log.log str, 0
    else
      log.log JSON.stringify(str), 0

  # Get distance beetwen two Position's
  getDist: (a, b) ->
    Math.sqrt Math.pow(b.getX() - a.getX(), 2) + Math.pow(b.getY() - a.getY(), 2)

  # Get angle beetwen two Position's
  getAngle: (a, b) ->
    deltaY = b.getY() - a.getY()
    deltaX = a.getX() - a.getX()
    Math.atan2(deltaY, deltaX) * 180 / Math.Pi

  # Make a absolute angle (e.g. turn) to relative (e.g. TurnBy)
  makeRelative: (pos) ->
    (pos + ship.angle) % 360


# Gun controll
gun =
  fire: -> null
  turn: -> null


# Main event loop
ship =
  ready: ->
    arena.emit 'sevent', queue.jsonify()
    queue.reset()

  turn: (num) ->
    queue.resetTurn()
    queue.turn num
  turnBy: (num) ->
    queue.turn num
  move: (num) ->
    queue.move num

  angle: 0
  hitWall: false
  position: new Position 0, 0


# Radar API
radar =
  scan: (dist) ->
    #TODO: Use dist somehow
    turn.getRaw()


#Logging util
log =
  lvls: [
    'log-info'
    'log-warn'
    'log-err'
    'log-ok'
  ]

  log: (str, lvl) ->
    $('<div>',
      class: log.lvls[lvl]
      text: str
    ).prependTo logSelector

   clear: ->
    $(logSelector).empty()
