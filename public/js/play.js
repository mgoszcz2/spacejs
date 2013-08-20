var sio = io.connect('http://localhost');

sio.socket.on('error', function (reason){
  console.error('Unable to connect to the server:', reason);
});

sio.on('connect', function(){
  console.info('Conected to the server');
});

/*Update room list*/
sio.of('/rooms').on('update', function(data){
  console.log(data);
});
