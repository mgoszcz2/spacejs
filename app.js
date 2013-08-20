/*Custom libs*/
var utils = require('./libs/utils');
var config = require('./config')
var user = require('./models/user');

/*External libs*/
var express = require('express');
var colors = require('colors');
var jade  = require('jade');
var socket = require('socket.io');
var connect = require('connect');

/*Passport libs*/
var passport = require('passport');
var LocalStrategy = require('passport-local').Strategy;

/*Env variable set configs*/
var port = config.port;
var mode = config.mode;
var sessionCookie = config.sessionCookie;
var secret = config.secret;

/*Passport local strategy using user.login model*/
passport.use(new LocalStrategy({
    usernameField: 'id'
}, user.login));

/*Passport serialization*/
passport.serializeUser(function(user, done) {
    done(null, user._id.toString());
});
passport.deserializeUser(function(id, done) {
    user.getId(id, function(user) {
        done(null, user);
    });
});

/*Web server code*/
var app = express();

/*Akward stuff to make socket.io sessions work*/
var sessionStore = new connect.session.MemoryStore();
var sessionPref = {
    'secret': secret,
    'key': sessionCookie,
    'store': sessionStore
}

app.set('views', 'views');
app.set('view engine', 'jade');
app.locals.pretty = true; //Force jade to preety print everything
app.enable('strict routing');
app.enable('case sensitive routing');
app.enable('view cache');
app.use(express.compress());
app.use(express.cookieParser());
app.use(express.bodyParser());
app.use(express.session(sessionPref));
app.use(passport.initialize());
app.use(passport.session());
require('./routes/user')(app, passport);
require('./routes/main')(app);
app.use(app.router); //Make sure routes do their thing. See http://stackoverflow.com/questions/12695591
app.use(express.static('public')); //Use public as the static dir

/*WTF! socket.io website is all wrong - https://github.com/LearnBoost/socket.io/issues/941*/
var io = socket.listen(app.listen(port));
/*Socket.io configuration*/
require('./realtime/main')(io, sessionStore, secret);
