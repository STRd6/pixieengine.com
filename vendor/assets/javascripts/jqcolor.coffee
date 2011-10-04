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

    leadingHash = options.leadingHash || false
    allowEmpty = options.allowEmpty || false

    # spectrum's width and height
    colorOverlaySize = 256

    dir = options.dir || '/assets/jscolor/'

    cursorSize = 12
    sliderSelectorSize = [7, 11]
    gradientStep = 4
    sliderSize = 18

    instanceId = 0
    instance = null
    elements = {}

    createDialog = ->
      # dialog
      elements.dialog = $ '<div class="color_picker"/>'

      handleMouseup = ->
        if (instance.holdHV || instance.holdS)
          instance.holdHV = instance.holdS = false

        instance.input.focus()

      $(elements.dialog).bind
        mousedown: ->
          instance.preserve = true
        mousemove: (e) ->
          if instance.holdHV
            setHV(e)

          if instance.holdS
            setS(e)
        mouseup: handleMouseup
        mouseout: handleMouseup

      # hue/value spectrum
      elements.hv = $('<div class="color_overlay" />')
      elements.hv.append('<div class="white_overlay" />', '<div class="black_overlay" />')

      setHV = (e) ->
        p = getMousePos(e)
        relX = if p[0]<instance.posHV[0] then 0 else (if p[0]-instance.posHV[0]>colorOverlaySize-1 then colorOverlaySize-1 else p[0]-instance.posHV[0])
        relY = if p[1]<instance.posHV[1] then 0 else (if p[1]-instance.posHV[1]>colorOverlaySize-1 then colorOverlaySize-1 else p[1]-instance.posHV[1])
        instance.color.saturation(relX / colorOverlaySize)
        instance.color.lightness(1 - (relY / colorOverlaySize))

        updateDialogPointers()
        updateDialogSaturation()
        updateInput(instance.input, instance.color, null)

      $(elements.hv).mousedown (e) ->
        instance.holdHV = true
        setHV(e)

      $(elements.dialog).append(elements.hv)

      # saturation gradient
      elements.grad = $ '<div class="slider" />'

      # saturation gradient's samples
      for i in [0...colorOverlaySize] by gradientStep
        g = $ '<div/>'
        g.css
          backgroundColor: "hsl(#{i}, 1, 0.5)"
          height: "#{gradientStep}px"
          fontSize: '1px'
          lineHeight: '0'

        $(elements.grad).append(g)

      $(elements.dialog).append(elements.grad)

      # saturation slider
      elements.s = $ '<div class="hue_selector" />'

      setS = (e) ->
        p = getMousePos(e)
        relY = if p[1]<instance.posS[1] then 0 else (if p[1]-instance.posS[1]>colorOverlaySize-1 then colorOverlaySize-1 else p[1]-instance.posS[1])
        instance.color.saturation(1 - 1/(colorOverlaySize - 1) * relY)

        updateDialogPointers()
        updateInput(instance.input, instance.color, null)

      $(elements.s).mousedown (e) ->
        instance.holdS = true
        setS(e)

      $(elements.dialog).append(elements.s)

    showDialog = (input) ->
      IS = [input.offsetWidth, input.offsetHeight]
      ip = getElementPos(input)
      sp = getScrollPos()
      ws = getWindowSize()
      ds = [colorOverlaySize+sliderSize, colorOverlaySize]
      dp = [
        if (-sp[0]+ip[0]+ds[0] > ws[0]-sliderSize) then (if (-sp[0]+ip[0]+IS[0]/2 > ws[0]/2) then ip[0]+IS[0]-ds[0] else ip[0]) else ip[0],
        if (-sp[1]+ip[1]+IS[1]+ds[1] > ws[1]-sliderSize) then (if (-sp[1]+ip[1]+IS[1]/2 > ws[1]/2) then ip[1]-ds[1] else ip[1]+IS[1]) else ip[1]+IS[1]
      ]

      instanceId++
      instance =
        input: input
        color: Color(input.value)
        preserve: false
        holdHV: false
        holdS: false
        posHV: [dp[0], dp[1]]
        posS: [dp[0] + colorOverlaySize, dp[1]]

      updateDialogPointers()
      updateDialogSaturation()

      $(elements.dialog).css
        left: dp[0] + 'px'
        top: dp[1] + 'px'

      $('body').append(elements.dialog)

    hideDialog = ->
      $(elements.dialog).remove()

      instance = null

    updateDialogPointers = ->
      # update hue/value cross
      [hue, saturation, lightness] = instance.color.toHsl()

      x = (hue / 6 * colorOverlaySize).round()
      y = ((1 - lightness) * (colorOverlaySize-1)).round()
      $(elements.hv).css
        backgroundPosition: (x + (cursorSize / 2).floor()) + 'px ' + (y - (cursorSize / 2).floor()) + 'px'

      # update saturation arrow
      y = ((1 - saturation) * colorOverlaySize).round()
      $(elements.s).css
        backgroundPosition: "0 #{(y - (sliderSelectorSize[1] / 2).floor())}px"

    updateDialogSaturation = ->
      # update saturation gradient
      [hue, saturation, lightness] = instance.color.toHsl()
      r = g = b = s = c = [lightness, 0, 0 ]

      i = hue.floor()
      f = if i % 2 then hue - i else 1 - (hue - i)
      switch i
        when 6, 0
          r=0
          g=1
          b=2
        when 1
          r=1
          g=0
          b=2
        when 2
          r=2
          g=0
          b=1
        when 3
          r=2
          g=1
          b=0
        when 4
          r=1
          g=2
          b=0
        when 5
          r=0
          g=2
          b=1

      gr_length = $(elements.grad).children().length
      $(elements.grad).children().each (i, element) ->
        hue = ((i / gr_length) * 360).round()

        $(element).css
          backgroundColor: "hsl(#{hue}, 100%, 50%)"

    updateInput = (el, color, realValue) ->
      if (allowEmpty && realValue != null && !/^\s*#?([0-9A-F]{3}([0-9A-F]{3})?)\s*$/i.test(realValue))
        $(el).val('')
        if reflectOnBackground
          $(el).css
            backgroundColor: el.originalStyle.backgroundColor
            color: el.originalStyle.color.toHex()
      else
        $(el).val((if leadingHash then '#' else '') + color.toHex())

        if reflectOnBackground
          $(el).css
            backgroundColor: '#' + color.toHex(false)
            color: if color.lightness() < 0.5 then '#FFF' else '#000'

    getElementPos = (e) ->
      x = $(e).offset().left
      y = $(e).offset().top

      return [x, y]

    getMousePos = (e) ->
      if !e
        e = window.event

      x = 0
      y = 0

      if(typeof e.pageX == 'number')
        x = e.pageX
        y = e.pageY
      else if(typeof e.clientX == 'number')
        x = e.clientX+document.documentElement.scrollLeft+document.body.scrollLeft
        y = e.clientY+document.documentElement.scrollTop+document.body.scrollTop

      return [x, y]

    getScrollPos = ->
      x = 0
      y = 0
      if(typeof window.pageYOffset == 'number')
        x = window.pageXOffset
        y = window.pageYOffset
      else if(document.body && (document.body.scrollLeft || document.body.scrollTop))
        x = document.body.scrollLeft
        y = document.body.scrollTop
      else if(document.documentElement && (document.documentElement.scrollLeft || document.documentElement.scrollTop))
        x = document.documentElement.scrollLeft
        y = document.documentElement.scrollTop

      return [x, y]

    getWindowSize = ->
      w = 0
      h = 0

      if(typeof window.innerWidth == 'number')
        w = window.innerWidth
        h = window.innerHeight
      else if(document.documentElement && (document.documentElement.clientWidth || document.documentElement.clientHeight))
        w = document.documentElement.clientWidth
        h = document.documentElement.clientHeight
      else if(document.body && (document.body.clientWidth || document.body.clientHeight))
        w = document.body.clientWidth
        h = document.body.clientHeight

      return [w, h]

    focus = ->
      if (instance && instance.preserve)
        instance.preserve = false
      else
        showDialog(this)

    blur = ->
      return if (instance && instance.preserve)

      self = this

      id = instanceId

      setTimeout ->
        return if (instance && instance.preserve)

        if (instance && instanceId == id)
          hideDialog()

        updateInput(self, Color(self.value), self.value)
      , 0

    setcolor = (str) ->
      c = Color(str)
      updateInput(this, c, str)
      if (instance && instance.input == this)
        instance.color = c
        updateDialogPointers()
        updateDialogSaturation()

    createDialog()

    return @each ->
      @originalStyle =
        color: @style.color
        backgroundColor: @style.backgroundColor

      $(this).bind 'focus', focus
      $(this).bind 'blur', blur

      @setcolor = setcolor

      updateInput(this, Color(@value), @value)
)(jQuery)
