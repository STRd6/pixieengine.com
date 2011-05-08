$.fn.tileEditor = (options) ->
  options = $.extend(
    layers: 2
    tilesWide: 20
    tilesTall: 15
    tileWidth: 32
    tileHeight: 32
  , options)

  tileEditor = $(this.get(0)).addClass("tile_editor")

  templates = $("#tile_editor_templates")
  templates.find(".editor.template").tmpl().appendTo(tileEditor)

  debugMode = false
  dirty = false

  firstGID = 1

  tilesWide = parseInt(options.tilesWide, 10)
  tilesTall = parseInt(options.tilesTall, 10)

  tileWidth = parseInt(options.tileWidth, 10)
  tileHeight = parseInt(options.tileHeight, 10)

  currentLayer = 0

  modeDown = null

  tileTray = "nav.bottom .tiles"
  layerSelect = "nav.left .layer_select"

  positionElementIndices = []

  grid = GridGen
    width: tileWidth
    height: tileHeight

  if $.fn.pixie
    createPixelEditor = (options) ->
      url = options.url
      tileEditor = options.tileEditor

      pixelEditor = $('<div />').pixie
        width: options.width
        height: options.height
        initializer: (canvas) ->
          if url
            canvas.fromDataURL(url)

          canvas.addAction
            name: "Save Tile"
            icon: "/images/icons/database_save.png"
            perform: (canvas) ->
              pixelEditor.trigger 'save', canvas.toDataURL()
              pixelEditor.remove()
              tileEditor.show()
            undoable: false

          canvas.addAction
            name: "Back to Tilemap"
            icon: "/images/icons/arrow_left.png"
            perform: (canvas) ->
              pixelEditor.remove()
              tileEditor.show()
            undoable: false

      tileEditor.hide().after(pixelEditor)

      window.currentComponent = pixelEditor

      return pixelEditor

  pixelEditTile = (selectedTile) ->
    if createPixelEditor
      imgSource = selectedTile.attr('src')

      pixelEditor = createPixelEditor
        width: selectedTile.get(0).width
        height: selectedTile.get(0).height
        tileEditor: tileEditor
        url: imgSource.replace('http://images.pixie.strd6.com', '/s3')

      pixelEditor.bind 'save', (event, data) ->
        img = $ "<img/>",
          src: data

        tileEditor.find('.component .tiles').append img

  createNewTile = ->
    if createPixelEditor
      pixelEditor = createPixelEditor
        width: tileWidth
        height: tileHeight
        tileEditor: tileEditor

      pixelEditor.bind 'save', (event, data) ->
        img = $ "<img/>",
          src: data

        tileEditor.find('.component .tiles').append img

  deleteTile = (tile) ->
    #TODO Maybe remove instances of tile in map
    tile.remove()

  tilePosition = (element, event) ->
    offset = element.offset()

    localY = (event.pageY - offset.top).snap(tileHeight).clamp(0, (tilesTall - 1) * tileHeight)
    localX = (event.pageX - offset.left).snap(tileWidth).clamp(0, (tilesWide - 1) * tileWidth)

    return {
      x: localX
      y: localY
    }

  addScreenLayer = () ->
    $("<div />",
      class: "layer"
      width: tilesWide * tileWidth
      height: tilesTall * tileHeight
    ).appendTo(tileEditor.find("section .layers"))

    tileEditor.find(".screen").find(".cursor, .selection").appendTo(tileEditor.find("section .layers"))

    positionElementIndices.push {}

  addNewLayer = () ->
    templates.find(".layer_select.template").tmpl(
      name: "Layer " + (tileEditor.find(".layer_select .choice").length + 1)
    ).appendTo(tileEditor.find(layerSelect)).find('.name').mousedown()

    addScreenLayer()

  selectNextVisibleLayer = () ->
    shownLayers = tileEditor.find(".layer_select .choice .show.on")

    if shownLayers.length
      shownLayers.eq(0).parent().find(".name").mousedown()

  prevTile = (mode) ->
    tileCount = $(".tiles img").length

    cur = tileEditor.find(".tiles ." + mode).removeClass(mode).index()

    tileEditor.find(".tiles img").eq((cur - 1).mod(tileCount)).addClass(mode)

  nextTile = (mode) ->
    tileCount = tileEditor.find(".tiles img").length

    cur = tileEditor.find(".tiles ." + mode).removeClass(mode).index()

    tileEditor.find(".tiles img").eq((cur + 1).mod(tileCount)).addClass(mode)

  inBounds = (x, y) ->
    (0 <= x < tileWidth * tilesWide) && (0 <= y < tileHeight * tilesTall)

  replaceTile = (x, y, tile) ->
    return unless inBounds(x, y)

    if !dirty
      dirty = true
      tileEditor.trigger "dirty"

    posString = x + "x" + y

    tile = tile.clone().removeClass("primary secondary").css(
      position: "absolute"
      top: y
      left: x
    ).attr("data-pos", posString)

    targetLayer = tileEditor.find(".screen .layer").eq(currentLayer)

    removeTile(x, y)

    targetLayer.append(tile)

    positionElementIndices[currentLayer][posString] = tile.get()

    return tile

  removeTile = (x, y) ->
    if !dirty
      dirty = true
      tileEditor.trigger "dirty"

    tileAt(x, y).remove()

    posString = x + "x" + y
    positionElementIndices[currentLayer][posString] = undefined

  tileAt = (x, y) ->
    posString = x + "x" + y

    $(positionElementIndices[currentLayer][posString])

  getNeighborPositions = (position) ->
    neighbors = [
      [position[0] - tileWidth, position[1]]
      [position[0] + tileWidth, position[1]]
      [position[0], position[1] - tileHeight]
      [position[0], position[1] + tileHeight]
    ].select (neighborPos) ->
      inBounds(neighborPos[0], neighborPos[1])

  floodFill = (x, y, tile) ->
    inSelection = isInSelection(x, y)
    targetSrc = tileAt(x, y).attr("src")
    paintSrc = tile.attr("src")

    return if targetSrc == paintSrc

    queue = []

    replaceTile(x, y, tile)
    queue.push([x, y])

    while queue.length
      position = queue.pop()

      neighbors = getNeighborPositions(position);

      neighbors.each (neighbor, index) ->
        if inSelection == isInSelection(neighbor[0], neighbor[1])
          if neighbor && tileAt(neighbor[0], neighbor[1]).attr("src") == targetSrc
            replaceTile(neighbor[0], neighbor[1], tile)
            queue.push(neighbor)


  selectionCache = null
  isInSelection = (x, y) ->
    if selectionCache
      selectionCache.top <= y < selectionCache.top + selectionCache.height &&
      selectionCache.left <= x < selectionCache.left + selectionCache.width
    else
      false

  clearSelection = () ->
    tileEditor.find(".screen .selection").removeClass("active")
    selectionCache = null

  selectionEach = (callback) ->
    $selection = tileEditor.find(".screen .selection")

    if $selection.hasClass("active")
      pos = $selection.position()
      selectionWidth = $selection.outerWidth()
      selectionHeight = $selection.outerHeight()

      y = pos.top
      while y < pos.top + selectionHeight
        x = pos.left
        while x < pos.left + selectionWidth
          callback(x, y)

          x += tileWidth
        y += tileHeight

      clearSelection()

  selectionDelete = () ->
    selectionEach(removeTile)

  savedSelectionCount = 0

  harvestSelection = (remove) ->
    rowY = undefined
    row = undefined

    savedSelection = templates.find(".saved_selection.template").tmpl(
      text: "Selection" + (++savedSelectionCount)
    ).appendTo(tileEditor.find(".saved_selections"))

    preview = savedSelection.find(".preview")

    selectionData = []

    selectionEach (x, y) ->
      if y != rowY
        rowY = y
        row = []
        selectionData.push row

      tile = tileAt(x, y).clone()
      row.push tile.attr("src")

      tile.css(
        position: "absolute"
        top: (selectionData.length - 1) * tileHeight
        left: (row.length - 1) * tileWidth
      )

      preview.append(tile)

      if remove
        removeTile(x, y)

    savedSelection.data("selectionData", selectionData)

    selectTile(savedSelection, "primary")

    selectTool("stamp", "primary")

  selectionCopy = () ->
    harvestSelection()

  selectionCut = () ->
    harvestSelection(true)

  selectionStart = null
  select = (x, y) ->
    if selectionStart
      $selection = tileEditor.find(".screen .selection")
      pos = $selection.position()

      deltaX = x - selectionStart.x
      deltaY = y - selectionStart.y

      selectionWidth = deltaX.abs() + tileWidth
      selectionHeight = deltaY.abs() + tileHeight

      selectionLeft = if deltaX < 0 then x else selectionStart.x
      selectionTop = if deltaY < 0 then y else selectionStart.y

      selectionCache =
        height: selectionHeight
        left: selectionLeft
        top: selectionTop
        width: selectionWidth

      $selection.css selectionCache

    else
      selectionCache =
        height: tileHeight
        left: x
        top: y
        width: tileWidth

      tileEditor.find(".screen .selection").addClass('active').css selectionCache

      selectionStart = {x: x, y: y}

  stamp = (x, y, mode) ->
    if (tile = tileEditor.find(".tiles").find("." + mode)).length
      replaceTile(x, y, tile)
    else if selection = tileEditor.find(".saved_selections").find("." + mode).data("selectionData")
      selection.each (row, tileY) ->
        row.each (src, tileX) ->
          if src
            targetX = x + tileX * tileWidth
            targetY = y + tileY * tileHeight

            replaceTile(targetX, targetY, tileEditor.find(".tiles img[src="+src+"]").eq(0))

  currentTool = (mode) ->
    tileEditor.find(".tools .tool." + mode).data("tool")

  entered = (x, y) ->
    if mode = modeDown
      switch currentTool(mode)
        when "stamp"
          stamp(x, y, mode)
        when "eraser"
          removeTile(x, y)
        when "fill"
          floodFill(x, y, tileEditor.find(".tiles").find("." + mode))
        when "selection"
          select(x, y)

  clickMode = (event) ->
    if event.which == 1
      "primary"
    else if event.which == 3
      "secondary"

  selectTool = (name, mode) ->
    tool = tileEditor.find(".tools .tool[data-tool="+name+"]")
    tool.takeClass(mode)

  selectTile = (tile, mode) ->
    tileEditor.find(".saved_selections .selection").removeClass(mode)
    tileEditor.find(".tiles img").removeClass(mode)
    tile.addClass(mode)

  propElement = null
  showPropertiesEditor = (element) ->
    propElement = element
    propEditor.setProps(propElement.data("properties"))
    propEditor.parent().show()

  tileEditor.bind "contextmenu", (event) ->
    unless debugMode
      event.preventDefault()

  $(".tools .tool", tileEditor).live 'mousedown', (event) ->
    event.preventDefault()

    if mode = clickMode event
      $(this).takeClass(mode)

  $(".tiles img, .saved_selections .selection", tileEditor).live
    mousedown: (event) ->
      event.preventDefault()

      if mode = clickMode event
        selectTile($(this), mode)

  $(".tiles img, .saved_selections .selection", tileEditor).live 'mouseup', (event) ->
    if event.which == 2
      $(this).remove()

  $(".tiles img", tileEditor).live "dblclick", (event) ->
    pixelEditTile($(this))

  tileEditor.find("button.new_tile").click () ->
    createNewTile()

  tileEditor.find("button.delete_tile").click () ->
    deleteTile(tileEditor.find('.tiles img.primary'))

  tileEditor.find(".prop_save").click (event) ->
    if propElement
      propElement.data("properties", propEditor.getProps())
      propEditor.parent().hide()

  tileEditor.find(".layer_select").parent().find('.new').click () ->
    addNewLayer()

  $(".layer_select .choice .name", tileEditor).live 'mousedown', (event) ->
    $layer = $(this).parent()
    $layer.takeClass("active")

    currentLayer = $layer.index()

  tileEditor.find(".layer_select").delegate ".show", 'mousedown', (event) ->
    $this = $(this)
    $choice = $this.parent()

    if $this.toggleClass("on").hasClass("on")
      tileEditor.find(".screen .layers .layer").eq($choice.index()).fadeIn()
      $choice.find(".name").mousedown()
    else
      tileEditor.find(".screen .layers .layer").eq($choice.index()).fadeOut()
      selectNextVisibleLayer()

  tileEditor.find(".screen .layers").bind "mousemove", (event) ->
    pos = tilePosition($(this), event)

    oldPos = tileEditor.find(".screen .cursor").position()

    unless oldPos.left == pos.x && oldPos.top == pos.y
      entered(pos.x, pos.y)

      tileEditor.find(".screen .cursor").css
        left: pos.x
        top: pos.y

  tileEditor.find(".screen .layers").bind "mousedown", (event) ->
    if modeDown = clickMode event
      pos = tilePosition($(this), event)

      entered(pos.x, pos.y)

  $(document).bind "mouseup", (event) ->
    selectionStart = null
    modeDown = null

  tileEditor.mousedown ->
    window.currentComponent = tileEditor

  hotkeys =
    a: (event) ->
      prevTile("primary")
    z: (event) ->
      nextTile("primary")
    s: (event) ->
      prevTile("secondary")
    x: (event) ->
      nextTile("secondary")
    p: ->
      showPropertiesEditor(tileEditor.find('.tiles img.primary'))
    i: ->
      {left, top} = tileEditor.find(".screen .cursor").position()
      if (tile = tileAt(left, top)).length
        showPropertiesEditor(tile)
    backspace: selectionDelete
    del: selectionDelete
    esc: clearSelection
    "ctrl+c": selectionCopy
    "ctrl+x": selectionCut

  $.each hotkeys, (key, fn) ->
    $(document).bind "keydown", key, (event) ->
      if window.currentComponent == tileEditor
        event.preventDefault()
        fn(event)

  tileEditor.find(tileTray).sortable()

  tileEditor.find(".component.tile_select").dropImageReader (file, event) ->
    if event.target.readyState == FileReader.DONE
      img = $ "<img/>",
        alt: file.name
        src: event.target.result
        title: file.name

      $(this).find(".tiles").append img

  $('.filename, .layer_select .name, .saved_selections .name', tileEditor).liveEdit()

  propEditor = $(".prop_editor", tileEditor).propertyEditor({test: true, foo: "bar", noice: 13})

  tileEditor.find("button.save").click ->
    options.save?(saveData())

  saveData = () ->
    tileIndexLookup = {}

    tileset = tileEditor.find("nav.bottom .tiles img").map((i) ->
      $this = $(this)
      src = $this.attr("src")

      tileIndexLookup[src] = i

      mapTileData = {
        src: src
      }

      if mapTileId = $this.data('guid')
        mapTileData.guid mapTileId

      if pixieId = $this.data("pixie_id")
        mapTileData.pixieId = mapTileSpriteId

      if props = $this.data("properties")
        mapTileData.properties = props

      return mapTileData
    ).get()

    layers = []

    tileEditor.find(".layer_select .choice").each (i) ->
      $this = $(this)
      name = $this.text().trim()
      entityLayer = name.match /entities/i

      screenLayer = tileEditor.find(".screen .layers .layer").eq(i)

      if entityLayer
        entities = screenLayer.find("img").map ->
          $element = $(this)

          src = $element.attr("src")
          {top, left} = $element.position()

          x: left
          y: top
          tileIndex: tileIndexLookup[src]
          properties: $(this).data("properties")
        .get()

        layer =
          name: name
          entities: entities
      else
        tileLookup = {}

        screenLayer.find("img").each ->
          src = this.getAttribute("src")
          pos = this.getAttribute("data-pos")

          tileLookup[pos] = tileIndexLookup[src]

        tiles = []

        tilesTall.times (y) ->
          row = []
          tiles.push row

          tilesWide.times (x) ->
            posString = x * tileWidth + "x" + y * tileHeight

            imgIndex = if tileLookup[posString]? then tileLookup[posString] else -1

            row.push imgIndex

        layer =
          name: name
          tiles: tiles

      layers.push layer

    return {
      title: tileEditor.find(".filename").text()
      version: "1.0"
      orientation: "orthogonal"
      width: tilesWide
      height: tilesTall
      tileWidth: tileWidth
      tileHeight: tileHeight

      tileset: tileset

      layers: layers
    }

  loadData = (data) ->
    tilesWide = data.width
    tilesTall = data.height
    tileWidth = data.tileWidth
    tileHeight = data.tileHeight

    tileEditor.find('.screen .layers').css('background-image', 'url(/images/tile_grid_' + tileWidth + '.png)')

    positionElementIndices = []

    tileLookup = {}

    tileEditor.find(tileTray).html('')
    data.tileset.each (tile, index) ->
      active = if index == 0
        "primary"
      else if index == 1
        "secondary"

      tileLookup[index] = $("<img />",
        class: active
        "data-guid": tile.guid
        "data-pixie_id": tile.pixieId
        src: tile.src
      ).appendTo(tileEditor.find(tileTray))

      if tile.properties
        tileLookup[index].data("properties", tile.properties)

    tileEditor.find("section .layers .layer").remove()

    tileEditor.find(layerSelect).html('')
    data.layers.each (layer, i) ->
      currentLayer = i

      addScreenLayer()

      templates.find(".layer_select.template").tmpl(
        name: layer.name
      ).appendTo(tileEditor.find(layerSelect))

      if tiles = layer.tiles
        tiles.each (row, y) ->
          row.each (tile, x) ->
            if tile >= 0
              replaceTile(x * tileWidth, y * tileHeight, tileLookup[tile])

      if entities = layer.entities
        for entity in entities
          tile = replaceTile(entity.x, entity.y, tileLookup[entity.tileIndex])

          if entity.properties
            tile.data("properties", entity.properties)

    tileEditor.find(layerSelect).find(".name").first().trigger("mousedown")

  if options.data
    loadData options.data
  else
    options.layers.times ->
      addNewLayer()

  tileEditor.find(".screen .cursor").css
    width: tileWidth - 1
    height: tileHeight - 1

  tileEditor.find(".screen .layers").css
    backgroundImage: grid.backgroundImage()
    width: tilesWide * tileWidth
    height: tilesTall * tileHeight

  tileEditor.bind "clean", ->
    dirty = false

  dirty = false

  $.extend tileEditor,
    addAction: (action) ->
      actionButton = $ "<button/>",
        text: action.name
        click: action.perform

      tileEditor.find("nav.left .actions").append(actionButton)

    mapData: saveData
