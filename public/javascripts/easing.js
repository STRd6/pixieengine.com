/* DO NOT MODIFY. This file was compiled Wed, 03 Aug 2011 16:15:15 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/easing.coffee
 */

(function() {
  var polynomialEasings;
  window.Easing = {
    sinusoidal: function(begin, end) {
      var change;
      change = end - begin;
      return function(t) {
        return begin + change * (1 - Math.cos(t * Math.TAU / 4));
      };
    },
    sinusoidalOut: function(begin, end) {
      var change;
      change = end - begin;
      return function(t) {
        return begin + change * (0 + Math.sin(t * Math.TAU / 4));
      };
    }
  };
  polynomialEasings = ["linear", "quadratic", "cubic", "quartic", "quintic"];
  polynomialEasings.each(function(easing, i) {
    var exponent, sign;
    exponent = i + 1;
    sign = exponent % 2 ? 1 : -1;
    Easing[easing] = function(begin, end) {
      var change;
      change = end - begin;
      return function(t) {
        return begin + change * Math.pow(t, exponent);
      };
    };
    return Easing["" + easing + "Out"] = function(begin, end) {
      var change;
      change = end - begin;
      return function(t) {
        return begin + change * (1 + sign * Math.pow(t - 1, exponent));
      };
    };
  });
  ["sinusoidal"].concat(polynomialEasings).each(function(easing) {
    return Easing["" + easing + "InOut"] = function(begin, end) {
      var easeIn, easeOut, midpoint;
      midpoint = (begin + end) / 2;
      easeIn = Easing[easing](begin, midpoint);
      easeOut = Easing["" + easing + "Out"](midpoint, end);
      return function(t) {
        if (t < 0.5) {
          return easeIn(2 * t);
        } else {
          return easeOut(2 * t - 1);
        }
      };
    };
  });
}).call(this);
