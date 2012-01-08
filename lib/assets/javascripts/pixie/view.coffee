###*
A base view for our frontbone framework.
###

namespace "Pixie", (Pixie) ->
  class Pixie.View extends Backbone.View
    initialize: ->
      # Force jQuery Element
      @el = $(@el)

      # Set up HTML if template exists
      if @template?
        @el.html $.tmpl(@template)

    include: (module) ->
      Object.extend this, module(this, this)
