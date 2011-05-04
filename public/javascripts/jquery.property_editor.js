/* DO NOT MODIFY. This file was compiled Wed, 04 May 2011 22:26:21 GMT from
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
      $('tr:not(.child_property) > td input', this.selector).live('keydown', function(event) {
        var $this, changeAmount, num;
        if (event.type !== "keydown") {
          return;
        }
        if (!(event.which === 38 || event.which === 40)) {
          return;
        }
        event.preventDefault();
        $this = $(this);
        changeAmount = event.which === 38 ? 1 : -1;
        if ($this.val().length) {
          if (event.shiftKey) {
            changeAmount *= 10;
            if (!isNaN($this.val())) {
              $this.val(parseInt($this.val()) + changeAmount);
            }
          } else {
            if ($this.val() === "true") {
              $this.val("false");
            } else if ($this.val() === "false") {
              $this.val("true");
            } else if (!isNaN($this.val())) {
              if (parseFloat($this.val()).abs() < 1) {
                num = parseFloat($this.val());
                $this.val((num + (0.1 * changeAmount)).toFixed(1));
              } else if (parseInt($this.val()) === 1) {
                num = parseInt($this.val());
                if (event.which === 38) {
                  $this.val(num + 1);
                } else {
                  $this.val((num - 0.1).toFixed(1));
                }
              } else if (parseInt($this.val()) === -1) {
                num = parseInt($this.val());
                if (event.which === 38) {
                  $this.val(num + 0.1).toFixed(1);
                } else {
                  $this.val(num - 1);
                }
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
