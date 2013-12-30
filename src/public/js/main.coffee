# Sorry - I have a minor case of OCD
loc = window.location
if loc.pathname isnt "/arena.html" and loc.hash isnt ""
  if "pushState" of history
    history.pushState "", document.title, loc.pathname + loc.search
  else
    scrollV = document.body.scrollTop
    scrollH = document.body.scrollLeft
    loc.hash = ""
    document.body.scrollTop = scrollV
    document.body.scrollLeft = scrollH

# Frame killer
$(document).css "display", ["none", "block"][self is top]
