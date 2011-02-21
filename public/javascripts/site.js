/* DO NOT MODIFY. This file was compiled Mon, 21 Feb 2011 20:20:24 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/site.coffee
 */

(function() {
  var getVal, setVal;
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
