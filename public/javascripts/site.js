/* DO NOT MODIFY. This file was compiled Sat, 26 Feb 2011 19:43:30 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/site.coffee
 */

(function() {
  var getVal, setVal;
  $(".clickable").live('click', function() {
    return document.location = $(this).find("a").eq(0).attr("href");
  });
  getVal = function(key) {
    if (localStorage) {
      try {
        return JSON.parse(localStorage[key]);
      } catch (error) {
        return void 0;
      }
    }
  };
  setVal = function(key, value) {
    if (localStorage) {
      return localStorage[key] = value;
    }
  };
  $(function() {
    var active, setLightTheme;
    setLightTheme = function(active) {
      $('#fullscreen').toggleClass('light', active);
      $('iframe').contents().find('html').toggleClass("light", active);
      return setVal('light', active);
    };
    $('#bulb').click(function() {
      $(this).toggleClass('on');
      return setLightTheme($(this).hasClass('on'));
    });
    if (active = getVal('light')) {
      $('#bulb').toggleClass('on', active);
      return setLightTheme(active);
    }
  });
}).call(this);
