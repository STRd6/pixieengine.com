window.Pixie ||= {}

###*
Simple jQuery constructor wrappers for common elements.
###

elements = [
  "Button"
  "Canvas"
  "Div"
  "Img"
  "Input"
]

Pixie.UI = {}

elements.each (type) ->
  tag = type.toLowerCase()
  Pixie.UI[type] = (options) ->
    jQuery "<#{tag}/>", options

# Aliases
Pixie.UI.Image = Pixie.UI.Img
