namespace "Pixie.Editor.Tile.Views", (Views) ->
  Models = Pixie.Editor.Tile.Models

  class Views.Layer extends Backbone.View
    tagName: 'li'
    className: 'layer'

    initialize: ->
      @el = $(@el)

      @el.attr "data-cid", @model.cid

      @model.bind 'change', @render
      @options.settings.bind "change:activeLayer", (settings) =>
        if @model == settings.get("activeLayer")
          @el.takeClass "active"

      @render()

    render: =>
      @el.html "<div class='name'>#{@model.get 'name'}</div> <eye />"
        
      if @model == @options.settings.get "activeLayer"
        @el.takeClass "active"

      if @model.get 'visible'
        @el.fadeTo 'fast', 1
      else
        @el.fadeTo 'fast', 0.5

      return this

    activate: ->
      @options.settings.set 
        activeLayer: @model

    toggleVisible: ->
      @model.set
        visible: not @model.get 'visible'

    events:
      click: "activate"
      "click eye": "toggleVisible"
