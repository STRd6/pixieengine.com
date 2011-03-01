/* DO NOT MODIFY. This file was compiled Tue, 01 Mar 2011 09:26:46 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.pixie.coffee
 */

(function() {
  (function($) {
    var ColorPicker, DIV, IMAGE_DIR, RGB_PARSER, TRANSPARENT, UndoStack, actions, colorNeighbors, colorTransparent, falseFn, scale, tools;
    DIV = "<div />";
    TRANSPARENT = "transparent";
    IMAGE_DIR = "/images/pixie/";
    RGB_PARSER = /^rgba?\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3}),?\s*(\d\.?\d*)?\)$/;
    scale = 1;
    falseFn = function() {
      return false;
    };
    ColorPicker = function() {
      return $('<input />', {
        "class": 'color'
      }).colorPicker();
    };
    UndoStack = function() {
      var empty, redos, undos;
      undos = [];
      redos = [];
      empty = true;
      return {
        last: function() {
          return undos[undos.length - 1];
        },
        popUndo: function() {
          var undo;
          undo = undos.pop();
          if (undo) {
            redos.push(undo);
          }
          return undo;
        },
        popRedo: function() {
          var undo;
          undo = redos.pop();
          if (undo) {
            undos.push(undo);
          }
          return undo;
        },
        next: function() {
          var last;
          last = this.last();
          if (!last || !empty) {
            undos.push({});
            empty = true;
            return redos = [];
          }
        },
        add: function(object, data) {
          var last;
          last = this.last();
          if (!last[object]) {
            last[object] = data;
            empty = false;
          }
          return this;
        },
        replayData: function() {
          var replayData;
          replayData = [];
          $.each(undos, function(i, items) {
            replayData[i] = [];
            return $.each(items, function(key, data) {
              var pixel;
              pixel = data.pixel;
              return replayData[i].push({
                x: pixel.x,
                y: pixel.y,
                color: data.newColor
              });
            });
          });
          return replayData;
        }
      };
    };
    /*
    infer action name and icon from key in json data.
    assume menu == false when there is no icon key in the data
    if no hotkey try to bind to the name of the json object key
    */
    /*
    shiftImage = (canvas, x, y) ->
      width = canvas.width
      height = canvas.height

      deferredColors = []

      if x?.abs() > 0
        height.times (y) ->
          # some mod stuff here to get the first column with x = 1 and the last with x = -1
          deferredColors[y] = canvas.getPixel(0, width), y).color()
      if y?.abs() > 0
        width.times (x) ->
          deferredColors[x] = canvas.getPixel(x, 0).color()

      canvas.eachPixel (pixel, x, y) ->
        adjacentPixel = canvas.getPixel(x + 1, y)

        pixel.color(adjacentPixel?.color())

      $.each deferredColors, (y, color) ->
        canvas.getPixel(width - 1, y).color(color)
    */
    actions = {
      undo: {
        hotkeys: ["ctrl+z", "meta+z"],
        perform: function(canvas) {
          return canvas.undo();
        }
      },
      redo: {
        hotkeys: ["ctrl+y", "meta+z"],
        perform: function(canvas) {
          return canvas.redo();
        }
      },
      clear: {
        perform: function(canvas) {
          return canvas.eachPixel(function(pixel) {
            return pixel.color(TRANSPARENT);
          });
        }
      },
      preview: {
        menu: false,
        perform: function(canvas) {
          return canvas.preview();
        }
      }
    };
    /*
      left:
        perform: (canvas) ->
          #shiftImage(canvas, -1, 0)
      right:
        perform: (canvas) ->
          #shiftImage(canvas, 1, 0)
      up:
        perform: (canvas) ->
          #shiftImage(canvas, 0, -1)
      down:
        perform: (canvas) ->
          #shiftImage(canavs, 0, 1)
      download:
        hotkeys: ["ctrl+s"]
        perform: (canvas) ->
          #w = window.open()
          #w.document.location = canvas.toDataURL()
      options:
        hotkeys: ["o"]
        perform: ->
          # $('#optionsModal').removeAttr('style').modal(
          #   persist: true
          # ,
          # onClose: ->
          #   $.modal.close()
          #   $('#optionsModal').attr('style', 'display: none')
          # )
    */
    colorNeighbors = function(color) {
      this.color(color);
      return $.each(this.canvas.getNeighbors(this.x, this.y), function(i, neighbor) {
        return neighbor != null ? neighbor.color(color) : void 0;
      });
    };
    colorTransparent = function() {
      return this.color(TRANSPARENT);
    };
    tools = {
      pencil: {
        hotkeys: ['p'],
        mousedown: function(e, color) {
          return this.color(color);
        },
        mouseenter: function(e, color) {
          return this.color(color);
        }
      },
      brush: {
        hotkeys: ['b'],
        mousedown: function(e, color) {
          return colorNeighbors.call(this, color);
        },
        mouseenter: function(e, color) {
          return colorNeighbors.call(this, color);
        }
      },
      dropper: {
        hotkeys: ['i'],
        mousedown: function() {
          this.canvas.color(this.color());
          return this.canvas.setTool(tools.pencil);
        }
      },
      eraser: {
        hotkeys: ['e'],
        mousedown: function() {
          return colorTransparent.call(this);
        },
        mouseenter: function() {
          return colorTransparent.call(this);
        }
      },
      fill: {
        hotkeys: ['f'],
        mousedown: function(e, newColor, pixel) {
          var canvas, neighbors, originalColor, q, _results;
          originalColor = this.color();
          if (newColor === originalColor) {
            return;
          }
          q = [];
          pixel.color(newColor);
          q.push(pixel);
          canvas = pixel.canvas;
          _results = [];
          while (q.length) {
            pixel = q.pop();
            neighbors = canvas.getNeighbors(pixel.x, pixel.y);
            _results.push($.each(neighbors, function(index, neighbor) {
              if ((neighbor != null ? neighbor.color() : void 0) === originalColor) {
                neighbor.color(newColor);
                return q.push(neighbor);
              }
            }));
          }
          return _results;
        }
      }
    };
    /*
      zoomIn:
        mousedown: ->
          scale = (scale * 2).clamp(0.25, 4)
          scaleCanvas(scale)
      zoomOut:
        mousedown: ->
          scale = (scale / 2).clamp(0.25, 4)
          scaleCanvas(scale)
    */
    return $.fn.pixie = function(options) {
      var Layer, PIXEL_HEIGHT, PIXEL_WIDTH, Pixel, height, initializer, width;
      Pixel = function(x, y, layerCanvas, canvas, undoStack) {
        var color, self;
        color = TRANSPARENT;
        self = {
          x: x,
          y: y,
          canvas: canvas,
          color: function(newColor, skipUndo) {
            if (arguments.length >= 1) {
              if (!skipUndo) {
                undoStack.add(self, {
                  pixel: self,
                  oldColor: color,
                  newColor: newColor
                });
              }
              color = newColor || TRANSPARENT;
              layerCanvas.clearRect(x * PIXEL_WIDTH, y * PIXEL_HEIGHT, PIXEL_WIDTH, PIXEL_HEIGHT);
              layerCanvas.fillStyle = color;
              layerCanvas.fillRect(x * PIXEL_WIDTH, y * PIXEL_HEIGHT, PIXEL_WIDTH, PIXEL_HEIGHT);
              return this;
            } else {
              return color;
            }
          },
          toString: function() {
            return "[Pixel: " + [this.x, this.y].join(",") + "]";
          }
        };
        return self;
      };
      Layer = function() {
        var context, gridColor, layer, layerElement, layerHeight, layerWidth;
        layer = $("<canvas />", {
          "class": "layer"
        });
        gridColor = "#000";
        layerWidth = width * PIXEL_WIDTH;
        layerHeight = height * PIXEL_HEIGHT;
        layerElement = layer.get(0);
        layerElement.width = layerWidth;
        layerElement.height = layerHeight;
        context = layerElement.getContext("2d");
        return $.extend(layer, {
          clear: function() {
            return context.clearRect(0, 0, width * PIXEL_WIDTH, height * PIXEL_HEIGHT);
          },
          drawGuide: function() {
            context.fillStyle = gridColor;
            height.times(function(row) {
              return context.fillRect(0, row * PIXEL_HEIGHT, layerWidth, 1);
            });
            return width.times(function(col) {
              return context.fillRect(col * PIXEL_WIDTH, 0, 1, layerHeight);
            });
          }
        });
      };
      PIXEL_WIDTH = 16;
      PIXEL_HEIGHT = 16;
      options || (options = {});
      width = options.width || 8;
      height = options.height || 8;
      initializer = options.initializer;
      return this.each(function() {
        var actionbar, active, canvas, currentTool, editingLayers, frameDiv, guideLayer, layerDiv, mode, pixels, pixie, preview, primaryColorPicker, secondaryColorPicker, tilePreview, toolbar, undoStack, viewport;
        pixie = $(DIV, {
          "class": 'pixie'
        });
        viewport = $(DIV, {
          "class": 'viewport'
        });
        canvas = $(DIV, {
          "class": 'canvas'
        });
        toolbar = $(DIV, {
          "class": 'toolbar'
        });
        actionbar = $(DIV, {
          "class": 'actions'
        });
        preview = $(DIV, {
          "class": 'preview',
          style: {
            width: width,
            height: height
          }
        });
        currentTool = void 0;
        active = false;
        editingLayers = [];
        mode = void 0;
        undoStack = UndoStack();
        primaryColorPicker = ColorPicker().addClass('primary');
        secondaryColorPicker = ColorPicker().addClass('secondary');
        tilePreview = true;
        pixie.bind('contextmenu', falseFn).bind('mousedown', function(e) {
          var target;
          target = $(e.target);
          if (target.is('.swatch')) {
            return canvas.color(target.css('backgroundColor'), e.button);
          }
        }).bind('mouseup keyup', function(e) {
          active = false;
          return mode = void 0;
        });
        pixels = [];
        frameDiv = $(DIV, {
          "class": "frame current"
        });
        layerDiv = Layer();
        editingLayers = layerDiv;
        height.times(function(row) {
          pixels[row] = [];
          return width.times(function(col) {
            var pixel;
            pixel = Pixel(col, row, layerDiv.get(0).getContext('2d'), canvas, undoStack);
            return pixels[row][col] = pixel;
          });
        });
        frameDiv.append(layerDiv);
        canvas.append(frameDiv);
        $.extend(canvas, {
          addAction: function(name, action) {
            var actionButton, doIt, iconImg, titleText, undoable;
            titleText = name;
            undoable = action.undoable;
            doIt = function() {
              if (undoable !== false) {
                undoStack.next();
              }
              return action.perform(canvas);
            };
            if (action.hotkeys) {
              titleText += " (" + action.hotkeys + ")";
              $.each(action.hotkeys, function(i, hotkey) {
                return $(document).bind('keydown', hotkey, function(e) {
                  doIt();
                  e.preventDefault();
                  return false;
                });
              });
            }
            if (action.menu !== false) {
              iconImg = $("<img />", {
                src: IMAGE_DIR + name + '.png'
              });
              actionButton = $("<a />", {
                "class": 'tool button',
                id: 'action_button_' + name.replace(" ", "-").toLowerCase(),
                href: '#',
                title: titleText,
                text: name
              }).prepend(iconImg).mousedown(function(e) {
                if (!$(this).attr('disabled')) {
                  doIt();
                }
                _gaq.push(['_trackEvent', 'action_button', action.name]);
                return false;
              });
              return actionButton.appendTo(actionbar);
            }
          },
          addTool: function(name, tool) {
            var alt, setMe, toolDiv;
            alt = name;
            tools[name].name = name;
            tools[name].icon = IMAGE_DIR + name + '.png';
            tools[name].cursor = 'url(' + IMAGE_DIR + name + '.png) 4 14, default';
            setMe = function() {
              canvas.setTool(tool);
              toolbar.children().removeClass("active");
              return toolDiv.addClass("active");
            };
            if (tool.hotkeys) {
              alt += " (" + tool.hotkeys + ")";
              $.each(tool.hotkeys, function(i, hotkey) {
                return $(document).bind('keydown', hotkey, function(e) {
                  setMe();
                  return e.preventDefault();
                });
              });
            }
            toolDiv = $("<div><img src='" + tool.icon + "' alt='" + alt + "' title='" + alt + "'></img></div>").addClass('tool').attr('data-icon_name', name).click(function(e) {
              setMe();
              return false;
            });
            return toolbar.append(toolDiv);
          },
          color: function(color, alternate) {
            var parsedColor;
            if (arguments.length === 0 || color === false) {
              if (mode === "S") {
                return secondaryColorPicker.css('backgroundColor');
              } else {
                return primaryColorPicker.css('backgroundColor');
              }
            } else if (color) {
              if (mode === "S") {
                return primaryColorPicker.css('backgroundColor');
              } else {
                return secondaryColorPicker.css('backgroundColor');
              }
            }
            parsedColor = null;
            if (color[0] !== "#") {
              parsedColor = "#" + (this.parseColor(color) || "FFFFFF");
            } else {
              parsedColor = color;
            }
            if ((mode === "S") ^ alternate) {
              secondaryColorPicker.val(parsedColor);
              secondaryColorPicker[0].onblur();
            } else {
              primaryColorPicker.val(parsedColor);
              primaryColorPicker[0].onblur();
            }
            return this;
          },
          clear: function() {
            return editingLayer.clear();
          },
          eachPixel: function(fn) {
            height.times(function(row) {
              return width.times(function(col) {
                var pixel;
                pixel = pixels[col][row];
                return fn.call(pixel, pixel, col, row);
              });
            });
            return canvas;
          },
          getPixel: function(x, y) {
            if (y >= 0 && y < height) {
              if (x >= 0 && x < width) {
                return pixels[y][x];
              }
            }
            return void 0;
          },
          getNeighbors: function(x, y) {
            return [this.getPixel(x + 1, y), this.getPixel(x, y + 1), this.getPixel(x - 1, y), this.getPixel(x, y - 1)];
          },
          toHex: function(bits) {
            var s;
            s = parseInt(bits).toString(16);
            if (s.length === 1) {
              s = '0' + s;
            }
            return s;
          },
          parseColor: function(colorString) {
            var bits;
            if (!colorString || colorString === transparent) {
              return false;
            }
            bits = rgbParser.exec(colorString);
            return [this.toHex(bits[1]), this.toHex(bits[2]), this.toHex(bits[3])].join('').toUpperCase();
          },
          preview: function() {
            var tileCount;
            tileCount = tilePreview ? 4 : 1;
            return preview.css({
              backgroundImage: this.toCSSImageURL(),
              width: tileCount * width,
              height: tileCount * height
            });
          },
          redo: function() {
            var data;
            data = undoStack.popRedo();
            if (data) {
              return $.each(data, function() {
                return this.pixel.color(this.oldColor, true);
              });
            }
          },
          setTool: function(tool) {
            currentTool = tool;
            return canvas.css('cursor', tool.cursor || "pointer");
          },
          toCSSImageURL: function() {
            return "url(" + (this.toDataURL()) + ")";
          },
          toDataURL: function() {
            var context;
            canvas = $('<canvas width="' + width + '" height="' + height + '"></canvas>').get(0);
            context = canvas.getContext('2d');
            this.eachPixel(function(pixel, x, y) {
              var color;
              color = pixel.color();
              context.fillStyle = color;
              return context.fillRect(x, y, 1, 1);
            });
            return canvas.toDataURL("image/png");
          },
          undo: function() {
            var data;
            data = undoStack.popUndo();
            if (data) {
              return $.each(data, function() {
                return this.pixel.color(this.oldColor, true);
              });
            }
          }
        });
        $.each(tools, function(key, tool) {
          return canvas.addTool(key, tool);
        });
        $.each(actions, function(key, action) {
          return canvas.addAction(key, action);
        });
        guideLayer = Layer().bind("mousedown", function(e) {
          undoStack.next();
          active = true;
          if (e.button === 0) {
            mode = "P";
          } else {
            mode = "S";
          }
          return e.preventDefault();
        }).bind("mousedown mousemove", function(event) {
          var col, eventType, localX, localY, offset, pixel, row;
          offset = $(this).offset();
          localY = event.pageY - offset.top;
          localX = event.pageX - offset.left;
          row = Math.floor(localY / PIXEL_HEIGHT);
          col = Math.floor(localX / PIXEL_WIDTH);
          pixel = canvas.getPixel(col, row);
          eventType = void 0;
          if (event.type === "mousedown") {
            eventType = event.type;
          } else if (pixel && event.type === "mousemove") {
            eventType = "mouseenter";
          }
          if (pixel && active) {
            return currentTool[eventType].call(pixel, event, canvas.color(), pixel);
          }
        });
        canvas.setTool(tools.pencil);
        canvas.append(guideLayer);
        viewport.append(canvas);
        $('nav.left').append(toolbar);
        $('nav.top').append(actionbar);
        $('nav.bottom').append(preview);
        pixie.append(viewport);
        return $(this).append(pixie);
      });
    };
  })(jQuery);
}).call(this);
