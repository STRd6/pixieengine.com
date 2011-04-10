/* DO NOT MODIFY. This file was compiled Fri, 08 Apr 2011 03:50:41 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/site.coffee
 */

(function() {
  var getVal, setVal;
  $(".clickable").live('click', function() {
    return document.location = $(this).find("a").eq(0).attr("href");
  });
  window.showTooltip = function(element, html) {
    var position;
    position = element.offset() || {
      top: 50,
      left: 50
    };
    position.left += element.width() + 42;
    return $("#tooltip").stop().offset(position).fadeIn().find(".content").html(html);
  };
  window.hideTooltip = function() {
    return $("#tooltip").stop().fadeOut();
  };
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
