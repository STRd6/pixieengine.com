/* Adapted from http://github.com/mathiasbynens/noSelect-jQuery-Plugin */

;(function($) {
	$.fn.noSelect = function() {
		function falseFn() {
			return false;
		}

		return this.each(function() {
			this.onselectstart = this.ondragstart = falseFn;
		});
	};
})(jQuery);
