/* DO NOT MODIFY. This file was compiled Tue, 08 Mar 2011 01:30:14 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/colors.coffee
 */

(function() {
  var Color;
  Color = function(color) {
    var a, b, g, getValue, parseRGB, parseRGBA, r, self;
    if (typeof color === "string") {
      if (color[0] = '#') {
        parseHex(color);
      } else if (color.substr(0, 4) === 'rgb(') {
        parseRGB(color);
      } else if (color.substr(0, 4) === 'rgba') {
        parseRGBA(color);
      }
    }
    if (typeof color === "array") {
      r = parseInt(color[0]);
      g = parseInt(color[1]);
      b = parseInt(color[2]);
      if (color[3]) {
        a = parseFloat(color[3]);
      } else {
        a = 1;
      }
    }
    ({
      channels: [typeof I.r === 'string' && parseHex(I.r) || I.r, typeof I.g === 'string' && parseHex(I.g) || I.g, typeof I.b === 'string' && parseHex(I.b) || I.b, (typeof I.a !== 'string' && typeof I.a !== 'number') && 1 || typeof I.a === 'string' && parseFloat(I.a) || I.a]
    });
    getValue = function() {
      return (channels[0] * 0x10000) | (channels[1] * 0x100) | channels[2];
    };
    parseRGB = function(color) {
      var results;
      results = color.match(/[\d,]+/).join(',').split(',');
      return [parseInt(results[0]), parseInt(results[1]), parseInt(results[2])];
    };
    parseRGBA = function(color) {
      var results;
      results = color.match(/(\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3}),?\s*(\d\.?\d*)/)[0].join(',').split(',');
      return [parseInt(results[0]), parseInt(results[1]), parseInt(results[2]), parseFloat(results[3])];
    };
    self = {
      channels: channels,
      equals: function(other) {
        return other.r === I.r && other.g === I.g && other.b === I.b && (other.a = I.a);
      },
      hexTriplet: function() {
        return "#" + ("00000" + getValue().toString(16)).substr(-6);
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
