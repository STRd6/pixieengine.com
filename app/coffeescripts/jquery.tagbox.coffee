###
 tagbox
 adapted from superbly tagfield v0.1
 http://www.superbly.ch
###
(($) ->
  $.fn.tagbox = ->
    inserted = []

    tagField = this.addClass('tag_container')
    tagList = $ "<ul class='tag_list' />"
    inputContainer = $ "<li class='input_container' />"
    tagInput = $ "<input class='tag_input'>"

    tagField.append(tagList)
    tagList.append(inputContainer)
    inputContainer.append(tagInput)

    addItem = (value) ->
      unless inserted.include(value)
        inserted.push(value)
        tagInput.parent().before("<li class='tag_item'><span>#{value}</span><a> x</a></li>")
        tagInput.val("")

        $(tagList.children('.tag_item:last a')).click (e) ->
          value = $(this).prev().text()
          removeItem(value)

        tagInput.focus()
        tagField.attr('data-tags', inserted.join(','))

    removeItem = (value) ->
      if inserted.include(value)
        inserted.remove(value)
        tagList.find(".tag_item span:contains(#{value})").parent().remove()

      tagInput.focus()
      tagField.attr('data-tags', inserted.join(','))

    removeLastItem = ->
      removeItem(inserted.last())

    keys =
      enter: 13
      tab: 9
      backspace: 8

    tagInput.keydown (e) ->
      if (e.which == keys.enter || e.which == keys.tab)
        value = tagInput.val() || ""

        addItem(value.trim()) unless value.blank()

        e.preventDefault() if e.which == keys.enter
      else if e.which == keys.backspace
        removeLastItem() if tagInput.val().blank()

    $('.tag_container').click (e) ->
      tagInput.focus()

  return this
)(jQuery)
