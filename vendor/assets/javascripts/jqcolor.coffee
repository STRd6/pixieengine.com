###
 jQuery Plugin port of
 JavaScript Color Picker

 @author    Honza Odvarko, http:#odvarko.cz
 @copyright Honza Odvarko
 @license   http://www.gnu.org/copyleft/gpl.html  GNU General Public License
 @version   1.0.9
 @link      http://jscolor.com

 @ported_by Daniel Moore http://strd6.com
 @ported_by Matt Diebolt http://pixieengine.com
###

#= require color
#= require tmpls/color_picker

(($) ->
  $.fn.colorPicker = (options) ->
    options ||= {}

    reflectOnBackground = options.reflectOnBackground || true
    leadingHash = options.leadingHash || true
    dir = options.dir || '/assets/jscolor/'

    colorOverlaySize = 256
    cursorSize = 15
    sliderPointerHeight = 11
    gradientStep = 4

    instanceId = 0
    instance = null

    colorPicker = $.tmpl "color_picker"
    slider = colorPicker.find '.hue_selector'
    overlay = colorPicker.find '.color_overlay'
    gradient = colorPicker.find '.slider'
    cursorOverlay = colorPicker.find '.cursor_overlay'

    createDialog = ->
      colorPicker.get(0).onmousedown = (e) ->
        instance.preserve = true

        cursorOverlay.css
          cursor: 'none'

      colorPicker.get(0).onmousemove = (e) ->
        setSV(e) if instance.overlayActive
        setHue(e) if instance.sliderActive

      colorPicker.get(0).onselectstart = (e) ->
        e.preventDefault()

      colorPicker.get(0).onmouseup = colorPicker.onmouseout = (e) ->
        cursorOverlay.css
          cursor: "url(/assets/jscolor/cross.png) 3 4, default"

        if (instance.overlayActive || instance.sliderActive)
          instance.overlayActive = instance.sliderActive = false

          # trigger change handler if we have bound a function
          instance.input.onchange?()

        instance.input.focus()

      setSV = (e) ->
        p = getMousePos(e)

        relX = (p.x - instance.cursor.x).clamp(0, colorOverlaySize)
        relY = (p.y - instance.cursor.y).clamp(0, colorOverlaySize)

        instance.color.saturation(relX / colorOverlaySize, 'hsv')
        instance.color.value(1 - (relY / colorOverlaySize))

        updateOverlayPosition(relX, relY)
        updateInput(instance.input, instance.color)

      overlay.get(0).onmousedown = (e) ->
        instance.overlayActive = true
        setSV(e)

      # saturation gradient's samples
      for i in [0...colorOverlaySize] by gradientStep
        g = $ '<div class="hue_gradient" />'
        g.css
          backgroundColor: "hsl(#{i}, 1, 0.5)"
          height: "#{gradientStep}px"

        $(gradient).append(g)

      setHue = (e) ->
        p = getMousePos(e)
        relY = (p.y - instance.sliderPosition).clamp(0, colorOverlaySize)

        instance.color.hue(((relY / colorOverlaySize) * 360).clamp(0, 359), 'hsv')

        updateSliderPosition(relY)
        updateInput(instance.input, instance.color)

      slider.get(0).onmousedown = (e) ->
        instance.sliderActive = true
        setHue(e)

        slider.css
          cursor: 'none'

      slider.get(0).onmouseup = ->
        slider.css
          cursor: 'pointer'

    showDialog = (input) ->
      inputHeight = input.offsetHeight

      ip = getElementPos(input)

      dp = {
        x: ip.x
        y: ip.y + inputHeight
      }

      instanceId++
      instance =
        input: input
        color: Color(input.value)
        preserve: false
        overlayActive: false
        sliderActive: false
        cursor: {x: dp.x, y: dp.y}
        sliderPosition: dp.y

      updateOverlayPosition()
      updateSliderPosition()
      generateHueGradient()

      $(colorPicker).css
        left: "#{dp.x}px"
        top: "#{dp.y}px"

      $('body').append(colorPicker)
      updateInput(instance.input, instance.color)

    hideDialog = ->
      $('body').find(colorPicker).remove()

      instance = null

    updateSliderPosition = (y) ->
      hue = instance.color.toHsv()[0]

      y ||= ((hue / 360) * colorOverlaySize).round()

      slider.css
        backgroundPosition: "0 #{(y - (sliderPointerHeight / 2) + 1).floor()}px"

      overlay.css
        backgroundColor: "hsl(#{hue}, 100%, 50%)"

    updateOverlayPosition = (x, y) ->
      [hue, saturation, value] = instance.color.toHsv()

      x ||= (saturation * colorOverlaySize).round()
      y ||= ((1 - value) * colorOverlaySize).round()

      cursorOverlay.css
        backgroundPosition: "#{((x - cursorSize / 2).floor())}px #{((y - cursorSize / 2).floor())}px"

    generateHueGradient = ->
      [hue, saturation, value] = instance.color.toHsv()
      r = g = b = s = c = [value, 0, 0]

      gr_length = $(gradient).children().length
      $(gradient).children().each (i, element) ->
        hue = ((i / gr_length) * 360).round()

        $(element).css
          backgroundColor: "hsl(#{hue}, 100%, 50%)"

    updateInput = (el, color) ->
      $(el).val(color.toHex(leadingHash).toUpperCase())

      if reflectOnBackground
        $(el).css
          backgroundColor: color.toHex()
          color: if color.value() < 0.6 then '#FFF' else '#000'
          textShadow: if color.value() < 0.6 then 'rgba(255, 255, 255, 0.2) 1px 1px' else 'rgba(0, 0, 0, 0.2) 1px 1px'

    getElementPos = (e) ->
      return {
        x: $(e).offset().left
        y: $(e).offset().top
      }

    getMousePos = (e) ->
      return {
        x: e.pageX
        y: e.pageY
      }

    focus = ->
      if instance?.preserve
        instance.preserve = false
      else
        showDialog(this)

    blur = ->
      return if instance?.preserve

      self = this

      id = instanceId

      setTimeout ->
        return if instance?.preserve

        if (instance && instanceId == id)
          hideDialog()

        updateInput(self, Color($(self).val()))
      , 0

    setColor = (str) ->
      color = Color(str)
      updateInput(this, color)
      if instance?.input == this
        instance.color = color
        updateOverlayPosition()
        updateSliderPosition()

    createDialog()

    return @each ->
      self = this

      @originalStyle =
        color: @style.color
        backgroundColor: @style.backgroundColor

      $(this).attr('autocomplete', 'off')
      @onfocus = focus
      @onblur = blur

      @setColor = setColor
)(jQuery)
