/* DO NOT MODIFY. This file was compiled Wed, 03 Aug 2011 18:36:59 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/display_object.coffee
 */

(function() {
  window.DisplayObject = function(I) {
    var self;
    $.reverseMerge(I, {
      alpha: 1,
      transform: Matrix()
    });
    self = Core(I).extend({
      draw: function(canvas) {
        if (I.sprite) {
          return canvas.withTransform(I.transform, function(canvas) {
            canvas.globalAlpha(I.alpha);
            return I.sprite.draw(canvas, 0, 0);
          });
        }
      },
      drawOutline: function(canvas) {
        return canvas.withTransform(I.transform, function(canvas) {
          return canvas.strokeRect(0, 0, I.width, I.height);
        });
      },
      move: function(delta) {
        return I.transform = Matrix.translation(delta.x, delta.y).concat(I.transform);
      },
      opacify: function(amount) {
        return I.alpha = (I.alpha + amount).clamp(0, 1);
      },
      pointWithin: function(point) {
        var p, _ref, _ref2;
        p = I.transform.inverse().transformPoint(point);
        return ((0 <= (_ref = p.x) && _ref <= I.width)) && ((0 <= (_ref2 = p.y) && _ref2 <= I.height));
      },
      registrationPoint: function() {
        return Point(I.width / 2, I.height / 2);
      },
      rotate: function(angle) {
        return I.transform = I.transform.rotate(angle, self.registrationPoint());
      },
      scale: function(amount) {
        return I.transform = I.transform.scale(1 + amount, 1 + amount, self.registrationPoint());
      },
      transparentize: function(amount) {
        return I.alpha = (I.alpha - amount).clamp(0, 1);
      }
    });
    self.attrAccessor("transform", "id");
    return self;
  };
}).call(this);
