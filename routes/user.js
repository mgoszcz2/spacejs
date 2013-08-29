/*Note to self: Do not fall-back if POST data absent: Unless someone is
messing with the system, the fields will always be present*/

module.exports = function(app, passport){
    var user = require('../models/user');
    var utils = require('../libs/utils');
    var helpers = require('../libs/helpers');

    /*passport.js technomagic - It's wonderful but it doesn't seem to
    work to well with whikser templates even using 'flash-connect' lib,
    the workaround is to use a fancy callback system and use native rendering
    system*/
    app.post('/login.html', helpers.ensureNew('/rooms.html'), function(request, response, next) {
        passport.authenticate('local', function(err, user, info) {
            utils.tryLog(err, "routes/user.post(/login)");
            if(!user){
                response.render('login', {'error': true});
            }else{
                request.logIn(user, function(err) {
                    if(err)
                        utils.tryLog(err, "routes/user.post(/login){request.logIn}");
                    else
                        response.redirect('rooms.html');
                });
            }
        })(request, response, next);
    });

    /*Server side verification of login - errors store error states which get
    toggled during error checking*/
    app.post('/register.html', helpers.ensureNew('/rooms.html'), function(request, response){
        var errors = {
            'misstype': false,
            'hasEmail': false,
            'hasName': false,
            'badName': false,
            'badEmail': false,
            'badPass': false,
        };
        username  = request.body.username;
        password  = request.body.password;
        password2 = request.body.password2;
        email     = request.body.email;

        if(username && email && password && password2){
            if(password != password2)
                errors.misstype = true;
            if(!/^[\w ]{6,}$/gi.test(password))
                errors.badPass = true;
            if(!/^[\w ]{2,32}$/gi.test(username))
                errors.badName = true;
            if(!/^([a-z0-9_\.\+-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/gi.test(email))
                errors.badEmail = true;
            user.checkName(username, function(_hN){
                errors.hasName = _hN;
                user.checkEmail(email, function(_hE){
                    errors.hasEmail = _hE;

                    /*We validated the shit out of registration data - make decision*/
                    if(errors.misstype || errors.hasEmail || errors.hasName || errors.badName || errors.badEmail || errors.badPass){
                        /*Add additional data to error data to help out register
                        form to be user friendly*/
                        errors.error     = true;
                        errors.username  = username;
                        errors.password  = password;
                        errors.password2 = password2;
                        errors.email     = email;
                        response.render('register', errors);
                    }else{
                        user.register(username, email, password);
                        response.redirect('/login.html');
                    }
                });
            });
        }
    });

    app.get('/logout.html', helpers.ensureLoged('/'), function(request, response){
      request.logout();
      response.redirect('/');
    });

    /*Oh.. Express.. Why can't you figure this out for yourself*/
    app.get('/login.html',    helpers.ensureNew('/rooms.html'), function(request, response){ response.render('login',    {'error': false}); });
    app.get('/register.html', helpers.ensureNew('/rooms.html'), function(request, response){ response.render('register', {'error': false}); });
};
