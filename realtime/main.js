/*External libs*/
var cookielib = require('cookie');
var connect = require('connect');

var config = require('../config');
var user = require('../models/user');

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
  io.enable('authorization'); //Enable aut
  io.set('log level', ioLogLevel);
  io.set('transports', transports);

  /*Socket IO global authorization*/
  //Shamelessly stolen from https://gist.github.com/bobbydavid/2640463
  io.set('authorization', function(data, accept){
    if (!data.headers.cookie)
      return accept('Please login', false);

    var cookie = cookielib.parse(data.headers.cookie);
    var sessionID = connect.utils.parseSignedCookie(cookie[sessionCookie], secret);

    sessionStore.get(sessionID, function(error, session){
      if(error){
        accept('Internal error', false);
      }else if(!session){
        accept('Please login', false);
      }else{
        user.getId(session.passport.user, function(userData){
          data.username = userData.username;
          data.userData = userData;
          accept(null, true);
        });
      }
    });
  });

  /*Require other realtime modules*/
  require('./rooms')(io.of('/rooms'));
  //Spend ages debuging it - It still said ./rooms
  require('./arena')(io.of('/arena'));
};
