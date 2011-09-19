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

$ ->
  # THEME
  setLightTheme = (active) ->
    $('html').toggleClass('light', active)
    $('iframe').contents().find('html').toggleClass("light", active)
    $('.bulb-sprite').toggleClass('static-off', !active).toggleClass('static-on', active)

    setVal('light', active)

  $('.bulb-sprite').click ->
    $this = $(this)
    $this.toggleClass('static-off').toggleClass('static-on')

    setLightTheme $this.hasClass('static-on')

  active = if $('.bulb-sprite').length then getVal('light') else true
  if active?
    setLightTheme active
  else if $('html').hasClass 'light'
    $('.bulb-sprite').attr('class', 'static-on')

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
