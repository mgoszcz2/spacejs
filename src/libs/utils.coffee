colors = require('colors')
utils = {}
module.exports = utils

#Try to log if error evals to true
utils.tryLog = (err, msg) ->
  if err
    console.log "[#{process.pid}] (#{err}) #{msg}".red.bold
    return false
  true

utils.log = (msg) ->
    console.log "[#{process.pid}] (LOG) #{msg}".green

utils.argArray = (arg) ->
  [].slice.call arg

utils.iss = (str) ->
  typeof str is 'string' or str instanceof String
