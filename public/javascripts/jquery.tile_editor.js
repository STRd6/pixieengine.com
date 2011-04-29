/* DO NOT MODIFY. This file was compiled Fri, 29 Apr 2011 00:08:37 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/jquery.tile_editor.coffee
 */

(function() {
  $.fn.tileEditor = function(options) {
    var addNewLayer, addScreenLayer, clearSelection, clickMode, createNewTile, createPixelEditor, currentLayer, currentTool, debugMode, deleteTile, entered, firstGID, floodFill, getNeighborPositions, grid, harvestSelection, hotkeys, inBounds, isInSelection, layerSelect, loadData, modeDown, nextTile, pixelEditTile, positionElementIndices, prevTile, propEditor, propElement, removeTile, replaceTile, saveData, savedSelectionCount, select, selectNextVisibleLayer, selectTile, selectTool, selectionCache, selectionCopy, selectionCut, selectionDelete, selectionEach, selectionStart, showPropertiesEditor, stamp, templates, tileAt, tileEditor, tileHeight, tilePosition, tileTray, tileWidth, tilesTall, tilesWide;
    options = $.extend({
      layers: 2,
      tilesWide: 20,
      tilesTall: 15,
      tileWidth: 32,
      tileHeight: 32
    }, options);
    tileEditor = $(this.get(0)).addClass("tile_editor");
    templates = $("#tile_editor_templates");
    templates.find(".editor.template").tmpl().appendTo(tileEditor);
    debugMode = false;
    firstGID = 1;
    tilesWide = parseInt(options.tilesWide, 10);
    tilesTall = parseInt(options.tilesTall, 10);
    tileWidth = parseInt(options.tileWidth, 10);
    tileHeight = parseInt(options.tileHeight, 10);
    currentLayer = 0;
    modeDown = null;
    tileTray = "nav.bottom .tiles";
    layerSelect = "nav.left .layer_select";
    positionElementIndices = [];
    grid = GridGen({
      width: tileWidth,
      height: tileHeight
    });
    if ($.fn.pixie) {
      createPixelEditor = function(options) {
        var pixelEditor, url;
        url = options.url;
        tileEditor = options.tileEditor;
        pixelEditor = $('<div />').pixie({
          width: options.width,
          height: options.height,
          initializer: function(canvas) {
            if (url) {
              canvas.fromDataURL(url);
            }
            canvas.addAction({
              name: "Save Tile",
              icon: "/images/icons/database_save.png",
              perform: function(canvas) {
                pixelEditor.trigger('save', canvas.toDataURL());
                pixelEditor.remove();
                return tileEditor.show();
              },
              undoable: false
            });
            return canvas.addAction({
              name: "Back to Tilemap",
              icon: "/images/icons/arrow_left.png",
              perform: function(canvas) {
                pixelEditor.remove();
                return tileEditor.show();
              },
              undoable: false
            });
          }
        });
        tileEditor.hide().after(pixelEditor);
        window.currentComponent = pixelEditor;
        return pixelEditor;
      };
    }
    pixelEditTile = function(selectedTile) {
      var imgSource, pixelEditor;
      if (createPixelEditor) {
        imgSource = selectedTile.attr('src');
        pixelEditor = createPixelEditor({
          width: selectedTile.get(0).width,
          height: selectedTile.get(0).height,
          tileEditor: tileEditor,
          url: imgSource.replace('http://images.pixie.strd6.com', '/s3')
        });
        return pixelEditor.bind('save', function(event, data) {
          var img;
          img = $("<img/>", {
            src: data
          });
          return tileEditor.find('.component .tiles').append(img);
        });
      }
    };
    createNewTile = function() {
      var pixelEditor;
      if (createPixelEditor) {
        pixelEditor = createPixelEditor({
          width: tileWidth,
          height: tileHeight,
          tileEditor: tileEditor
        });
        return pixelEditor.bind('save', function(event, data) {
          var img;
          img = $("<img/>", {
            src: data
          });
          return tileEditor.find('.component .tiles').append(img);
        });
      }
    };
    deleteTile = function(tile) {
      return tile.remove();
    };
    tilePosition = function(element, event) {
      var localX, localY, offset;
      offset = element.offset();
      localY = (event.pageY - offset.top).snap(tileHeight).clamp(0, (tilesTall - 1) * tileHeight);
      localX = (event.pageX - offset.left).snap(tileWidth).clamp(0, (tilesWide - 1) * tileWidth);
      return {
        x: localX,
        y: localY
      };
    };
    addScreenLayer = function() {
      $("<div />", {
        "class": "layer",
        width: tilesWide * tileWidth,
        height: tilesTall * tileHeight
      }).appendTo("section .layers");
      tileEditor.find(".screen").find(".cursor, .selection").appendTo("section .layers");
      return positionElementIndices.push({});
    };
    addNewLayer = function() {
      templates.find(".layer_select.template").tmpl({
        name: "Layer " + (tileEditor.find(".layer_select .choice").length + 1)
      }).appendTo(layerSelect).find('.name').mousedown();
      return addScreenLayer();
    };
    selectNextVisibleLayer = function() {
      var shownLayers;
      shownLayers = tileEditor.find(".layer_select .choice .show.on");
      if (shownLayers.length) {
        return shownLayers.eq(0).parent().find(".name").mousedown();
      }
    };
    prevTile = function(mode) {
      var cur, tileCount;
      tileCount = $(".tiles img").length;
      cur = tileEditor.find(".tiles ." + mode).removeClass(mode).index();
      return tileEditor.find(".tiles img").eq((cur - 1).mod(tileCount)).addClass(mode);
    };
    nextTile = function(mode) {
      var cur, tileCount;
      tileCount = tileEditor.find(".tiles img").length;
      cur = tileEditor.find(".tiles ." + mode).removeClass(mode).index();
      return tileEditor.find(".tiles img").eq((cur + 1).mod(tileCount)).addClass(mode);
    };
    inBounds = function(x, y) {
      return ((0 <= x && x < tileWidth * tilesWide)) && ((0 <= y && y < tileHeight * tilesTall));
    };
    replaceTile = function(x, y, tile) {
      var posString, targetLayer;
      if (!inBounds(x, y)) {
        return;
      }
      posString = x + "x" + y;
      tile = tile.clone().removeClass("primary secondary").css({
        position: "absolute",
        top: y,
        left: x
      }).attr("data-pos", posString);
      targetLayer = tileEditor.find(".screen .layer").eq(currentLayer);
      removeTile(x, y);
      targetLayer.append(tile);
      return positionElementIndices[currentLayer][posString] = tile.get();
    };
    removeTile = function(x, y) {
      var posString;
      tileAt(x, y).remove();
      posString = x + "x" + y;
      return positionElementIndices[currentLayer][posString] = void 0;
    };
    tileAt = function(x, y) {
      var posString;
      posString = x + "x" + y;
      return $(positionElementIndices[currentLayer][posString]);
    };
    getNeighborPositions = function(position) {
      var neighbors;
      return neighbors = [[position[0] - tileWidth, position[1]], [position[0] + tileWidth, position[1]], [position[0], position[1] - tileHeight], [position[0], position[1] + tileHeight]].select(function(neighborPos) {
        return inBounds(neighborPos[0], neighborPos[1]);
      });
    };
    floodFill = function(x, y, tile) {
      var inSelection, neighbors, paintSrc, position, queue, targetSrc, _results;
      inSelection = isInSelection(x, y);
      targetSrc = tileAt(x, y).attr("src");
      paintSrc = tile.attr("src");
      if (targetSrc === paintSrc) {
        return;
      }
      queue = [];
      replaceTile(x, y, tile);
      queue.push([x, y]);
      _results = [];
      while (queue.length) {
        position = queue.pop();
        neighbors = getNeighborPositions(position);
        _results.push(neighbors.each(function(neighbor, index) {
          if (inSelection === isInSelection(neighbor[0], neighbor[1])) {
            if (neighbor && tileAt(neighbor[0], neighbor[1]).attr("src") === targetSrc) {
              replaceTile(neighbor[0], neighbor[1], tile);
              return queue.push(neighbor);
            }
          }
        }));
      }
      return _results;
    };
    selectionCache = null;
    isInSelection = function(x, y) {
      if (selectionCache) {
        return (selectionCache.top <= y && y < selectionCache.top + selectionCache.height) && (selectionCache.left <= x && x < selectionCache.left + selectionCache.width);
      } else {
        return false;
      }
    };
    clearSelection = function() {
      tileEditor.find(".screen .selection").removeClass("active");
      return selectionCache = null;
    };
    selectionEach = function(callback) {
      var $selection, pos, selectionHeight, selectionWidth, x, y;
      $selection = tileEditor.find(".screen .selection");
      if ($selection.hasClass("active")) {
        pos = $selection.position();
        selectionWidth = $selection.outerWidth();
        selectionHeight = $selection.outerHeight();
        y = pos.top;
        while (y < pos.top + selectionHeight) {
          x = pos.left;
          while (x < pos.left + selectionWidth) {
            callback(x, y);
            x += tileWidth;
          }
          y += tileHeight;
        }
        return clearSelection();
      }
    };
    selectionDelete = function() {
      return selectionEach(removeTile);
    };
    savedSelectionCount = 0;
    harvestSelection = function(remove) {
      var preview, row, rowY, savedSelection, selectionData;
      rowY = void 0;
      row = void 0;
      savedSelection = templates.find(".saved_selection.template").tmpl({
        text: "Selection" + (++savedSelectionCount)
      }).appendTo(".saved_selections");
      preview = savedSelection.find(".preview");
      selectionData = [];
      selectionEach(function(x, y) {
        var tile;
        if (y !== rowY) {
          rowY = y;
          row = [];
          selectionData.push(row);
        }
        tile = tileAt(x, y).clone();
        row.push(tile.attr("src"));
        tile.css({
          position: "absolute",
          top: (selectionData.length - 1) * tileHeight,
          left: (row.length - 1) * tileWidth
        });
        preview.append(tile);
        if (remove) {
          return removeTile(x, y);
        }
      });
      savedSelection.data("selectionData", selectionData);
      selectTile(savedSelection, "primary");
      return selectTool("stamp", "primary");
    };
    selectionCopy = function() {
      return harvestSelection();
    };
    selectionCut = function() {
      return harvestSelection(true);
    };
    selectionStart = null;
    select = function(x, y) {
      var $selection, deltaX, deltaY, pos, selectionHeight, selectionLeft, selectionTop, selectionWidth;
      if (selectionStart) {
        $selection = tileEditor.find(".screen .selection");
        pos = $selection.position();
        deltaX = x - selectionStart.x;
        deltaY = y - selectionStart.y;
        selectionWidth = deltaX.abs() + tileWidth;
        selectionHeight = deltaY.abs() + tileHeight;
        selectionLeft = deltaX < 0 ? x : selectionStart.x;
        selectionTop = deltaY < 0 ? y : selectionStart.y;
        selectionCache = {
          height: selectionHeight,
          left: selectionLeft,
          top: selectionTop,
          width: selectionWidth
        };
        return $selection.css(selectionCache);
      } else {
        selectionCache = {
          height: tileHeight,
          left: x,
          top: y,
          width: tileWidth
        };
        tileEditor.find(".screen .selection").addClass('active').css(selectionCache);
        return selectionStart = {
          x: x,
          y: y
        };
      }
    };
    stamp = function(x, y, mode) {
      var selection, tile;
      if ((tile = tileEditor.find(".tiles").find("." + mode)).length) {
        return replaceTile(x, y, tile);
      } else if (selection = tileEditor.find(".saved_selections").find("." + mode).data("selectionData")) {
        return selection.each(function(row, tileY) {
          return row.each(function(src, tileX) {
            var targetX, targetY;
            if (src) {
              targetX = x + tileX * tileWidth;
              targetY = y + tileY * tileHeight;
              return replaceTile(targetX, targetY, tileEditor.find(".tiles img[src=" + src + "]").eq(0));
            }
          });
        });
      }
    };
    currentTool = function(mode) {
      return tileEditor.find(".tools .tool." + mode).data("tool");
    };
    entered = function(x, y) {
      var mode;
      if (mode = modeDown) {
        switch (currentTool(mode)) {
          case "stamp":
            return stamp(x, y, mode);
          case "eraser":
            return removeTile(x, y);
          case "fill":
            return floodFill(x, y, tileEditor.find(".tiles").find("." + mode));
          case "selection":
            return select(x, y);
        }
      }
    };
    clickMode = function(event) {
      if (event.which === 1) {
        return "primary";
      } else if (event.which === 3) {
        return "secondary";
      }
    };
    selectTool = function(name, mode) {
      var tool;
      tool = tileEditor.find(".tools .tool[data-tool=" + name + "]");
      return tool.takeClass(mode);
    };
    selectTile = function(tile, mode) {
      tileEditor.find(".saved_selections .selection").removeClass(mode);
      tileEditor.find(".tiles img").removeClass(mode);
      return tile.addClass(mode);
    };
    propElement = null;
    showPropertiesEditor = function(element) {
      propElement = element;
      propEditor.setProps(propElement.data("properties"));
      return propEditor.parent().show();
    };
    tileEditor.bind("contextmenu", function(event) {
      if (!debugMode) {
        return event.preventDefault();
      }
    });
    $(".tools .tool", tileEditor).live('mousedown', function(event) {
      var mode;
      event.preventDefault();
      if (mode = clickMode(event)) {
        return $(this).takeClass(mode);
      }
    });
    $(".tiles img, .saved_selections .selection", tileEditor).live({
      mousedown: function(event) {
        var mode;
        event.preventDefault();
        if (mode = clickMode(event)) {
          return selectTile($(this), mode);
        }
      }
    });
    $(".tiles img, .saved_selections .selection", tileEditor).live('mouseup', function(event) {
      if (event.which === 2) {
        return $(this).remove();
      }
    });
    $(".tiles img", tileEditor).live("dblclick", function(event) {
      return pixelEditTile($(this));
    });
    tileEditor.find("button.new_tile").click(function() {
      return createNewTile();
    });
    tileEditor.find("button.delete_tile").click(function() {
      return deleteTile(tileEditor.find('.tiles img.primary'));
    });
    tileEditor.find(".prop_save").click(function(event) {
      if (propElement) {
        propElement.data("properties", propEditor.getProps());
        return propEditor.parent().hide();
      }
    });
    tileEditor.find(".layer_select").parent().find('.new').click(function() {
      return addNewLayer();
    });
    $(".layer_select .choice .name", tileEditor).live('mousedown', function(event) {
      var $layer;
      $layer = $(this).parent();
      $layer.takeClass("active");
      return currentLayer = $layer.index();
    });
    tileEditor.find(".layer_select").delegate(".show", 'mousedown', function(event) {
      var $choice, $this;
      $this = $(this);
      $choice = $this.parent();
      if ($this.toggleClass("on").hasClass("on")) {
        tileEditor.find(".screen .layers .layer").eq($choice.index()).fadeIn();
        return $choice.find(".name").mousedown();
      } else {
        tileEditor.find(".screen .layers .layer").eq($choice.index()).fadeOut();
        return selectNextVisibleLayer();
      }
    });
    tileEditor.find(".screen .layers").bind("mousemove", function(event) {
      var oldPos, pos;
      pos = tilePosition($(this), event);
      oldPos = tileEditor.find(".screen .cursor").position();
      if (!(oldPos.left === pos.x && oldPos.top === pos.y)) {
        entered(pos.x, pos.y);
        return tileEditor.find(".screen .cursor").css({
          left: pos.x,
          top: pos.y
        });
      }
    });
    tileEditor.find(".screen .layers").bind("mousedown", function(event) {
      var pos;
      if (modeDown = clickMode(event)) {
        pos = tilePosition($(this), event);
        return entered(pos.x, pos.y);
      }
    });
    $(document).bind("mouseup", function(event) {
      selectionStart = null;
      return modeDown = null;
    });
    tileEditor.mousedown(function() {
      return window.currentComponent = tileEditor;
    });
    hotkeys = {
      a: function(event) {
        return prevTile("primary");
      },
      z: function(event) {
        return nextTile("primary");
      },
      s: function(event) {
        return prevTile("secondary");
      },
      x: function(event) {
        return nextTile("secondary");
      },
      p: function() {
        return showPropertiesEditor(tileEditor.find('.tiles img.primary'));
      },
      backspace: selectionDelete,
      del: selectionDelete,
      esc: clearSelection,
      "ctrl+c": selectionCopy,
      "ctrl+x": selectionCut
    };
    $.each(hotkeys, function(key, fn) {
      return $(document).bind("keydown", key, function(event) {
        if (window.currentComponent === tileEditor) {
          event.preventDefault();
          return fn(event);
        }
      });
    });
    tileEditor.find(tileTray).sortable();
    tileEditor.find(".component.tile_select").dropImageReader(function(file, event) {
      var img;
      if (event.target.readyState === FileReader.DONE) {
        img = $("<img/>", {
          alt: file.name,
          src: event.target.result,
          title: file.name
        });
        return $(this).find(".tiles").append(img);
      }
    });
    $('.filename, .layer_select .name, .saved_selections .name', tileEditor).liveEdit();
    propEditor = $(".prop_editor", tileEditor).propertyEditor({
      test: true,
      foo: "bar",
      noice: 13
    });
    tileEditor.find("button.save").click(function() {
      return typeof options.save === "function" ? options.save(saveData()) : void 0;
    });
    saveData = function() {
      var layers, tileIndexLookup, tileset;
      tileIndexLookup = {};
      tileset = tileEditor.find("nav.bottom .tiles img").map(function(i) {
        var $this, mapTileData, mapTileId, pixieId, props, src;
        $this = $(this);
        src = $this.attr("src");
        tileIndexLookup[src] = i;
        mapTileData = {
          src: src
        };
        if (mapTileId = $this.data('guid')) {
          mapTileData.guid(mapTileId);
        }
        if (pixieId = $this.data("pixie_id")) {
          mapTileData.pixieId = mapTileSpriteId;
        }
        if (props = $this.data("properties")) {
          mapTileData.properties = props;
        }
        return mapTileData;
      }).get();
      layers = [];
      tileEditor.find(".layer_select .choice").each(function(i) {
        var $this, layer, screenLayer, tileLookup, tiles;
        $this = $(this);
        screenLayer = tileEditor.find(".screen .layers .layer").eq(i);
        tileLookup = {};
        screenLayer.find("img").each(function() {
          var src;
          src = this.getAttribute("src");
          return tileLookup[this.getAttribute("data-pos")] = tileIndexLookup[src];
        });
        tiles = [];
        tilesTall.times(function(y) {
          var row;
          row = [];
          tiles.push(row);
          return tilesWide.times(function(x) {
            var imgIndex, posString;
            posString = x * tileWidth + "x" + y * tileHeight;
            imgIndex = tileLookup[posString] != null ? tileLookup[posString] : -1;
            return row.push(imgIndex);
          });
        });
        layer = {
          name: $this.text(),
          tiles: tiles
        };
        return layers.push(layer);
      });
      return {
        title: tileEditor.find(".filename").text(),
        version: "1.0",
        orientation: "orthogonal",
        width: tilesWide,
        height: tilesTall,
        tileWidth: tileWidth,
        tileHeight: tileHeight,
        tileset: tileset,
        layers: layers
      };
    };
    loadData = function(data) {
      var tileLookup;
      tilesWide = data.width;
      tilesTall = data.height;
      tileWidth = data.tileWidth;
      tileHeight = data.tileHeight;
      tileEditor.find('.screen .layers').css('background-image', 'url(/images/tile_grid_' + tileWidth + '.png)');
      positionElementIndices = [];
      tileLookup = {};
      tileEditor.find(tileTray).html('');
      data.tileset.each(function(tile, index) {
        var active;
        active = index === 0 ? "primary" : index === 1 ? "secondary" : void 0;
        tileLookup[index] = $("<img />", {
          "class": active,
          "data-guid": tile.guid,
          "data-pixie_id": tile.pixieId,
          src: tile.src
        }).appendTo(tileTray);
        if (tile.properties) {
          return tileLookup[index].data("properties", tile.properties);
        }
      });
      tileEditor.find("section .layers .layer").remove();
      tileEditor.find(layerSelect).html('');
      data.layers.each(function(layer, i) {
        currentLayer = i;
        addScreenLayer();
        templates.find(".layer_select.template").tmpl({
          name: layer.name
        }).appendTo(layerSelect);
        return layer.tiles.each(function(row, y) {
          return row.each(function(tile, x) {
            if (tile >= 0) {
              return replaceTile(x * tileWidth, y * tileHeight, tileLookup[tile]);
            }
          });
        });
      });
      return tileEditor.find(layerSelect).find(".name").first().trigger("mousedown");
    };
    if (options.data) {
      loadData(options.data);
    } else {
      options.layers.times(function() {
        return addNewLayer();
      });
    }
    tileEditor.find(".screen .cursor").css({
      width: tileWidth - 1,
      height: tileHeight - 1
    });
    tileEditor.find(".screen .layers").css({
      backgroundImage: grid.backgroundImage(),
      width: tilesWide * tileWidth,
      height: tilesTall * tileHeight
    });
    return $.extend(tileEditor, {
      mapData: saveData
    });
  };
}).call(this);
