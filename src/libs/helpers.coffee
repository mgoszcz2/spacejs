helpers = {}
module.exports = helpers

#JavaScript clojures techomagic - dir is added to closure. On failure user is
#redirected to dir
helpers.ensureLoged = (dir) ->
  (request, response, next) ->
    if request.user
      next()
    else
      response.redirect dir

helpers.ensureNew = (dir) ->
  (request, response, next) ->
    if request.user
      response.redirect dir
    else
      next()

helpers.addUserData = (request, response, next) ->
  response.locals.username = request.user.username
  next()
