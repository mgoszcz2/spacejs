colors = require 'colors'
_ = require 'lodash'

module.exports = utils = {}

#Try to log if error evals to true
utils.tryLog = (err, msg) ->
  utils.extraLog err, msg, 'red', yes if err
  err is undefined

# Your general log
utils.log = (msg) -> utils.extraLog 'LOG', msg, 'green'

# Info log
utils.infoLog = (msg) -> utils.extraLog 'INFO', msg, 'yellow'

# Info log
utils.debugLog = (msg) -> utils.extraLog 'DEBUG', msg, 'red'

# Fully custom log
utils.extraLog = (tag, msg, color = 'green', bold = no) ->
  unless _.isString msg
    msg = JSON.stringify msg

  final = "(#{tag}) #{msg}"[color]
  final = final.bold if bold

  console.log final
