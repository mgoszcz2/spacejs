#External libs
cookielib = require 'cookie'
connect = require 'connect'
config = require '../config'
user = require '../models/user'

#Set up configs
ioLogLevel = config.ioLogLevel
canUseFlash = config.canUseFlash
secret = config.secret
sessionCookie = config.sessionCookie

module.exports = (io, sessionStore) ->
  #Socket IO config
  transports = [
    'websocket'
    'flashsocket'
    'htmlfile'
    'xhr-polling'
    'jsonp-polling'
  ]

  #Pop of flashsocet if we can't use it
  transports.pop 1  unless canUseFlash

  #DAMN. It's explicit now - set this to false and waste hours debugging
  io.enable 'heartbeats'
  io.enable 'browser client minification'
  io.enable 'browser client gzip'
  io.enable 'browser client etag'
  io.enable 'authorization' #Enable aut
  io.set 'log level', ioLogLevel
  io.set 'transports', transports

  #Socket IO global authorization

  #Shamelessly stolen from https://gist.github.com/bobbydavid/2640463
  io.set 'authorization', (data, accept) ->
    return accept('Please login', false)  unless data.headers.cookie
    cookie = cookielib.parse(data.headers.cookie)
    sessionID = connect.utils.parseSignedCookie(cookie[sessionCookie], secret)
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
  require('./rooms') io.of('/rooms')

  #Spend ages debuging it - It still said ./rooms
  require('./arena') io.of('/arena')
