#= require templates/pixie/window

window.Pixie ||= {}

Pixie.Window = (I={}) ->
  self = $(JST["pixie/window"](I))

  self.draggable(
    handle: "h3"
    iframeFix: true
  ).find("h3").disableSelection()

  return self
