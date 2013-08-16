var helpers = {}
module.exports = helpers

/*JavaScript clojures techomagic - dir is added to closure. On failure user is
redirected to dir*/
helpers.ensureLoged = function(dir){
    return function(request, response, next){
        if(request.user)
            next();
        else
            response.redirect(dir);
    }
}

helpers.ensureNew = function(dir){
    return function(request, response, next){
        if(request.user)
            response.redirect(dir);
        else
            next();
    }
}
