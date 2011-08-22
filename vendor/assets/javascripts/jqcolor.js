/**
 * jQuery Plugin port of
 * JavaScript Color Picker
 *
 * @author    Honza Odvarko, http://odvarko.cz
 * @copyright Honza Odvarko
 * @license   http://www.gnu.org/copyleft/gpl.html  GNU General Public License
 * @version   1.0.9
 * @link      http://jscolor.com
 *
 * @ported_by Daniel Moore http://strd6.com
 *
 */

(function($) {
  $.fn.colorPicker = function(options) {
    options = options || {};
    // set field's background according selected color?
    var reflectOnBackground = options.reflectOnBackground === false ? false : true;

    // prepend field's color code with #
    var leadingHash = options.leadingHash || false;

    // allow an empty value in the field instead of setting it to #000000
    var allowEmpty = options.allowEmpty || false;

    // spectrum's width and height
    var HVSize = [ 180, 101 ]; // normal
    switch(options.HVSize) {
      case 'small':
        HVSize = [ 120, 69 ];
        break;
      case 'tiny':
        HVSize = [ 102, 61 ];
        break;
    }

    var dir = options.dir || '/assets/jscolor/';

    var padding = 10;
    var borderWidth = 1;
    var HVCrossSize = [ 15, 15 ];
    var SSize = 22;
    var SArrowSize = [ 7, 11 ];
    var SSampleSize = 4;
    var ClientSliderSize = 18;

    var instanceId = 0;
    var instance;
    var elements = {};


    function createDialog() {

      // dialog
      elements.dialog = document.createElement('div');
      setStyle(elements.dialog, {
        'zIndex' : '1000',
        'clear' : 'both',
        'position' : 'absolute',
        'width' : HVSize[0]+SSize+3*padding+'px',
        'height' : HVSize[1]+2*padding+'px',
        'border' : borderWidth+'px solid ThreeDHighlight',
        'borderRightColor' : 'ThreeDShadow', 'borderBottomColor' : 'ThreeDShadow',
        'background' : "url('"+dir+"hv"+HVSize[0]+'x'+HVSize[1]+".png') "+padding+"px "+padding+"px no-repeat ThreeDFace"
      });

      elements.dialog.onmousedown = function() {
        instance.preserve = true;
      };

      elements.dialog.onmousemove = function(e) {
        if(instance.holdHV) {
          setHV(e);
        }
        if(instance.holdS) {
          setS(e);
        }
      };

      elements.dialog.onmouseup = elements.dialog.onmouseout = function() {
        if(instance.holdHV || instance.holdS) {
          instance.holdHV = instance.holdS = false;
          if(typeof instance.input.onchange == 'function') {
            instance.input.onchange();
          }
        }
        instance.input.focus();
      };

      // hue/value spectrum
      elements.hv = document.createElement('div');
      setStyle(elements.hv, {
        'position' : 'absolute',
        'left' : '0',
        'top' : '0',
        'width' : HVSize[0]+2*padding+'px',
        'height' : HVSize[1]+2*padding+'px',
        'background' : "url('"+dir+"cross.gif') no-repeat",
        'cursor' : 'crosshair'
      });
      var setHV = function(e) {
        var p = getMousePos(e);
        var relX = p[0]<instance.posHV[0] ? 0 : (p[0]-instance.posHV[0]>HVSize[0]-1 ? HVSize[0]-1 : p[0]-instance.posHV[0]);
        var relY = p[1]<instance.posHV[1] ? 0 : (p[1]-instance.posHV[1]>HVSize[1]-1 ? HVSize[1]-1 : p[1]-instance.posHV[1]);
        instance.color.setHSV(6/HVSize[0]*relX, null, 1-1/(HVSize[1]-1)*relY);
        updateDialogPointers();
        updateDialogSaturation();
        updateInput(instance.input, instance.color, null);
      };
      elements.hv.onmousedown = function(e) {
        instance.holdHV = true; setHV(e);
      };
      elements.dialog.appendChild(elements.hv);

      // saturation gradient
      elements.grad = document.createElement('div');
      setStyle(elements.grad, {
        'position' : 'absolute',
        'left' : HVSize[0]+SArrowSize[0]+2*padding+'px',
        'top' : padding+'px',
        'width' : SSize-SArrowSize[0]+'px'
      });
      // saturation gradient's samples
      for(var i=0; i+SSampleSize<=HVSize[1]; i+=SSampleSize) {
        var g = document.createElement('div');
        g.style.height = SSampleSize+'px';
        g.style.fontSize = '1px';
        g.style.lineHeight = '0';
        elements.grad.appendChild(g);
      }
      elements.dialog.appendChild(elements.grad);

      // saturation slider
      elements.s = document.createElement('div');
      setStyle(elements.s, {
        'position' : 'absolute',
        'left' : HVSize[0]+2*padding+'px',
        'top' : '0',
        'width' : SSize+padding+'px',
        'height' : HVSize[1]+2*padding+'px',
        'background' : "url('"+dir+"s.gif') no-repeat"
      });
      // IE 5 fix
      try {
        elements.s.style.cursor = 'pointer';
      } catch(eOldIE) {
        elements.s.style.cursor = 'hand';
      }

      var setS = function(e) {
        var p = getMousePos(e);
        var relY = p[1]<instance.posS[1] ? 0 : (p[1]-instance.posS[1]>HVSize[1]-1 ? HVSize[1]-1 : p[1]-instance.posS[1]);
        instance.color.setHSV(null, 1-1/(HVSize[1]-1)*relY, null);
        updateDialogPointers();
        updateInput(instance.input, instance.color, null);
      };

      elements.s.onmousedown = function(e) {
        instance.holdS = true;
        setS(e);
      };

      elements.dialog.appendChild(elements.s);
    }


    function showDialog(input) {
      var is = [ input.offsetWidth, input.offsetHeight ];
      var ip = getElementPos(input);
      var sp = getScrollPos();
      var ws = getWindowSize();
      var ds = [
        HVSize[0]+SSize+3*padding+2*borderWidth,
        HVSize[1]+2*padding+2*borderWidth
      ];
      var dp = [
        -sp[0]+ip[0]+ds[0] > ws[0]-ClientSliderSize ? (-sp[0]+ip[0]+is[0]/2 > ws[0]/2 ? ip[0]+is[0]-ds[0] : ip[0]) : ip[0],
        -sp[1]+ip[1]+is[1]+ds[1] > ws[1]-ClientSliderSize ? (-sp[1]+ip[1]+is[1]/2 > ws[1]/2 ? ip[1]-ds[1] : ip[1]+is[1]) : ip[1]+is[1]
      ];

      instanceId++;
      instance = {
        input : input,
        color : new color(input.value),
        preserve : false,
        holdHV : false,
        holdS : false,
        posHV : [ dp[0]+borderWidth+padding, dp[1]+borderWidth+padding ],
        posS : [ dp[0]+borderWidth+HVSize[0]+2*padding, dp[1]+borderWidth+padding ]
      };

      updateDialogPointers();
      updateDialogSaturation();

      elements.dialog.style.left = dp[0]+'px';
      elements.dialog.style.top = dp[1]+'px';
      document.getElementsByTagName('body')[0].appendChild(elements.dialog);
    }


    function hideDialog() {
      var b = document.getElementsByTagName('body')[0];
      b.removeChild(elements.dialog);

      instance = null;
    }


    function updateDialogPointers() {
      // update hue/value cross
      var x = Math.round(instance.color.hue/6*HVSize[0]);
      var y = Math.round((1-instance.color.value)*(HVSize[1]-1));
      elements.hv.style.backgroundPosition =
        (padding-Math.floor(HVCrossSize[0]/2)+x)+'px '+
        (padding-Math.floor(HVCrossSize[1]/2)+y)+'px';

      // update saturation arrow
      var y = Math.round((1-instance.color.saturation)*HVSize[1]);
      elements.s.style.backgroundPosition = '0 '+(padding-Math.floor(SArrowSize[1]/2)+y)+'px';
    }


    function updateDialogSaturation() {
      // update saturation gradient
      var r, g, b, s, c = [ instance.color.value, 0, 0 ];
      var i = Math.floor(instance.color.hue);
      var f = i%2 ? instance.color.hue-i : 1-(instance.color.hue-i);
      switch(i) {
        case 6:
        case 0:
          r=0;g=1;b=2;
          break;
        case 1:
          r=1;g=0;b=2;
          break;
        case 2:
          r=2;g=0;b=1;
          break;
        case 3:
          r=2;g=1;b=0;
          break;
        case 4:
          r=1;g=2;b=0;
          break;
        case 5:
          r=0;g=2;b=1;
          break;
      }
      var gr = elements.grad.childNodes;
      for(var i=0; i<gr.length; i++) {
        s = 1 - 1/(gr.length-1)*i;
        c[1] = c[0] * (1 - s*f);
        c[2] = c[0] * (1 - s);
        gr[i].style.backgroundColor = 'rgb('+(c[r]*100)+'%,'+(c[g]*100)+'%,'+(c[b]*100)+'%)';
      }
    }


    function updateInput(e, color, realValue) {
      if(allowEmpty && realValue != null && !/^\s*#?([0-9A-F]{3}([0-9A-F]{3})?)\s*$/i.test(realValue)) {
        e.value = '';
        if(reflectOnBackground) {
          e.style.backgroundColor = e.originalStyle.backgroundColor;
          e.style.color = e.originalStyle.color;
        }
      } else {
        e.value = (leadingHash?'#':'')+color;
        if(reflectOnBackground) {
          e.style.backgroundColor = '#'+color;
          e.style.color =
            0.212671 * color.red +
            0.715160 * color.green +
            0.072169 * color.blue < 0.5 ? '#FFF' : '#000';
        }
      }
    }


    function setStyle(e, properties) {
      for(var p in properties) {
        eval('e.style.'+p+' = properties[p]');
      }
    }


    function getElementPos(e) {
      var x=0, y=0;
      if(e.offsetParent) {
        do {
          x += e.offsetLeft;
          y += e.offsetTop;
        } while(e = e.offsetParent);
      }
      return [ x, y ];
    }


    function getMousePos(e) {
      if(!e) {
        var e = window.event;
      }
      var x=0, y=0;
      if(typeof e.pageX == 'number') {
        x = e.pageX;
        y = e.pageY;
      } else if(typeof e.clientX == 'number') {
        x = e.clientX+document.documentElement.scrollLeft+document.body.scrollLeft;
        y = e.clientY+document.documentElement.scrollTop+document.body.scrollTop;
      }
      return [ x, y ];
    }


    function getScrollPos() {
      var x=0, y=0;
      if(typeof window.pageYOffset == 'number') {
        x = window.pageXOffset;
        y = window.pageYOffset;
      } else if(document.body && (document.body.scrollLeft || document.body.scrollTop)) {
        x = document.body.scrollLeft;
        y = document.body.scrollTop;
      } else if(document.documentElement && (document.documentElement.scrollLeft || document.documentElement.scrollTop)) {
        x = document.documentElement.scrollLeft;
        y = document.documentElement.scrollTop;
      }
      return [ x, y ];
    }


    function getWindowSize() {
      var w=0, h=0;
      if(typeof window.innerWidth == 'number') {
        w = window.innerWidth;
        h = window.innerHeight;
      } else if(document.documentElement && (document.documentElement.clientWidth || document.documentElement.clientHeight)) {
        w = document.documentElement.clientWidth;
        h = document.documentElement.clientHeight;
      } else if(document.body && (document.body.clientWidth || document.body.clientHeight)) {
        w = document.body.clientWidth;
        h = document.body.clientHeight;
      }
      return [ w, h ];
    }


    function color(hex) {

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

    }


    var onfocus = function() {
      if(instance && instance.preserve) {
        instance.preserve = false;
      } else {
        showDialog(this);
      }
    };

    var onblur = function() {
      if(instance && instance.preserve) {
        return;
      }

      var This = this;
      var Id = instanceId;
      setTimeout(function() {
        if(instance && instance.preserve) {
          return;
        }

        if(instance && instanceId == Id) {
          hideDialog(); // if dialog hasn't been already shown by another instance
        }

        updateInput(This, new color(This.value), This.value);
      }, 0);
    };

    var setcolor = function(str) {
      var c = new color(str);
      updateInput(this, c, str);
      if(instance && instance.input == this) {
        instance.color = c;
        updateDialogPointers();
        updateDialogSaturation();
      }
    };

    createDialog();

    return this.each(function() {
      this.originalStyle = {
        'color' : this.style.color,
        'backgroundColor' : this.style.backgroundColor
      };
      this.setAttribute('autocomplete', 'off');
      this.onfocus = onfocus;
      this.onblur = onblur;
      this.setcolor = setcolor;

      updateInput(this, new color(this.value), this.value);
    });
  };
})(jQuery);