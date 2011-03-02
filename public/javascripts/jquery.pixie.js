/* DO NOT MODIFY. This file was compiled Wed, 02 Mar 2011 09:41:39 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.pixie.coffee
 */

(function() {
  (function($) {
    var ColorPicker, DIV, IMAGE_DIR, RGB_PARSER, TRANSPARENT, UndoStack, actions, colorNeighbors, colorTransparent, falseFn, scale, shiftImageHorizontal, shiftImageVertical, tools;
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
          if (!(last && empty)) {
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
    shiftImageHorizontal = function(canvas, byX) {
      var deferredColors, height, index, width;
      width = canvas.width;
      height = canvas.height;
      index = byX === -1 ? 0 : width - 1;
      deferredColors = [];
      height.times(function(y) {
        return deferredColors[y] = canvas.getPixel(index, y).color();
      });
      canvas.eachPixel(function(pixel, x, y) {
        var adjacentPixel;
        adjacentPixel = canvas.getPixel(x - byX, y);
        return pixel.color(adjacentPixel != null ? adjacentPixel.color() : void 0);
      });
      return $.each(deferredColors, function(y, color) {
        return canvas.getPixel(index, y).color(color);
      });
    };
    shiftImageVertical = function(canvas, byY) {
      var deferredColors, height, index, width;
      width = canvas.width;
      height = canvas.height;
      index = byY === -1 ? 0 : height - 1;
      deferredColors = [];
      width.times(function(x) {
        return deferredColors[x] = canvas.getPixel(x, index).color();
      });
      canvas.eachPixel(function(pixel, x, y) {
        var adjacentPixel;
        adjacentPixel = canvas.getPixel(x, y - byY);
        return pixel.color(adjacentPixel != null ? adjacentPixel.color() : void 0);
      });
      return $.each(deferredColors, function(x, color) {
        return canvas.getPixel(x, index).color(color);
      });
    };
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
      },
      left: {
        menu: false,
        perform: function(canvas) {
          return shiftImageHorizontal(canvas, -1);
        }
      },
      right: {
        menu: false,
        perform: function(canvas) {
          return shiftImageHorizontal(canvas, 1);
        }
      },
      up: {
        menu: false,
        perform: function(canvas) {
          return shiftImageVertical(canvas, -1);
        }
      },
      down: {
        menu: false,
        perform: function(canvas) {
          return shiftImageVertical(canavs, 1);
        }
      },
      download: {
        hotkeys: ["ctrl+s"],
        perform: function(canvas) {
          var w;
          w = window.open();
          return w.document.location = canvas.toDataURL();
        }
      },
      options: {
        hotkeys: ["o"],
        perform: function() {
          return $('#optionsModal').removeAttr('style').modal({
            persist: true,
            onClose: function() {
              $.modal.close();
              return $('#optionsModal').attr('style', 'display: none');
            }
          });
        }
      }
    };
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
          canvas = this.canvas;
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
    return $.fn.pixie = function(options) {
      var Layer, PIXEL_HEIGHT, PIXEL_WIDTH, Pixel, height, initializer, width;
      Pixel = function(x, y, layerCanvas, undoStack) {
        var color, self;
        color = TRANSPARENT;
        self = {
          x: x,
          y: y,
          canvas: layerCanvas,
          color: function(newColor, skipUndo) {
            var xPos, yPos;
            if (arguments.length >= 1) {
              if (!skipUndo) {
                undoStack.add(self, {
                  pixel: self,
                  oldColor: color,
                  newColor: newColor
                });
              }
              color = newColor || TRANSPARENT;
              xPos = x * PIXEL_WIDTH;
              yPos = y * PIXEL_HEIGHT;
              layerCanvas.clearRect(xPos, yPos, PIXEL_WIDTH, PIXEL_HEIGHT);
              layerCanvas.fillStyle = color;
              layerCanvas.fillRect(xPos, yPos, PIXEL_WIDTH, PIXEL_HEIGHT);
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
        var actionbar, active, canvas, colorPickerHolder, colorbar, currentTool, layer, mode, pixels, pixie, preview, primaryColorPicker, secondaryColorPicker, swatches, tilePreview, toolbar, undoStack, viewport;
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
        swatches = $(DIV, {
          "class": 'swatches'
        });
        colorbar = $(DIV, {
          "class": "toolbar"
        });
        actionbar = $(DIV, {
          "class": 'actions'
        });
        preview = $(DIV, {
          "class": 'preview',
          style: "width: " + width + "px; height: " + height + "px;"
        });
        currentTool = void 0;
        active = false;
        mode = void 0;
        undoStack = UndoStack();
        primaryColorPicker = ColorPicker().addClass('primary');
        secondaryColorPicker = ColorPicker().addClass('secondary');
        tilePreview = true;
        colorPickerHolder = $(DIV, {
          "class": 'color_picker_holder'
        }).append(primaryColorPicker, secondaryColorPicker);
        colorbar.append(colorPickerHolder, swatches);
        pixie.bind('contextmenu', falseFn).bind('mouseup keyup', function(e) {
          active = false;
          return mode = void 0;
        });
        $('nav.right').bind('mousedown', function(e) {
          var target;
          target = $(e.target);
          if (target.is('.swatch')) {
            return canvas.color(target.css('backgroundColor'), e.button !== 0);
          }
        });
        pixels = [];
        layer = Layer().bind("mousedown", function(e) {
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
        height.times(function(row) {
          pixels[row] = [];
          return width.times(function(col) {
            var pixel;
            pixel = Pixel(col, row, layer.get(0).getContext('2d'), undoStack);
            return pixels[row][col] = pixel;
          });
        });
        canvas.append(layer);
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
          addSwatch: function(color) {
            return swatches.append($(DIV, {
              "class": 'swatch',
              style: "background-color: " + color
            }));
          },
          addTool: function(name, tool) {
            var alt, img, setMe, toolDiv;
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
            img = $("<img />", {
              src: tool.icon,
              alt: alt,
              title: alt
            });
            toolDiv = $("<div />", {
              "class": "tool"
            }).append(img).mousedown(function(e) {
              setMe();
              return false;
            });
            return toolbar.append(toolDiv);
          },
          color: function(color, alternate) {
            debugger;            var parsedColor;
            if (arguments.length === 0 || color === false) {
              if (mode === "S") {
                return secondaryColorPicker.css('backgroundColor');
              } else {
                return primaryColorPicker.css('backgroundColor');
              }
            } else if (color === true) {
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
            return layer.clear();
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
            if (((0 <= y && y < height)) && ((0 <= x && x < width))) {
              return pixels[y][x];
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
            if (!(colorString || colorString === transparent)) {
              return false;
            }
            bits = RGB_PARSER.exec(colorString);
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
            canvas = $('<canvas />', {
              width: width,
              height: height
            }).get(0);
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
        $.each(["#000", "#FFF", "#666", "#DCDCDC", "#EB070E", "#F69508", "#FFDE49", "#388326", "#0246E3", "#563495", "#58C4F5", "#E5AC99", "#5B4635", "#FFFEE9"], function(i, color) {
          return canvas.addSwatch(color);
        });
        canvas.setTool(tools.pencil);
        viewport.append(canvas);
        $('nav.left').append(toolbar);
        $('nav.top').append(actionbar);
        $('nav.right').append(colorbar, preview);
        pixie.append(viewport);
        return $(this).append(pixie);
      });
    };
  })(jQuery);
}).call(this);
