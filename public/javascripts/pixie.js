/* DO NOT MODIFY. This file was compiled Mon, 28 Feb 2011 06:48:23 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/pixie.coffee
 */

(function() {
  (function($) {
    var falseFn;
    falseFn = function() {
      return false;
    };
    return $.fn.pixie = function(options) {
      var DIV, Layer, Pixel, canvas, frames, height, initializer, layers, pixelHeight, pixelWidth, width;
      canvas = null;
      DIV = "<div />";
      Pixel = function(I) {
        var self;
        I || (I = {});
        $.reverseMerge(I, {
          x: 0,
          y: 0,
          z: 0,
          f: f,
          canvas: null
        });
        self = {};
        return self;
      };
      Layer = function() {
        var context, gridColor, layer, layerElement, layerHeight, layerWidth;
        layer = $("<canvas />", {
          "class": "layer"
        });
        gridColor = "#000";
        layerWidth = width * pixelWidth;
        layerHeight = height * pixelHeight;
        layerElement = layer.get(0);
        layerElement.width = layerWidth;
        layerElement.height = layerHeight;
        context = layerElement.getContext("2d");
        return $.extend(layer, {
          clear: function() {
            return context.clearRect(0, 0, width * pixelWidth, height * pixelHeight);
          }
        });
      };
      options || (options = {});
      width = options.width || 8;
      height = options.height || 8;
      pixelWidth = options.pixelSize || 16;
      pixelHeight = options.pixelSize || 16;
      initializer = options.initializer;
      layers = options.layers || 2;
      frames = options.frames || 1;
      return this.each(function() {
        var active, currentTool, guideLayer, layer, layerMenu, mode, pixels, pixie, viewport;
        pixie = $(DIV, {
          "class": 'pixie'
        });
        viewport = $(DIV, {
          "class": 'viewport'
        });
        canvas = $(DIV, {
          "class": 'canvas'
        });
        layerMenu = $(DIV, {
          "class": 'layers'
        }).prepend('<h3>Layer:</h3>');
        currentTool = void 0;
        active = false;
        layer = 0;
        mode = void 0;
        pixie.bind('contextmenu', falseFn).bind('mousedown', function(e) {
          var target;
          target = $(e.target);
          if (target.is('.swatch')) {
            return canvas.color(target.css('backgroundColor'), e.button);
          }
        }).bind('mouseup', function(e) {
          active = false;
          return mode = void 0;
        });
        pixels = [];
        guideLayer = Layer().bind('mousedown', function(e) {
          active = true;
          if (e.button) {
            mode = "P";
          } else {
            mode = "S";
          }
          return e.preventDefault();
        }).bind('mousedown mousemove', function(event) {
          var eventType, lastPixel, offset, pixel;
          offset = $(this).offset();
          pixel = canvas.getPixel(col, row, layer);
          eventType = void 0;
          if (event.type === 'mousedown') {
            eventType = event.type;
          } else if (pixel && pixel !== lastPixel && event.type === 'mousemove') {
            eventType = 'mouseenter';
          }
          if (pixel && active && currentTool && currentTool[eventType]) {
            currentTool[eventType].call(pixel, event, canvas.color(), pixel);
          }
          return lastPixel = pixel;
        });
        $.extend(canvas, {
          clear: function() {
            return $.each(editingLayers, function() {
              return $.each(this, function() {
                return this.clear();
              });
            });
          },
          eachPixel: function(fn, z, f) {
            if (z === void 0) {
              z = layer;
            }
            if (f === void 0) {
              f = frame;
            }
            height.times(function(row) {
              return width.times(function(col) {
                var pixel;
                pixel = pixels[f][z][col][row];
                return fn.call(pixel, pixel, col, row);
              });
            });
            return canvas;
          },
          getPixel: function(x, y, z, f) {
            if (z === void 0) {
              z = layer;
            }
            if (f === void 0) {
              f = frame;
            }
            if (y >= 0 && y < height) {
              if (x >= 0 && x < width) {
                return pixels[f][z][y][x];
              }
            }
            return void 0;
          }
        });
        viewport.append(canvas);
        pixie.append(viewport);
        return $(this).append(pixie);
      });
    };
  })(jQuery);
}).call(this);
