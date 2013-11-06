/*Local libs*/
var utils = require('../libs/utils');
var config = require('../config');

var mongoPort = config.mongoPort;

/*Mongolian set up*/
var Mongolian = require('mongolian');
var ObjectId = Mongolian.ObjectId;
var server = new Mongolian('127.0.0.1:'+mongoPort, {'log': {}});
var db = server.db("master");
var rooms = db.collection('rooms');

var room = {};
module.exports = room;

room.listRooms = function(callback){
  rooms.find().toArray(function(error, array){
    utils.tryLog(error, "models/room.listRooms");
    callback(array);
  });
};

room.addRoom = function(name, limit){
  rooms.save({'name': name, 'limit': limit});
};
