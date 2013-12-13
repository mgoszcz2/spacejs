#Helper functions
xy = (x, y) ->
  x: x
  y: y
config = {}

#Port used by http server
config.port = 1024

#Mode - not used ATM
config.mode = 'development'

#Port used by mongodb
config.mongoPort = 1025

# Port used by redis
config.redisPort = 1026

#Bcrypt encryption cost
config.bcryptCost = 10

#Socket.IO log level
config.ioLogLevel = 1

#Can Socket.IO use flash
config.canUseFlash = true

#Session secret
config.secret = 'hello world is the secret'

#Session cookie name
config.sessionCookie = 'sid'

#Room cache time, ms
config.roomCache = 1000

#Size of the room
config.roomSize = xy 900, 800

#Max robot move in pixels
config.maxMove = 250

# Size of the avatar
config.avatarSize = xy 50, 50

#Robot starting postions
config.startPos = [
  xy 50, 50
  xy 50, config.roomSize.y - 50
  xy config.roomSize.x - 50, 50
  xy config.roomSize.x - 50, config.roomSize.y - 50
]
module.exports = config
