/* DO NOT MODIFY. This file was compiled Mon, 07 Mar 2011 19:20:52 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/colors.coffee
 */

(function() {
  var Color;
  Color = function(I) {
    var aArr, bArr, bHex, gArr, gHex, getValue, rArr, rHex, self;
    I || (I = {});
    if (I.hex) {
      rHex = parseInt(I.hex.substr(1, 2), 16);
      gHex = parseInt(I.hex.substr(3, 2), 16);
      bHex = parseInt(I.hex.substr(5, 2), 16);
    } else {
      rHex = gHex = bHex = void 0;
    }
    if (I.array) {
      rArr = I.array[0];
      gArr = I.array[1];
      bArr = I.array[2];
      aArr = I.array[3];
    } else {
      rArr = gArr = bArr = aArr = 0;
    }
    $.reverseMerge(I, {
      r: rHex || rArr || 0,
      g: gHex || gArr || 0,
      b: bHex || bArr || 0,
      a: aArr || 0
    });
    ({
      channels: [typeof I.r === str && parseHex(I.r) || I.r, typeof I.g === str && parseHex(I.g) || I.g, typeof I.b === str && parseHex(I.b) || I.b, (typeof I.a !== str && typeof I.a !== "number") && 1 || typeof I.a === str && parseFloat(I.a) || I.a]
    });
    getValue = function() {
      return (channels[0] * 0x10000) | (channels[1] * 0x100) | channels[2];
    };
    self = {
      channels: channels,
      equals: function(other) {
        return other.r === I.r && other.g === I.g && other.b === I.b && (other.a = I.a);
      },
      hexTriplet: function() {
        return "#" + ("00000" + getValue().toString(16)).substr(-6);
      },
      mix: function(otherColor, amount) {
        var newColors, percent;
        percent = amount ? amount.round / 100.0 : 0.5;
        newColors = channels.zip(color2.channels).map(function(element) {
          return (element[0] * percent) + (element[1] * (1 - percent));
        });
        return Color({
          array: newColors
        });
      },
      rgba: function() {
        return "rgba(" + (I.channels.join(',')) + ")";
      },
      toString: function() {
        if (channels[3] === 1) {
          return self.hexTriplet();
        } else {
          return self.rgba();
        }
      }
    };
    return self;
  };
}).call(this);
