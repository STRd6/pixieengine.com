/* DO NOT MODIFY. This file was compiled Fri, 01 Apr 2011 22:27:37 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.property_editor.coffee
 */

(function() {
  (function($) {
    return $.fn.propertyEditor = function(properties) {
      var addRow, element;
      element = this.eq(0);
      element.addClass("properties");
      element.getProps = function() {
        var props;
        props = {};
        element.find("tr").each(function() {
          var inputs, key, value;
          inputs = $(this).find("input");
          if (key = inputs.eq(0).val()) {
            value = inputs.eq(1).val();
            try {
              props[key] = JSON.parse(value);
            } catch (e) {
              props[key] = value;
            }
            return;
          }
        });
        return props;
      };
      element.setProps = function(properties) {
        element.html('');
        if (properties) {
          $.each(properties, addRow);
        }
        addRow('', '');
        return element;
      };
      addRow = function(key, value) {
        var cell, row;
        row = $("<tr>");
        cell = $("<td>").appendTo(row);
        $("<input>", {
          type: "text",
          placeholder: "key",
          value: key
        }).appendTo(cell);
        cell = $("<td>").appendTo(row);
        if (typeof value !== "string") {
          value = JSON.stringify(value);
        }
        $("<input>", {
          type: "text",
          placeholder: "value",
          value: value
        }).appendTo(cell);
        return row.appendTo(element);
      };
      $('input', this.selector).live('keydown', function(event) {
        var $this, changeAmount, num;
        if (event.type === "keydown") {
          if (!(event.which === 38 || event.which === 40)) {
            return;
          }
        }
        event.preventDefault();
        $this = $(this);
        changeAmount = event.which === 38 ? 1 : -1;
        if ($this.val().length) {
          if (event.shiftKey) {
            changeAmount *= 5;
            if (!isNaN($this.val())) {
              $this.val(parseInt($this.val()) + changeAmount);
            }
          } else {
            if ($this.val() === "true") {
              $this.val("false");
            } else if ($this.val() === "false") {
              $this.val("true");
            } else if (!isNaN($this.val())) {
              if (parseFloat($this.val()).abs() <= 1) {
                num = parseFloat($this.val());
                $this.val((num + (0.1 * changeAmount)).toFixed(1));
              } else {
                $this.val(parseInt($this.val()) + changeAmount);
              }
            }
          }
          return element.trigger("change", element.getProps());
        }
      });
      $('input', this.selector).live('blur', function(event) {
        var $this, input;
        element.trigger("change", element.getProps());
        $this = $(this);
        if ((input = element.find("tr").last().find("input").first()).length) {
          if (input.val()) {
            return addRow('', '');
          }
        } else {
          return addRow('', '');
        }
      });
      return element.setProps(properties);
    };
  })(jQuery);
}).call(this);
