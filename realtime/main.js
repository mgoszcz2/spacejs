/*External libs*/
var cookie = require('cookie');
var connect = require('connect');

var config = require('../config');

var ioLogLevel = config.ioLogLevel;
var canUseFlash = config.canUseFlash;
var secret = config.secret;
var sessionCookie = config.sessionCookie;

module.exports = function(io, sessionStore){
  /*Socket IO config*/
  var transports = ['websocket','flashsocket','htmlfile','xhr-polling','jsonp-polling'];
  //Pop of flashsocet if we can't use it
  if(!canUseFlash)
    transports.pop(1);

  //DAMN. It's explicit now - set this to false and waste hours debugging
  io.enable('heartbeats');
  io.enable('browser client minification');
  io.enable('browser client gzip');
  io.enable('browser client etag');
  io.set('log level', ioLogLevel);
  io.set('transports', transports);

  /*Socket IO global authorization*/
  //Shamelessly stolen from https://gist.github.com/bobbydavid/2640463
  io.set('authorization', function(data, accept){
    if (!data.headers.cookie)
      return accept('Please login', false);

    data.cookie = cookie.parse(data.headers.cookie);
    data.sessionID = connect.utils.parseSignedCookie(data.cookie[sessionCookie], secret);

    sessionStore.get(data.sessionID, function(error, session){
      if(error){
        accept('Internal error', false);
      }else if(!session){
        accept('Please login', false);
      }else{
        data.session = session;
        accept(null, true);
      }
    });
  });

  io.of('/rooms').on('connection', function(socket) {
    socket.emit('update', []);
  });
}
