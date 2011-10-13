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

#= require tmpls/color_picker

(($) ->
  $.fn.colorPicker = (options) ->
    options ||= {}

    leadingHash = options.leadingHash || true
    dir = options.dir || '/assets/jscolor/'

    colorOverlaySize = 256
    cursorSize = 15
    sliderPointerHeight = 11
    gradientStep = 2

    instanceId = 0
    instance = null

    colorPicker = $.tmpl "color_picker"
    slider = colorPicker.find '.hue_selector'
    overlay = colorPicker.find '.color_overlay'
    gradient = colorPicker.find '.slider'
    cursorOverlay = colorPicker.find '.cursor_overlay'

    color = (hex) ->
      @hue = 0
      @saturation = 1
      @value = 0

      @red = 0
      @green = 0
      @blue = 0

      @setRGB = (r, g, b) ->
        @red = r if r?
        @green = g if g?
        @blue = b if b?

        hsv = RGB_HSV(@red, @green, @blue)

        @hue = hsv[0]
        @saturation = hsv[1]
        @value = hsv[2]

      @setHSV = (h, s, v) ->
        @hue = h if h?
        @saturation = s if s?
        @value = v if v?

        rgb = HSV_RGB(@hue, @saturation, @value)

        @red = rgb[0]
        @green = rgb[1]
        @blue = rgb[2]

      RGB_HSV = (r, g, b) ->
        n = Math.min(r,g,b)
        v = Math.max(r,g,b)
        m = v - n

        if m == 0
          return [null, 0, v]

        if r == n
          h = 3 + (b - g) / m
        else if g == n
          h = 5 + (r - b) / m
        else
          h = 1 + (g - r) / m

        h = h % 6

        return [h, m / v, v]

      HSV_RGB = (h, s, v) ->
        return [v, v, v] unless h?

        i = Math.floor(h)
        f = if i%2 then h-i else 1-(h-i)
        m = v * (1 - s)
        n = v * (1 - s*f)

        switch i
          when 0, 6
            return [v, n, m]
          when 1
            return [n, v, m]
          when 2
            return [m, v, n]
          when 3
            return [m, n, v]
          when 4
            return [n, m, v]
          when 5
            return [v, m, n]

      @setString = (hex) ->
        m = hex.match(/^\s*#?([0-9A-F]{3}([0-9A-F]{3})?)\s*$/i)
        if(m)
          if (m[1].length==6)
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
        [r, g, b] = ((color * 255).round().toString(16) for color in [@red, @green, @blue])

        return (
          (if r.length==1 then '0'+r else r)+
          (if g.length==1 then '0'+g else g)+
          (if b.length==1 then '0'+b else b)
        ).toUpperCase()

      if hex
        @setString(hex)

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

        instance.color.saturation = relX / colorOverlaySize
        instance.color.value = 1 - (relY / colorOverlaySize)
        instance.color.setHSV()

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

        instance.color.hue = ((relY / colorOverlaySize) * 6).clamp(0, 5.99)
        instance.color.setHSV()

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
      inputWidth = input.offsetWidth

      colorPickerWidth = 292

      ip = getElementPos(input)

      dp = {
        x: ip.x + inputWidth - colorPickerWidth
        y: ip.y + inputHeight
      }

      instanceId++
      instance =
        input: input
        color: new color(input.value)
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

    hideDialog = ->
      $('body').find(colorPicker).remove()

      instance = null

    updateSliderPosition = (y) ->
      hue = instance.color.hue

      y ||= ((hue / 6) * colorOverlaySize).round()

      slider.css
        backgroundPosition: "0 #{(y - (sliderPointerHeight / 2) + 1).floor()}px"

      overlay.css
        backgroundColor: "hsl(#{hue * 60}, 100%, 50%)"

    updateOverlayPosition = (x, y) ->
      [hue, saturation, value] = [instance.color.hue, instance.color. saturation, instance.color.value]

      x ||= (saturation * colorOverlaySize).round()
      y ||= ((1 - value) * colorOverlaySize).round()

      cursorOverlay.css
        backgroundPosition: "#{((x - cursorSize / 2).floor())}px #{((y - cursorSize / 2).floor())}px"

    generateHueGradient = ->
      [hue, saturation, value] = [instance.color.hue, instance.color.saturation, instance.color.value]
      r = g = b = s = c = [value, 0, 0]

      gr_length = $(gradient).children().length
      $(gradient).children().each (i, element) ->
        hue = ((i / gr_length) * 360).round()

        $(element).css
          backgroundColor: "hsl(#{hue}, 100%, 50%)"

    updateInput = (el, color) ->
      $(el).val((if leadingHash then '#' else '') + color)

      $(el).css
        backgroundColor: '#' + color
        color: if color.value < 0.6 then '#FFF' else '#000'
        textShadow: if color.value < 0.6 then 'rgba(255, 255, 255, 0.2) 1px 1px' else 'rgba(0, 0, 0, 0.2) 1px 1px'

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

        updateInput(self, new color($(self).val()))
      , 0

    createDialog()

    return @each ->
      self = this

      $(this).css
        backgroundColor: @value

      @originalStyle =
        color: @style.color
        backgroundColor: @style.backgroundColor

      $(this).attr('autocomplete', 'off')
      @onfocus = focus
      @onblur = blur

      updateInput(this, new color(this.value))
)(jQuery)
