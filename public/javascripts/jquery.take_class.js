/* DO NOT MODIFY. This file was compiled Tue, 26 Apr 2011 04:49:16 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/jquery.take_class.coffee
 */

(function() {
  (function($) {
    return $.fn.takeClass = function(name) {
      this.addClass(name).siblings().removeClass(name);
      return this;
    };
  })(jQuery);
}).call(this);
