/* DO NOT MODIFY. This file was compiled Tue, 24 May 2011 21:18:55 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.tagbox.coffee
 */

(function() {
  /*
   tagbox
   adapted from superbly tagfield v0.1
   http://www.superbly.ch
  */  (function($) {
    $.fn.tagbox = function() {
      var addItem, inputContainer, inserted, keys, removeItem, removeLastItem, tagField, tagInput, tagList;
      inserted = [];
      tagField = this.addClass('tag_container');
      tagList = $("<ul class='tag_list' />");
      inputContainer = $("<li class='input_container' />");
      tagInput = $("<input class='tag_input'>");
      tagField.append(tagList);
      tagList.append(inputContainer);
      inputContainer.append(tagInput);
      addItem = function(value) {
        if (!inserted.include(value)) {
          inserted.push(value);
          tagInput.parent().before("<li class='tag_item'><span>" + value + "</span><a> x</a></li>");
          tagInput.val("");
          $(tagList.children('.tag_item:last a')).click(function(e) {
            value = $(this).prev().text();
            return removeItem(value);
          });
          tagInput.focus();
          return tagField.attr('data-tags', inserted.join(','));
        }
      };
      removeItem = function(value) {
        if (inserted.include(value)) {
          inserted.remove(value);
          tagList.find(".tag_item span:contains(" + value + ")").parent().remove();
        }
        tagInput.focus();
        return tagField.attr('data-tags', inserted.join(','));
      };
      removeLastItem = function() {
        return removeItem(inserted.last());
      };
      keys = {
        enter: 13,
        tab: 9,
        backspace: 8
      };
      tagInput.keydown(function(e) {
        var value;
        if (e.which === keys.enter || e.which === keys.tab) {
          value = tagInput.val() || "";
          if (!value.blank()) {
            addItem(value.trim());
          }
          if (e.which === keys.enter) {
            return e.preventDefault();
          }
        } else if (e.which === keys.backspace) {
          if (tagInput.val().blank()) {
            return removeLastItem();
          }
        }
      });
      return $('.tag_container').click(function(e) {
        return tagInput.focus();
      });
    };
    return this;
  })(jQuery);
}).call(this);
