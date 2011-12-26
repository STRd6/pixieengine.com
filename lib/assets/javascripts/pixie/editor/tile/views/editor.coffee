#= require tmpls/pixie/editor/tile/editor

#= require ../console

namespace "Pixie.Editor.Tile.Views", (exports) ->
  Models = Pixie.Editor.Tile.Models
  Views = exports

  {Button} = Pixie.UI

  class Views.Editor extends Backbone.View
    className: 'editor tile_editor'

    initialize: ->
      # Force jQuery Element
      @el = $(@el)

      # Set up HTML
      @el.html $.tmpl("pixie/editor/tile/editor")

      @settings = new Models.Settings

      layerList = new Models.LayerList [
        new Models.Layer
          name: "Background"
        new Models.Layer
          name: "Entities"
      ]

      layerList.activeLayer(layerList.at(0))
      
      entityList = new Models.EntityList [
        new Models.Entity
      ]

      # Add Sub-components
      screen = new Views.Screen
        collection: layerList
        settings: @settings
      @$(".content").prepend screen.el

      layerSelection = new Views.LayerSelection
        collection: layerList
      @$(".module.right").append layerSelection.el
      
      entitySelection = new Views.EntitySelection
        collection: entityList
      @$(".module.right").append entitySelection.el

      toolbar = new Views.Toolbar
      @$(".module.left").append toolbar.el
      
      # Set Eval Context
      @eval = (code) =>
        eval(code)

      # TODO: Refactor this to be a real self.include
      # TODO: Reconcile Backbone Views and Super-System
      Pixie.Editor.Tile.Console(this, this)

      @render()

    addAction: (action) =>
      name = action.name
      titleText = name.capitalize()
      undoable = action.undoable
      self = this

      doIt = ->
        if undoable
          self.trigger("dirty")
          self.nextUndo()

        action.perform(self)

      # TODO: Action Hotkeys

      if action.menu != false
        # TODO: Action Image Icons

        actionButton = Button
          text: name.capitalize()
          title: titleText
        .on "mousedown touchstart", ->
          doIt() unless $(this).attr('disabled')

          return false

        actionButton.appendTo(@$(".content .actions.top"))

    render: =>
