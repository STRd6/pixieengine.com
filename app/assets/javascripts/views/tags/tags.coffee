#= require templates/tags/tag

namespace "Pixie.Views.Tags", (Tags) ->
  class Tags.Tags extends Backbone.View
    el: '.tags'

    events:
      'click .tag': 'searchTags'

    initialize: ->
      @collection.bind 'afterReset', =>
        @render()

    searchTags: (e) =>
      tag = $(e.target).text().toLowerCase()
      @collection.filterTagged(tag)

    render: =>
      tags = []

      $(@el).empty()

      for model in @collection.models
        if model.attributes.tags
          for tag in model.attributes.tags
            tags.push tag.name unless tags.include(tag.name)

      for name in tags
        $(@el).append($(JST['tags/tag']({name: name})))

      return @
