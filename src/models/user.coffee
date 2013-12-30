hashPassword = (password) ->
  bc.hashSync password, config.bcryptCost

#Prep libs
bc = require 'bcrypt'
utils = require '../libs/utils'
config = require '../config'
Mongolian = require 'mongolian'


#Mongolian set up
server = new Mongolian('127.0.0.1:' + config.mongoPort,
  log: new Object()
)
db = server.db 'master'
users = db.collection 'users'


#Exports
user = {}
module.exports = user


#Check if user with following username exists
user.checkName = (name, callback) ->
  users.findOne username: name, (err, user) ->
    utils.tryLog err, 'models/user.checkName'
    callback (if user then true else false)


#Check if user with following email exists
user.checkEmail = (email, callback) ->
  users.findOne email: email, (err, user) ->
    utils.tryLog err, 'models/user.checkEmail'
    callback (if user then true else false)


#Check whether user exists with an id
user.getId = (id, callback) ->
  users.findOne _id: new Mongolian.ObjectId(id), (err, user) ->
    utils.tryLog err, 'models/user.getId'
    callback user


#Get username by their id and password,
#rewritten for passport.js localStrategy callback format
#Auth success
user.login = (id, password, callback) ->
  users.findOne $or: [{email: id}, {username: id}], (err, user) ->
    utils.tryLog err, 'models/users.login'
    unless user
      callback null, false
    else if bc.compareSync(password, user.password) is true
      callback null, user
    else
      callback null, false


# Register a new user
user.register = (username, email, password) ->
  users.save
    username: username
    email: email
    password: hashPassword(password)
