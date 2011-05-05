/* DO NOT MODIFY. This file was compiled Wed, 04 May 2011 23:59:07 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.property_editor.coffee
 */

(function() {
  (function($) {
    return $.fn.propertyEditor = function(properties) {
      var addRow, element, generateChildElements, populateParentObjects;
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
        populateParentObjects();
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
      populateParentObjects = function() {
        return element.find('tr > tr.child_property').parent().each(function(i, group) {
          var props;
          props = {};
          $(group).find('tr.child_property').each(function(i, row) {
            var inputs, key, value;
            inputs = $(row).find('input');
            key = inputs.eq(0).val().substring(inputs.eq(0).val().search(/\./) + 1);
            value = inputs.eq(1).val();
            if (!isNaN(value)) {
              value = parseFloat(value);
            }
            try {
              props[key] = JSON.parse(value);
            } catch (e) {
              props[key] = value;
            }
            return;
          });
          return $(group).find('> td input').eq(1).val(JSON.stringify(props));
        });
      };
      generateChildElements = function(childData, parentName) {
        var key, key_cell, results, row, value, value_cell;
        results = [];
        for (key in childData) {
          value = childData[key];
          row = $("<tr class='child_property'>");
          key_cell = $("<td><input type='text' placeholder='key', value=" + parentName + "." + key + "></td>");
          value_cell = $("<td><input type='text' placeholder='value', value=" + value + "></td>");
          results.push(row.append(key_cell, value_cell));
        }
        return results;
      };
      addRow = function(key, value) {
        var cell, obj, row;
        row = $("<tr>");
        cell = $("<td>").appendTo(row);
        $("<input>", {
          type: "text",
          placeholder: "key",
          value: key
        }).appendTo(cell);
        cell = $("<td>").appendTo(row);
        if (Object.prototype.toString.call(value) === '[object Object]') {
          obj = JSON.parse(JSON.stringify(value));
        }
        if (typeof value !== "string") {
          value = JSON.stringify(value);
        }
        $("<input>", {
          type: "text",
          placeholder: "value",
          value: value
        }).appendTo(cell);
        if (obj) {
          generateChildElements(obj, key).each(function(childRow) {
            return childRow.appendTo(row);
          });
        }
        return row.appendTo(element);
      };
      $('input', this.selector).live('keydown', function(event) {
        var $this, changeAmount, changeNumber, flipBoolean, result, value;
        if (event.type !== "keydown") {
          return;
        }
        if (!(event.which === 38 || event.which === 40)) {
          return;
        }
        event.preventDefault();
        $this = $(this);
        changeAmount = event.which === 38 ? 1 : -1;
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
        value = $this.val();
        if (value.length) {
          result = null;
          if (event.shiftKey && Number.isNumber(value)) {
            changeAmount *= 10;
          }
          element.trigger("change", element.getProps());
          if (flipBoolean(value)) {
            result = flipBoolean(value);
          } else if (Number.isNumber(value)) {
            result = changeNumber(value, changeAmount);
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
