
#= require tmpls/pixie/window.js.tmpl.haml

window.Pixie ||= {}

Pixie.Window = (I={}) ->

  self = $.tmpl("tmpls/pixie/window", I)

  self.draggable(
    handle: "h3"
    iframeFix: true
  ).find("h3").disableSelection()

  return self
