#Custom libs
utils = require './libs/utils'
config = require './config'
user = require './models/user'

#External libs
express = require 'express'
colors = require 'colors'
jade = require 'jade'
socket = require 'socket.io'

#Persistant session store
MongoStore = require('connect-mongo') express

#Passport libs
passport = require 'passport'
localStrategy = require('passport-local').Strategy

#Env variable set configs
port = config.port
mode = config.mode
sessionCookie = config.sessionCookie
secret = config.secret

#Passport local strategy using user.login model
passport.use new localStrategy {usernameField: 'id'}, user.login

#Passport serialization
passport.serializeUser (user, done) ->
  done null, user._id.toString()

passport.deserializeUser (id, done) ->
  user.getId id, (user) ->
    done null, user

#Web server code
app = express()

#Akward stuff to make socket.io sessions work (and also persistant sessions)
sessionStore = new MongoStore
  db: 'master'
  port: config.mongoPort
  collection: config.sessionCollection
sessionPref =
  secret: secret
  key: sessionCookie
  store: sessionStore

app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'
app.locals.pretty = true #Force jade to preety print everything
app.enable 'strict routing'
app.enable 'case sensitive routing'
#app.enable 'view cache'
app.use express.compress()
app.use express.cookieParser()
app.use express.bodyParser()
app.use express.session sessionPref
app.use passport.initialize()
app.use passport.session()
require('./routes/user') app, passport
require('./routes/main') app
app.use app.router #Make sure routes do their thing. See http://stackoverflow.com/questions/12695591
app.use express.static "#{__dirname}/public" #Use public as the static dir

#WTF! socket.io website is all wrong - https://github.com/LearnBoost/socket.io/issues/941
io = socket.listen app.listen(port), log: config.ioLogEnabled

#Socket.io configuration
(require './realtime/main') io, sessionStore, secret
