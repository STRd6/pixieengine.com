/* DO NOT MODIFY. This file was compiled Thu, 19 May 2011 23:06:54 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/jquery.property_editor.coffee
 */

(function() {
  (function($) {
    return $.fn.propertyEditor = function(properties) {
      var addBlurEvents, addNestedRow, addRow, element, object, rowCheck;
      properties || (properties = {});
      object = properties;
      element = this.eq(0);
      element.addClass("properties");
      element.getProps = function() {
        return object;
      };
      element.setProps = function(properties) {
        var key, propertiesArray, value;
        object = properties;
        element.html('');
        if (properties) {
          propertiesArray = [];
          for (key in properties) {
            value = properties[key];
            propertiesArray.push([key, value]);
          }
          propertiesArray.sort().each(function(pair) {
            key = pair[0], value = pair[1];
            if (key.match(/color/i)) {
              return addRow(key, value).find('td:last input').colorPicker({
                leadingHash: true
              });
            } else if (Object.isObject(value) && value.hasOwnProperty('x') && value.hasOwnProperty('y')) {
              return addRow(key, value).find('td:last input').vectorPicker();
            } else if (Object.isObject(value)) {
              return addNestedRow(key, value);
            } else {
              return addRow(key, value);
            }
          });
        }
        addRow('', '');
        return element;
      };
      rowCheck = function() {
        var input;
        if ((input = element.find("tr").last().find("input").first()).length) {
          if (input.val()) {
            return addRow('', '');
          }
        } else {
          return addRow('', '');
        }
      };
      addBlurEvents = function(keyInput, valueInput) {
        keyInput.blur(function() {
          var currentName, previousName;
          currentName = keyInput.val();
          previousName = keyInput.data("previousName");
          if (currentName.blank()) {
            return;
          }
          if (currentName !== previousName) {
            keyInput.data("previousName", currentName);
            delete object[previousName];
            object[currentName] = valueInput.val();
            try {
              element.trigger("change", object);
            } catch (error) {
              if (typeof console != "undefined" && console !== null) {
                if (typeof console.error === "function") {
                  console.error(error);
                }
              }
            }
            return rowCheck();
          }
        });
        return valueInput.blur(function() {
          var currentValue, previousValue;
          currentValue = valueInput.val().parse();
          previousValue = valueInput.data("previousValue");
          if (currentValue !== previousValue) {
            valueInput.data("previousValue", currentValue);
            object[keyInput.val()] = currentValue;
            try {
              element.trigger("change", object);
            } catch (error) {
              if (typeof console != "undefined" && console !== null) {
                if (typeof console.error === "function") {
                  console.error(error);
                }
              }
            }
            return rowCheck();
          }
        });
      };
      addRow = function(key, value) {
        var cell, keyInput, row, valueInput;
        row = $("<tr>");
        cell = $("<td>").appendTo(row);
        keyInput = $("<input>", {
          "class": "key",
          data: {
            previousName: key
          },
          type: "text",
          placeholder: "key",
          value: key
        }).appendTo(cell);
        cell = $("<td>").appendTo(row);
        if (typeof value !== "string") {
          value = JSON.stringify(value);
        }
        valueInput = $("<input>", {
          "class": "value",
          data: {
            previousValue: value
          },
          type: "text",
          placeholder: "value",
          value: value
        }).appendTo(cell);
        addBlurEvents(keyInput, valueInput);
        return row.appendTo(element);
      };
      addNestedRow = function(key, value) {
        var cell, nestedEditor, row;
        row = $("<tr>");
        cell = $("<td colspan='2'>").appendTo(row);
        $("<label>", {
          text: key
        }).appendTo(cell);
        nestedEditor = $("<table>", {
          "class": "nested"
        }).appendTo(cell).propertyEditor(value);
        return row.appendTo(element);
      };
      return element.setProps(properties);
    };
  })(jQuery);
}).call(this);
