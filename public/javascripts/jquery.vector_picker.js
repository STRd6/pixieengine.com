/* DO NOT MODIFY. This file was compiled Sun, 15 May 2011 20:42:18 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/jquery.vector_picker.coffee
 */

(function() {
  (function($) {
    return $.fn.vectorPicker = function() {
      var RADIUS, SIZE, input, mouseHeld, setVector, showDialog;
      input = this.eq(0);
      SIZE = 126;
      RADIUS = 5;
      mouseHeld = false;
      setVector = function(x, y) {
        var xTranslate, yTranslate, _ref;
        _ref = [x, y].map(function(value) {
          return ((value - SIZE / 2) / 5).round();
        }), xTranslate = _ref[0], yTranslate = _ref[1];
        input.val(JSON.stringify({
          x: xTranslate,
          y: yTranslate
        }));
        return $('.unit_circle').css({
          backgroundPosition: "" + (x - RADIUS) + "px " + (y - RADIUS) + "px"
        });
      };
      showDialog = function() {
        var dialog, height, offset;
        dialog = $('<div />', {
          "class": "vector_picker"
        });
        $('<div class="unit_circle" />').bind({
          mousedown: function(e) {
            setVector(e.offsetX, e.offsetY);
            return mouseHeld = true;
          },
          mousemove: function(e) {
            if (mouseHeld) {
              return setVector(e.offsetX, e.offsetY);
            }
          },
          mouseup: function() {
            $(input).focus();
            return mouseHeld = false;
          }
        }).appendTo(dialog);
        offset = input.offset();
        height = input.get(0).offsetHeight;
        dialog.css({
          left: offset.left,
          top: offset.top + height
        });
        return $('body').append(dialog);
      };
      return input.bind({
        blur: function() {
          if (!mouseHeld) {
            return $('.vector_picker').remove();
          }
        },
        focus: function() {
          var obj;
          if (!$('.vector_picker').length) {
            showDialog();
          }
          try {
            obj = JSON.parse(input.val());
          } catch (e) {
            obj = null;
          }
          return $('.unit_circle').css({
            backgroundPosition: obj ? "" + (5 * obj.x + (SIZE / 2) - RADIUS) + "px " + (5 * obj.y + (SIZE / 2) - RADIUS) + "px" : void 0
          });
        }
      });
    };
  })(jQuery);
}).call(this);
