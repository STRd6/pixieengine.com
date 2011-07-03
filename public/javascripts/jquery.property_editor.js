/* DO NOT MODIFY. This file was compiled Mon, 13 Jun 2011 18:51:36 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/jquery.property_editor.coffee
 */

(function() {
  (function($) {
    var events, hiddenFields, shouldHide;
    events = ["create", "step", "update", "destroy"];
    hiddenFields = events.eachWithObject([], function(event, array) {
      return array.push(event, event + "Coffee");
    });
    shouldHide = function(key, value) {
      return hiddenFields.include(key) || $.isFunction(value);
    };
    return $.fn.propertyEditor = function(properties) {
      var addBlurEvents, addNestedRow, addRow, element, fireChangedEvent, object, rowCheck;
      properties || (properties = {});
      object = properties;
      element = this.eq(0);
      element.addClass("properties");
      element.getProps = function() {
        return object;
      };
      element.setProps = function(properties) {
        var key, propertiesArray, value;
        properties || (properties = {});
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
            if (shouldHide(key, value)) {
              ;
            } else if (key.match(/color/i)) {
              return addRow(key, value).find('td:last input').colorPicker({
                leadingHash: true
              });
            } else if (Object.isObject(value)) {
              return addNestedRow(key, value);
            } else if (value != null ? typeof value.match === "function" ? value.match(/^data:image\//) : void 0 : void 0) {
              return addRow(key, value).find('td:last input').modalPixelEditor(properties);
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
      fireChangedEvent = function() {
        try {
          return element.trigger("change", [object]);
        } catch (error) {
          return typeof console != "undefined" && console !== null ? typeof console.error === "function" ? console.error(error) : void 0 : void 0;
        }
      };
      addBlurEvents = function(keyInput, valueInput) {
        keyInput.blur(function() {
          var currentName, previousName;
          currentName = keyInput.val();
          previousName = keyInput.data("previousName");
          if (currentName !== previousName) {
            keyInput.data("previousName", currentName);
            delete object[previousName];
            if (currentName.blank()) {
              return;
            }
            object[currentName] = valueInput.val();
            fireChangedEvent();
            return rowCheck();
          }
        });
        return valueInput.blur(function() {
          var currentValue, key, previousValue;
          currentValue = valueInput.val().parse();
          previousValue = valueInput.data("previousValue");
          if (currentValue !== previousValue) {
            if (!(key = keyInput.val())) {
              return;
            }
            valueInput.data("previousValue", currentValue);
            object[key] = currentValue;
            fireChangedEvent();
            return rowCheck();
          }
        });
      };
      addRow = function(key, value, options) {
        var keyInput, row, valueInput, valueInputType;
        if (options == null) {
          options = {};
        }
        row = $("<tr>");
        keyInput = $("<input>", {
          "class": "key",
          data: {
            previousName: key
          },
          type: "text",
          placeholder: "key",
          value: key
        }).appendTo($("<td>").appendTo(row));
        if (typeof value !== "string") {
          value = JSON.stringify(value);
        }
        valueInputType = options.valueInputType || "input";
        valueInput = $("<" + valueInputType + ">", {
          "class": "value",
          data: {
            previousValue: value
          },
          type: "text",
          placeholder: "value",
          value: value
        }).appendTo($("<td>").appendTo(row));
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
        nestedEditor.bind("change", function(event, changedNestedObject) {
          event.stopPropagation();
          return fireChangedEvent();
        });
        return row.appendTo(element);
      };
      return element.setProps(properties);
    };
  })(jQuery);
}).call(this);
