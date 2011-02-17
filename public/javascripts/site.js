/* DO NOT MODIFY. This file was compiled Thu, 17 Feb 2011 01:29:28 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/site.coffee
 */

(function() {
  var getVal, setVal;
  getVal = function(key) {
    if (localStorage) {
      return JSON.parse(localStorage[key]);
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
