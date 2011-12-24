# DUCT TAPE
window.namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top    = target
  target = target[item] or= {} for item in name.split '.'
  block target, top

Object.isObject = (object) ->
  Object.prototype.toString.call(object) == '[object Object]'

Function::debounce = (wait) ->
  timeout = null
  func = this

  return ->
    context = this
    args = arguments

    later = ->
      timeout = null
      func.apply(context, args)

    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
# END DUCT TAPE

# Event tracking
window.trackEvent = (category, action, label) ->
  _gaq.push(['_trackEvent', category, action, label])

clickTrackers =
  a: "click"
  button: "click"

for tag, type of clickTrackers
  do (tag, type) ->
    $(tag).live type, ->
      category = $(this).parents('[eventCategory]:first').attr('eventCategory') || "Page"
      label = $(this).attr('eventLabel') || $(this).text() || $(this).attr('title')
      trackEvent(category, type, $.trim(label))

# Notifications
window.notify = (message, delay) ->
  $.pnotify
    pnotify_animate_speed: 'fast'
    pnotify_text: message
    pnotify_delay: delay
    pnotify_history: false

# Clickable
$(".clickable").live 'click', (event) ->
  unless $(event.target).is("a")
    document.location = $(this).find("a").eq(0).attr("href")

# Local Storage
window.getVal = (key) ->
  if localStorage
    try
      JSON.parse(localStorage[key])
    catch error
      undefined

window.setVal = (key, value) ->
  if localStorage
    localStorage[key] = value

window.trackPageview = (pageName) ->
  _gaq.push ["_trackPageview", pageName]

window.getCsrfData = ->
  data = {}
  data[$("meta[name=csrf-param]").attr("content")] = $("meta[name=csrf-token]").attr("content")
  return data

$(".tag .remove").live "click", ->
  $this = $(this)
  spriteId = $this.parent().attr("data-sprite_id")
  tag = $this.prev().text()
  $this.parent().fadeOut()
  $.post "/sprites/#{spriteId}/remove_tag",
    tag: tag

$ ->
  $.modal.defaults.overlayClose = true

  makeTag = (tag, spriteId) ->
    tagElem = $("<div class='tag' />")
    tagElem.attr "data-sprite_id", spriteId
    link = $("<a href='/sprites/?tagged=#{escape(tag)}' />").text(tag)
    tagElem.append link
    tagElem.append $("<div class='remove' />").text("X")  if loggedIn
    return tagElem

  $(".tags form").ajaxForm beforeSubmit: (array, $form) ->
    input = $form.find("input[name=tag]")
    spriteId = $form.attr("data-sprite_id")
    tag = input.val()
    $form.before makeTag(tag, spriteId)
    input.val ""

  $("#flashes .close").live "mousedown", ->
    $(this).parent().slideUp()

  # Display Flash Notice
  $("#flashes .notice").each ->
    notify($(this).html())

  # Tipsy
  $('.tipsy').tipsy
    delayIn: 200
    delayOut: 500
    fade: 50
    gravity: 'w'
    opacity: 1

  # Draggable UI Windows
  $(".window").draggable(
    handle: "h3"
    iframeFix: true
  ).find("h3").disableSelection()

  $('.window .ui-icon-close').live "click", ->
    $(this).parent().hide().children("iframe").remove()

