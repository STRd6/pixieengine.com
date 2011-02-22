/* DO NOT MODIFY. This file was compiled Tue, 22 Feb 2011 00:27:03 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.dropimagereader.coffee
 */

(function() {
  (function($) {
    $.event.fix = (function(originalFix) {
      return function(event) {
        event = originalFix.apply(this, arguments);
        if (event.type.indexOf('drag') === 0 || event.type.indexOf('drop') === 0) {
          event.dataTransfer = event.originalEvent.dataTransfer;
        }
        return event;
      };
    })($.event.fix);
    return $.fn.dropImageReader = function(callback) {
      var stopFn;
      stopFn = function(event) {
        event.stopPropagation();
        return event.preventDefault();
      };
      return this.each(function() {
        var $this, content, element;
        element = this;
        $this = $(this);
        content = $this.children();
        $this.bind('dragenter dragover', function(event) {
          var big, div, small;
          stopFn(event);
          div = $("<div>", {
            "class": "drag_drop_placeholder"
          });
          big = $("<p>", {
            "class": "big",
            text: "drag images here"
          });
          small = $("<p>", {
            "class": "small",
            text: "to post them to chat"
          });
          div.append(big, small);
          $this.css({
            width: $this.width(),
            height: $this.height()
          });
          $this.children().remove();
          return $this.append(div);
        });
        $this.bind('dragleave drop', function(event) {
          stopFn(event);
          $this.children().remove();
          return $this.append(content);
        });
        return $this.bind('drop', function(event) {
          return Array.prototype.forEach.call(event.dataTransfer.files, function(file) {
            var imageType, reader;
            imageType = /image.*/;
            if (!file.type.match(imageType)) {
              return;
            }
            reader = new FileReader();
            reader.onload = function(evt) {
              return callback.call(element, file, evt);
            };
            return reader.readAsDataURL(file);
          });
        });
      });
    };
  })(jQuery);
}).call(this);
