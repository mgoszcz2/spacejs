module.exports = (app) ->
  helpers = require('../libs/helpers')
  app.get '/rooms.html', helpers.ensureLoged('/'), helpers.addUserData, (request, response) ->
    response.render 'rooms'

  app.get '/arena.html', helpers.ensureLoged('/'), helpers.addUserData, (request, response) ->
    response.render 'arena'

  app.get '/', helpers.ensureNew('/rooms.html'), (request, response) ->
    response.render 'index'

  app.get '/spec.html', (request, response) ->
    response.render 'spec'

