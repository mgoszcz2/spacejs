user = require('../models/user')
utils = require('../libs/utils')
helpers = require('../libs/helpers')

#Note to self: Do not fall-back if POST data absent: Unless someone is
#messing with the system, the fields will always be present
module.exports = (app, passport) ->
  #passport.js technomagic - It's wonderful but it doesn't seem to
  #    work to well with whikser templates even using 'flash-connect' lib,
  #    the workaround is to use a fancy callback system and use native rendering
  #    system
  app.post '/login.html', helpers.ensureNew('/rooms.html'), (request, response, next) ->
    passport.authenticate('local', (err, user, info) ->
      utils.tryLog err, 'routes/user.post(/login)'
      utils.log "User #{user} is trying to login"
      unless user
        response.render 'login',
          error: true

      else
        request.logIn user, (err) ->
          if err
            utils.tryLog err, 'routes/user.post(/login){request.logIn}'
          else
            utils.log "User #{user} logged in"
            response.redirect 'rooms.html'

    ) request, response, next


  #Server side verification of login - errors store error states which get
  #    toggled during error checking
  app.post '/register.html', helpers.ensureNew('/rooms.html'), (request, response) ->
    errors =
      misstype: false
      hasEmail: false
      hasName: false
      badName: false
      badEmail: false
      badPass: false

    username = request.body.username
    password = request.body.password
    password2 = request.body.password2
    email = request.body.email

    if username? and email? and password? and password2?
      errors.misstype = true unless password is password2
      errors.badPass = true unless /^[\w ]{6,}$/g.test(password) #Words and spaces min 6
      errors.badName = true unless /^\w{2,32}$/g.test(username) #Just words min 2, max 32
      errors.badEmail = true unless /^([a-z0-9_\.\+-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/g.test(email) #Email
      user.checkName username, (_hN) ->
        errors.hasName = _hN
        user.checkEmail email, (_hE) ->
          errors.hasEmail = _hE

          #We validated the shit out of registration data - make decision
          if errors.misstype or errors.hasEmail or errors.hasName or errors.badName or errors.badEmail or errors.badPass

            #Add additional data to error data to help out register 
            errors.error = {}
            # Start with f to prevent conflicting with base template
            errors.fusername = username
            errors.fpassword = password
            errors.fpassword2 = password2
            errors.femail = email

            # Nice logging
            utils.log "User failed to register data: #{username}:#{email}"

            response.render 'register', errors
          else
            utils.log "User #{username} (#{email}) registred"
            user.register username, email, password
            response.redirect '/login.html'



  app.get '/logout.html', helpers.ensureLoged('/'), (request, response) ->
    request.logout()
    response.redirect '/'

  #Oh.. Express.. Why can't you figure this out for yourself
  app.get '/login.html', helpers.ensureNew('/rooms.html'), (request, response) ->
    response.render 'login',
      error: false


  app.get '/register.html', helpers.ensureNew('/rooms.html'), (request, response) ->
    response.render 'register',
      error: false


