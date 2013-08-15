/*Note to self: Do not fallback if POST data asbsent: Unless someone is
messing with the system, the fields will always be present*/

module.exports = function(app, passport){
    var user = require('../models/user');
    var utils = require('../libs/utils');

    /*passport.js technomagic - It's wonderful but it doesn't seem to
    work to well with whikser templates even using 'flash-connect' lib,
    the workaround is to use a fancy callback system and use native rendering
    system*/
    app.post('/login.html', function(request, response, next) {
        passport.authenticate('local', function(err, user, info) {
            utils.tryLog(err, "routes/user.post(/login)");
            console.log(info);
            if(!user){
                response.render('login', {'error': true});
            }else{
                request.logIn(user, function(err) {
                    if(err)
                        utils.tryLog(err, "routes/user.post(/login){request.logIn}");
                    else
                        response.redirect('play.html');
                });
            }
        })(request, response, next);
    });

    /*Server side verfication of login - errors store error states which get
    toggled during error checking*/
    app.post('/register.html', function(request, response){
        var errors = {
            'misstype': false,
            'hasEmail': false,
            'hasName': false,
            'badName': false,
            'badEmail': false,
            'badPass': false,
        }
        username  = request.body.username;
        password  = request.body.password;
        password2 = request.body.password2;
        email     = request.body.email;

        if(username && email && password && password2){
            if(password != password2)
                errors.misstype = true;
            if(!/^[A-Z0-9]{6,}$/gi.test(password))
                errors.badPass = true;
            if(!/^[A-Z0-9]{2,}$/gi.test(username))
                errors.badName = true;
            if(!/^([a-z0-9_\.\+-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/gi.test(email))
                errors.badEmail = true;
            user.checkName(username, function(_hN){
                errors.hasName = _hN;
                user.checkEmail(email, function(_hE){
                    errors.hasEmail = _hE;
                    console.log(errors);

                    /*We validated the shit out of registartion data - make decision*/
                    if(errors.misstype || errors.hasEmail || errors.hasName || errors.badName || errors.badEmail || errors.badPass){
                        /*Add adtitional data to error data to help out register
                        form to be user freindly*/
                        errors.error     = true;
                        errors.username  = username;
                        errors.password  = password;
                        errors.password2 = password2;
                        errors.email     = email;
                        response.render('register', errors);
                    }else{
                        user.register(username, email, password, function(){ response.redirect('/login.html'); });
                    }
                });
            });
        }
    });

    /*Oh.. Express.. Why can't you figure this out for yourself*/
    app.get('/login.html',    function(request, response){ response.render('login',    {'error': false}); });
    app.get('/register.html', function(request, response){ response.render('register', {'error': false}); });
}
