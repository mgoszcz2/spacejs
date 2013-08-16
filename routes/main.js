module.exports = function(app){
    var helpers = require('../libs/helpers');
    app.get('/play.html', helpers.ensureLoged('/'), function(request, response){
        response.render('play');
    });

    app.get('/', helpers.ensureNew('/play.html'), function(request, response){
        response.render('index');
    });
}
