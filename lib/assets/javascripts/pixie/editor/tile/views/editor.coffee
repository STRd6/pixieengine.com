#= require tmpls/pixie/editor/tile/editor

#= require pixie/editor/base

#= require ../actions
#= require ../command
#= require ../console

namespace "Pixie.Editor.Tile.Views", (Views) ->
  {Tile} = Pixie.Editor
  {Command, Models} = Tile

  class Views.Editor extends Backbone.View
    className: 'editor tile_editor'

    initialize: ->
      # Force jQuery Element
      @el = $(@el)

      # Set up HTML
      @el.html $.tmpl("pixie/editor/tile/editor")

      @layerList = new Models.LayerList [
        new Models.Layer
          name: "Background"
          zIndex: 0
        new Models.Layer
          name: "Entities"
          zIndex: 1
      ]

      @entityList = new Models.EntityList [
        new Models.Entity
          src: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAABHUlEQVRYR+2WwQ3CMAxFW3HkxjzMgZgAMQUHpkBMgDoH83DjiEA+BJlg/3y7SBVSeyQl7+U7Tdx3Ez/9xPzuvwW21/uzJHhZL1OLCf9JQ73yRWQoAQZqyTAiTYEsnC2NKzAWrBNBSXwJMODheHO/3s1hZY55EmEBBNdkS8SS+BBAq2fBUQlKIAMvInUSdQqjBB6n3XvBi/3ZrH2rFE0Bb/UaXsishE4BCkTgSAKlMAukEpC4rT0gv1v7IF0CmZDdB94GlDloAXm5PozQGSApIHALLuPUUZw9iJh7gRJApfBuJQZuJmCVQUOYNDy4zAOPYg2KXssIipoT2BExEm5jUA3Q/YA3YUbmJz2hJeTJMMB6vmZTykacfW8WmBN4AS/7qCEFLkXAAAAAAElFTkSuQmCC"
        new Models.Entity
          src: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAA5klEQVRYR2NkGGDAOMD2M4w6YDQERkOA6BD4NpXjP7WyLFf2D7i9RDkAZPnh2/8Y9H0rGS5ubieLBjme70Yn2A8kOQDZckpCAGQ5yBO2qkzEO4DaloNCEOQQokKAFpbDooGgA6iZ4GBpB2Q5KP0QFQUgB3zSKCc7wcESKizeQUEPA0RFAcwBlCQ6WHCDPAIDJIUActCR65DREBgNgdEQGA2BQRUC2EpBUAGHtUFCi5oQvQ6Ala44HYBchlNaFKPXgMjmEQwBcptgsCBHb4KhewanA8j1Nbo+5MYHNjOJapRSyzGD0gEAm/Y7MAMUHQMAAAAASUVORK5CYII="
      ]

      @settings = new Models.Settings
        activeLayer: @layerList.at(0)
        activeEntity: @entityList.at(0)

      # Add Sub-components
      screen = new Views.Screen
        collection: @layerList
        settings: @settings
      @$(".content").prepend screen.el

      layerSelection = new Views.LayerSelection
        collection: @layerList
        settings: @settings
      @$(".module.right").append layerSelection.el
      
      entitySelection = new Views.EntitySelection
        collection: @entityList
        settings: @settings
      @$(".module.right").append entitySelection.el

      toolbar = new Views.Toolbar
        settings: @settings
      @$(".module.left").append toolbar.el

      # TODO: We really need that self.include method
      Object.extend this, Pixie.Editor.Base(this, this)

      $.each Tile.actions, (name, action) =>
        action.name ||= name

        @addAction action

      @addAction
        name: "delete selection"
        menu: false
        hotkeys: "del"
        perform: (editor) ->
          editor.deleteSelection()

      # Set Eval Context
      @eval = (code) =>
        eval(code)

      # TODO: Refactor this to be a real self.include
      # TODO: Reconcile Backbone Views and Super-System
      Tile.Console(this, this)

      @render()

      @takeFocus()

    render: =>
      return this

    takeFocus: =>
      window.currentComponent = this

    deleteSelection: ->
      layer = @settings.get "activeLayer"

      compoundCommand = Command.CompoundCommand()

      @settings.selection.eachPosition (x, y) ->
        if instance = layer.instanceAt(x, y)

          compoundCommand.push Command.RemoveInstance
            instance: instance
            layer: layer
          , true

      @settings.execute compoundCommand unless compoundCommand.empty()

    toJSON: ->
      settingsJSON = @settings.toJSON()

      return Object.extend settingsJSON,
        entityCache: @entityList.toJSON()
        layers: @layerList.toJSON()
        orientation: "orthogonal"

    events:
      mousemove: "takeFocus"