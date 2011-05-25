/* DO NOT MODIFY. This file was compiled Wed, 25 May 2011 05:25:35 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.tagbox.coffee
 */

(function() {
  /*
   tagbox
   adapted from superbly tagfield v0.1
   http://www.superbly.ch
  */  (function($) {
    $.fn.tagbox = function(options) {
      var addItem, inputContainer, inserted, keys, removeItem, tagField, tagInput, tagList, updateTags, _ref;
      inserted = [];
      tagField = this.addClass('tag_container');
      tagList = $("<ul class='tag_list' />");
      inputContainer = $("<li class='input_container' />");
      tagInput = $("<input class='tag_input'>");
      tagField.append(tagList);
      tagList.append(inputContainer);
      inputContainer.append(tagInput);
      updateTags = function() {
        tagInput.focus();
        return tagField.attr('data-tags', inserted.join(','));
      };
      addItem = function(value) {
        if (!inserted.include(value)) {
          inserted.push(value);
          tagInput.parent().before("<li class='tag_item'><span>" + value + "</span><a> x</a></li>");
          tagInput.val("");
          $(tagList.find('.tag_item:last a')).click(function(e) {
            value = $(this).prev().text();
            return removeItem(value);
          });
          return updateTags();
        }
      };
      removeItem = function(value) {
        if (inserted.include(value)) {
          inserted.remove(value);
          tagList.find('.tag_item span').filter(function() {
            return $(this).text() === value;
          }).parent().remove();
          return updateTags();
        }
      };
      if (options != null ? (_ref = options.presets) != null ? _ref.length : void 0 : void 0) {
        options.presets.each(function(item) {
          return addItem(item);
        });
      }
      keys = {
        enter: 13,
        tab: 9,
        backspace: 8
      };
      tagInput.keydown(function(e) {
        var key, value;
        value = $(this).val() || "";
        key = e.which;
        if (key === keys.enter || key === keys.tab) {
          if (!value.blank()) {
            addItem(value.trim());
          }
          if (key === keys.enter) {
            return e.preventDefault();
          }
        } else if (key === keys.backspace) {
          if (value.blank()) {
            return removeItem(inserted.last());
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
