/* DO NOT MODIFY. This file was compiled Mon, 08 Aug 2011 04:59:01 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/site.coffee
 */

(function() {
  var clickTrackers, getVal, setVal, tag, type, _fn;
  window.trackEvent = function(category, action, label) {
    return _gaq.push(['_trackEvent', category, action, label]);
  };
  clickTrackers = {
    a: "click",
    button: "click"
  };
  _fn = function(tag, type) {
    return $(tag).live(type, function() {
      var category, label;
      category = $(this).parents('[eventCategory]:first').attr('eventCategory');
      label = $(this).attr('eventLabel') || $(this).text() || $(this).attr('title');
      return trackEvent(category, type, $.trim(label));
    });
  };
  for (tag in clickTrackers) {
    type = clickTrackers[tag];
    _fn(tag, type);
  }
  window.notify = function(message, delay) {
    return $.pnotify({
      pnotify_text: message,
      pnotify_delay: delay
    });
  };
  $(".clickable").live('click', function(event) {
    if (!$(event.target).is("a")) {
      return document.location = $(this).find("a").eq(0).attr("href");
    }
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
    if (position.top < 5) {
      position.top = 5;
      $("#tooltip .icon").css('top', -tooltipHeight + 7);
    } else {
      $("#tooltip .icon").css('top', 0);
    }
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
        return;
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
      $('html').toggleClass('light', active);
      $('iframe').contents().find('html').toggleClass("light", active);
      $('.bulb').toggleClass("on", active);
      return setVal('light', active);
    };
    $('.bulb').click(function() {
      $(this).toggleClass('on');
      return setLightTheme($(this).hasClass('on'));
    });
    active = getVal('light');
    if (active != null) {
      setLightTheme(active);
    } else if ($('html').hasClass('light')) {
      $('.bulb').toggleClass("on", true);
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
