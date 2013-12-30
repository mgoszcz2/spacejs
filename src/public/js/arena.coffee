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
class Entitydata
  constructor: (@data) ->
    @position = new Position @data.pos
  getName: -> @data.name
  getType: -> @data.type
  getAngle: -> @data.angle
  getPosition: -> @position
  hasHitWall: -> @data.hitWall #TODO: We could do this on the client side




# Keep track of current turn
class Queue
  constructor: ->
    @_turn = null
    @_move = null
    @_fire = null

  reset: ->
    @_turn = null
    @_move = null
    @_fire = null

  resetTurn: -> @_turn = null

  turn: (deg) -> @_turn += deg
  move: (steps) -> @_move += steps
  fire: (deg) -> @_fire = deg

  jsonify: ->
    data = {}
    data.move = value: @_move if @_move?
    data.fire = value: @_fire if @_fire?
    data.turn = value: @_turn if @_turn?
    console.log this, data
    return data




# Polyfill for window.location.origin support
unless window.location.origin?
  window.location.origin = "#{window.location.protocol}//#{window.location.hostname}"
  window.location.origin += ":#{window.location.host}" if window.location.host

# Try to send disconnect signal on unload
arena = io.connect "#{window.location.origin}/arena", 'sync disconnect on unload': true

# Queue singleton
queue = new Queue

# Has the game started yet
started = no




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

  $('footer').hide() # Hide the footer


revalCode = (code) ->
  try
    eval code
  catch e
    log.log "#{e.message}:\n#{e.stack}", 2

# Get room name
getRoomName = -> window.location.hash.substring 1
ROAUND_ANGLE = 360
makeValidAngle = (angle) -> Math.abs(angle) % ROAUND_ANGLE





user = null


editor =
  instance: ace.edit('code')

  prepareEditor: ->
    ed = editor.instance
    ed.getSession().setUseWorker false #No lint
    ed.setHighlightActiveLine true #Show current line
    ed.renderer.setShowGutter false #No line numbers
    ed.getSession().setMode 'ace/mode/javascript'
    ed.setTheme 'ace/theme/tomorrow'
    ed.insert(if localStorage.code then localStorage.code else '//Write your program here')

  getValue: ->
    editor.instance.getValue()


  disableEditor: ->
    $(codeSelector).addClass 'height_hidden'
    $(loggerSelector).removeClass 'height_hidden'
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
arena.on 'kick', (data) ->
  alert data
  window.location.pathname = '/rooms.html'


animateEnitytDiv = (entity) ->
  $entityDiv = $(".#{entity.getName()}")

  return addEntityDiv entity if $entityDiv.length is 0

  $entityDiv.animate(
      top: entity.getPosition().getY()
      left: entity.getPosition().getX()
    , 300)

  $(deg: $entityDiv.data('angle')).animate deg: entity.getAngle(),
    duration: 300
    step: (now) -> $entityDiv.css transform: "rotate(-#{now}deg)"

  $entityDiv.data 'angle', makeValidAngle entity.getAngle()

addEntityDiv = (entity) ->
  $('<div>', class: "#{entity.getType()} #{entity.getName()}").css(
    top: entity.getPosition().getY()
    left: entity.getPosition().getX()
    transform: "rotate(-#{entity.getAngle()}deg)"
  ).appendTo('#arena').data 'angle', makeValidAngle entity.getAngle()




# Board changed
arena.on 'update', (data) ->
  for entity in data
    entity = new Entitydata entity

    # If we are ourself capture the data onto the ship object
    if entity.getType() is 'ship' and entity.getName() is user
      ship.angle = entity.getAngle()
      ship.hitWall = entity.hasHitWall()
      ship.position = entity.getPosition()

    if started then animateEnitytDiv entity
    else addEntityDiv entity

  # Now that we are done, say we are started!
  started = yes

  # Wait for all the animations to finish
  setTimeout(->
      revalCode editor.getValue()
    , 300)




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
  angle: 0
  fire: -> queue.fire gun.angle
  turn: (num) -> gun.angle = num


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
