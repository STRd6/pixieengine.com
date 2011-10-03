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

    # prepend field's color code with #
    leadingHash = options.leadingHash || false

    # allow an empty value in the field instead of setting it to #000000
    allowEmpty = options.allowEmpty || false

    # spectrum's width and height
    HVSize = 256

    dir = options.dir || '/assets/jscolor/'

    HVCrossSize = 12
    SSize = 22
    SArrowSize = [7, 11]
    SSampleSize = 4
    ClientSliderSize = 18

    instanceId = 0
    instance = null
    elements = {}

    createDialog = ->
      # dialog
      elements.dialog = $ '<div class="color_picker"/>'

      handleMouseup = ->
        if (instance.holdHV || instance.holdS)
          instance.holdHV = instance.holdS = false
          if (typeof instance.input.onchange == 'function')
            instance.input.onchange()

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
      $(elements.hv).append('<div class="white_overlay" />', '<div class="black_overlay" />')

      setHV = (e) ->
        p = getMousePos(e)
        relX = if p[0]<instance.posHV[0] then 0 else (if p[0]-instance.posHV[0]>HVSize-1 then HVSize-1 else p[0]-instance.posHV[0])
        relY = if p[1]<instance.posHV[1] then 0 else (if p[1]-instance.posHV[1]>HVSize-1 then HVSize-1 else p[1]-instance.posHV[1])
        instance.color.setHSV(6/HVSize*relX, null, 1-1/(HVSize-1)*relY)
        updateDialogPointers()
        updateDialogSaturation()
        updateInput(instance.input, instance.color, null)

      elements.hv.mousedown = (e) ->
        instance.holdHV = true
        setHV(e)

      $(elements.dialog).append($(elements.hv))

      # saturation gradient
      elements.grad = $ '<div class="slider" />'

      # saturation gradient's samples
      for i in [0...HVSize] by SSampleSize
        g = $ '<div/>'
        g.css
          height: "#{SSampleSize}px"
          fontSize = '1px'
          lineHeight = '0'

        $(elements.grad).append(g)


      #`for(i=0 i+SSampleSize<=HVSize i+=SSampleSize) {
      #  g = document.createElement('div')
      #  g.style.height = SSampleSize+'px'
      #  g.style.fontSize = '1px'
      #  g.style.lineHeight = '0'
      #  elements.grad.appendChild(g)
      #}`

      $(elements.dialog).append($(elements.grad))

      # saturation slider
      elements.s = $ '<div class="hue_selector" />'

      setS = (e) ->
        p = getMousePos(e)
        relY = if p[1]<instance.posS[1] then 0 else (if p[1]-instance.posS[1]>HVSize-1 then HVSize-1 else p[1]-instance.posS[1])
        instance.color.setHSV(null, 1-1/(HVSize-1)*relY, null)
        updateDialogPointers()
        updateInput(instance.input, instance.color, null)

      $(elements.s).mousedown (e) ->
        instance.holdS = true
        setS(e)

      $(elements.dialog).append($(elements.s))

    showDialog = (input) ->
      IS = [input.offsetWidth, input.offsetHeight]
      ip = getElementPos(input)
      sp = getScrollPos()
      ws = getWindowSize()
      ds = [
        HVSize+SSize,
        HVSize
      ]
      dp = [
        if (-sp[0]+ip[0]+ds[0] > ws[0]-ClientSliderSize) then (if (-sp[0]+ip[0]+IS[0]/2 > ws[0]/2) then ip[0]+IS[0]-ds[0] else ip[0]) else ip[0],
        if (-sp[1]+ip[1]+IS[1]+ds[1] > ws[1]-ClientSliderSize) then (if (-sp[1]+ip[1]+IS[1]/2 > ws[1]/2) then ip[1]-ds[1] else ip[1]+IS[1]) else ip[1]+IS[1]
      ]

      instanceId++
      instance =
        input: input
        color: new color(input.value)
        preserve: false
        holdHV: false
        holdS: false
        posHV: [dp[0], dp[1]]
        posS: [dp[0] + HVSize, dp[1]]

      updateDialogPointers()
      updateDialogSaturation()

      $(elements.dialog).css
        left: dp[0] + 'px'
        top: dp[1] + 'px'

      $('body').append($(elements.dialog))

    hideDialog = ->
      $(elements.dialog).remove()

      instance = null

    updateDialogPointers = ->
      # update hue/value cross
      x = Math.round(instance.color.hue/6*HVSize)
      y = Math.round((1-instance.color.value)*(HVSize-1))
      $(elements.hv).css
        backgroundPosition: (x + (HVCrossSize / 2).floor()) + 'px ' + (y - (HVCrossSize / 2).floor()) + 'px'

      # update saturation arrow
      y = Math.round((1-instance.color.saturation)*HVSize)
      $(elements.s).css
        backgroundPosition: "0 #{(y - (SArrowSize[1] / 2).floor())}px"

    updateDialogSaturation = ->
      # update saturation gradient
      [r, g, b] = instance.color.value
      [s, c] = [0, 0]
      i = instance.color.hue.floor()
      f = if i % 2 then instance.color.hue - i else 1 - (instance.color.hue - i)
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

      gr = $(elements.grad).children()
      gr.length.times (i) ->
        s = 1 - 1/(gr.length-1)*i
        c[1] = c[0] * (1 - s*f)
        c[2] = c[0] * (1 - s)
        $(gr[i]).css
          backgroundColor: "rgb(#{c[r]*100}%, #{c[g]*100}%, #{c[b]*100}%)"

    updateInput = (el, color, realValue) ->
      if (allowEmpty && realValue != null && !/^\s*#?([0-9A-F]{3}([0-9A-F]{3})?)\s*$/i.test(realValue))
        $(el).val('')
        if reflectOnBackground
          $(el).css
            backgroundColor: el.originalStyle.backgroundColor
            color: el.originalStyle.color
      else
        $(el).val((if leadingHash then '#' else '') + color)

        if reflectOnBackground
          $(el).css
            backgroundColor: '#' + color
            color: if (0.212671 * color.red + 0.715160 * color.green + 0.072169 * color.blue) < 0.5 then '#FFF' else '#000'

    getElementPos = (e) ->
      x = 0
      y = 0
      `if (e.offsetParent) {
        do {
          x += e.offsetLeft
          y += e.offsetTop
        } while(e = e.offsetParent)
      }`
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

    color = (hex) ->
      @hue = 0
      @saturation = 1
      @value = 0

      @red = 0
      @green = 0
      @blue = 0

      @setRGB = (r, g, b) ->
        hsv = RGB_HSV(
          if (r == null) then @red else (@red = r),
          if (g == null) then @green else (@green = g),
          if (b == null) then @blue else (@blue = b)
        )

        if hsv[0] != null
          @hue = hsv[0]

        if hsv[2] != 0
          @saturation = hsv[1]

        @value = hsv[2]

      @setHSV = (h, s, v) ->
        rgb = HSV_RGB(
          if (h == null) then @hue else (@hue = h),
          if (s == null) then @saturation else (@saturation = s),
          if (v == null) then @value else (@value = v)
        )
        @red = rgb[0]
        @green = rgb[1]
        @blue = rgb[2]

      RGB_HSV = (r, g, b) ->
        n = Math.min(r, g, b)
        v = Math.max(r, g, b)
        m = v - n
        if m == 0
          return [null, 0, v]

        h = if r==n then 3+(b-g)/m else (if g==n then 5+(r-b)/m else 1+(g-r)/m)
        return [(if h==6 then 0 else h), m/v, v]

      HSV_RGB = (h, s, v) ->
        if h == null
          return [v, v, v]

        i = Math.floor(h)
        f = if i%2 then h-i else 1-(h-i)
        m = v * (1 - s)
        n = v * (1 - s*f)
        switch i
          when 6, 0
            [v, n, m]
          when 1
            [n, v, m]
          when 2
            [m, v, n]
          when 3
            [m, n, v]
          when 4
            [n, m, v]
          when 5
            [v, m, n]

      @setString = (hex) ->
        m = hex.match(/^\s*#?([0-9A-F]{3}([0-9A-F]{3})?)\s*$/i)
        if m
          if m[1].length==6
            @setRGB(
              parseInt(m[1].substr(0,2),16)/255,
              parseInt(m[1].substr(2,2),16)/255,
              parseInt(m[1].substr(4,2),16)/255
            )
          else
            @setRGB(
              parseInt(m[1].charAt(0)+m[1].charAt(0),16)/255,
              parseInt(m[1].charAt(1)+m[1].charAt(1),16)/255,
              parseInt(m[1].charAt(2)+m[1].charAt(2),16)/255
            )
        else
          @setRGB(0,0,0)
          return false

      @toString = ->
        r = Math.round(@red * 255).toString(16)
        g = Math.round(@green * 255).toString(16)
        b = Math.round(@blue * 255).toString(16)
        return (
          (if r.length == 1 then '0' + r else r) +
          (if g.length == 1 then '0' + g else g) +
          (if b.length == 1 then '0' + b else b)
        ).toUpperCase()

      if hex
        @setString(hex)

    onfocus = ->
      if (instance && instance.preserve)
        instance.preserve = false
      else
        showDialog(this)

    onblur = ->
      return if (instance && instance.preserve)

      This = this
      Id = instanceId
      setTimeout ->
        return if (instance && instance.preserve)

        if (instance && instanceId == Id)
          hideDialog()

        updateInput(This, new color(This.value), This.value)
      , 0

    setcolor = (str) ->
      c = new color(str)
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

      @setAttribute('autocomplete', 'off')
      @onfocus = onfocus
      @onblur = onblur
      @setcolor = setcolor

      updateInput(this, new color(@value), @value)
)(jQuery)
