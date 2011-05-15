/* DO NOT MODIFY. This file was compiled Sun, 15 May 2011 19:46:03 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/jquery.property_editor.coffee
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
        element.find("tr:not(.child_property)").each(function() {
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
        var key, value;
        element.html('');
        if (properties) {
          for (key in properties) {
            value = properties[key];
            if (key.match(/color/i)) {
              addRow(key, value).find('td:last input').colorPicker();
            } else if (Object.isObject(value) && value.hasOwnProperty('x') && value.hasOwnProperty('y')) {
              addRow(key, value).find('td:last input').vectorPicker();
            } else {
              addRow(key, value);
            }
          }
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
