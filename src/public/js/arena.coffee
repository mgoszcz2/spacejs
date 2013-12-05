#Stack Overflow!

#Connection boilerplate

#No room error

#User - user management

#Set up ace

#Ace hiding
codeOff = ->
  $('#ready').hide()

  $('#code').animate height: '0%', 500, ->
    $('#logger').animate height: '30%', 500, ->
      log.log 'Logger started', 3



#Turn based stuff

#DRY
startTurn = ->
  try
    eval code
  catch e
    log.log e, 2

#Data handling
handleData = (data) ->
  turnData = data
  $('#arena').empty()
  for i of data
    if i is user
      ship.angle = data[i].angle
      ship.hitWall = ->
        data[i].hitwall
    i = data[i]
    console.log i
    $('<div>',
      class: 'robot'
    ).css(
      top: i.pos.y
      left: i.pos.x
    ).appendTo('#arena').rotate i.angle


jQuery.fn.rotate = (degrees) ->
  $(this).css
    '-webkit-transform': 'rotate(' + degrees + 'deg)'
    '-moz-transform': 'rotate(' + degrees + 'deg)'
    '-ms-transform': 'rotate(' + degrees + 'deg)'
    transform: 'rotate(' + degrees + 'deg)'

  return this

arena = io.connect 'http://localhost/arena', 'sync disconnect on unload': true
user = null

arena.socket.on 'error', (reason) ->
  console.error 'Unable to connect to the server:', reason

arena.on 'no_room', (data) ->
  console.log data, 2
  window.location.pathname = '/rooms.html'

arena.on 'joined', (data) ->
  log.log data + ' joined', 3

arena.on 'left', (data) ->
  log.log data + ' left', 3

editor = ace.edit('code')
editor.setTheme 'ace/theme/monokai'
editor.setHighlightActiveLine false
editor.setShowPrintMargin false
editor.getSession().setUseWorker false
editor.getSession().setMode 'ace/mode/javascript'
editor.insert (if localStorage.code then localStorage.code else '//Write your program here')
$('#code').css 'font-size', '16px'
code = undefined
turnData = undefined
$('#ready').click ->
  arena.emit 'join',
    roomn: window.location.hash
  , (data) ->
    user = data

  code = editor.getValue()
  localStorage.code = code
  codeOff()

arena.on 'start', (data) ->
  startTurn()

arena.on 'update', (data) ->
  handleData data
  startTurn()


#Friend-ish utils
utils = {}
ship =
  angle: 0
  hitWall: new Function()

gun = {}
queue = {}
radar = {}
utils.print = (str) ->
  if typeof str is 'string'
    log.log str, 0
  else
    log.log JSON.stringify(str), 0

utils.getDist = (a, b) ->
  Math.sqrt Math.pow(b.x - a.x, 2) + Math.pow(b.x - a.x, 2)

utils.getAngle = (a, b) ->
  deltaY = b.y - a.y
  deltaX = a.x - a.x
  Math.atan2(deltaY, deltaX) * 180 / Math.Pi

utils.makeRelative = (pos) ->
  (pos + ship.angle) % 360

ship.move = (num) ->
  num = 1  unless num
  queue.move = value: num

ship.turn = (num) ->
  num = 1  unless num
  queue.turn = value: num

ship.turnBy = (num) ->
  num = 1  unless num
  queue.turn = value: num + ship.angle

gun.turn = new Function()
gun.fire = new Function()
ship.ready = ->
  arena.emit 'sevent', queue
  queue = {}

radar.scan = (dist) ->
  dist = 1  unless dist
  res = []
  for i of turnData
    res.push turnData[i]
  res


#Logging util
log = {}
log.log = (str, lvl) ->
  $('<div>',
    class: [
      'log-info'
      'log-warn'
      'log-err'
      'log-ok'
    ][lvl]
    text: str
  ).prependTo '#logger'

log.clear = ->
  $('#logger').empty()
