/*Custom libs*/
var utils = require('./libs/utils');
var config = require('./config')
var user = require('./models/user');

/*External libs*/
var express = require('express');
var colors = require('colors');
var jade  = require('jade');

/*Passport libs*/
var passport = require('passport');
var LocalStrategy = require('passport-local').Strategy;

/*Env variable set configs*/
var port = config.port;
var mode = config.mode;

/*Passport local strategy using user.login model*/
passport.use(new LocalStrategy({
    usernameField: 'id'
}, user.login));

/*Passport serialization*/
passport.serializeUser(function(user, done) {
    done(null, user._id);
});
passport.deserializeUser(function(id, done) {
    console.log('Deser', id);
    user.getId(id, function(user) {
        console.log('Deser-dat', user);
        done(null, user);
    });
});

/*Web server code*/
var app = express();
app.set('views', 'views');
app.set('view engine', 'jade');
app.use(express.cookieParser());
app.use(express.bodyParser());
app.use(express.session({
    'secret': 'mgoszcz2 mostly random secret',
    'key': 'sid'
}));
app.use(passport.initialize());
app.use(passport.session());
require('./routes/user')(app, passport);
require('./routes/main')(app);
app.use(express.static('public')); //Use public as the static dir
app.listen(port);
