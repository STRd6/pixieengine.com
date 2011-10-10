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

(($) ->
  $.fn.colorPicker = (options) ->
    options ||= {}

    reflectOnBackground = options.reflectOnBackground || true
    leadingHash = options.leadingHash || true
    dir = options.dir || '/assets/jscolor/'

    colorOverlaySize = 256
    cursorSize = 12
    sliderSelectorSize = 11
    gradientStep = 4
    sliderSize = 18

    instanceId = 0
    instance = null
    elements = {}

    createDialog = ->
      elements.dialog = $ '<div class="color_picker"/>'

      handleMouseup = ->
        if (instance.holdHV || instance.holdS)
          instance.holdHV = instance.holdS = false
          if(typeof instance.input.onchange == 'function')
            instance.input.change()

        instance.input.focus()

      $(elements.dialog).bind
        mousedown: ->
          instance.preserve = true
        mousemove: (e) ->
          console.log 'here'
          if instance.holdHV
            setHV(e)

          if instance.holdS
            setHue(e)
        mouseup: handleMouseup
        mouseout: handleMouseup

      # hue/value spectrum
      elements.hv = $('<div class="color_overlay" />')
      elements.hv.append('<div class="white_overlay" />', '<div class="black_overlay" />')

      setHV = (e) ->
        p = getMousePos(e)
        relX = (p.x - instance.posHV[0]).clamp(0, colorOverlaySize)
        relY = (p.y - instance.posHV[1]).clamp(0, colorOverlaySize)

        instance.color.saturation(relX / colorOverlaySize)
        instance.color.value(1 - (relY / colorOverlaySize))

        updateDialogPointers()
        updateInput(instance.input, instance.color, null)

      $(elements.hv).mousedown (e) ->
        instance.holdHV = true
        setHV(e)

      $(elements.dialog).append(elements.hv)

      # saturation gradient
      elements.grad = $ '<div class="slider" />'

      # saturation gradient's samples
      for i in [0...colorOverlaySize] by gradientStep
        g = $ '<div class="hue_gradient" />'
        g.css
          backgroundColor: "hsl(#{i}, 1, 0.5)"
          height: "#{gradientStep}px"

        $(elements.grad).append(g)

      $(elements.dialog).append(elements.grad)

      # saturation slider
      elements.s = $ '<div class="hue_selector" />'

      setHue = (e) ->
        p = getMousePos(e)
        relY = if p.y<instance.posS[1] then 0 else (if p.y-instance.posS[1]>colorOverlaySize then colorOverlaySize else p.y-instance.posS[1])
        instance.color.hue(((relY / colorOverlaySize) * 360).clamp(0, 359))

        updateDialogPointers()
        updateInput(instance.input, instance.color, null)

      $(elements.s).mousedown (e) ->
        instance.holdS = true
        setHue(e)

      $(elements.dialog).append(elements.s)
      $(elements.dialog).append("<div class='color_inputs'><span>Red</span><input type='text' class='red' /><span>Green</span><input type='text' class='green' /><span>Blue</span><input type='text' class='blue' /><span>Hex:</span><input type='text' class='hex' /></div>")

    showDialog = (input) ->
      IS = [input.offsetWidth, input.offsetHeight]
      ip = getElementPos(input)
      sp = getScrollPos()
      ws = getWindowSize()
      ds = [colorOverlaySize+sliderSize, colorOverlaySize]
      dp = [
        if (-sp.x+ip.x+ds[0] > ws[0]-sliderSize) then (if (-sp.x+ip.x+IS[0]/2 > ws[0]/2) then ip.x+IS[0]-ds[0] else ip.x) else ip.x,
        if (-sp.y+ip.y+IS[1]+ds[1] > ws[1]-sliderSize) then (if (-sp.y+ip.y+IS[1]/2 > ws[1]/2) then ip.y-ds[1] else ip.y+IS[1]) else ip.y+IS[1]
      ]

      instanceId++
      instance =
        input: input
        color: Color(input.value)
        preserve: true
        holdHV: false
        holdS: false
        posHV: [dp[0], dp[1]]
        posS: [dp[0] + colorOverlaySize, dp[1]]

      updateDialogPointers()
      updateDialogSaturation()

      $(elements.dialog).css
        left: "#{dp[0]}px"
        top: "#{dp[1]}px"

      $('body').append(elements.dialog)

    hideDialog = ->
      $('body').find(elements.dialog).remove()

      instance = null

    updateDialogPointers = ->
      # update hue/value cross
      [hue, saturation, value] = instance.color.toHsv()

      x = (saturation * colorOverlaySize).round()
      y = ((1 - value) * colorOverlaySize).round()

      $(elements.hv).css
        backgroundPosition: "#{((x - cursorSize).floor())}px #{((y - cursorSize).floor())}px"

      y = ((hue / 360) * colorOverlaySize).round()

      $(elements.s).css
        backgroundPosition: "0 #{(y - sliderSelectorSize).floor()}px"

      $(elements.hv).css
        backgroundColor: "hsl(#{hue}, 100%, 50%)"

    updateDialogSaturation = ->
      [hue, saturation, value] = instance.color.toHsv()
      r = g = b = s = c = [value, 0, 0 ]

      gr_length = $(elements.grad).children().length
      $(elements.grad).children().each (i, element) ->
        hue = ((i / gr_length) * 360).round()

        $(element).css
          backgroundColor: "hsl(#{hue}, 100%, 50%)"

    updateInput = (el, color, realValue) ->
      $(el).val(color.toHex(leadingHash).toUpperCase())
      $('input.red').val(color.r)
      $('input.green').val(color.g)
      $('input.blue').val(color.b)
      $('input.hex').val(color.toHex(false).toUpperCase())

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
        x: $(e).get(0).pageX
        y: $(e).get(0).pageY
      }

    getScrollPos = ->
      x = 0
      y = 0

      if typeof window.pageYOffset == 'number'
        x = window.pageXOffset
        y = window.pageYOffset
      else if (document.body && (document.body.scrollLeft || document.body.scrollTop))
        x = document.body.scrollLeft
        y = document.body.scrollTop
      else if (document.documentElement && (document.documentElement.scrollLeft || document.documentElement.scrollTop))
        x = document.documentElement.scrollLeft
        y = document.documentElement.scrollTop

      return {
        x: x
        y: y
      }

    getWindowSize = ->
      return [$(window).width(), $(window).height()]

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

        updateInput(self, Color($(self).val()), $(self).val())
      , 0

    setColor = (str) ->
      color = Color(str)
      updateInput(this, color, str)
      if instance?.input == this
        instance.color = color
        updateDialogPointers()

    createDialog()

    return @each ->
      @originalStyle =
        color: @style.color
        backgroundColor: @style.backgroundColor

      $(this).attr('autocomplete', 'off')
      $(this).bind
        focus: focus
        blur: blur

      @setColor = setColor

      updateInput(this, Color(@value), @value)
)(jQuery)
