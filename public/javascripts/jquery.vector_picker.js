/* DO NOT MODIFY. This file was compiled Wed, 11 May 2011 23:00:52 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.vector_picker.coffee
 */

(function() {
  (function($) {
    return $.fn.vectorPicker = function(options) {
      var BORDER_WIDTH, RADIUS, SIZE, choosingVector, dialog, input, setVector, showDialog;
      options || (options = {});
      SIZE = 130;
      BORDER_WIDTH = 2;
      RADIUS = 7;
      dialog = null;
      input = null;
      choosingVector = false;
      setVector = function(x, y, element) {
        var xTranslate, yTranslate;
        xTranslate = ((x - SIZE / 2) / 5).round();
        yTranslate = ((y - SIZE / 2) / 5).round();
        $(element).css('backgroundPosition', "" + (x - RADIUS) + "px " + (y - RADIUS) + "px");
        return input.val(JSON.stringify({
          x: xTranslate,
          y: yTranslate
        }));
      };
      showDialog = function(element) {
        var inputHeight, inputOffset, x, y;
        dialog = $('<div class="vector_picker" />');
        $('<div class="unit_circle" />').bind({
          mousedown: function(e) {
            setVector(e.offsetX, e.offsetY, $(this));
            choosingVector = false;
            return input.select();
          },
          mouseenter: function() {
            return choosingVector = true;
          },
          mousemove: function(e) {
            setVector(e.offsetX, e.offsetY, $(this));
            return choosingVector = false;
          }
        }).appendTo(dialog);
        inputOffset = $(element).offset();
        inputHeight = element.offsetHeight;
        x = inputOffset.left + BORDER_WIDTH;
        y = inputOffset.top + BORDER_WIDTH + inputHeight;
        dialog.css({
          left: x,
          top: y
        });
        return $('body').append(dialog);
      };
      return this.each(function() {
        var $this;
        $this = $(this);
        input = $this;
        return $this.bind({
          blur: function(e) {
            if (!choosingVector) {
              return $('.vector_picker').remove();
            }
          },
          focus: function() {
            if (!$('.vector_picker').length) {
              return showDialog(this);
            }
          }
        });
      });
    };
  })(jQuery);
}).call(this);
