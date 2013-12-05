#Local libs
utils = require('../libs/utils')
config = require('../config')
mongoPort = config.mongoPort

#Mongolian set up
Mongolian = require('mongolian')
ObjectId = Mongolian.ObjectId
server = new Mongolian('127.0.0.1:' + mongoPort,
  log: {}
)

# Other set up
db = server.db('master')
rooms = db.collection('rooms')

# Module set up
room = {}
module.exports = room

# Get all rooms
room.listRooms = (callback) ->
  rooms.find().toArray (error, array) ->
    utils.tryLog error, 'models/room.listRooms'
    callback array

# Add a room
room.addRoom = (name, limit) ->
  rooms.save
    name: name
    limit: limit

# Get room with name
room.getRoom = (name, callback) ->
  rooms.findOne {name: name}, (error, room) ->
    utils.tryLog error, 'models/room.listRooms'
    callback room
