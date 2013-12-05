colors = require('colors')
module.exports = utils = {}

#Try to log if error evals to true
utils.tryLog = (err, msg) ->
  utils.extraLog err, msg, 'red', yes if err
  err is undefined

# Your general log
utils.log = (msg) -> utils.extraLog 'LOG', msg, 'green'

# Info log
utils.infoLog = (msg) -> utils.extraLog 'INFO', msg, 'yellow'

# Fully custom log
utils.extraLog = (tag, msg, color = 'green', bold = no) ->
  final = "(#{tag}) #{msg}"[color]
  final = final.bold if bold

  console.log final
