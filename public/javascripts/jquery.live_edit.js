/* DO NOT MODIFY. This file was compiled Tue, 25 Jan 2011 16:33:35 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.live_edit.coffee
 */

(function() {
  (function($) {
    return $.fn.liveEdit = function() {
      this.live('dblclick', function() {
        var $this, id, textInput;
        $this = $(this);
        if ($this.is("input")) {
          return;
        }
        textInput = $("<input/>", {
          "class": $this.attr("class"),
          "data-origType": this.tagName,
          id: (id = $this.attr("id")) ? id : null,
          type: "text",
          value: $.trim($this.text())
        });
        $this.replaceWith(textInput);
        return textInput.focus().select();
      });
      this.live('blur keydown', function(event) {
        var $this, id;
        if (event.type === "keydown") {
          if (!(event.which === 13 || event.which === 9)) {
            return;
          }
        }
        $this = $(this);
        if ($this.data("removed")) {
          return;
        }
        if (!$this.is("input")) {
          return;
        }
        $this.attr("data-removed", true);
        return $this.replaceWith($("<" + $this.data("origType") + " />", {
          "class": $this.attr("class"),
          id: (id = $this.attr("id")) ? id : null,
          text: $this.val()
        }));
      });
      return this;
    };
  })(jQuery);
}).call(this);
