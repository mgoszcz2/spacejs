# Helper functions
xy = (x, y) ->
  x: x
  y: y
config = {}

# Port used by http server
config.port = 1024

# Mode - not used ATM
config.mode = 'development'

# Port used by mongodb
config.mongoPort = 1025

# Session collection
config.sessionCollection = 'sessions'

# Bcrypt encryption cost
config.bcryptCost = 10

# Socket.IO log level
config.ioLogLevel = 1

# Should Socket.IO log anything
config.ioLogEnabled = no

# Can Socket.IO use flash
config.canUseFlash = no

# Session secret
config.secret = 'hello world is the secret'

# Session cookie name
config.sessionCookie = 'sid'

# Size of the room
config.roomSize = xy 300, 300

# Max robot move in pixels
config.maxMove = 10

# Size of the avatar
config.avatarSize = xy 50, 50

# Default turn/time span for a bullet (-1 for Inf)
config.turnSpan = -1

# Distance for bullets to move each turn (preferable same as config.maxMove)
config.bulletMaxMove = config.maxMove + 10

# Default life for a user
config.defaultLive = 100

# Userdata hit values
config.hitValues =
  bullet: 20

# Robot starting postions
config.startPos = [
  xy 50, 50
  xy 50, config.roomSize.y - 50
  xy config.roomSize.x - 50, 50
  xy config.roomSize.x - 50, config.roomSize.y - 50
]
module.exports = config
