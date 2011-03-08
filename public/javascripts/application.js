function notify(message) {
  var notice = $("#flashes .notice").first();
  if(notice.length < 1) {
    notice = $("<div class='notice' />").html(message);
    $('#flashes').append(notice);
  } else {
    notice.html(message);
  }

  notice.append($("<div class='close'/>"));
  notice.hide()
  notice.slideToggle().delay(4000).fadeOut();
}

function showTooltip(element, html) {
  var position = element.offset();

  position.left += element.width() + 42;
  $("#tooltip").stop().offset(position).fadeIn().find(".content").html(html);
}

function hideTooltip() {
  $("#tooltip").stop().fadeOut();
}

function trackPageview(pageName) {
  _gaq.push(['_trackPageview', pageName]);
}

function getCsrfData() {
  var data = {};
  data[$('meta[name=csrf-param]').attr('content')] = $('meta[name=csrf-token]').attr('content');

  return data;
}

// Tags
$(".tag .remove").live("click", function() {
  var $this = $(this);
  var spriteId = $this.parent().attr("data-sprite_id");
  var tag = $this.prev().text();
  $this.parent().fadeOut();

  $.post("/sprites/" + spriteId + "/remove_tag", {
    tag: tag
  });
});

$(function() {
  $.modal.defaults.overlayClose = true;

  function makeTag(tag, spriteId) {
    var tagElem = $("<div class='tag' />");
    tagElem.attr("data-sprite_id", spriteId);

    var link = $("<a href='/sprites/?tagged="+escape(tag)+"' />").text(tag);
    tagElem.append(link);

    if(loggedIn) {
      tagElem.append($("<div class='remove' />").text("X"));
    }

    return tagElem;
  }

  $(".tags form").ajaxForm({
    beforeSubmit: function(array, $form) {
      var input = $form.find("input[name=tag]");
      var spriteId = $form.attr("data-sprite_id");
      var tag = input.val();
      $form.before(makeTag(tag, spriteId));
      input.val('');
    }
  });

  $("#flashes .close").live("mousedown", function() {
    $(this).parent().slideUp();
  });
});
