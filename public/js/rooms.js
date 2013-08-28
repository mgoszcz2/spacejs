var rooms = io.connect('http://localhost/rooms');

rooms.socket.on('error', function (reason){
  console.error('Unable to connect to the server:', reason);
});

rooms.on('connect', function(){
  console.info('Conected to the server');
});

/*Update room list*/
rooms.on('update', function(data){
  $('#rooms').empty();
  data.forEach(function(i){
    //funny - no need to encode url
    $('<a>',{
      'text': i.name,
      'href': '/arena.html#' + i.name
    }).appendTo('#rooms');
  });
});
