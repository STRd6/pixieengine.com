/* DO NOT MODIFY. This file was compiled Mon, 01 Aug 2011 22:21:00 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/jquery.power_canvas.coffee
 */

(function() {
  var __slice = Array.prototype.slice;
  (function($) {
    return $.fn.powerCanvas = function(options) {
      var $canvas, canvas, context;
      options || (options = {});
      canvas = this.get(0);
      context = void 0;
      /**
      * PowerCanvas provides a convenient wrapper for working with Context2d.
      * @name PowerCanvas
      * @constructor
      */
      $canvas = $(canvas).extend((function() {
        /**
         * Passes this canvas to the block with the given matrix transformation
         * applied. All drawing methods called within the block will draw
         * into the canvas with the transformation applied. The transformation
         * is removed at the end of the block, even if the block throws an error.
         *
         * @name withTransform
         * @methodOf PowerCanvas#
         *
         * @param {Matrix} matrix
         * @param {Function} block
         * @returns this
        */
      })(), {
        withTransform: function(matrix, block) {
          context.save();
          context.transform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
          try {
            block(this);
          } finally {
            context.restore();
          }
          return this;
        },
        clear: function() {
          context.clearRect(0, 0, canvas.width, canvas.height);
          return this;
        },
        clearRect: function(x, y, width, height) {
          context.clearRect(x, y, width, height);
          return this;
        },
        context: function() {
          return context;
        },
        element: function() {
          return canvas;
        },
        globalAlpha: function(newVal) {
          if (newVal != null) {
            context.globalAlpha = newVal;
            return this;
          } else {
            return context.globalAlpha;
          }
        },
        compositeOperation: function(newVal) {
          if (newVal != null) {
            context.globalCompositeOperation = newVal;
            return this;
          } else {
            return context.globalCompositeOperation;
          }
        },
        createLinearGradient: function(x0, y0, x1, y1) {
          return context.createLinearGradient(x0, y0, x1, y1);
        },
        createRadialGradient: function(x0, y0, r0, x1, y1, r1) {
          return context.createRadialGradient(x0, y0, r0, x1, y1, r1);
        },
        buildRadialGradient: function(c1, c2, stops) {
          var color, gradient, position;
          gradient = context.createRadialGradient(c1.x, c1.y, c1.radius, c2.x, c2.y, c2.radius);
          for (position in stops) {
            color = stops[position];
            gradient.addColorStop(position, color);
          }
          return gradient;
        },
        createPattern: function(image, repitition) {
          return context.createPattern(image, repitition);
        },
        drawImage: function(image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight) {
          context.drawImage(image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight);
          return this;
        },
        drawLine: function(x1, y1, x2, y2, width) {
          if (arguments.length === 3) {
            width = x2;
            x2 = y1.x;
            y2 = y1.y;
            y1 = x1.y;
            x1 = x1.x;
          }
          width || (width = 3);
          context.lineWidth = width;
          context.beginPath();
          context.moveTo(x1, y1);
          context.lineTo(x2, y2);
          context.closePath();
          context.stroke();
          return this;
        },
        fill: function(color) {
          $canvas.fillColor(color);
          context.fillRect(0, 0, canvas.width, canvas.height);
          return this;
        }
      }, (function() {
        /**
         * Fills a circle at the specified position with the specified
         * radius and color.
         *
         * @name fillCircle
         * @methodOf PowerCanvas#
         *
         * @param {Number} x
         * @param {Number} y
         * @param {Number} radius
         * @param {Number} color
         * @see PowerCanvas#fillColor
         * @returns this
        */
      })(), {
        fillCircle: function(x, y, radius, color) {
          $canvas.fillColor(color);
          context.beginPath();
          context.arc(x, y, radius, 0, Math.TAU, true);
          context.closePath();
          context.fill();
          return this;
        }
      }, (function() {
        /**
         * Fills a rectangle with the current fillColor
         * at the specified position with the specified
         * width and height
        
         * @name fillRect
         * @methodOf PowerCanvas#
         *
         * @param {Number} x
         * @param {Number} y
         * @param {Number} width
         * @param {Number} height
         * @see PowerCanvas#fillColor
         * @returns this
        */
      })(), {
        fillRect: function(x, y, width, height) {
          context.fillRect(x, y, width, height);
          return this;
        },
        fillShape: function() {
          var points;
          points = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          context.beginPath();
          points.each(function(point, i) {
            if (i === 0) {
              return context.moveTo(point.x, point.y);
            } else {
              return context.lineTo(point.x, point.y);
            }
          });
          context.lineTo(points[0].x, points[0].y);
          return context.fill();
        }
      }, (function() {
        /**
        * Adapted from http://js-bits.blogspot.com/2010/07/canvas-rounded-corner-rectangles.html
        */
      })(), {
        fillRoundRect: function(x, y, width, height, radius, strokeWidth) {
          radius || (radius = 5);
          context.beginPath();
          context.moveTo(x + radius, y);
          context.lineTo(x + width - radius, y);
          context.quadraticCurveTo(x + width, y, x + width, y + radius);
          context.lineTo(x + width, y + height - radius);
          context.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
          context.lineTo(x + radius, y + height);
          context.quadraticCurveTo(x, y + height, x, y + height - radius);
          context.lineTo(x, y + radius);
          context.quadraticCurveTo(x, y, x + radius, y);
          context.closePath();
          if (strokeWidth) {
            context.lineWidth = strokeWidth;
            context.stroke();
          }
          context.fill();
          return this;
        },
        fillText: function(text, x, y) {
          context.fillText(text, x, y);
          return this;
        },
        centerText: function(text, y) {
          var textWidth;
          textWidth = $canvas.measureText(text);
          return $canvas.fillText(text, (canvas.width - textWidth) / 2, y);
        },
        fillWrappedText: function(text, x, y, width) {
          var lineHeight, tokens, tokens2;
          tokens = text.split(" ");
          tokens2 = text.split(" ");
          lineHeight = 16;
          if ($canvas.measureText(text) > width) {
            if (tokens.length % 2 === 0) {
              tokens2 = tokens.splice(tokens.length / 2, tokens.length / 2, "");
            } else {
              tokens2 = tokens.splice(tokens.length / 2 + 1, (tokens.length / 2) + 1, "");
            }
            context.fillText(tokens.join(" "), x, y);
            return context.fillText(tokens2.join(" "), x, y + lineHeight);
          } else {
            return context.fillText(tokens.join(" "), x, y + lineHeight);
          }
        },
        fillColor: function(color) {
          if (color) {
            if (color.channels) {
              context.fillStyle = color.toString();
            } else {
              context.fillStyle = color;
            }
            return this;
          } else {
            return context.fillStyle;
          }
        },
        font: function(font) {
          if (font != null) {
            context.font = font;
            return this;
          } else {
            return context.font;
          }
        },
        measureText: function(text) {
          return context.measureText(text).width;
        },
        putImageData: function(imageData, x, y) {
          context.putImageData(imageData, x, y);
          return this;
        },
        strokeColor: function(color) {
          if (color) {
            if (color.channels) {
              context.strokeStyle = color.toString();
            } else {
              context.strokeStyle = color;
            }
            return this;
          } else {
            return context.strokeStyle;
          }
        },
        strokeCircle: function(x, y, radius, color) {
          $canvas.strokeColor(color);
          context.beginPath();
          context.arc(x, y, radius, 0, Math.TAU, true);
          context.closePath();
          context.stroke();
          return this;
        },
        strokeRect: function(x, y, width, height) {
          context.strokeRect(x, y, width, height);
          return this;
        },
        textAlign: function(textAlign) {
          context.textAlign = textAlign;
          return this;
        },
        height: function() {
          return canvas.height;
        },
        width: function() {
          return canvas.width;
        }
      });
      if (canvas != null ? canvas.getContext : void 0) {
        context = canvas.getContext('2d');
        if (options.init) {
          options.init($canvas);
        }
        return $canvas;
      }
    };
  })(jQuery);
}).call(this);
