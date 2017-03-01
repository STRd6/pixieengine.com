//= require lib/ui
//= require ajax
//= require lib/isotope.min

$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});

function trackPageview(e){return _gaq.push(["_trackPageview",e])}
function trackEvent(e,t,n){return _gaq.push(["_trackEvent",e,t,n])}
