###
 jQuery Plugin port of
 JavaScript Color Picker

 @author    Honza Odvarko, http:#odvarko.cz
 @copyright Honza Odvarko
 @license   http://www.gnu.org/copyleft/gpl.html  GNU General Public License
 @version   1.0.9
 @link      http://jscolor.com

 @ported_by Daniel Moore http://strd6.com
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
    cursorSize = 11
    sliderPointerHeight = 11
    gradientStep = 4

    instanceId = 0
    instance = null

    colorPicker = $.tmpl "color_picker"
    slider = colorPicker.find '.hue_selector'
    overlay = colorPicker.find '.color_overlay'
    gradient = colorPicker.find '.slider'

    createDialog = ->
      colorPicker.get(0).onmousedown = (e) ->
        instance.preserve = true

      colorPicker.get(0).onmousemove = (e) ->
        setHV(e) if instance.overlayActive
        setHue(e) if instance.sliderActive

      colorPicker.get(0).onmouseup = colorPicker.onmouseout = (e) ->
        return if $(e.target).is('.red') || $(e.target).is('.green') || $(e.target).is('.blue') || $(e.target).is('.hex') || $(e.target).is('label')

        if (instance.overlayActive || instance.sliderActive)
          instance.overlayActive = instance.sliderActive = false

          # trigger change handler if we have bound a function
          instance.input.onchange?()

        instance.input.focus()

      setHV = (e) ->
        p = getMousePos(e)

        relX = (p.x - instance.cursor.x).clamp(0, colorOverlaySize)
        relY = (p.y - instance.cursor.y).clamp(0, colorOverlaySize)

        instance.color.saturation(relX / colorOverlaySize, 'hsv')
        instance.color.value(1 - (relY / colorOverlaySize))

        updateDialogPointers()
        updateInput(instance.input, instance.color)

      overlay.get(0).onmousedown = (e) ->
        instance.overlayActive = true
        setHV(e)

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

        instance.color.hue(((relY / colorOverlaySize) * 360).clamp(0, 359))

        updateDialogPointers()
        updateInput(instance.input, instance.color)

      slider.get(0).onmousedown = (e) ->
        instance.sliderActive = true
        setHue(e)

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

      updateDialogPointers()
      updateDialogSaturation()

      $(colorPicker).css
        left: "#{dp.x}px"
        top: "#{dp.y}px"

      $('body').append(colorPicker)
      updateInput(instance.input, instance.color)

    hideDialog = ->
      $('body').find(colorPicker).remove()

      instance = null

    updateDialogPointers = ->
      [hue, saturation, value] = instance.color.toHsv()

      x = (saturation * colorOverlaySize).round()
      y = ((1 - value) * colorOverlaySize).round()
      sliderY = ((hue / 360) * colorOverlaySize).round()

      slider.css
        backgroundPosition: "0 #{(sliderY - sliderPointerHeight).floor()}px"

      overlay.css
        backgroundColor: "hsl(#{hue}, 100%, 50%)"
        backgroundPosition: "#{((x - cursorSize).floor())}px #{((y - cursorSize).floor())}px"

    updateDialogSaturation = ->
      [hue, saturation, value] = instance.color.toHsv()
      r = g = b = s = c = [value, 0, 0]

      gr_length = $(gradient).children().length
      $(gradient).children().each (i, element) ->
        hue = ((i / gr_length) * 360).round()

        $(element).css
          backgroundColor: "hsl(#{hue}, 100%, 50%)"

    updateInput = (el, color) ->
      $(el).val(color.toHex(leadingHash).toUpperCase())

      map =
        red: color.r
        green: color.g
        blue: color.b
        hex: color.toHex(false).toUpperCase()

      for name, value of map
        $("input.#{name}").val(value)

      if reflectOnBackground
        $(el).css
          backgroundColor: color.toHex()
          color: if color.value() < 0.5 then '#FFF' else '#000'

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
        updateDialogPointers()

    createDialog()

    return @each ->
      @originalStyle =
        color: @style.color
        backgroundColor: @style.backgroundColor

      $(this).attr('autocomplete', 'off')
      this.onfocus = focus
      this.onblur = blur

      @setColor = setColor

      updateInput(this, Color(@value))
)(jQuery)
