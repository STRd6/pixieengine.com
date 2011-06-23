/* DO NOT MODIFY. This file was compiled Thu, 23 Jun 2011 00:14:49 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/site.coffee
 */

(function() {
  var getVal, setVal;
  window.notify = function(message, delay) {
    return $.pnotify({
      pnotify_text: message,
      pnotify_delay: delay
    });
  };
  $(".clickable").live('click', function() {
    return document.location = $(this).find("a").eq(0).attr("href");
  });
  window.showTooltip = function(element, html) {
    var position, tooltipHeight;
    position = element.offset() || {
      top: 50,
      left: 50
    };
    if (!element.offset()) {
      $("#tooltip .icon").hide();
    } else {
      $("#tooltip .icon").show();
    }
    $("#tooltip").find(".content").html(html);
    tooltipHeight = $('#tooltip').height();
    position.left += element.width() + 30;
    position.top -= tooltipHeight / 2;
    return $("#tooltip").stop().offset(position).fadeIn();
  };
  window.hideTooltip = function() {
    return $("#tooltip").stop().fadeOut();
  };
  $("#tooltip").live({
    mouseenter: function() {
      return $(this).css('opacity', 1);
    },
    mouseleave: function() {
      return $(this).css('opacity', 0.4);
    }
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
      $('.bulb').toggleClass("on", active);
      return setVal('light', active);
    };
    $('.bulb').click(function() {
      $(this).toggleClass('on');
      return setLightTheme($(this).hasClass('on'));
    });
    if (active = getVal('light') || $("body").is(".light")) {
      setLightTheme(active);
    }
    $("#flashes .notice").each(function() {
      return notify($(this).html());
    });
    return $('.tipsy').tipsy({
      delayIn: 200,
      delayOut: 500,
      fade: 50,
      gravity: 'w',
      opacity: 1
    });
  });
}).call(this);
