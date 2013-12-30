#External libs
cookielib = require 'cookie'
connect = require 'connect'
config = require '../config'
user = require '../models/user'
storage = require './storage'
utils = require '../libs/utils'
room = require '../models/room'




#Socket IO config
transports = [
  'websocket'
  'flashsocket'
  'htmlfile'
  'xhr-polling'
  'jsonp-polling'
]
#Pop of flashsocet if we can't use it
transports.pop 1 unless config.canUseFlash



# Get room list and update it fro globall use
rooms = new storage.Rooms
# Do not remove the function - bad things will happen
room.listRooms (data) -> rooms.updateData data #FTFY WTF?

module.exports = (io, sessionStore) ->
  #DAMN. It's explicit now - set this to false and waste hours debugging
  io.enable 'heartbeats'
  io.enable 'browser client minification'
  io.enable 'browser client gzip'
  io.enable 'browser client etag'
  io.enable 'authorization' #Enable aut
  io.set 'log level', config.ioLogLevel
  io.set 'transports', transports


  #Socket IO global authorization
  #Shamelessly stolen from https://gist.github.com/bobbydavid/2640463
  io.set 'authorization', (data, accept) ->
    return accept 'Please login', false  unless data.headers.cookie
    cookie = cookielib.parse data.headers.cookie
    sessionID = connect.utils.parseSignedCookie cookie[config.sessionCookie], config.secret
    sessionStore.get sessionID, (error, session) ->
      if error
        accept 'Internal error', false
      else unless session
        accept 'Please login', false
      else
        user.getId session.passport.user, (userData) ->
          if userData and userData.username
            data.username = userData.username
            data.userData = userData
            accept null, true
          else
            accept "Can't get user data", false




  #Require other realtime modules
  require('./rooms') io.of('/rooms'), rooms

  #Spend ages debuging it - It still said ./rooms
  require('./arena').main io.of('/arena'), rooms
