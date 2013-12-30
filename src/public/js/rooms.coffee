rooms = io.connect "http://localhost/rooms"
rooms.socket.on "error", (reason) ->
  console.error "Unable to connect to the server:", reason

#Update room list
rooms.on "update", (data) ->
  $elm = $ '#rooms'
  $elm.empty()

  for room in data
    url = "/arena.html##{room.name}"
    name = room.name
    limit = room.limit
    taken = room.taken

    html = "<li class='button action'><a href='#{url}'>#{name}</a><span>#{taken}/#{limit}</span></li>"
    $elm.append html
