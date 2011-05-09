(($) ->
  $.fn.vectorPicker = (options) ->
    options ||= {}

    reflectOnBackground = if options.reflectOnBackground == false then false else true
    leadingHash = options.leadingHash || false
    allowEmpty = options.allowEmpty || false
    HVSize = [180, 101]

    dir = options.dir || '/images/jscolor/'

    padding = 10
    borderWidth = 1
    HVCrossSize = [15, 15]
    SSize = 22
    SArrowSize = [7, 11]
    SSampleSize = 4
    ClientSliderSize = 18

    instanceId = 0
    instance = null
    elements = {}

    createDialog = ->
      elements.dialog = $ '<div/>'
      dialogStyles =
        zIndex: '1000'
        clear: 'both'
        position: 'absolute'
        width: "#{HVSize[0] + SSize + (3*padding)}px"
        height: "#{HVSize[1] + (2*padding)}px"
        border: "#{borderWidth}px solid ThreeDHighlight"
        #borderRightColor: 'ThreeDShadow', 'borderBottomColor' : 'ThreeDShadow'
        background: "url(#{dir}hv#{HVSize[0]}x#{HVSize[1]}.png) #{padding}px #{padding}px no-repeat ThreeDFace"

      elements.dialog.css(dialogStyles)

      elements.dialog.bind
        mousedown: ->
          instance.preserve = true
        mousemove: (e) ->
          setHV(e) if instance.holdHV
          setS(e) if instance.holdS
        mouseout: ->
          if (instance.holdHV || instance.holdS)
            instance.holdHV = instance.holdS = false

            if typeof instance.input.onchange == 'function'
              instance.input.onchange()

          instance.input.focus()

      elements.hv = $ '<div/>'
      hvStyles =
        position: 'absolute'
        left: '0'
        top: '0'
        width: "#{HVSize[0] + (2*padding)}px"
        height: "#{HVSize[1] + (2*padding)}px"
        background: "url(#{dir}cross.gif) no-repeat"
        cursor: 'crosshair'

      elements.hv.css(hvStyles)

      setHV = (e) ->
        p = getMousePos(e)
        relX = if p[0]<instance.posHV[0] then 0 else (if p[0]-instance.posHV[0]>HVSize[0]-1 then HVSize[0]-1 else p[0]-instance.posHV[0])
        relY = if p[1]<instance.posHV[1] then 0 else (if p[1]-instance.posHV[1]>HVSize[1]-1 then HVSize[1]-1 else p[1]-instance.posHV[1])
        instance.color.setHSV(6/HVSize[0]*relX, null, 1-1/(HVSize[1]-1)*relY)
        updateDialogPointers()
        updateDialogSaturation()
        updateInput(instance.input, instance.color, null)

      elements.hv.mousedown (e) ->
        instance.holdHV = true
        setHV(e)

      elements.dialog.append(elements.hv)

      elements.grad = $ '<div/>'
      gradStyles =
        position: 'absolute'
        left: "#{HVSize[0] + SArrowSize[0] + (2*padding)}px"
        top: "#{padding}px"
        width: "#{SSize - SArrowSize[0]}px"

      elements.grad.css(gradStyles)

      #watch for off by 1
      (HVSize[1] / SSampleSize).times (i) ->
        g = $ '<div/>'
        g.css
          height: "#{SSampleSize}px"
          fontSize: '1px'
          lineHeight: '0'

        elements.grad.append g

      elements.dialog.append elements.grad

      elements.s = document.createElement('div')
      saturationStyles =
        position: 'absolute'
        left: "#{HVSize[0] + (2*padding)}px"
        top: '0'
        width: "#{SSize + padding}px"
        height: "#{HVSize[1] + (2*padding)}px"
        background: "url(#{dir}s.gif) no-repeat"

      elements.s.css(saturationStyles)

      setS = (e) ->
        p = getMousePos(e)
        relY = if p[1]<instance.posS[1] then 0 else (if p[1]-instance.posS[1]>HVSize[1]-1 then HVSize[1]-1 else p[1]-instance.posS[1])
        instance.color.setHSV(null, 1-1/(HVSize[1]-1)*relY, null)
        updateDialogPointers()
        updateInput(instance.input, instance.color, null)

      elements.s.mousedown = (e) ->
        instance.holdS = true
        setS(e)

      elements.dialog.append(elements.s)

    showDialog = (input) ->
      inputDimensions = [input.offsetWidth, input.offsetHeight]
      ip = getElementPos(input)
      sp = getScrollPos()
      ws = getWindowSize()
      ds = [HVSize[0]+SSize+3*padding+2*borderWidth, HVSize[1]+2*padding+2*borderWidth]
      dp = [
        if -sp[0]+ip[0]+ds[0] > ws[0]-ClientSliderSize then (if -sp[0]+ip[0]+inputDimentions[0]/2 > ws[0]/2 then ip[0]+inputDimensions[0]-ds[0] else ip[0]) else ip[0],
        if -sp[1]+ip[1]+inputDimensions[1]+ds[1] > ws[1]-ClientSliderSize then (if -sp[1]+ip[1]+inputDimensions[1]/2 > ws[1]/2 then ip[1]-ds[1] else ip[1]+inputDimensions[1]) else ip[1]+inputDimensions[1]
      ]

      instanceId++
      instance =
        input: input
        color: Color(input.value)
        preserve: false
        holdHV: false
        holdS: false
        posHV: [dp[0]+borderWidth+padding, dp[1]+borderWidth+padding]
        posS: [dp[0]+borderWidth+HVSize[0]+2*padding, dp[1]+borderWidth+padding]

      updateDialogPointers()
      updateDialogSaturation()

      elements.dialog.css
        left: "#{dp[0]}px"
        top: "#{dp[1]}px"

      $('body').append(elements.dialog)

    hideDialog = ->
      b = $('body')
      b.remove(elements.dialog)

      instance = null

    updateDialogPointers = ->
      x = (instance.color.hue/6*HVSize[0]).round()
      y = ((1-instance.color.value)*(HVSize[1]-1)).round()
      elements.hv.css('backgroundPosition', "#{padding - (HVCrossSize[0]/2).floor() + x} px #{padding - (HVCrossSize[1]/2).floor() + y} px")

      y = ((1-instance.color.saturation)*HVSize[1]).round()
      elements.s.css('backgroundPosition', "0 #{padding - (SArrowSize[1]/2).floor() + y} px")

    updateDialogSaturation = ->
      r = g = b = s = c = [instance.color.value, 0, 0]
      i = instance.color.hue.floor()
      f = if i%2 then instance.color.hue-i else 1-(instance.color.hue-i)
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
      gr = elements.grad.childNodes
      gr.length.times (i) ->
        s = 1 - 1/(gr.length-1)*i
        c[1] = c[0] * (1 - s*f)
        c[2] = c[0] * (1 - s)
        gr[i].css('backgroundColor', "rgb(#{(c[r]*100)}%,#{c[g]*100}%,#{c[b]*100}%)")

    updateInput = (e, color, realValue) ->
      if (allowEmpty && realValue != null && !/^\s*#?([0-9A-F]{3}([0-9A-F]{3})?)\s*$/i.test(realValue))
        e.value = ''
        e.css
          backgroundColor: e.originalStyle.backgroundColor
          color: e.originalStyle.color

        e.value = (if leadingHash then '#' else '') + color

        e.css
          backgroundColor: "##{color}"
          color: if (0.212671 * color.red + 0.715160 * color.green + 0.072169 * color.blue < 0.5) then '#FFF' else '#000'

    getElementPos = (e) ->
      x = y = 0
      if e.offsetParent
        while(e = e.offsetParent)
          x += e.offsetLeft
          y += e.offsetTop

      return [x, y]

    getMousePos = (e) ->
      e = window.event unless e

      x = y = 0
      if typeof e.pageX == 'number'
        x = e.pageX
        y = e.pageY
      else if typeof e.clientX == 'number'
        x = e.clientX+document.documentElement.scrollLeft+document.body.scrollLeft
        y = e.clientY+document.documentElement.scrollTop+document.body.scrollTop

      return [x, y]

    getScrollPos = ->
      x = y = 0
      if typeof window.pageYOffset == 'number'
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
      w = h = 0
      if typeof window.innerWidth == 'number'
        w = window.innerWidth
        h = window.innerHeight
      else if(document.documentElement && (document.documentElement.clientWidth || document.documentElement.clientHeight))
        w = document.documentElement.clientWidth
        h = document.documentElement.clientHeight
      else if(document.body && (document.body.clientWidth || document.body.clientHeight))
        w = document.body.clientWidth
        h = document.body.clientHeight

      return [w, h]

    onfocus = ->
      if instance && instance.preserve
        instance.preserve = false
      else
        showDialog(this)

    onblur = ->
      return if instance && instance.preserve

      This = this
      Id = instanceId

      setTimeout( ->
        return if (instance && instance.preserve)

        if instance && instanceId == Id
          hideDialog()

        updateInput(This, Color(This.value), This.value)
      , 0)

    setcolor = (str) ->
      c = Color(str)
      updateInput(this, c, str)
      if (instance && instance.input == this)
        instance.color = c
        updateDialogPointers()
        updateDialogSaturation()

    createDialog()

    return this.each ->
      this.originalStyle =
        color: this.css('color'),
        backgroundColor: this.css('backgroundColor')

      this.attr('autocomplete', 'off')
      this.focus(onfocus)
      this.blur(onblur)
      this.setcolor = setcolor

      updateInput(this, Color(this.value), this.value)
)(jQuery)