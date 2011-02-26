# Clickable
$(".clickable").live 'click', ->
  document.location = $(this).find("a").eq(0).attr("href")

# Local Storage
getVal = (key) ->
  if localStorage
    try
      JSON.parse(localStorage[key])
    catch error
      undefined

setVal = (key, value) ->
  if localStorage
    localStorage[key] = value

$ ->
  # THEME
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
