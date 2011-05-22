/* DO NOT MODIFY. This file was compiled Sun, 22 May 2011 17:28:39 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/jquery.property_editor.coffee
 */

(function() {
  (function($) {
    var createCodeMirrorEditor;
    createCodeMirrorEditor = function(textArea) {
      var code, editor, lang;
      code = textArea.val();
      lang = "coffeescript";
      editor = new CodeMirror.fromTextArea(textArea.get(0), {
        autoMatchParens: true,
        content: code,
        lineNumbers: true,
        parserfile: ["tokenize_" + lang + ".js", "parse_" + lang + ".js"],
        path: "/javascripts/codemirror/",
        stylesheet: ["/stylesheets/codemirror/main.css"],
        tabMode: "shift",
        textWrapping: false
      });
      $(editor.win.document).find('html').toggleClass('light', $("#bulb").hasClass('on'));
      return $(editor.win.document).keyup(function() {
        textArea.val(editor.getCode());
        return textArea.trigger('blur');
      });
    };
    return $.fn.propertyEditor = function(properties) {
      var addBlurEvents, addNestedRow, addRow, element, isCodeField, object, rowCheck;
      properties || (properties = {});
      object = properties;
      element = this.eq(0);
      element.addClass("properties");
      element.getProps = function() {
        return object;
      };
      isCodeField = function(key, value) {
        return ["create", "step", "update", "destroy"].include(key);
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
            if (key.match(/color/i)) {
              return addRow(key, value).find('td:last input').colorPicker({
                leadingHash: true
              });
            } else if (isCodeField(key, value)) {
              return createCodeMirrorEditor(addRow(key, value, {
                valueInputType: "textarea"
              }).find('td:last textarea'));
            } else if (Object.isObject(value) && value.hasOwnProperty('x') && value.hasOwnProperty('y')) {
              return addRow(key, value).find('td:last input').vectorPicker();
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
        return row.appendTo(element);
      };
      return element.setProps(properties);
    };
  })(jQuery);
}).call(this);
