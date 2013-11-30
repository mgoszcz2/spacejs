#External libs

#Local libs

#Mongolian set up

#Exports

#Check if user with following username exists

#Check if user with following email exists

#Check whether user exists with an id

#ObjectId takes in hex string and is a constructor

#Get username by their id and password,
#rewritten for passport.js localStrategy callback format
#Auth success
hashPassword = (password) ->
  bc.hashSync password, bcryptCost
bc = require('bcrypt')
utils = require('../libs/utils')
config = require('../config')
mongoPort = config.mongoPort
bcryptCost = config.bcryptCost
Mongolian = require('mongolian')
ObjectId = Mongolian.ObjectId
server = new Mongolian('127.0.0.1:' + mongoPort,
  log: new Object()
)
db = server.db('master')
users = db.collection('users')
user = {}
module.exports = user
user.checkName = (name, callback) ->
  users.findOne
    username: name
  , (err, user) ->
    utils.tryLog err, 'models/user.checkName'
    callback (if user then true else false)


user.checkEmail = (email, callback) ->
  users.findOne
    email: email
  , (err, user) ->
    utils.tryLog err, 'models/user.checkEmail'
    callback (if user then true else false)


user.getId = (id, callback) ->
  users.findOne
    _id: new ObjectId(id)
  , (err, user) ->
    utils.tryLog err, 'models/user.getId'
    callback user


user.login = (id, password, callback) ->
  users.findOne
    $or: [
      {
        email: id
      }
      {
        username: id
      }
    ]
  , (err, user) ->
    utils.tryLog err, 'models/users.login'
    unless user
      callback null, false
    else if bc.compareSync(password, user.password) is true
      callback null, user
    else
      callback null, false


user.register = (username, email, password) ->
  users.save
    username: username
    email: email
    password: hashPassword(password)

