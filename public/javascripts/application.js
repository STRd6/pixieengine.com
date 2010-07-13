function notify(message) {
  var notice = $("#flashes .notice").first();
  if(notice.length < 1) {
    notice = $("<div class='notice' />").html(message);
    $('#flashes').append(notice);
  } else {
    notice.html(message);
  }
}

function trackPageview(pageName) {
  _gaq.push(['_trackPageview', pageName]);
}
