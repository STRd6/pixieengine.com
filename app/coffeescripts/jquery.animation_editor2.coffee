$.fn.animationEditor = ->
  animationNumber = 1
  animations = []

  Controls = ->
    playing = false
    paused = false

    scrubberEl = $('.scrubber')

    scrubber =
      min: scrubberEl.get(0).min
      max: scrubberEl.get(0).max
      val: scrubberEl.val()

    fpsEl = $('.fps input')

    fps =
      min: fpsEl.get(0).min
      max: fpsEl.get(0).max
      val: fpsEl.val()

    self =
      play: ->
        scrubber.val = (scrubber.val + 1) % scrubber.max

      stop: ->
        scrubber.val = 0

      update: ->
        scrubberEl.val(scrubber.val)

    return self

  Animation = (name) ->
    tileset = []
    sequences = []
    currentFrameIndex = 0

    name ||= "Animation #{animationNumber}"
    animationNumber += 1

    self =
      addFrame: (image) ->
        tileset.push(image)

      advanceFrame: ->
        currentFrameIndex = (currentFrameIndex + 1) % tileset.length

      name: name

      removeFrame: (image) ->
        tileset.remove(image)

    return self

  animations.push(Animation())

  animationEditor = $(this.get(0)).addClass("editor animation_editor")

  templates = $("#animation_editor_templates")
  animationTemplate = templates.find('.animation')

  templates.find(".editor.template").tmpl().appendTo(animationEditor)

  controls = Controls()

  updateUI = ->
    for animation in animations
      animations = $('.animations')

      animations.children().remove()
      animationTemplate.tmpl(animation.name).appendTo(animations)

  updateUI()

  controls.play()
  controls.update()
