/* DO NOT MODIFY. This file was compiled Thu, 12 May 2011 08:03:11 GMT from
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
      $('input', this.selector).live('keydown', function(event) {
        var $this, changeAmount, changeNumber, changeObject, flipBoolean, nextValue, obj, result, value;
        if (event.type !== "keydown") {
          return;
        }
        if (!(event.which === 13 || event.which === 37 || event.which === 38 || event.which === 39 || event.which === 40)) {
          return;
        }
        if (event.which === 13) {
          nextValue($(this));
          return;
        }
        event.preventDefault();
        $this = $(this);
        changeAmount = event.which === 38 ? 1 : -1;
        nextValue = function(input) {
          return $(input).parent().parent().next().find('td:last input').select();
        };
        flipBoolean = function(bool) {
          if (bool === "true") {
            return "false";
          } else if (bool === "false") {
            return "true";
          } else {
            return false;
          }
        };
        changeNumber = function(value, direction) {
          var num;
          if (parseFloat(value).abs() < 1) {
            num = parseFloat(value);
            return (num + (0.1 * changeAmount)).toFixed(1);
          } else if (parseInt(value) === 1) {
            num = parseInt(value);
            if (event.which === 38) {
              return num + changeAmount;
            } else {
              return (num - 0.1).toFixed(1);
            }
          } else if (parseInt(value) === -1) {
            num = parseInt(value);
            if (event.which === 38) {
              return (num + 0.1).toFixed(1);
            } else {
              return num + changeAmount;
            }
          } else {
            return parseInt(value) + changeAmount;
          }
        };
        changeObject = function(obj, key) {
          switch (key) {
            case 37:
              obj.x--;
              break;
            case 38:
              obj.y--;
              break;
            case 39:
              obj.x++;
              break;
            case 40:
              obj.y++;
          }
          return JSON.stringify(obj);
        };
        value = $this.val();
        if (value.length) {
          result = null;
          if (event.shiftKey && Number.isNumber(value)) {
            changeAmount *= 10;
          }
          element.trigger("change", element.getProps());
          try {
            obj = JSON.parse(value);
          } catch (e) {
            obj = null;
          }
          if (flipBoolean(value)) {
            result = flipBoolean(value);
          } else if (Number.isNumber(value)) {
            result = changeNumber(value, changeAmount);
          } else if (obj && obj.hasOwnProperty('x') && obj.hasOwnProperty('y')) {
            result = changeObject(obj, event.which);
          }
          return $this.val(result);
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
