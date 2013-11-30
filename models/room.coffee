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
db = server.db('master')
rooms = db.collection('rooms')
room = {}
module.exports = room
room.listRooms = (callback) ->
  rooms.find().toArray (error, array) ->
    utils.tryLog error, 'models/room.listRooms'
    callback array


room.addRoom = (name, limit) ->
  rooms.save
    name: name
    limit: limit

