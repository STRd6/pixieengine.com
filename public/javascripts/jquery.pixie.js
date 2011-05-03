/* DO NOT MODIFY. This file was compiled Tue, 03 May 2011 18:31:31 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/jquery.pixie.coffee
 */

(function() {
  (function($) {
    var ColorPicker, ColorUtil, DEBUG, DIV, IMAGE_DIR, RGB_PARSER, UndoStack, actions, colorNeighbors, debugTools, erase, falseFn, palette, scale, tools;
    DEBUG = false;
    DIV = "<div />";
    IMAGE_DIR = "/images/pixie/";
    RGB_PARSER = /^rgba?\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3}),?\s*(\d\.?\d*)?\)$/;
    scale = 1;
    ColorUtil = {
      additive: function(c1, c2) {
        var A, B, G, R, a, ax, b, bx, g, gx, r, rx, _ref, _ref2;
        _ref = c1.channels(), R = _ref[0], G = _ref[1], B = _ref[2], A = _ref[3];
        _ref2 = c2.channels(), r = _ref2[0], g = _ref2[1], b = _ref2[2], a = _ref2[3];
        if (a === 0) {
          return c1;
        }
        if (A === 0) {
          return c2;
        }
        ax = 1 - (1 - a) * (1 - A);
        rx = (r * a / ax + R * A * (1 - a) / ax).round().clamp(0, 255);
        gx = (g * a / ax + G * A * (1 - a) / ax).round().clamp(0, 255);
        bx = (b * a / ax + B * A * (1 - a) / ax).round().clamp(0, 255);
        return Color(rx, gx, bx, ax);
      },
      replace: function(c1, c2) {
        return c2;
      }
    };
    palette = ["#000000", "#FFFFFF", "#666666", "#DCDCDC", "#EB070E", "#F69508", "#FFDE49", "#388326", "#0246E3", "#563495", "#58C4F5", "#E5AC99", "#5B4635", "#FFFEE9"];
    falseFn = function() {
      return false;
    };
    ColorPicker = function() {
      return $('<input/>', {
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
          var redo;
          redo = redos.pop();
          if (redo) {
            undos.push(redo);
          }
          return redo;
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
          if (last[object]) {
            last[object].newColor = data.newColor;
          } else {
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
                color: data.newColor.toString()
              });
            });
          });
          return replayData;
        }
      };
    };
    actions = {
      undo: {
        hotkeys: ['ctrl+z', 'meta+z'],
        perform: function(canvas) {
          return canvas.undo();
        },
        undoable: false
      },
      redo: {
        hotkeys: ["ctrl+y", "meta+z"],
        perform: function(canvas) {
          return canvas.redo();
        },
        undoable: false
      },
      clear: {
        perform: function(canvas) {
          return canvas.eachPixel(function(pixel) {
            return pixel.color(Color().toString(), false, "replace");
          });
        }
      },
      preview: {
        menu: false,
        perform: function(canvas) {
          return canvas.preview();
        },
        undoable: false
      },
      left: {
        hotkeys: ["left"],
        menu: false,
        perform: function(canvas) {
        var deferredColors = [];

        canvas.height.times(function(y) {
          deferredColors[y] = canvas.getPixel(0, y).color();
        });

        canvas.eachPixel(function(pixel, x, y) {
          var rightPixel = canvas.getPixel(x + 1, y);

          if(rightPixel) {
            pixel.color(rightPixel.color(), false, 'replace');
          } else {
            pixel.color(Color(), false, 'replace')
          }
        });

        $.each(deferredColors, function(y, color) {
          canvas.getPixel(canvas.width - 1, y).color(color);
        });
      }
      },
      right: {
        hotkeys: ["right"],
        menu: false,
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
              currentPixel.color(leftPixel.color(), false, 'replace');
            } else {
              currentPixel.color(Color(), false, 'replace');
            }
          }
        }

        $.each(deferredColors, function(y, color) {
          canvas.getPixel(0, y).color(color);
        });
      }
      },
      up: {
        hotkeys: ["up"],
        menu: false,
        perform: function(canvas) {
        var deferredColors = [];

        canvas.width.times(function(x) {
          deferredColors[x] = canvas.getPixel(x, 0).color();
        });

        canvas.eachPixel(function(pixel, x, y) {
          var lowerPixel = canvas.getPixel(x, y + 1);

          if(lowerPixel) {
            pixel.color(lowerPixel.color(), false, 'replace');
          } else {
            pixel.color(Color(), false, 'replace');
          }
        });

        $.each(deferredColors, function(x, color) {
          canvas.getPixel(x, canvas.height - 1).color(color);
        });
      }
      },
      down: {
        hotkeys: ["down"],
        menu: false,
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
              currentPixel.color(upperPixel.color(), false, 'replace');
            } else {
              currentPixel.color(Color(), false, 'replace');
            }
          }
        }

        $.each(deferredColors, function(x, color) {
          canvas.getPixel(x, 0).color(color);
        });
      }
      },
      download: {
        hotkeys: ["ctrl+s"],
        perform: function(canvas) {
          var w;
          w = window.open();
          return w.document.location = canvas.toDataURL();
        },
        undoable: false
      }
    };
    colorNeighbors = function(color) {
      this.color(color);
      return $.each(this.canvas.getNeighbors(this.x, this.y), function(i, neighbor) {
        return neighbor != null ? neighbor.color(color) : void 0;
      });
    };
    erase = function(pixel, opacity) {
      var inverseOpacity, pixelColor;
      inverseOpacity = 1 - opacity;
      pixelColor = pixel.color();
      return pixel.color(Color(pixelColor.toString(), pixelColor.a() * inverseOpacity), false, "replace");
    };
    tools = {
      pencil: {
        cursor: "url(" + IMAGE_DIR + "pencil.png) 4 14, default",
        hotkeys: ['p', '1'],
        mousedown: function(e, color) {
          return this.color(color);
        },
        mouseenter: function(e, color) {
          return this.color(color);
        }
      },
      brush: {
        cursor: "url(" + IMAGE_DIR + "brush.png) 4 14, default",
        hotkeys: ['b', '2'],
        mousedown: function(e, color) {
          return colorNeighbors.call(this, color);
        },
        mouseenter: function(e, color) {
          return colorNeighbors.call(this, color);
        }
      },
      dropper: {
        cursor: "url(" + IMAGE_DIR + "dropper.png) 13 13, default",
        hotkeys: ['i', '3'],
        mousedown: function() {
          this.canvas.color(this.color());
          return this.canvas.setTool(tools.pencil);
        },
        mouseup: function() {
          return this.canvas.setTool(tools.pencil);
        }
      },
      eraser: {
        cursor: "url(" + IMAGE_DIR + "eraser.png) 4 11, default",
        hotkeys: ['e', '4'],
        mousedown: function(e, color, pixel) {
          return erase(pixel, color.a());
        },
        mouseenter: function(e, color, pixel) {
          return erase(pixel, color.a());
        }
      },
      fill: {
        cursor: "url(" + IMAGE_DIR + "fill.png) 12 13, default",
        hotkeys: ['f', '5'],
        mousedown: function(e, newColor, pixel) {
          var canvas, neighbors, originalColor, q, _results;
          originalColor = this.color();
          if (newColor.equals(originalColor)) {
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
              if (neighbor != null ? neighbor.color().equals(originalColor) : void 0) {
                neighbor.color(newColor);
                return q.push(neighbor);
              }
            }));
          }
          return _results;
        }
      }
    };
    debugTools = {
      inspector: {
        mousedown: function() {
          return console.log(this.color());
        }
      }
    };
    return $.fn.pixie = function(options) {
      var Layer, PIXEL_HEIGHT, PIXEL_WIDTH, Pixel, height, initializer, width;
      Pixel = function(x, y, layerCanvas, canvas, undoStack) {
        var color, redraw, self;
        color = Color();
        redraw = function() {
          var xPos, yPos;
          xPos = x * PIXEL_WIDTH;
          yPos = y * PIXEL_HEIGHT;
          layerCanvas.clearRect(xPos, yPos, PIXEL_WIDTH, PIXEL_HEIGHT);
          layerCanvas.fillStyle = color.toString();
          return layerCanvas.fillRect(xPos, yPos, PIXEL_WIDTH, PIXEL_HEIGHT);
        };
        self = {
          canvas: canvas,
          redraw: redraw,
          color: function(newColor, skipUndo, blendMode) {
            var oldColor;
            if (arguments.length >= 1) {
              blendMode || (blendMode = "additive");
              oldColor = Color(color);
              color = ColorUtil[blendMode](Color(oldColor), Color(newColor));
              redraw();
              if (!skipUndo) {
                undoStack.add(self, {
                  pixel: self,
                  oldColor: oldColor,
                  newColor: color
                });
              }
              return self;
            } else {
              return Color(color);
            }
          },
          toString: function() {
            return "[Pixel: " + [this.x, this.y].join(",") + "]";
          },
          x: x,
          y: y
        };
        return self;
      };
      Layer = function() {
        var context, gridColor, layer, layerElement, layerHeight, layerWidth;
        layer = $("<canvas />", {
          "class": "layer"
        });
        gridColor = "#000";
        layerWidth = function() {
          return width * PIXEL_WIDTH;
        };
        layerHeight = function() {
          return height * PIXEL_HEIGHT;
        };
        layerElement = layer.get(0);
        layerElement.width = layerWidth();
        layerElement.height = layerHeight();
        context = layerElement.getContext("2d");
        return $.extend(layer, {
          clear: function() {
            return context.clearRect(0, 0, layerWidth(), layerHeight());
          },
          context: context,
          drawGuide: function() {
            context.fillStyle = gridColor;
            height.times(function(row) {
              return context.fillRect(0, (row + 1) * PIXEL_HEIGHT, layerWidth(), 1);
            });
            return width.times(function(col) {
              return context.fillRect((col + 1) * PIXEL_WIDTH, 0, 1, layerHeight());
            });
          },
          resize: function() {
            layerElement.width = layerWidth();
            return layerElement.height = layerHeight();
          }
        });
      };
      options || (options = {});
      width = parseInt(options.width || 8, 10);
      height = parseInt(options.height || 8, 10);
      initializer = options.initializer;
      PIXEL_WIDTH = parseInt(options.pixelWidth || options.pixelSize || 16, 10);
      PIXEL_HEIGHT = parseInt(options.pixelHeight || options.pixelSize || 16, 10);
      return this.each(function() {
        var actionbar, active, canvas, colorPickerHolder, colorbar, content, currentTool, guideLayer, initialStateData, lastClean, lastPixel, layer, layers, mode, navLeft, navRight, opacitySlider, opacityVal, pixels, pixie, preview, primaryColorPicker, replaying, secondaryColorPicker, swatches, tilePreview, toolbar, undoStack, viewport;
        pixie = $(this).addClass("pixie");
        content = $(DIV, {
          "class": 'content'
        });
        viewport = $(DIV, {
          "class": 'viewport'
        });
        canvas = $(DIV, {
          "class": 'canvas',
          width: width * PIXEL_WIDTH + 2,
          height: height * PIXEL_HEIGHT + 2
        });
        toolbar = $(DIV, {
          "class": 'toolbar'
        });
        swatches = $(DIV, {
          "class": 'swatches'
        });
        colorbar = $(DIV, {
          "class": 'toolbar'
        });
        actionbar = $(DIV, {
          "class": 'actions'
        });
        navRight = $("<nav class='right'></nav>");
        navLeft = $("<nav class='left'></nav>");
        opacityVal = $(DIV, {
          "class": "val",
          text: 100
        });
        opacitySlider = $(DIV, {
          "class": "opacity"
        }).slider({
          orientation: 'vertical',
          value: 100,
          min: 5,
          max: 100,
          step: 5,
          slide: function(event, ui) {
            return opacityVal.text(ui.value);
          }
        }).append(opacityVal);
        opacityVal.text(opacitySlider.slider('value'));
        tilePreview = true;
        preview = $(DIV, {
          "class": 'preview',
          style: "width: " + width + "px; height: " + height + "px"
        });
        preview.mousedown(function() {
          tilePreview = !tilePreview;
          return canvas.preview();
        });
        currentTool = void 0;
        active = false;
        mode = void 0;
        undoStack = UndoStack();
        primaryColorPicker = ColorPicker().addClass('primary');
        secondaryColorPicker = ColorPicker().addClass('secondary');
        replaying = false;
        initialStateData = void 0;
        colorPickerHolder = $(DIV, {
          "class": 'color_picker_holder'
        }).append(primaryColorPicker, secondaryColorPicker);
        colorbar.append(colorPickerHolder, swatches);
        pixie.bind('contextmenu', falseFn).bind('mouseup', function(e) {
          active = false;
          mode = void 0;
          return canvas.preview();
        });
        $(document).bind('keyup', function() {
          return canvas.preview();
        });
        $(navRight).bind('mousedown', function(e) {
          var color, target;
          target = $(e.target);
          color = Color(target.css('backgroundColor'));
          if (target.is('.swatch')) {
            return canvas.color(color, e.button !== 0);
          }
        });
        pixels = [];
        lastPixel = void 0;
        layer = Layer();
        guideLayer = Layer().bind("mousedown", function(e) {
          pixie.trigger('dirty');
          undoStack.next();
          active = true;
          if (e.button === 0) {
            mode = "P";
          } else {
            mode = "S";
          }
          return e.preventDefault();
        }).bind("mousedown mousemove", function(event) {
          var col, eventType, localX, localY, offset, opacity, pixel, row;
          opacity = opacityVal.text() / 100;
          offset = $(this).offset();
          localY = event.pageY - offset.top;
          localX = event.pageX - offset.left;
          row = Math.floor(localY / PIXEL_HEIGHT);
          col = Math.floor(localX / PIXEL_WIDTH);
          pixel = canvas.getPixel(col, row);
          eventType = void 0;
          if (event.type === "mousedown") {
            eventType = event.type;
          } else if (pixel && pixel !== lastPixel && event.type === "mousemove") {
            eventType = "mouseenter";
          }
          if (pixel && active && currentTool && currentTool[eventType]) {
            currentTool[eventType].call(pixel, event, Color(canvas.color().toString(), opacity), pixel);
          }
          return lastPixel = pixel;
        });
        layers = [layer, guideLayer];
        height.times(function(row) {
          pixels[row] = [];
          return width.times(function(col) {
            var pixel;
            pixel = Pixel(col, row, layer.get(0).getContext('2d'), canvas, undoStack);
            return pixels[row][col] = pixel;
          });
        });
        canvas.append(layer, guideLayer);
        $.extend(canvas, {
          addAction: function(action) {
            var actionButton, doIt, iconImg, name, titleText, undoable;
            name = action.name;
            titleText = name.capitalize();
            undoable = action.undoable;
            doIt = function() {
              if (undoable !== false) {
                pixie.trigger('dirty');
                undoStack.next();
              }
              return action.perform(canvas);
            };
            if (action.hotkeys) {
              titleText += " (" + action.hotkeys + ") ";
              $.each(action.hotkeys, function(i, hotkey) {
                return $(document).bind('keydown', hotkey, function(e) {
                  if (currentComponent === pixie) {
                    e.preventDefault();
                    doIt();
                    return false;
                  }
                });
              });
            }
            if (action.menu !== false) {
              iconImg = $("<img />", {
                src: action.icon || IMAGE_DIR + name + '.png'
              });
              actionButton = $("<a />", {
                "class": 'tool button',
                title: titleText,
                text: name.capitalize()
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
              style: "background-color: " + (color.toString())
            }));
          },
          addTool: function(tool) {
            var alt, img, name, setMe, toolDiv;
            name = tool.name;
            alt = name.capitalize();
            tool.icon || (tool.icon = IMAGE_DIR + name + '.png');
            setMe = function() {
              canvas.setTool(tool);
              toolbar.children().removeClass("active");
              return toolDiv.addClass("active");
            };
            if (tool.hotkeys) {
              alt += " (" + tool.hotkeys + ")";
              $.each(tool.hotkeys, function(i, hotkey) {
                return $(document).bind('keydown', hotkey, function(e) {
                  if (currentComponent === pixie) {
                    e.preventDefault();
                    setMe();
                    return false;
                  }
                });
              });
            }
            img = $("<img />", {
              src: tool.icon,
              alt: alt,
              title: alt
            });
            toolDiv = $("<div class='tool'></div>").append(img).mousedown(function(e) {
              setMe();
              return false;
            });
            return toolbar.append(toolDiv);
          },
          color: function(color, alternate) {
            if (arguments.length === 0 || color === false) {
              if (mode === "S") {
                return Color(secondaryColorPicker.css('backgroundColor'));
              } else {
                return Color(primaryColorPicker.css('backgroundColor'));
              }
            } else if (color === true) {
              if (mode === "S") {
                return Color(primaryColorPicker.css('backgroundColor'));
              } else {
                return Color(secondaryColorPicker.css('backgroundColor'));
              }
            }
            if ((mode === "S") ^ alternate) {
              secondaryColorPicker.val(color.toHex().substr(1));
              secondaryColorPicker[0].onblur();
            } else {
              primaryColorPicker.val(color.toHex().substr(1));
              primaryColorPicker[0].onblur();
            }
            return this;
          },
          clear: function() {
            return layer.clear();
          },
          dirty: function(newDirty) {
            var lastClean;
            if (newDirty !== void 0) {
              if (newDirty === false) {
                lastClean = undoStack.last();
              }
              return this;
            } else {
              return lastClean !== undoStack.last();
            }
          },
          displayInitialState: function(stateData) {
            this.clear();
            stateData || (stateData = initialStateData);
            if (stateData) {
              return $.each(stateData, function(f, data) {
                return canvas.eachPixel(function(pixel, x, y) {
                  var pos;
                  pos = x + y * canvas.width;
                  return pixel.color(Color(data[pos]), true, "replace");
                });
              });
            }
          },
          eachPixel: function(fn) {
            height.times(function(row) {
              return width.times(function(col) {
                var pixel;
                pixel = pixels[row][col];
                return fn.call(pixel, pixel, col, row);
              });
            });
            return canvas;
          },
          fromDataURL: function(dataURL) {
            var context, image;
            context = document.createElement('canvas').getContext('2d');
            image = new Image();
            image.onload = function() {
              var getColor, imageData;
              canvas.resize(image.width, image.height);
              context.drawImage(image, 0, 0);
              imageData = context.getImageData(0, 0, image.width, image.height);
              getColor = function(x, y) {
                var index;
                index = (x + y * imageData.width) * 4;
                return Color(imageData.data[index + 0], imageData.data[index + 1], imageData.data[index + 2], imageData.data[index + 3] / 255);
              };
              return canvas.eachPixel(function(pixel, x, y) {
                return pixel.color(getColor(x, y), true);
              });
            };
            return image.src = dataURL;
          },
          getColor: function(x, y) {
            var context, imageData;
            context = layer.context;
            imageData = context.getImageData(x * PIXEL_WIDTH, y * PIXEL_HEIGHT, 1, 1);
            return Color(imageData.data[0], imageData.data[1], imageData.data[2], imageData.data[3] / 255);
          },
          getNeighbors: function(x, y) {
            return [this.getPixel(x + 1, y), this.getPixel(x, y + 1), this.getPixel(x - 1, y), this.getPixel(x, y - 1)];
          },
          getPixel: function(x, y) {
            if (((0 <= y && y < height)) && ((0 <= x && x < width))) {
              return pixels[y][x];
            }
            return void 0;
          },
          getReplayData: function() {
            return undoStack.replayData();
          },
          toHex: function(bits) {
            var s;
            s = parseInt(bits).toString(16);
            if (s.length === 1) {
              s = '0' + s;
            }
            return s;
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
              pixie.trigger("dirty");
              return $.each(data, function() {
                return this.pixel.color(this.newColor, true, "replace");
              });
            }
          },
          replay: function(steps, parentData) {
            var delay, i, runStep;
            if (!replaying) {
              replaying = true;
              canvas = this;
              if (!steps) {
                steps = canvas.getReplayData();
                canvas.displayInitialState();
              } else {
                if (parentData) {
                  canvas.displayInitialState(parentData);
                } else {
                  canvas.clear();
                }
              }
              i = 0;
              delay = (5000 / steps.length).clamp(1, 200);
              runStep = function() {
                var step;
                step = steps[i];
                if (step) {
                  $.each(step, function(j, p) {
                    return canvas.getPixel(p.x, p.y).color(p.color, true, "replace");
                  });
                  i++;
                  return setTimeout(runStep, delay);
                } else {
                  return replaying = false;
                }
              };
              return setTimeout(runStep, delay);
            }
          },
          resize: function(newWidth, newHeight) {
            this.width = width = newWidth;
            this.height = height = newHeight;
            pixels = pixels.slice(0, newHeight);
            while (pixels.length < newHeight) {
              pixels.push([]);
            }
            pixels.each(function(row, y) {
              var _results;
              while (row.length > newWidth) {
                row.pop();
              }
              _results = [];
              while (row.length < newWidth) {
                _results.push(row.push(Pixel(row.length, y, layer.get(0).getContext('2d'), canvas, undoStack)));
              }
              return _results;
            });
            layers.each(function(layer) {
              layer.clear();
              return layer.resize();
            });
            canvas.css({
              width: width * PIXEL_WIDTH + 2,
              height: height * PIXEL_HEIGHT + 2
            });
            return pixels.each(function(row) {
              return row.each(function(pixel) {
                return pixel.redraw();
              });
            });
          },
          setInitialState: function(frameData) {
            initialStateData = frameData;
            return this.displayInitialState();
          },
          setTool: function(tool) {
            currentTool = tool;
            return canvas.css('cursor', tool.cursor || "pointer");
          },
          toBase64: function(f) {
            var data;
            data = this.toDataURL(f);
            return data.substr(data.indexOf(',') + 1);
          },
          toCSSImageURL: function() {
            return "url(" + (this.toDataURL()) + ")";
          },
          toDataURL: function() {
            var context, tempCanvas;
            tempCanvas = $("<canvas width=" + width + " height=" + height + "></canvas>").get(0);
            context = tempCanvas.getContext('2d');
            this.eachPixel(function(pixel, x, y) {
              var color;
              color = pixel.color();
              context.fillStyle = color.toString();
              return context.fillRect(x, y, 1, 1);
            });
            return tempCanvas.toDataURL("image/png");
          },
          undo: function() {
            var data;
            data = undoStack.popUndo();
            if (data) {
              pixie.trigger("dirty");
              return $.each(data, function() {
                return this.pixel.color(this.oldColor, true, "replace");
              });
            }
          },
          width: width,
          height: height
        });
        $.each(tools, function(key, tool) {
          tool.name = key;
          return canvas.addTool(tool);
        });
        if (DEBUG) {
          $.each(debugTools, function(key, tool) {
            tool.name = key;
            return canvas.addTool(tool);
          });
        }
        $.each(actions, function(key, action) {
          action.name = key;
          return canvas.addAction(action);
        });
        $.each(palette, function(i, color) {
          return canvas.addSwatch(Color(color));
        });
        canvas.setTool(tools.pencil);
        viewport.append(canvas);
        $(navLeft).append(toolbar);
        $(navRight).append(colorbar, preview, opacitySlider);
        content.append(actionbar, viewport, navLeft, navRight);
        pixie.append(content);
        pixie.bind('mouseenter', function() {
          return window.currentComponent = pixie;
        });
        window.currentComponent = pixie;
        if (initializer) {
          initializer(canvas);
        }
        return lastClean = undoStack.last();
      });
    };
  })(jQuery);
}).call(this);
