/* DO NOT MODIFY. This file was compiled Tue, 11 Jan 2011 01:42:43 GMT from
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
          var files;
          stopFn(event);
          return files = Array.prototype.each.call(event.dataTransfer.files, function(file) {
            var imageType, reader;
            imageType = /image.*/;
            if (!file.type.match(imageType)) {
              return;
            }
            reader = new FileReader();
            reader.onerror = function(evt) {
              var msg;
              msg = 'Error ' + evt.target.error.code;
              if (evt.target.error.code && FileError.NOT_READABLE_ERR) {
                msg += ': NOT_READABLE_ERR';
              }
              return alert(msg);
            };
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
