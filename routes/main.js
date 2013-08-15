module.exports = function(app){
    app.get('/play.html', function(request, response){
        console.log(request.user);
        response.end("hi");
    });
}
