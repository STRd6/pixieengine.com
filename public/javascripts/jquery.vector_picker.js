/* DO NOT MODIFY. This file was compiled Mon, 09 May 2011 17:20:01 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.vector_picker.coffee
 */

(function() {
  (function($) {
    return $.fn.vectorPicker = function(options) {
      var ClientSliderSize, HVCrossSize, HVSize, SArrowSize, SSampleSize, SSize, allowEmpty, borderWidth, createDialog, dir, elements, getElementPos, getMousePos, getScrollPos, getWindowSize, hideDialog, instance, instanceId, leadingHash, onblur, onfocus, padding, reflectOnBackground, setcolor, showDialog, updateDialogPointers, updateDialogSaturation, updateInput;
      options || (options = {});
      reflectOnBackground = options.reflectOnBackground === false ? false : true;
      leadingHash = options.leadingHash || false;
      allowEmpty = options.allowEmpty || false;
      HVSize = [180, 101];
      dir = options.dir || '/images/jscolor/';
      padding = 10;
      borderWidth = 1;
      HVCrossSize = [15, 15];
      SSize = 22;
      SArrowSize = [7, 11];
      SSampleSize = 4;
      ClientSliderSize = 18;
      instanceId = 0;
      instance = null;
      elements = {};
      createDialog = function() {
        var dialogStyles, gradStyles, hvStyles, saturationStyles, setHV, setS;
        elements.dialog = $('<div/>');
        dialogStyles = {
          zIndex: '1000',
          clear: 'both',
          position: 'absolute',
          width: "" + (HVSize[0] + SSize + (3 * padding)) + "px",
          height: "" + (HVSize[1] + (2 * padding)) + "px",
          border: "" + borderWidth + "px solid ThreeDHighlight",
          background: "url(" + dir + "hv" + HVSize[0] + "x" + HVSize[1] + ".png) " + padding + "px " + padding + "px no-repeat ThreeDFace"
        };
        elements.dialog.css(dialogStyles);
        elements.dialog.bind({
          mousedown: function() {
            return instance.preserve = true;
          },
          mousemove: function(e) {
            if (instance.holdHV) {
              setHV(e);
            }
            if (instance.holdS) {
              return setS(e);
            }
          },
          mouseout: function() {
            if (instance.holdHV || instance.holdS) {
              instance.holdHV = instance.holdS = false;
              if (typeof instance.input.onchange === 'function') {
                instance.input.onchange();
              }
            }
            return instance.input.focus();
          }
        });
        elements.hv = $('<div/>');
        hvStyles = {
          position: 'absolute',
          left: '0',
          top: '0',
          width: "" + (HVSize[0] + (2 * padding)) + "px",
          height: "" + (HVSize[1] + (2 * padding)) + "px",
          background: "url(" + dir + "cross.gif) no-repeat",
          cursor: 'crosshair'
        };
        elements.hv.css(hvStyles);
        setHV = function(e) {
          var p, relX, relY;
          p = getMousePos(e);
          relX = p[0] < instance.posHV[0] ? 0 : (p[0] - instance.posHV[0] > HVSize[0] - 1 ? HVSize[0] - 1 : p[0] - instance.posHV[0]);
          relY = p[1] < instance.posHV[1] ? 0 : (p[1] - instance.posHV[1] > HVSize[1] - 1 ? HVSize[1] - 1 : p[1] - instance.posHV[1]);
          instance.color.setHSV(6 / HVSize[0] * relX, null, 1 - 1 / (HVSize[1] - 1) * relY);
          updateDialogPointers();
          updateDialogSaturation();
          return updateInput(instance.input, instance.color, null);
        };
        elements.hv.mousedown(function(e) {
          instance.holdHV = true;
          return setHV(e);
        });
        elements.dialog.append(elements.hv);
        elements.grad = $('<div/>');
        gradStyles = {
          position: 'absolute',
          left: "" + (HVSize[0] + SArrowSize[0] + (2 * padding)) + "px",
          top: "" + padding + "px",
          width: "" + (SSize - SArrowSize[0]) + "px"
        };
        elements.grad.css(gradStyles);
        (HVSize[1] / SSampleSize).times(function(i) {
          var g;
          g = $('<div/>');
          g.css({
            height: "" + SSampleSize + "px",
            fontSize: '1px',
            lineHeight: '0'
          });
          return elements.grad.append(g);
        });
        elements.dialog.append(elements.grad);
        elements.s = document.createElement('div');
        saturationStyles = {
          position: 'absolute',
          left: "" + (HVSize[0] + (2 * padding)) + "px",
          top: '0',
          width: "" + (SSize + padding) + "px",
          height: "" + (HVSize[1] + (2 * padding)) + "px",
          background: "url(" + dir + "s.gif) no-repeat"
        };
        elements.s.css(saturationStyles);
        setS = function(e) {
          var p, relY;
          p = getMousePos(e);
          relY = p[1] < instance.posS[1] ? 0 : (p[1] - instance.posS[1] > HVSize[1] - 1 ? HVSize[1] - 1 : p[1] - instance.posS[1]);
          instance.color.setHSV(null, 1 - 1 / (HVSize[1] - 1) * relY, null);
          updateDialogPointers();
          return updateInput(instance.input, instance.color, null);
        };
        elements.s.mousedown = function(e) {
          instance.holdS = true;
          return setS(e);
        };
        return elements.dialog.append(elements.s);
      };
      showDialog = function(input) {
        var dp, ds, inputDimensions, ip, sp, ws;
        inputDimensions = [input.offsetWidth, input.offsetHeight];
        ip = getElementPos(input);
        sp = getScrollPos();
        ws = getWindowSize();
        ds = [HVSize[0] + SSize + 3 * padding + 2 * borderWidth, HVSize[1] + 2 * padding + 2 * borderWidth];
        dp = [-sp[0] + ip[0] + ds[0] > ws[0] - ClientSliderSize ? (-sp[0] + ip[0] + inputDimentions[0] / 2 > ws[0] / 2 ? ip[0] + inputDimensions[0] - ds[0] : ip[0]) : ip[0], -sp[1] + ip[1] + inputDimensions[1] + ds[1] > ws[1] - ClientSliderSize ? (-sp[1] + ip[1] + inputDimensions[1] / 2 > ws[1] / 2 ? ip[1] - ds[1] : ip[1] + inputDimensions[1]) : ip[1] + inputDimensions[1]];
        instanceId++;
        instance = {
          input: input,
          color: Color(input.value),
          preserve: false,
          holdHV: false,
          holdS: false,
          posHV: [dp[0] + borderWidth + padding, dp[1] + borderWidth + padding],
          posS: [dp[0] + borderWidth + HVSize[0] + 2 * padding, dp[1] + borderWidth + padding]
        };
        updateDialogPointers();
        updateDialogSaturation();
        elements.dialog.css({
          left: "" + dp[0] + "px",
          top: "" + dp[1] + "px"
        });
        return $('body').append(elements.dialog);
      };
      hideDialog = function() {
        var b;
        b = $('body');
        b.remove(elements.dialog);
        return instance = null;
      };
      updateDialogPointers = function() {
        var x, y;
        x = (instance.color.hue / 6 * HVSize[0]).round();
        y = ((1 - instance.color.value) * (HVSize[1] - 1)).round();
        elements.hv.css('backgroundPosition', "" + (padding - (HVCrossSize[0] / 2).floor() + x) + " px " + (padding - (HVCrossSize[1] / 2).floor() + y) + " px");
        y = ((1 - instance.color.saturation) * HVSize[1]).round();
        return elements.s.css('backgroundPosition', "0 " + (padding - (SArrowSize[1] / 2).floor() + y) + " px");
      };
      updateDialogSaturation = function() {
        var b, c, f, g, gr, i, r, s;
        r = g = b = s = c = [instance.color.value, 0, 0];
        i = instance.color.hue.floor();
        f = i % 2 ? instance.color.hue - i : 1 - (instance.color.hue - i);
        switch (i) {
          case 6:
          case 0:
            r = 0;
            g = 1;
            b = 2;
            break;
          case 1:
            r = 1;
            g = 0;
            b = 2;
            break;
          case 2:
            r = 2;
            g = 0;
            b = 1;
            break;
          case 3:
            r = 2;
            g = 1;
            b = 0;
            break;
          case 4:
            r = 1;
            g = 2;
            b = 0;
            break;
          case 5:
            r = 0;
            g = 2;
            b = 1;
        }
        gr = elements.grad.childNodes;
        return gr.length.times(function(i) {
          s = 1 - 1 / (gr.length - 1) * i;
          c[1] = c[0] * (1 - s * f);
          c[2] = c[0] * (1 - s);
          return gr[i].css('backgroundColor', "rgb(" + (c[r] * 100) + "%," + (c[g] * 100) + "%," + (c[b] * 100) + "%)");
        });
      };
      updateInput = function(e, color, realValue) {
        if (allowEmpty && realValue !== null && !/^\s*#?([0-9A-F]{3}([0-9A-F]{3})?)\s*$/i.test(realValue)) {
          e.value = '';
          e.css({
            backgroundColor: e.originalStyle.backgroundColor,
            color: e.originalStyle.color
          });
          e.value = (leadingHash ? '#' : '') + color;
          return e.css({
            backgroundColor: "#" + color,
            color: 0.212671 * color.red + 0.715160 * color.green + 0.072169 * color.blue < 0.5 ? '#FFF' : '#000'
          });
        }
      };
      getElementPos = function(e) {
        var x, y;
        x = y = 0;
        if (e.offsetParent) {
          while ((e = e.offsetParent)) {
            x += e.offsetLeft;
            y += e.offsetTop;
          }
        }
        return [x, y];
      };
      getMousePos = function(e) {
        var x, y;
        if (!e) {
          e = window.event;
        }
        x = y = 0;
        if (typeof e.pageX === 'number') {
          x = e.pageX;
          y = e.pageY;
        } else if (typeof e.clientX === 'number') {
          x = e.clientX + document.documentElement.scrollLeft + document.body.scrollLeft;
          y = e.clientY + document.documentElement.scrollTop + document.body.scrollTop;
        }
        return [x, y];
      };
      getScrollPos = function() {
        var x, y;
        x = y = 0;
        if (typeof window.pageYOffset === 'number') {
          x = window.pageXOffset;
          y = window.pageYOffset;
        } else if (document.body && (document.body.scrollLeft || document.body.scrollTop)) {
          x = document.body.scrollLeft;
          y = document.body.scrollTop;
        } else if (document.documentElement && (document.documentElement.scrollLeft || document.documentElement.scrollTop)) {
          x = document.documentElement.scrollLeft;
          y = document.documentElement.scrollTop;
        }
        return [x, y];
      };
      getWindowSize = function() {
        var h, w;
        w = h = 0;
        if (typeof window.innerWidth === 'number') {
          w = window.innerWidth;
          h = window.innerHeight;
        } else if (document.documentElement && (document.documentElement.clientWidth || document.documentElement.clientHeight)) {
          w = document.documentElement.clientWidth;
          h = document.documentElement.clientHeight;
        } else if (document.body && (document.body.clientWidth || document.body.clientHeight)) {
          w = document.body.clientWidth;
          h = document.body.clientHeight;
        }
        return [w, h];
      };
      onfocus = function() {
        if (instance && instance.preserve) {
          return instance.preserve = false;
        } else {
          return showDialog(this);
        }
      };
      onblur = function() {
        var Id, This;
        if (instance && instance.preserve) {
          return;
        }
        This = this;
        Id = instanceId;
        return setTimeout(function() {
          if (instance && instance.preserve) {
            return;
          }
          if (instance && instanceId === Id) {
            hideDialog();
          }
          return updateInput(This, Color(This.value), This.value);
        }, 0);
      };
      setcolor = function(str) {
        var c;
        c = Color(str);
        updateInput(this, c, str);
        if (instance && instance.input === this) {
          instance.color = c;
          updateDialogPointers();
          return updateDialogSaturation();
        }
      };
      createDialog();
      return this.each(function() {
        this.originalStyle = {
          color: this.css('color'),
          backgroundColor: this.css('backgroundColor')
        };
        this.attr('autocomplete', 'off');
        this.focus(onfocus);
        this.blur(onblur);
        this.setcolor = setcolor;
        return updateInput(this, Color(this.value), this.value);
      });
    };
  })(jQuery);
}).call(this);
