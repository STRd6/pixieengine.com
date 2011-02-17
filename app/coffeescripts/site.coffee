getVal = (key) ->
  if localStorage
    JSON.parse(localStorage[key])

setVal = (key, value) ->
  if localStorage
    localStorage[key] = value

$ ->
  setLightTheme = (active) ->
    $('#fullscreen').toggleClass('light', active)
    $('iframe').contents().find('html').toggleClass("light", active)

    setVal('light', active)

  $('#bulb').click ->
    $(this).toggleClass('on')

    setLightTheme $(this).hasClass('on')

  if active = getVal('light')
    $('#bulb').toggleClass('on', active)
    setLightTheme active
