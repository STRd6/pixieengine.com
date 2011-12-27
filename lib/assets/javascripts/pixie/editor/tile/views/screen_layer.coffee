namespace "Pixie.Editor.Tile.Views", (Views) ->
  Models = Pixie.Editor.Tile.Models

  class Views.ScreenLayer extends Backbone.View
    className: "layer"

    tagName: "li"

    initialize: ->
      # Force jQuery
      @el = $(@el)

      @el.attr "data-cid", @model.cid

      @settings = @options.settings

      @model.bind 'change', @render
      
      @objectInstances = @model.objectInstances
      @objectInstances.bind "add", @instanceAdded
      @objectInstances.bind "reset", @resetInstances
      
      @resetInstances()

      @render()
      
    instanceAdded: (instance) =>
      screenInstance = new Views.ScreenInstance
        model: instance

      @el.append screenInstance.el

    resetInstances: =>
      @$(".instance").remove()

      @objectInstances.each (instance) =>
        @instanceAdded(instance)

    render: =>
      @el.css
        zIndex: @model.get "zIndex"

      if @model.get 'visible'
        @el.fadeTo 'fast', 1
      else
        @el.fadeTo 'fast', 0

      return this
