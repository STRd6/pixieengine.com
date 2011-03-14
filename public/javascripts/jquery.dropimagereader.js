/* DO NOT MODIFY. This file was compiled Mon, 14 Mar 2011 06:34:27 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/jquery.dropimagereader.coffee
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
        var $this, element;
        element = this;
        $this = $(this);
        $this.bind('dragenter dragover dragleave', stopFn);
        return $this.bind('drop', function(event) {
          stopFn(event);
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
