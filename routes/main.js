module.exports = function(app){
    app.get('/play.html', function(request, response){
        response.render('play');
    });

    app.get('/', function(request, response){
        response.render('index');
    });
}
