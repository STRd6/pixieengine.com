$.fn.animationEditor = ->
  animationNumber = 1

  animation:
    name: "Animation #{animationNumber}"
    tileset: []
    sequences: []

  addAnimation: ->
    animationNumber += 1

  animationEditor = $(this.get(0)).addClass("editor animation_editor")

  templates = $("#animation_editor_templates")

  templates.find(".editor.template").tmpl().appendTo(animationEditor)