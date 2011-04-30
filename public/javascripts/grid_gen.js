/* DO NOT MODIFY. This file was compiled Fri, 29 Apr 2011 20:33:48 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/grid_gen.coffee
 */

(function() {
  window.GridGen = function(options) {
    var canvas, canvasHeight, canvasWidth, color, context, guide, height, width;
    options = $.extend({}, {
      color: "#414141",
      height: 32,
      width: 32,
      guide: 5
    }, options);
    width = options.width, height = options.height, guide = options.guide, color = options.color;
    canvasWidth = width * guide;
    canvasHeight = height * guide;
    canvas = $("<canvas width='" + canvasWidth + "' height='" + canvasHeight + "'></canvas>").get(0);
    context = canvas.getContext("2d");
    context.fillStyle = color;
    guide.times(function(i) {
      context.fillRect(i * width, 0, 1, canvasHeight);
      return context.fillRect(0, i * height, canvasWidth, 1);
    });
    context.fillRect(0, 0, 2, canvasHeight);
    context.fillRect(0, 0, canvasWidth, 2);
    return {
      backgroundImage: function() {
        return "url(" + (this.toDataURL()) + ")";
      },
      toDataURL: function() {
        return canvas.toDataURL("image/png");
      }
    };
  };
}).call(this);
