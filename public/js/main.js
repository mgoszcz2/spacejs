/*Sorry - I have a minor case of OCD*/
var loc = window.location;

if(window.location.pathname != '/arena.html' && loc.hash != ''){
  var scrollV;
  var scrollH;

  if ("pushState" in history) history.pushState("", document.title, loc.pathname + loc.search);
  else {
    scrollV = document.body.scrollTop;
    scrollH = document.body.scrollLeft;
    loc.hash = "";
    document.body.scrollTop = scrollV;
    document.body.scrollLeft = scrollH;
  }
}

/*Frame killer*/
$(document).css('display', ['none', 'block'][self == top]);
