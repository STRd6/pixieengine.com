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

    `function color(hex) {
      this.hue        = 0; // 0-6
      this.saturation = 1; // 0-1
      this.value      = 0; // 0-1

      this.red   = 0; // 0-1
      this.green = 0; // 0-1
      this.blue  = 0; // 0-1

      this.setRGB = function(r, g, b) { // null = don't change
        var hsv = RGB_HSV(
          r==null ? this.red : (this.red=r),
          g==null ? this.green : (this.green=g),
          b==null ? this.blue : (this.blue=b)
        );
        if(hsv[0] != null) {
          this.hue = hsv[0];
        }
        if(hsv[2] != 0) {
          this.saturation = hsv[1];
        }
        this.value = hsv[2];
      };

      this.setHSV = function(h, s, v) { // null = don't change
        var rgb = HSV_RGB(
          h==null ? this.hue : (this.hue=h),
          s==null ? this.saturation : (this.saturation=s),
          v==null ? this.value : (this.value=v)
        );
        this.red   = rgb[0];
        this.green = rgb[1];
        this.blue  = rgb[2];
      };

      function RGB_HSV(r, g, b) {
        var n = Math.min(Math.min(r,g),b);
        var v = Math.max(Math.max(r,g),b);
        var m = v - n;
        if(m == 0) {
          return [ null, 0, v ];
        }

        var h = r==n ? 3+(b-g)/m : (g==n ? 5+(r-b)/m : 1+(g-r)/m);
        return [ h==6?0:h, m/v, v ];
      }

      function HSV_RGB(h, s, v) {
        if(h == null) {
          return [ v, v, v ];
        }

        var i = Math.floor(h);
        var f = i%2 ? h-i : 1-(h-i);
        var m = v * (1 - s);
        var n = v * (1 - s*f);

        switch(i) {
          case 6:
          case 0:
            return [ v, n, m ];
          case 1:
            return [ n, v, m ];
          case 2:
            return [ m, v, n ];
          case 3:
            return [ m, n, v ];
          case 4:
            return [ n, m, v ];
          case 5:
            return [ v, m, n ];
        }
      }

      this.setString = function(hex) {
        var m = hex.match(/^\s*#?([0-9A-F]{3}([0-9A-F]{3})?)\s*$/i);
        if(m) {
          if(m[1].length==6) { // 6x hex
            this.setRGB(
              parseInt(m[1].substr(0,2),16)/255,
              parseInt(m[1].substr(2,2),16)/255,
              parseInt(m[1].substr(4,2),16)/255
            );
          } else { // 3x hex
            this.setRGB(
              parseInt(m[1].charAt(0)+m[1].charAt(0),16)/255,
              parseInt(m[1].charAt(1)+m[1].charAt(1),16)/255,
              parseInt(m[1].charAt(2)+m[1].charAt(2),16)/255
            );
          }
        } else {
          this.setRGB(0,0,0);
          return false;
        }
      };

      this.toString = function() {
        var r = Math.round(this.red * 255).toString(16);
        var g = Math.round(this.green * 255).toString(16);
        var b = Math.round(this.blue * 255).toString(16);
        return (
          (r.length==1 ? '0'+r : r)+
          (g.length==1 ? '0'+g : g)+
          (b.length==1 ? '0'+b : b)
        ).toUpperCase();
      };

      if(hex) {
        this.setString(hex);
      }

    }`

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

      ip = getElementPos(input)

      dp = {
        x: ip.x
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
      updateInput(instance.input, instance.color)

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

      $(this).attr('autocomplete', 'off')
      @onfocus = focus
      @onblur = blur
)(jQuery)
