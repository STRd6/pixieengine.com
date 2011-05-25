###
 tagbox
 adapted from superbly tagfield v0.1
 http://www.superbly.ch
###
(($) ->
  $.fn.tagbox = (options) ->
    inserted = []

    tagField = this.addClass('tag_container')
    tagList = $ "<ul class='tag_list' />"
    inputContainer = $ "<li class='input_container' />"
    tagInput = $ "<input class='tag_input'>"

    tagField.append(tagList)
    tagList.append(inputContainer)
    inputContainer.append(tagInput)

    updateTags = ->
      tagInput.focus()
      tagField.attr('data-tags', inserted.join(','))

    addItem = (value) ->
      unless inserted.include(value)
        inserted.push(value)
        tagInput.parent().before("<li class='tag_item'><span>#{value}</span><a> x</a></li>")
        tagInput.val("")

        $(tagList.find('.tag_item:last a')).click (e) ->
          value = $(this).prev().text()
          removeItem(value)

        updateTags()

    removeItem = (value) ->
      if inserted.include(value)
        inserted.remove(value)
        tagList.find('.tag_item span').filter( ->
          $(this).text() == value
        ).parent().remove()

        updateTags()

    if options?.presets?.length
      options.presets.each (item) ->
        addItem(item)

    keys =
      enter: 13
      tab: 9
      backspace: 8

    tagInput.keydown (e) ->
      value = $(this).val() || ""
      key = e.which

      if (key == keys.enter || key == keys.tab)
        addItem(value.trim()) unless value.blank()

        e.preventDefault() if key == keys.enter
      else if key == keys.backspace
        removeItem(inserted.last()) if value.blank()

    $('.tag_container').click (e) ->
      tagInput.focus()

  return this
)(jQuery)
