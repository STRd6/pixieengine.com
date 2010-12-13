Number.prototype.times = function(iterator, context) {
  for(var i = 0; i < this; i++) {
    iterator.call(context, i);
  }
  return i;
};

Number.prototype.clamp = function(min, max) {
  return Math.min(Math.max(this, min), max);
};

/*global jQuery */
(function($) {
  /************************************************************************
   *
   * pixie.js - The jQuery pixel editor.
   *
   ************************************************************************/

  var imageDir = "/images/pixie/";
  var transparent = "transparent";

  var scale = 1;
  var xLast = 0;
  var yLast = 0;
  var xImage = 0;
  var yImage = 0;

  var actions = {
    undo: {
      name: "Undo",
      cssClass: "pillbox-left",
      icon: "/images/icons/arrow_undo.png",
      undoable: false,
      hotkeys: ["ctrl+z"],
      perform: function(canvas) {
        canvas.undo();

        canvas.showPreview();
      }
    },

    redo: {
      name: "Redo",
      cssClass: "pillbox-middle",
      icon: "/images/icons/arrow_redo.png",
      undoable: false,
      hotkeys: ["ctrl+y"],
      perform: function(canvas) {
        canvas.redo();

        canvas.showPreview();
      }
    },

    clear: {
      name: "Clear Layer",
      cssClass: "pillbox-right",
      icon: "/images/icons/application.png",
      perform: function(canvas) {
        canvas.eachPixel(function(pixel) {
          pixel.color(transparent);
        });

        canvas.showPreview();
      }
    },

    preview: {
      name: "Preview",
      menu: false,
      perform: function(canvas) {
        canvas.showPreview();
      }
    },

    left: {
      name: "Move Left",
      icon: "/images/icons/arrow_left.png",
      menu: false,
      hotkeys: ['left'],
      perform: function(canvas) {
        var deferredColors = [];

        canvas.height.times(function(y) {
          deferredColors[y] = canvas.getPixel(0, y).color();
        });

        canvas.eachPixel(function(pixel, x, y) {
          var rightPixel = canvas.getPixel(x + 1, y);

          if(rightPixel) {
            pixel.color(rightPixel.color());
          }
        });

        $.each(deferredColors, function(y, color) {
          canvas.getPixel(canvas.width - 1, y).color(color);
        });
      }
    },

    right: {
      name: "Move Right",
      icon: "/images/icons/arrow_right.png",
      menu: false,
      hotkeys: ['right'],
      perform: function(canvas) {
        var width = canvas.width;
        var height = canvas.height;

        var deferredColors = [];

        height.times(function(y) {
          deferredColors[y] = canvas.getPixel(width - 1, y).color();
        });

        for(var x = width-1; x >= 0; x--) {
          for(var y = 0; y < height; y++) {
            var currentPixel = canvas.getPixel(x, y);
            var leftPixel = canvas.getPixel(x - 1, y);

            if(leftPixel) {
              currentPixel.color(leftPixel.color());
            } else {
              currentPixel.color(transparent);
            }
          }
        }

        $.each(deferredColors, function(y, color) {
          canvas.getPixel(0, y).color(color);
        });
      }
    },

    up: {
      name: "Move Up",
      icon: "/images/icons/arrow_up.png",
      menu: false,
      hotkeys: ['up'],
      perform: function(canvas) {
        var deferredColors = [];

        canvas.width.times(function(x) {
          deferredColors[x] = canvas.getPixel(x, 0).color();
        });

        canvas.eachPixel(function(pixel, x, y) {
          var lowerPixel = canvas.getPixel(x, y + 1);

          if(lowerPixel) {
            pixel.color(lowerPixel.color());
          } else {
            pixel.color(transparent);
          }
        });

        $.each(deferredColors, function(x, color) {
          canvas.getPixel(x, canvas.height - 1).color(color);
        });
      }
    },

    down: {
      name: "Move Down",
      icon: "/images/icons/arrow_down.png",
      menu: false,
      hotkeys: ['down'],
      perform: function(canvas) {
        var width = canvas.width;
        var height = canvas.height;

        var deferredColors = [];

        canvas.width.times(function(x) {
          deferredColors[x] = canvas.getPixel(x, height - 1).color();
        });

        for(var x = 0; x < width; x++) {
          for(var y = height-1; y >= 0; y--) {
            var currentPixel = canvas.getPixel(x, y);
            var upperPixel = canvas.getPixel(x, y-1);

            if(upperPixel) {
              currentPixel.color(upperPixel.color());
            } else {
              currentPixel.color(transparent);
            }
          }
        }

        $.each(deferredColors, function(x, color) {
          canvas.getPixel(x, 0).color(color);
        });
      }
    },
    save: {
      name: "Download",
      icon: "/images/icons/disk.png",
      hotkeys: ["ctrl+s"],
      perform: function(canvas) {
        var w = window.open();
        w.document.location = canvas.toDataURL();
      }
    },
    options: {
      name: "Options",
      icon: "images/icons/page_gear.png",
      hotkeys: ["o"],
      perform: function() {
        $('#optionsModal').removeAttr("style").modal({
          persist: true,
          containerCss: {
            height: 70,
            width: 140
          },
          onClose: function() {
            $.modal.close();
            $('#optionsModal').attr("style", "display: none");
          }
        });
      }
    }
  };

  var CloneTool = function() {
    var cloneX, cloneY, targetX, targetY;

    return {
      name: "Clone",
      hotkeys: ['C'],
      icon: imageDir + "clone.png",
      cursor: "url("+ imageDir +"clone.png) 0 0, default",
      mousedown: function(e) {
        if(e.shiftKey) {
          cloneX = this.x;
          cloneY = this.y;
        } else {
          targetX = this.x;
          targetY = this.y;
          var selection = this.canvas.getPixel(cloneX, cloneY);

          if(selection) {
            this.color(selection.color());
          }
        }
      },
      mouseenter: function(e) {
        var deltaX = this.x - targetX;
        var deltaY = this.y - targetY;
        var selection = this.canvas.getPixel(cloneX + deltaX, cloneY + deltaY);

        if(selection) {
          this.color(selection.color());
        }
      }
    };
  };

  function scaleCanvas(scaleFactor) {
    var viewportEl = $('.pixie .viewport');
    var canvasEl = $('canvas');

    var canvasWidth = parseInt(canvasEl.attr('width'));
    var canvasHeight = parseInt(canvasEl.attr('height'));

    $('canvas').css('-webkit-transform', 'scale(' + scale + ')')
               .css('-moz-transform', 'scale(' + scale + ')')
               .css('-webkit-transform-origin', 0 + 'px ' + 0 + 'px')
               .css('-mov-transform-origin', 0 + 'px ' + 0 + 'px');

    $('.nogrid').css('width', canvasWidth * scale)
                .css('height', canvasHeight * scale);

    if (canvasWidth * scaleFactor <= 512 || canvasHeight * scaleFactor <= 512) {
      viewportEl.css('overflow', 'hidden');
    } else {
      viewportEl.css('overflow', 'auto');
    }

    viewportEl.scrollTo(0, 0)
  }

  var tools = {
    pencil: {
      name: "Pencil",
      hotkeys: ['P'],
      icon: imageDir + "pencil.png",
      cursor: "url(" + imageDir + "pencil.png) 4 14, default",
      mousedown: function(e, color) {
        this.color(color);
      },
      mouseenter: function(e, color) {
        this.color(color);
      }
    },

    brush: {
      name: "Brush",
      hotkeys: ['B'],
      icon: imageDir + "paintbrush.png",
      cursor: "url(" + imageDir + "paintbrush.png) 4 14, default",
      mousedown: function(e, color) {
        this.color(color);

        $.each(this.canvas.getNeighbors(this.x, this.y), function(i, neighbor) {
          if(neighbor) {
            neighbor.color(color);
          }
        });
      },
      mouseenter: function(e, color) {
        this.color(color);

        $.each(this.canvas.getNeighbors(this.x, this.y), function(i, neighbor) {
          if(neighbor) {
            neighbor.color(color);
          }
        });
      }
    },

    dropper: {
      name: "Dropper",
      hotkeys: ['I'],
      icon: imageDir + "dropper.png",
      cursor: "url(" + imageDir + "dropper.png) 13 13, default",
      mousedown: function() {
        this.canvas.color(this.color());
        this.canvas.setTool(tools.pencil);
      }
    },

    eraser: {
      name: "Eraser",
      hotkeys: ['E'],
      icon: imageDir + "eraser.png",
      cursor: "url(" + imageDir + "eraser.png) 4 11, default",
      mousedown: function() {
        this.color(transparent);
      },
      mouseenter: function() {
        this.color(transparent);
      }
    },

    fill: {
      name: "Fill",
      hotkeys: ['F'],
      icon: imageDir + "fill.png",
      cursor: "url(" + imageDir + "fill.png) 12 13, default",
      mousedown: function(e, newColor, pixel) {
        // Store original pixel's color here
        var originalColor = this.color();

        // Return if original color is same as currentColor
        if(newColor === originalColor) {
          return;
        }

        var q = new Array();
        pixel.color(newColor);
        q.push(pixel);

        var canvas = pixel.canvas;

        while(q.length > 0) {
          pixel = q.pop();

          // Add neighboring pixels to the queue
          var neighbors = canvas.getNeighbors(pixel.x, pixel.y);

          $.each(neighbors, function(index, neighbor) {
            if(neighbor && neighbor.color() === originalColor) {
              neighbor.color(newColor);
              q.push(neighbor);
            }
          });
        }
      }
    },

    clone: CloneTool(),

    zoom_in: {
      name: "Zoom In",
      hotkeys: ['Z'],
      icon: imageDir + "zoom_in.png",
      cursor: "url(" + imageDir + "zoom_in.png) 12 13, default",
      mousedown: function() {
        scale = (scale * 2).clamp(0.25, 4);

        scaleCanvas(scale);
      }
    },

    zoom_out: {
      name: "Zoom Out",
      hotkeys: ['alt'],
      icon: imageDir + "zoom_out.png",
      cursor: "url(" + imageDir + "zoom_out.png) 12 13, default",
      mousedown: function() {
        scale = (scale / 2).clamp(0.25, 4);

        scaleCanvas(scale);
      }
    }
  };

  var falseFn = function() {return false};
  var div = '<div></div>';
  var ColorPicker = function() {
    return $('<input></input>').addClass('color').colorPicker();
  };

  var rgbParser = /^rgba?\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3}),?\s*(\d\.?\d*)?\)$/;

  var UndoStack = function() {
    var undos = [];
    var redos = [];
    var empty = true;

    return {
      last: function() {
        return undos[undos.length - 1];
      },

      popUndo: function() {
        var undo = undos.pop();

        if(undo) {
          redos.push(undo);
        }

        return undo;
      },

      popRedo: function() {
        var undo = redos.pop();

        if(undo) {
          undos.push(undo);
        }

        return undo;
      },

      next: function() {
        var last = this.last();
        if(!last || !empty) {
          undos.push({});
          empty = true;
          // New future, no more redos
          redos = [];
        }
      },

      add: function(object, data) {
        var last = undos[undos.length - 1];

        // Only store this objects data if it is not already present.
        if(!last[object]) {
          last[object] = data;
          empty = false;
        }

        return this;
      },

      replayData: function() {
        var replayData = [];

        $.each(undos, function(i, items) {
          replayData[i] = [];
          $.each(items, function(key, data) {
            var pixel = data.pixel;
            replayData[i].push({
              x: pixel.x,
              y: pixel.y,
              z: pixel.z,
              f: pixel.f,
              color: data.newColor
            });
          });
        });

        return replayData;
      }
    };
  };

  $.fn.pixie = function(options) {
    /**
     * A pixel class.
     * @name Pixie.Pixel
     * @constructor
     */
    var Pixel = function(x, y, z, f, layerCanvas, canvas, undoStack) {
      var color = transparent;

      var self = {
        x: x,
        y: y,
        z: z,
        f: f,

        canvas: canvas,

        toString: function() {
          return "[Pixel: " + [this.x, this.y, this.z, + this.f].join(",") + "]";
        },

        /**
         * If called with no arguments returns the String representing the color
         * of this pixel.
         *
         * If called with an argument sets this pixels color to the argument.
         *
         * @name color
         * @methodOf Pixie.Pixel#
         *
         * @param {String} [newColor] The color to set this pixel to
         * @param {Boolean} [skipUndo] True if this action should not be undoable.
         *
         * @returns String
         */
        color: function(newColor, skipUndo) {
          if(arguments.length >= 1) {
            if(!skipUndo) {
              undoStack.add(self, {pixel: self, oldColor: color, newColor: newColor});
            }

            color = newColor || transparent;

            // Draw
            layerCanvas.clearRect(x * pixelWidth, y * pixelHeight, pixelWidth, pixelHeight);
            layerCanvas.fillStyle = color;
            layerCanvas.fillRect(x * pixelWidth, y * pixelHeight, pixelWidth, pixelHeight);
            return this;
          } else {
            return color;
          }
        }
      };

      return self;
    };

    var Layer = function() {
      var layer = $("<canvas></canvas>").addClass('layer');
      var gridColor = "#000";
      var layerWidth = width * pixelWidth;
      var layerHeight = height * pixelHeight;

      var layerElement = layer.get(0);
      layerElement.width = layerWidth;
      layerElement.height = layerHeight;

      var context = layerElement.getContext("2d");

      return $.extend(layer, {
        clear: function() {
          context.clearRect(0, 0, width * pixelWidth, height * pixelHeight);
        },
        drawGuide: function() {
          context.fillStyle = gridColor;
          for(var i = 1; i < height; i++) {
            context.fillRect(0, i * pixelHeight, layerWidth, 1);
          }

          for(i = 1; i < width; i++) {
            context.fillRect(i * pixelWidth, 0, 1, layerHeight);
          }
        }
      });
    };

    options = options || {};
    var width = options.width || 8;
    var height = options.height || 8;
    var pixelWidth = options.pixelSize || 16;
    var pixelHeight = options.pixelSize || 16;
    var initializer = options.initializer;
    var layers = options.layers || 2;
    var frames = options.frames || 1;
    var lastClean;

    return this.each(function() {
      var pixie = $(div).addClass('pixie');
      var actionsMenu = $(div).addClass('actions');
      var viewport = $(div).addClass('viewport');
      var canvas = $(div).addClass('canvas');
      var toolbar = $(div).addClass('toolbar');
      var colorbar = $(div).addClass('toolbar');
      var swatches = $(div).addClass('swatches');
      var optionsModal = $('#optionsModal');
      var preview = $(div).addClass('preview').css({width: width, height: height});
      var previewToggleHolder = $(div).addClass('toggle_holder');
      var previewLabel = $('<label class=\'preview-control\'>Tiled Preview</label>').click(function() {
        if (previewToggle.attr('checked')) {
          previewToggle.removeAttr('checked');
          tilePreview = false;
        } else {
          previewToggle.attr('checked', 'true');
          tilePreview = true;
        }
        canvas.showPreview();
      });
      var previewToggle = $('<input class="preview-control" type="checkbox"></input>').change(function() {
        if($(this).attr('checked')) {
          tilePreview = true;
        } else {
          tilePreview = false;
        }
        canvas.showPreview();
      }).attr("checked", "true");

      canvas.addClass('nogrid');

      var guideToggleHolder = $(div).addClass('toggle_holder');
      var guideLabel = $('<label class=\'guide-control\'>Display Guides</label>').click(function() {

        if (guideToggle.attr('checked')) {
          guideToggle.removeAttr('checked');

          canvas.removeClass('grid').addClass('nogrid');
          guideLayer.clear();
        } else {
          guideToggle.attr('checked', 'true');
          canvas.removeClass('nogrid').addClass('grid');
          guideLayer.drawGuide();
        }
      });

      var guideToggle = $('<input class="guide-control" type="checkbox"></input>').change(function() {
        if(!$(this).attr('checked')) {
          canvas.removeClass('grid').addClass('nogrid');
          guideLayer.clear();
        } else {
          canvas.removeClass('nogrid').addClass('grid');
          guideLayer.drawGuide();
        }
      });

      var layerMenu = $(div).addClass('layers').prepend('<h3>Layer:</h3>');
      var frameMenu = $(div).addClass('actions').prepend('<h3>Frame:</h3>');
      var previewMenu = $(div).prepend('<h3>Preview:</h3>');

      var undoStack = UndoStack();

      var currentTool = undefined;
      var active = false;
      var layer = 0;
      var editingLayers = [];
      var frame = 0;
      var mode = undefined;
      var replaying = false;
      var initialStateData = undefined;

      var primaryColorPicker = ColorPicker().addClass('primary');
      var secondaryColorPicker = ColorPicker().addClass('secondary');
      var tilePreview = true;

      var colorPickerHolder = $(div)
        .addClass('color_picker_holder')
        .append(primaryColorPicker)
        .append(secondaryColorPicker);

      colorbar.append(colorPickerHolder);
      colorbar.append(swatches);

      pixie
        .bind('contextmenu', falseFn)
        .bind("mousedown", function(e){
          var target = $(e.target);

          if(target.is(".swatch")) {
            canvas.color(target.css('backgroundColor'), e.button !== 0);
          }
        })
        .bind("mouseup", function(e) {
          active = false;
          mode = undefined;

          // Update Preview
          canvas.showPreview();
        });

      var pixels = [];

      for(frame = 0; frame < frames; frame++) {
        var frameDiv = $(div).addClass("frame");

        if(frame == 0) {
          frameDiv.addClass("current");
        }

        editingLayers[frame] = [];
        pixels[frame] = [];

        for(layer = 0; layer < layers; layer++) {
          var layerDiv = Layer();
          editingLayers[frame][layer] = layerDiv;

          if(layer == 0) {
            layerDiv.addClass('bottom');
          }

          pixels[frame][layer] = [];

          for(var row = 0; row < height; row++) {
            pixels[frame][layer][row] = [];

            for(var col = 0; col < width; col++) {
              var pixel = Pixel(col, row, layer, frame, layerDiv.get(0).getContext('2d'), canvas, undoStack);
              pixels[frame][layer][row][col] = pixel;
            }
          }

          frameDiv.append(layerDiv);
        }

        canvas.append(frameDiv);
      }

      var lastPixel = undefined;
      var guideLayer = Layer()
        .bind("mousedown", function(e) {
          undoStack.next();
          active = true;
          if(e.button === 0) {
            mode = "P";
          } else {
            mode = "S";
          }

          e.preventDefault();
        })
        .bind("mousedown mousemove", function(event) {
          var offset = $(this).offset();

          var localY = (event.pageY - offset.top) / scale;
          var localX = (event.pageX - offset.left) / scale;

          var row = Math.floor(localY / pixelHeight);
          var col = Math.floor(localX / pixelWidth);

          var pixel = canvas.getPixel(col, row, layer);
          var eventType = undefined;

          // TODO: This is crufty...
          if(event.type == "mousedown") {
            eventType = event.type;
          } else if(pixel && pixel != lastPixel && event.type == "mousemove") {
            eventType = "mouseenter";
          }

          if(pixel && active && currentTool && currentTool[eventType]) {
            currentTool[eventType].call(pixel, event, canvas.color(), pixel);
          }

          lastPixel = pixel;
        });

      guideLayer.html("<p>Can't use the editor? You may need <a href='http://www.google.com/chrome'>a browser that supports HTML5 Canvas</a></p>");

      canvas.append(guideLayer);

      layer = layers - 1;
      frame = 0;

      /**
       * @name Pixie.Canvas
       * @constructor
       */
      $.extend(canvas, {
        // Just visually clear the layers, doesn't affect undos or data
        clear: function() {
          $.each(editingLayers, function() {
            $.each(this, function() {
              this.clear();
            });
          });
        },

        /**
         * Iterate through each pixel, yielding it to the iterator function.
         * @name eachPixel
         * @methodOf Pixie.Canvas#
         *
         * @param {Number} fn The iterator function that will receive three arguments
         * for each pixel in the current layer and frame: the pixel, the column, the row.
         * @param {Number} [z] The layer coordinate, defaults to the current layer
         * @param {Number} [f] The frame coordinate, defaults to the current frame
         *
         * @return this, for chaining
         * @type Pixie.Canvas
         */
        eachPixel: function(fn, z, f) {
          if(z === undefined) {
            z = layer;
          }

          if(f === undefined) {
            f = frame;
          }

          for(row = 0; row < height; row++) {
            for(col = 0; col < width; col++) {
              var pixel = pixels[f][z][row][col];
              fn.call(pixel, pixel, col, row);
            }
          }

          return canvas;
        },

        /**
         * Gets the pixel at the specified coordinates.
         * @name getPixel
         * @methodOf Pixie.Canvas#
         *
         * @param {Number} x The x coordinate
         * @param {Number} y The y coordinate
         * @param {Number} [z] The layer coordinate, defaults to the current layer
         * @param {Number} [f] The frame coordinate, defaults to the current frame
         *
         * @return The pixel at the specified coordinates, undefined if no pixel
         * is present
         * @type Pixie.Pixel
         */
        getPixel: function(x, y, z, f) {
          if(z === undefined) {
            z = layer;
          }

          if(f === undefined) {
            f = frame;
          }

          if(y >= 0 && y < height) {
            if(x >= 0 && x < width) {
              return pixels[f][z][y][x];
            }
          }

          return undefined;
        },

        /**
         * Gets an array containing the four adjacent pixels to the coordinates
         * specified.
         * @name getNeighbors
         * @methodOf Pixie.Canvas#
         *
         * @param {Number} x The x coordinate
         * @param {Number} y The y coordinate
         * @param {Number} [z] The layer coordinate, defaults to the current layer
         * @param {Number} [f] The frame coordinate, defaults to the current frame
         *
         * @return An array containing the results from calling getPixel for each
         * adjacent coordinate
         * @type Array
         */
        getNeighbors: function(x, y, z, f) {
          if(z === undefined) {
            z = layer;
          }

          if(f === undefined) {
            f = frame
          }

          return [
            this.getPixel(x+1, y, z, f),
            this.getPixel(x, y+1, z, f),
            this.getPixel(x-1, y, z, f),
            this.getPixel(x, y-1, z, f)
          ];
        },

        toHex: function(bits) {
          var s = parseInt(bits).toString(16);
          if(s.length == 1) {
            s = '0' + s
          }
          return s;
        },

        parseColor: function(colorString) {
          if(!colorString || colorString == transparent) {
            return false;
          }

          var bits = rgbParser.exec(colorString);
          return [
            this.toHex(bits[1]),
            this.toHex(bits[2]),
            this.toHex(bits[3])
          ].join('').toUpperCase();
        },

        color: function(color, alternate) {
          // Handle cases where nothing, or only true or false is passed in
          // i.e. when getting the alternate color `canvas.color(true)`
          if(arguments.length === 0 || color === false) {
            return mode == "S" ?
              secondaryColorPicker.css('backgroundColor') :
              primaryColorPicker.css('backgroundColor');
          } else if(color === true) {
            // Switch color choice when alterate is true
            return mode == "S" ?
              primaryColorPicker.css('backgroundColor') :
              secondaryColorPicker.css('backgroundColor');
          }

          var parsedColor;
          if(color[0] != "#") {
            parsedColor = "#" + (this.parseColor(color) || "FFFFFF");
          } else {
            parsedColor = color;
          }

          if((mode == "S") ^ alternate) {
            secondaryColorPicker.val(parsedColor);
            secondaryColorPicker[0].onblur();
          } else {
            primaryColorPicker.val(parsedColor);
            primaryColorPicker[0].onblur();
          }

          return this;
        },

        dirty: function(newDirty) {
          if(newDirty !== undefined) {
            if(newDirty === false) {
              // Clear dirty
              lastClean = undoStack.last();
            }

            return this;
          } else {
            return lastClean != undoStack.last();
          }
        },

        addSwatch: function(color) {
          swatches.append(
            $(div)
              .addClass('swatch')
              .css({backgroundColor: color})
          );
        },

        addAction: function(action) {
          var titleText = action.name;
          var undoable = action.undoable;

          function doIt() {
            if(undoable !== false) {
              undoStack.next();
            }
            action.perform(canvas);
          }

          if(action.hotkeys) {
            titleText += " ("+ action.hotkeys +")";

            $.each(action.hotkeys, function(i, hotkey) {
              $(document).bind('keydown', hotkey, function(e) {
                doIt();
                e.preventDefault();

                canvas.showPreview();

                return false;
              });
            });
          }

          if(action.menu !== false) {
            if(action.icon) {
              var iconImg = new Image();
              iconImg.src = action.icon;
            }

            var actionButton = $("<a id='action-button-" + action.name.replace(" ", "-").toLowerCase() + "' href='#' title='"+ titleText +"'>"+ action.name +"</a>")
              .prepend(iconImg)
              .addClass((action.cssClass) ? action.cssClass : '')
              .addClass('tool button')
              .click(function(e) {
                if(!$(this).attr("disabled")) {
                  doIt();
                }

                _gaq.push(['_trackEvent', 'action_button', action.name]);

                return false;
              });

            actionButton.appendTo(actionsMenu);
          }
        },

        /**
         * Adds a tool to be used with the canvas.
         * @name addTool
         * @methodOf Pixie.Canvas#
         *
         * @param {Pixie.Tool} tool
         */
        addTool: function(tool) {
          var alt = tool.name;

          function setMe() {
            canvas.setTool(tool);
            toolbar.children().removeClass("active");
            toolDiv.addClass("active");
          }

          if(tool.hotkeys) {
            alt += " ("+ tool.hotkeys +")";

            $.each(tool.hotkeys, function(i, hotkey) {
              $(document).bind('keydown', hotkey, function(e) {
                setMe();
                e.preventDefault();
              });
            });
          }

          var toolDiv = $("<div><img src='"+ tool.icon +"' alt='"+ alt +"' title='"+ alt +"'></img></div>")
            .addClass('tool')
            .click(function(e) {
              setMe();
              return false;
            });

          toolbar.append(toolDiv);
        },

        setTool: function(tool) {
          currentTool = tool;
          if(tool.cursor) {
            canvas.css({cursor: tool.cursor});
          } else {
            canvas.css({cursor: "pointer"});
          }
        },

        toCSSImageURL: function() {
          return 'url(' + this.toDataURL() + ')';
        },

        toDataURL: function(f) {
          var canvas = $('<canvas width="' + width + '" height="' + height+ '"></canvas>').get(0);
          var context = canvas.getContext('2d');

          for(var z = 0; z < layers; z++) {
            this.eachPixel(function(pixel, x, y) {
              var color = pixel.color();

              context.fillStyle = color;
              context.fillRect(x, y, 1, 1);
            }, z, f);
          }

          return canvas.toDataURL("image/png");
        },

        toBase64: function(f) {
          var data = this.toDataURL(f);
          return data.substr(data.indexOf(',') + 1);
        },

        fromDataURL: function(dataURL) {
          var context = document.createElement('canvas').getContext('2d');

          var image = new Image();
          image.onload = function() {
            context.drawImage(image, 0, 0);
            var imageData = context.getImageData(0, 0, image.width, image.height);

            function getColor(x, y) {
              var index = (x + y * imageData.width) * 4
              return "rgba(" + [
                imageData.data[index  + 0],
                imageData.data[index  + 1],
                imageData.data[index  + 2],
                imageData.data[index  + 3]/255
              ].join(',') + ")"
            }

            canvas.eachPixel(function(pixel, x, y) {
              pixel.color(getColor(x, y), true);
            });
          };

          image.src = dataURL;
        },

        getReplayData: function() {
          return undoStack.replayData();
        },

        replay: function(steps) {
          if(!replaying) {
            replaying = true;
            var canvas = this;

            if(!steps) {
              steps = this.getReplayData();
              canvas.displayInitialState();
            } else {
              canvas.clear();
            }

            var i = 0;
            var delay = 200;

            function runStep() {
              var step = steps[i];

              if(step) {
                $.each(step, function(j, p) {
                  canvas.getPixel(p.x, p.y, p.z, p.f).color(p.color, true);
                });

                i++;

                setTimeout(runStep, delay);
              } else {
                replaying = false;
              }
            }
            setTimeout(runStep, delay);
          }
        },

        frameDataToBase64: function() {
          var frameData = [];
          for(var f = 0; f < frames; f++) {
            frameData[f] = this.toBase64(f);
          }
          return frameData;
        },

        setInitialState: function(frameData) {
          initialStateData = frameData;

          this.displayInitialState();
        },

        displayInitialState: function() {
          this.clear();

          if(initialStateData) {
            $.each(initialStateData, function(f, data) {
              canvas.eachPixel(function(pixel, x, y) {
                var pos = x + y*canvas.width;
                pixel.color(data[pos], true);
              }, undefined, f);
            });
          }
        },

        showPreview: function() {
          var tileCount = tilePreview ? 4 : 1;
          preview.css({
            backgroundImage: this.toCSSImageURL(),
            width: tileCount * width,
            height: tileCount * height
          });
        },

        undo: function() {
          var data = undoStack.popUndo();

          if(data) {
            $.each(data, function() {
              this.pixel.color(this.oldColor, true);
            });
          }
        },

        redo: function() {
          var data = undoStack.popRedo();

          if(data) {
            $.each(data, function() {
              this.pixel.color(this.newColor, true);
            });
          }
        },

        width: width,
        height: height
      });

      $.each(actions, function(key, action) {
        canvas.addAction(action);
      });

      $.each(["#000", "#FFF", "#666", "#DCDCDC", "#EB070E", "#F69508", "#FFDE49", "#388326", "#0246E3", "#563495", "#58C4F5", "#E5AC99", "#5B4635", "#FFFEE9"], function(i, color) {
        canvas.addSwatch(color);
      });

      $.each(tools, function(key, tool) {
        canvas.addTool(tool);
      });

      canvas.setTool(tools.pencil);
      toolbar.children().eq(0).addClass("active");

      // Set up layer and frame menus
      for(var i = layers-1; i >= 0; i--) {
        (function(currentLayer) {
          var layerName;

          if(currentLayer == 0) {
            layerName = "Background";
          } else if(currentLayer == 1) {
            layerName = "Foreground";
          } else {
            layerName = "Layer " + currentLayer;
          }

          var layerSelection = $("<a href='#' title='Layer "+ currentLayer +"'>"+ layerName +"</a>")
            .addClass('tool')
            .bind("mousedown", function(e) {
              layer = currentLayer;
              layerMenu.children().removeClass("active");
              $(this).addClass("active");
            })
            .click(falseFn)

          if(currentLayer == layers - 1) {
            layerSelection.addClass("active");
          }

          layerMenu.append(layerSelection);
        })(i);
      }

      for(i = 0; i < frames; i++) {
        (function(currentFrame) {
          var frameSelection = $("<a href='#' title='Frame "+ currentFrame +"'>" + currentFrame + "</a>")
            .addClass('tool')
            .bind("mousedown", function(e) {
              frame = currentFrame;
              frameMenu.children().removeClass("active");
              $(this).addClass("active");

              var frameElement = canvas.children().eq(currentFrame);
              frameElement.addClass("current");
              frameElement.siblings().removeClass("current");
            })
            .click(falseFn)

          if(currentFrame === 0) {
            frameSelection.addClass("active");
          }

          frameMenu.append(frameSelection);
        })(i);
      }

      viewport.append(canvas);

      previewToggleHolder
        .append(previewToggle)
        .append(previewLabel);

      guideToggleHolder
        .append(guideToggle)
        .append(guideLabel);

      optionsModal
        .append(guideToggleHolder)
        .append(previewToggleHolder)

      colorbar
        .append(layerMenu)
        .append(previewMenu)
        .append(preview);

      pixie
        .append(actionsMenu)
        .append(toolbar)
        .append(viewport)
        .append(colorbar)

      if(frames > 1) {
        pixie.append(frameMenu);
      }

      if(initializer) {
        initializer(canvas);
      }

      lastClean = undoStack.last();

      $(this).append(pixie);

      canvas.showPreview();

      if (width * pixelWidth > 512 || height * pixelHeight > 512) {
        $('.pixie .viewport').css('overflow', 'auto');
      }
    });
  };
})(jQuery);
