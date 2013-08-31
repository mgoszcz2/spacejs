module.exports = function(app){
  var helpers = require('../libs/helpers');

  app.get('/rooms.html', helpers.ensureLoged('/'), helpers.addUserData, function(request, response){
    response.render('rooms');
  });

  app.get('/arena.html', helpers.ensureLoged('/'), helpers.addUserData, function(request, response){
    response.render('arena');
  });

  app.get('/', helpers.ensureNew('/rooms.html'), function(request, response){
    response.render('index');
  });

  app.get('/spec', function(request, response){
    response.render('spec');
  });
};
