/* DO NOT MODIFY. This file was compiled Fri, 29 Apr 2011 00:01:35 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/grid_gen.coffee
 */

(function() {
  window.GridGen = function(options) {
    var canvas, canvasHeight, canvasWidth, context;
    options = $.extend({}, {
      color: "#414141",
      height: 32,
      width: 32
    }, options);
    canvasWidth = options.width;
    canvasHeight = options.height;
    canvas = $("<canvas width='" + canvasWidth + "' height='" + canvasHeight + "'></canvas>").get(0);
    context = canvas.getContext("2d");
    context.fillStyle = options.color;
    context.fillRect(0, 0, 1, canvasHeight);
    context.fillRect(0, 0, canvasWidth, 1);
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
