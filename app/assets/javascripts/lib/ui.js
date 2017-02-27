(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.UI = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){

/*
Action
======

Actions have a function to call, a hotkey, and a function that determines
whether or not they are disabled. This is so we can present them in the UI for
menus.

The hotkey is for display purposes only and needs to be listened to by a
separate mechanism to perform. [TODO] The action can be executed like a regular
function (instead of needing to use call).

Actions may have icons and help text as well.
 */
var Observable,
  slice = [].slice;

Observable = require("observable");

module.exports = function(fn, hotkey) {
  var disabled;
  disabled = Observable(false);
  setInterval(function() {
    return disabled.toggle();
  }, 1000);
  return {
    disabled: disabled,
    hotkey: function() {
      return hotkey;
    },
    call: function() {
      var args;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return fn.call.apply(fn, args);
    }
  };
};


},{"observable":11}],2:[function(require,module,exports){
var ContextMenu, FormSampleTemplate, MenuBar, Modal, Observable, Progress, Style, Table, Window, addWindow, contextMenu, desktop, element, notepadMenuParsed, notepadMenuText, o, parseMenu, ref, ref1, sampleMenuParsed, style;

ref = require("./export"), ContextMenu = ref.ContextMenu, MenuBar = ref.MenuBar, Modal = ref.Modal, Observable = ref.Observable, (ref1 = ref.Util, parseMenu = ref1.parseMenu), Progress = ref.Progress, Style = ref.Style, Table = ref.Table, Window = ref.Window;

o = require("./util").o;

notepadMenuText = require("./samples/notepad-menu");

notepadMenuParsed = parseMenu(notepadMenuText);

FormSampleTemplate = require("./samples/test-form");

style = document.createElement("style");

style.innerHTML = Style.all;

document.head.appendChild(style);

sampleMenuParsed = parseMenu("[M]odal\n  [A]lert\n  [C]onfirm\n  [P]rompt\n  [F]orm\n  P[r]ogress\n[T]est Nesting\n  Test[1]\n    Hello\n    Wat\n  Test[2]\n    [N]ested\n    [R]ad\n      So Rad\n      Hella\n        Hecka\n          Super Hecka\n            Wicked\n[W]indow\n  New [I]mage -> newImage\n  New [P]ixel -> newPixel\n  New [T]ext -> newText\n  New [S]preadsheet -> newSheet");

element = MenuBar({
  items: sampleMenuParsed,
  handlers: {
    alert: function() {
      return Modal.alert("yolo");
    },
    prompt: function() {
      return Modal.prompt("Pretty cool, eh?", "Yeah!").then(console.log);
    },
    confirm: function() {
      return Modal.confirm("Jawsome!").then(console.log);
    },
    form: function() {
      return Modal.form(FormSampleTemplate()).then(console.log);
    },
    progress: function() {
      var initialMessage, intervalId, progressView;
      initialMessage = "Reticulating splines";
      progressView = Progress({
        value: 0,
        max: 2,
        message: initialMessage
      });
      Modal.show(progressView.element, {
        cancellable: false
      });
      return intervalId = setInterval(function() {
        var ellipses, ellipsesCount, j, newValue, results;
        newValue = progressView.value() + 1 / 60;
        ellipsesCount = Math.floor(newValue * 4) % 4;
        ellipses = (function() {
          results = [];
          for (var j = 0; 0 <= ellipsesCount ? j < ellipsesCount : j > ellipsesCount; 0 <= ellipsesCount ? j++ : j--){ results.push(j); }
          return results;
        }).apply(this).map(function() {
          return ".";
        }).join("");
        progressView.value(newValue);
        progressView.message(initialMessage + ellipses);
        if (newValue > 2) {
          clearInterval(intervalId);
          return Modal.hide();
        }
      }, 15);
    },
    newImage: function() {
      var img;
      img = document.createElement("img");
      img.src = "https://s3.amazonaws.com/whimsyspace-databucket-1g3p6d9lcl6x1/danielx/data/pI1mvEvxcXJk4mNHNUW-kZsNJsrPDXcAtgguyYETRXQ";
      return addWindow({
        title: "Yoo",
        content: img
      });
    },
    newPixel: function() {
      var frame;
      frame = document.createElement("iframe");
      frame.src = "https://danielx.net/pixel-editor/embedded/";
      return addWindow({
        title: "Pixel",
        content: frame
      });
    },
    newText: function() {
      var textarea;
      textarea = document.createElement("textarea");
      return addWindow({
        title: "Notepad.exe",
        content: textarea
      });
    },
    newSheet: function() {
      var InputTemplate, RowElement, data, menuBar, tableView;
      data = [0, 1, 2, 3, 4].map(function(i) {
        return {
          id: i,
          name: "yolo",
          color: "#FF0000"
        };
      });
      InputTemplate = require("./templates/input");
      RowElement = function(datum) {
        var tr, types;
        tr = document.createElement("tr");
        types = ["number", "text", "color"];
        Object.keys(datum).forEach(function(key, i) {
          var td;
          td = document.createElement("td");
          td.appendChild(InputTemplate({
            value: o(datum, key),
            type: types[i]
          }));
          return tr.appendChild(td);
        });
        return tr;
      };
      element = (tableView = Table({
        data: data,
        RowElement: RowElement
      })).element;
      menuBar = MenuBar({
        items: parseMenu("Insert\n  Row -> insertRow\nHelp\n  About"),
        handlers: {
          about: function() {
            return Modal.alert("Spreadsheet v0.0.1 by Daniel X Moore");
          },
          insertRow: function() {
            data.push({
              id: 50,
              name: "new",
              color: "#FF00FF"
            });
            return tableView.render();
          }
        }
      });
      return addWindow({
        title: "Spreadsheet [DEMO VERSION]",
        content: element,
        menuBar: menuBar.element
      });
    }
  }
}).element;

document.body.appendChild(element);

desktop = document.createElement("desktop");

document.body.appendChild(desktop);

contextMenu = ContextMenu({
  items: sampleMenuParsed[1][1],
  handlers: {}
});

desktop.addEventListener("contextmenu", function(e) {
  if (e.target === desktop) {
    e.preventDefault();
    return contextMenu.display({
      inElement: document.body,
      x: e.pageX,
      y: e.pageY
    });
  }
});

addWindow = function(arg) {
  var content, menuBar, title, windowView;
  title = arg.title, menuBar = arg.menuBar, content = arg.content;
  if (menuBar == null) {
    menuBar = MenuBar({
      items: notepadMenuParsed,
      handlers: {}
    }).element;
  }
  if (title == null) {
    title = "Hello";
  }
  windowView = Window({
    title: title,
    menuBar: menuBar,
    content: content
  });
  desktop.appendChild(windowView.element);
  return windowView;
};


},{"./export":3,"./samples/notepad-menu":12,"./samples/test-form":13,"./templates/input":15,"./util":24}],3:[function(require,module,exports){
var Action, ContextMenuView, MenuBarView, MenuItemView, MenuView, Modal, Observable, ProgressView, Style, TableView, WindowView;

Action = require("./action");

ContextMenuView = require("./views/context-menu");

Modal = require("./modal");

MenuView = require("./views/menu");

MenuBarView = require("./views/menu-bar");

MenuItemView = require("./views/menu-item");

Observable = require("observable");

ProgressView = require("./views/progress");

Style = require("./style");

TableView = require("./views/table");

WindowView = require("./views/window");

module.exports = {
  Action: Action,
  Bindable: require("bindable"),
  ContextMenu: ContextMenuView,
  Modal: Modal,
  Menu: MenuView,
  MenuBar: MenuBarView,
  MenuItem: MenuItemView,
  Observable: Observable,
  Progress: ProgressView,
  Style: Style,
  Table: TableView,
  Util: {
    parseMenu: require("./lib/indent-parse")
  },
  Window: WindowView
};


},{"./action":1,"./lib/indent-parse":5,"./modal":7,"./style":14,"./views/context-menu":25,"./views/menu":29,"./views/menu-bar":26,"./views/menu-item":27,"./views/progress":30,"./views/table":31,"./views/window":32,"bindable":8,"observable":11}],4:[function(require,module,exports){
module.exports = function(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
};


},{}],5:[function(require,module,exports){
var parse, top;

top = function(stack) {
  return stack[stack.length - 1];
};

parse = function(source) {
  var depth, indentation, stack;
  stack = [[]];
  indentation = /^(  )*/;
  depth = 0;
  source.split("\n").forEach(function(line, lineNumber) {
    var current, items, match, newDepth, prev, text;
    match = line.match(indentation)[0];
    text = line.replace(match, "");
    newDepth = match.length / 2;
    if (!text.trim().length) {
      return;
    }
    current = text;
    if (newDepth > depth) {
      if (newDepth !== depth + 1) {
        throw new Error("Unexpected indentation on line " + lineNumber);
      }
      items = [];
      prev = top(stack);
      prev.push([prev.pop(), items]);
      stack.push(items);
    } else if (newDepth < depth) {
      stack = stack.slice(0, newDepth + 1);
    }
    depth = newDepth;
    return top(stack).push(current);
  });
  return stack[0];
};

module.exports = parse;


},{}],6:[function(require,module,exports){

module.exports = require("./export");



},{"./demo":2,"./export":3}],7:[function(require,module,exports){

/*
Modal

Display modal alerts or dialogs.

Modal has promise returning equivalents of the native browser:

- Alert
- Confirm
- Prompt

These accept the same arguments and return a promise fulfilled with
the same return value as the native methods.

You can display any element in the modal:

    modal.show myElement
 */
var Modal, ModalTemplate, PromptTemplate, cancellable, closeHandler, empty, formDataToObject, handle, modal, prompt, ref;

ref = require("./util"), formDataToObject = ref.formDataToObject, handle = ref.handle, empty = ref.empty;

PromptTemplate = require("./templates/modal/prompt");

ModalTemplate = require("./templates/modal");

modal = ModalTemplate();

cancellable = true;

modal.onclick = function(e) {
  if (e.target === modal && cancellable) {
    return Modal.hide();
  }
};

document.addEventListener("keydown", function(e) {
  if (!e.defaultPrevented) {
    if (e.key === "Escape" && cancellable) {
      e.preventDefault();
      return Modal.hide();
    }
  }
});

document.body.appendChild(modal);

closeHandler = null;

prompt = function(params) {
  return new Promise(function(resolve) {
    var element, ref1;
    element = PromptTemplate(params);
    Modal.show(element, {
      cancellable: false,
      closeHandler: resolve
    });
    return (ref1 = element.querySelector(params.focus)) != null ? ref1.focus() : void 0;
  });
};

module.exports = Modal = {
  show: function(element, options) {
    if (typeof options === "function") {
      closeHandler = options;
    } else {
      closeHandler = options != null ? options.closeHandler : void 0;
      if ((options != null ? options.cancellable : void 0) != null) {
        cancellable = options.cancellable;
      }
    }
    empty(modal).appendChild(element);
    return modal.classList.add("active");
  },
  hide: function(dataForHandler) {
    if (typeof closeHandler === "function") {
      closeHandler(dataForHandler);
    }
    modal.classList.remove("active");
    cancellable = true;
    return empty(modal);
  },
  alert: function(message) {
    return prompt({
      title: "Alert",
      message: message,
      focus: "button",
      confirm: handle(function() {
        return Modal.hide();
      })
    });
  },
  prompt: function(message, defaultValue) {
    if (defaultValue == null) {
      defaultValue = "";
    }
    return prompt({
      title: "Prompt",
      message: message,
      focus: "input",
      defaultValue: defaultValue,
      cancel: handle(function() {
        return Modal.hide(null);
      }),
      confirm: handle(function() {
        return Modal.hide(modal.querySelector("input").value);
      })
    });
  },
  confirm: function(message) {
    return prompt({
      title: "Confirm",
      message: message,
      focus: "button",
      cancel: handle(function() {
        return Modal.hide(false);
      }),
      confirm: handle(function() {
        return Modal.hide(true);
      })
    });
  },
  form: function(formElement) {
    return new Promise(function(resolve) {
      var submitHandler;
      submitHandler = handle(function(e) {
        var formData, result;
        formData = new FormData(formElement);
        result = formDataToObject(formData);
        return Modal.hide(result);
      });
      formElement.addEventListener("submit", submitHandler);
      return Modal.show(formElement, function(result) {
        formElement.removeEventListener("submit", submitHandler);
        return resolve(result);
      });
    });
  }
};


},{"./templates/modal":19,"./templates/modal/prompt":20,"./util":24}],8:[function(require,module,exports){
// Generated by CoffeeScript 1.12.4
(function() {
  var remove,
    slice = [].slice;

  module.exports = function(I, self) {
    var eventCallbacks;
    if (I == null) {
      I = {};
    }
    if (self == null) {
      self = {};
    }
    eventCallbacks = {};
    self.on = function(namespacedEvent, callback) {
      var event, namespace, ref;
      ref = namespacedEvent.split("."), event = ref[0], namespace = ref[1];
      if (namespace) {
        callback.__PIXIE || (callback.__PIXIE = {});
        callback.__PIXIE[namespace] = true;
      }
      eventCallbacks[event] || (eventCallbacks[event] = []);
      eventCallbacks[event].push(callback);
      return self;
    };
    self.off = function(namespacedEvent, callback) {
      var callbacks, event, key, namespace, ref;
      ref = namespacedEvent.split("."), event = ref[0], namespace = ref[1];
      if (event) {
        eventCallbacks[event] || (eventCallbacks[event] = []);
        if (namespace) {
          eventCallbacks[event] = eventCallbacks.filter(function(callback) {
            var ref1;
            return ((ref1 = callback.__PIXIE) != null ? ref1[namespace] : void 0) == null;
          });
        } else {
          if (callback) {
            remove(eventCallbacks[event], callback);
          } else {
            eventCallbacks[event] = [];
          }
        }
      } else if (namespace) {
        for (key in eventCallbacks) {
          callbacks = eventCallbacks[key];
          eventCallbacks[key] = callbacks.filter(function(callback) {
            var ref1;
            return ((ref1 = callback.__PIXIE) != null ? ref1[namespace] : void 0) == null;
          });
        }
      }
      return self;
    };
    self.trigger = function() {
      var callbacks, event, parameters;
      event = arguments[0], parameters = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      callbacks = eventCallbacks[event];
      if (callbacks) {
        callbacks.forEach(function(callback) {
          return callback.apply(self, parameters);
        });
      }
      return self;
    };
    return self;
  };

  remove = function(array, value) {
    var index;
    index = array.indexOf(value);
    if (index >= 0) {
      return array.splice(index, 1)[0];
    }
  };

}).call(this);

},{}],9:[function(require,module,exports){
// Generated by CoffeeScript 1.7.1
(function() {
  "use strict";
  var Observable, Runtime, bindEvent, bindObservable, bufferTo, classes, createElement, empty, eventNames, get, id, isEvent, isFragment, makeElement, observeAttribute, observeAttributes, observeContent, specialBindings, valueBind, valueIndexOf;

  Observable = require("o_0");

  eventNames = "abort\nblur\nchange\nclick\ncontextmenu\ndblclick\ndrag\ndragend\ndragenter\ndragexit\ndragleave\ndragover\ndragstart\ndrop\nerror\nfocus\ninput\nkeydown\nkeypress\nkeyup\nload\nmousedown\nmousemove\nmouseout\nmouseover\nmouseup\nreset\nresize\nscroll\nselect\nsubmit\ntouchcancel\ntouchend\ntouchenter\ntouchleave\ntouchmove\ntouchstart\nunload".split("\n");

  isEvent = function(name) {
    return eventNames.indexOf(name) !== -1;
  };

  isFragment = function(node) {
    return (node != null ? node.nodeType : void 0) === 11;
  };

  valueBind = function(element, value, context) {
    Observable(function() {
      var update;
      value = Observable(value, context);
      switch (element.nodeName) {
        case "SELECT":
          element.oninput = element.onchange = function() {
            var optionValue, _ref, _value;
            _ref = this.children[this.selectedIndex], optionValue = _ref.value, _value = _ref._value;
            return value(_value || optionValue);
          };
          update = function(newValue) {
            var options;
            element._value = newValue;
            if ((options = element._options)) {
              if (newValue.value != null) {
                return element.value = (typeof newValue.value === "function" ? newValue.value() : void 0) || newValue.value;
              } else {
                return element.selectedIndex = valueIndexOf(options, newValue);
              }
            } else {
              return element.value = newValue;
            }
          };
          return bindObservable(element, value, context, update);
        default:
          element.oninput = element.onchange = function() {
            return value(element.value);
          };
          if (typeof element.attachEvent === "function") {
            element.attachEvent("onkeydown", function() {
              return setTimeout(function() {
                return value(element.value);
              }, 0);
            });
          }
          return bindObservable(element, value, context, function(newValue) {
            if (element.value !== newValue) {
              return element.value = newValue;
            }
          });
      }
    });
  };

  specialBindings = {
    INPUT: {
      checked: function(element, value, context) {
        element.onchange = function() {
          return typeof value === "function" ? value(element.checked) : void 0;
        };
        return bindObservable(element, value, context, function(newValue) {
          return element.checked = newValue;
        });
      }
    },
    SELECT: {
      options: function(element, values, context) {
        var updateValues;
        values = Observable(values, context);
        updateValues = function(values) {
          empty(element);
          element._options = values;
          return values.map(function(value, index) {
            var option, optionName, optionValue;
            option = createElement("option");
            option._value = value;
            if (typeof value === "object") {
              optionValue = (value != null ? value.value : void 0) || index;
            } else {
              optionValue = value.toString();
            }
            bindObservable(option, optionValue, value, function(newValue) {
              return option.value = newValue;
            });
            optionName = (value != null ? value.name : void 0) || value;
            bindObservable(option, optionName, value, function(newValue) {
              return option.textContent = option.innerText = newValue;
            });
            element.appendChild(option);
            if (value === element._value) {
              element.selectedIndex = index;
            }
            return option;
          });
        };
        return bindObservable(element, values, context, updateValues);
      }
    }
  };

  observeAttribute = function(element, context, name, value) {
    var binding, nodeName, _ref;
    nodeName = element.nodeName;
    if (name === "value") {
      valueBind(element, value);
    } else if (binding = (_ref = specialBindings[nodeName]) != null ? _ref[name] : void 0) {
      binding(element, value, context);
    } else if (name.match(/^on/) && isEvent(name.substr(2))) {
      bindEvent(element, name, value, context);
    } else if (isEvent(name)) {
      bindEvent(element, "on" + name, value, context);
    } else {
      bindObservable(element, value, context, function(newValue) {
        if ((newValue != null) && newValue !== false) {
          return element.setAttribute(name, newValue);
        } else {
          return element.removeAttribute(name);
        }
      });
    }
    return element;
  };

  observeAttributes = function(element, context, attributes) {
    return Object.keys(attributes).forEach(function(name) {
      var value;
      value = attributes[name];
      return observeAttribute(element, context, name, value);
    });
  };

  bindObservable = function(element, value, context, update) {
    var observable, observe, unobserve;
    observable = Observable(value, context);
    observe = function() {
      observable.observe(update);
      return update(observable());
    };
    unobserve = function() {
      return observable.stopObserving(update);
    };
    observe();
    return element;
  };

  bindEvent = function(element, name, fn, context) {
    return element[name] = function() {
      return fn.apply(context, arguments);
    };
  };

  id = function(element, context, sources) {
    var lastId, update, value;
    value = Observable.concat.apply(Observable, sources.map(function(source) {
      return Observable(source, context);
    }));
    update = function(newId) {
      return element.id = newId;
    };
    lastId = function() {
      return value.last();
    };
    return bindObservable(element, lastId, context, update);
  };

  classes = function(element, context, sources) {
    var classNames, update, value;
    value = Observable.concat.apply(Observable, sources.map(function(source) {
      return Observable(source, context);
    }));
    update = function(classNames) {
      return element.className = classNames;
    };
    classNames = function() {
      return value.join(" ");
    };
    return bindObservable(element, classNames, context, update);
  };

  createElement = function(name) {
    return document.createElement(name);
  };

  observeContent = function(element, context, contentFn) {
    var append, contents, update;
    contents = [];
    contentFn.call(context, {
      buffer: bufferTo(context, contents),
      element: makeElement
    });
    append = function(item) {
      if (item == null) {

      } else if (typeof item === "string") {
        return element.appendChild(document.createTextNode(item));
      } else if (typeof item === "number") {
        return element.appendChild(document.createTextNode(item));
      } else if (typeof item === "boolean") {
        return element.appendChild(document.createTextNode(item));
      } else if (typeof item.each === "function") {
        return item.each(append);
      } else if (typeof item.forEach === "function") {
        return item.forEach(append);
      } else {
        return element.appendChild(item);
      }
    };
    update = function(contents) {
      empty(element);
      return contents.forEach(append);
    };
    return update(contents);
  };

  bufferTo = function(context, collection) {
    return function(content) {
      if (typeof content === 'function') {
        content = Observable(content, context);
      }
      collection.push(content);
      return content;
    };
  };

  makeElement = function(name, context, attributes, fn) {
    var element;
    if (attributes == null) {
      attributes = {};
    }
    element = createElement(name);
    Observable(function() {
      if (attributes.id != null) {
        id(element, context, attributes.id);
        return delete attributes.id;
      }
    });
    Observable(function() {
      if (attributes["class"] != null) {
        classes(element, context, attributes["class"]);
        return delete attributes["class"];
      }
    });
    Observable(function() {
      return observeAttributes(element, context, attributes);
    }, context);
    if (element.nodeName !== "SELECT") {
      Observable(function() {
        return observeContent(element, context, fn);
      }, context);
    }
    return element;
  };

  Runtime = function(context) {
    var self;
    self = {
      buffer: function(content) {
        if (self.root) {
          throw "Cannot have multiple root elements";
        }
        return self.root = content;
      },
      element: makeElement,
      filter: function(name, content) {}
    };
    return self;
  };

  Runtime.VERSION = require("../package.json").version;

  Runtime.Observable = Observable;

  module.exports = Runtime;

  empty = function(node) {
    var child, _results;
    _results = [];
    while (child = node.firstChild) {
      _results.push(node.removeChild(child));
    }
    return _results;
  };

  valueIndexOf = function(options, value) {
    if (typeof value === "object") {
      return options.indexOf(value);
    } else {
      return options.map(function(option) {
        return option.toString();
      }).indexOf(value.toString());
    }
  };

  get = function(x) {
    if (typeof x === 'function') {
      return x();
    } else {
      return x;
    }
  };

}).call(this);

},{"../package.json":10,"o_0":11}],10:[function(require,module,exports){
module.exports={
  "_args": [
    [
      {
        "raw": "hamlet.coffee@^0.7.0",
        "scope": null,
        "escapedName": "hamlet.coffee",
        "name": "hamlet.coffee",
        "rawSpec": "^0.7.0",
        "spec": ">=0.7.0 <0.8.0",
        "type": "range"
      },
      "/home/daniel/apps/ui/node_modules/jadeletify"
    ]
  ],
  "_from": "hamlet.coffee@>=0.7.0 <0.8.0",
  "_id": "hamlet.coffee@0.7.6",
  "_inCache": true,
  "_location": "/hamlet.coffee",
  "_nodeVersion": "5.9.1",
  "_npmOperationalInternal": {
    "host": "packages-16-east.internal.npmjs.com",
    "tmp": "tmp/hamlet.coffee-0.7.6.tgz_1462565840722_0.9751376679632813"
  },
  "_npmUser": {
    "name": "strd6",
    "email": "yahivin@gmail.com"
  },
  "_npmVersion": "3.7.3",
  "_phantomChildren": {},
  "_requested": {
    "raw": "hamlet.coffee@^0.7.0",
    "scope": null,
    "escapedName": "hamlet.coffee",
    "name": "hamlet.coffee",
    "rawSpec": "^0.7.0",
    "spec": ">=0.7.0 <0.8.0",
    "type": "range"
  },
  "_requiredBy": [
    "/jadeletify"
  ],
  "_resolved": "https://registry.npmjs.org/hamlet.coffee/-/hamlet.coffee-0.7.6.tgz",
  "_shasum": "c537eeadd175b2e66279b85bc4efedb0e5bd8763",
  "_shrinkwrap": null,
  "_spec": "hamlet.coffee@^0.7.0",
  "_where": "/home/daniel/apps/ui/node_modules/jadeletify",
  "bugs": {
    "url": "https://github.com/dr-coffee-labs/hamlet/issues"
  },
  "dependencies": {
    "hamlet-compiler": "0.7.0",
    "o_0": "0.3.8"
  },
  "description": "Truly amazing templating!",
  "devDependencies": {
    "browserify": "^12.0.1",
    "coffee-script": "~1.7.1",
    "jsdom": "^7.2.0",
    "mocha": "^2.3.3"
  },
  "directories": {},
  "dist": {
    "shasum": "c537eeadd175b2e66279b85bc4efedb0e5bd8763",
    "tarball": "https://registry.npmjs.org/hamlet.coffee/-/hamlet.coffee-0.7.6.tgz"
  },
  "files": [
    "dist/"
  ],
  "gitHead": "9c7b1fe2248307a606e3513f590c1a3b0fc82858",
  "homepage": "http://hamlet.coffee",
  "main": "dist/runtime.js",
  "maintainers": [
    {
      "name": "strd6",
      "email": "yahivin@gmail.com"
    }
  ],
  "name": "hamlet.coffee",
  "optionalDependencies": {},
  "readme": "ERROR: No README data found!",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/dr-coffee-labs/hamlet.git"
  },
  "scripts": {
    "prepublish": "script/prepublish",
    "test": "script/test"
  },
  "version": "0.7.6"
}

},{}],11:[function(require,module,exports){
(function (global){
// Generated by CoffeeScript 1.8.0
(function() {
  var Observable, PROXY_LENGTH, computeDependencies, copy, extend, flatten, get, last, magicDependency, remove, splat, tryCallWithFinallyPop,
    __slice = [].slice;

  module.exports = Observable = function(value, context) {
    var changed, fn, listeners, notify, notifyReturning, self;
    if (typeof (value != null ? value.observe : void 0) === "function") {
      return value;
    }
    listeners = [];
    notify = function(newValue) {
      return copy(listeners).forEach(function(listener) {
        return listener(newValue);
      });
    };
    if (typeof value === 'function') {
      fn = value;
      self = function() {
        magicDependency(self);
        return value;
      };
      changed = function() {
        value = computeDependencies(self, fn, changed, context);
        return notify(value);
      };
      changed();
    } else {
      self = function(newValue) {
        if (arguments.length > 0) {
          if (value !== newValue) {
            value = newValue;
            notify(newValue);
          }
        } else {
          magicDependency(self);
        }
        return value;
      };
    }
    self.each = function(callback) {
      magicDependency(self);
      if (value != null) {
        [value].forEach(function(item) {
          return callback.call(item, item);
        });
      }
      return self;
    };
    if (Array.isArray(value)) {
      ["concat", "every", "filter", "forEach", "indexOf", "join", "lastIndexOf", "map", "reduce", "reduceRight", "slice", "some"].forEach(function(method) {
        return self[method] = function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          magicDependency(self);
          return value[method].apply(value, args);
        };
      });
      ["pop", "push", "reverse", "shift", "splice", "sort", "unshift"].forEach(function(method) {
        return self[method] = function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return notifyReturning(value[method].apply(value, args));
        };
      });
      if (PROXY_LENGTH) {
        Object.defineProperty(self, 'length', {
          get: function() {
            magicDependency(self);
            return value.length;
          },
          set: function(length) {
            value.length = length;
            return notifyReturning(value.length);
          }
        });
      }
      notifyReturning = function(returnValue) {
        notify(value);
        return returnValue;
      };
      extend(self, {
        each: function(callback) {
          self.forEach(function(item, index) {
            return callback.call(item, item, index, self);
          });
          return self;
        },
        remove: function(object) {
          var index;
          index = value.indexOf(object);
          if (index >= 0) {
            return notifyReturning(value.splice(index, 1)[0]);
          }
        },
        get: function(index) {
          magicDependency(self);
          return value[index];
        },
        first: function() {
          magicDependency(self);
          return value[0];
        },
        last: function() {
          magicDependency(self);
          return value[value.length - 1];
        },
        size: function() {
          magicDependency(self);
          return value.length;
        }
      });
    }
    extend(self, {
      listeners: listeners,
      observe: function(listener) {
        return listeners.push(listener);
      },
      stopObserving: function(fn) {
        return remove(listeners, fn);
      },
      toggle: function() {
        return self(!value);
      },
      increment: function(n) {
        return self(value + n);
      },
      decrement: function(n) {
        return self(value - n);
      },
      toString: function() {
        return "Observable(" + value + ")";
      }
    });
    return self;
  };

  Observable.concat = function() {
    var arg, args, collection, i, o, _i, _len;
    args = new Array(arguments.length);
    for (i = _i = 0, _len = arguments.length; _i < _len; i = ++_i) {
      arg = arguments[i];
      args[i] = arguments[i];
    }
    collection = Observable(args);
    o = Observable(function() {
      return flatten(collection.map(splat));
    });
    o.push = collection.push;
    return o;
  };

  extend = function(target) {
    var i, name, source, _i, _len;
    for (i = _i = 0, _len = arguments.length; _i < _len; i = ++_i) {
      source = arguments[i];
      if (i > 0) {
        for (name in source) {
          target[name] = source[name];
        }
      }
    }
    return target;
  };

  global.OBSERVABLE_ROOT_HACK = [];

  magicDependency = function(self) {
    var observerSet;
    observerSet = last(global.OBSERVABLE_ROOT_HACK);
    if (observerSet) {
      return observerSet.add(self);
    }
  };

  tryCallWithFinallyPop = function(fn, context) {
    try {
      return fn.call(context);
    } finally {
      global.OBSERVABLE_ROOT_HACK.pop();
    }
  };

  computeDependencies = function(self, fn, update, context) {
    var deps, value, _ref;
    deps = new Set;
    global.OBSERVABLE_ROOT_HACK.push(deps);
    value = tryCallWithFinallyPop(fn, context);
    if ((_ref = self._deps) != null) {
      _ref.forEach(function(observable) {
        return observable.stopObserving(update);
      });
    }
    self._deps = deps;
    deps.forEach(function(observable) {
      return observable.observe(update);
    });
    return value;
  };

  try {
    Object.defineProperty((function() {}), 'length', {
      get: function() {},
      set: function() {}
    });
    PROXY_LENGTH = true;
  } catch (_error) {
    PROXY_LENGTH = false;
  }

  remove = function(array, value) {
    var index;
    index = array.indexOf(value);
    if (index >= 0) {
      return array.splice(index, 1)[0];
    }
  };

  copy = function(array) {
    return array.concat([]);
  };

  get = function(arg) {
    if (typeof arg === "function") {
      return arg();
    } else {
      return arg;
    }
  };

  splat = function(item) {
    var result, results;
    results = [];
    if (item == null) {
      return results;
    }
    if (typeof item.forEach === "function") {
      item.forEach(function(i) {
        return results.push(i);
      });
    } else {
      result = get(item);
      if (result != null) {
        results.push(result);
      }
    }
    return results;
  };

  last = function(array) {
    return array[array.length - 1];
  };

  flatten = function(array) {
    return array.reduce(function(a, b) {
      return a.concat(b);
    }, []);
  };

}).call(this);

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{}],12:[function(require,module,exports){
module.exports = "[F]ile\n  [N]ew\n  [O]pen\n  [S]ave\n  Save [A]s\n  -\n  Page Set[u]p\n  [P]rint\n  -\n  E[x]it\n[E]dit\n  [U]ndo\n  Redo\n  -\n  Cu[t]\n  [C]opy\n  [P]aste\n  De[l]ete\n  -\n  [F]ind\n  Find [N]ext\n  [R]eplace\n  [G]o To\n  -\n  Select [A]ll\n  Time/[D]ate\nF[o]rmat\n  [W]ord Wrap\n  [F]ont...\n[V]iew\n  [S]tatus Bar\n[H]elp\n  View [H]elp\n  -\n  [A]bout Notepad";


},{}],13:[function(require,module,exports){
module.exports = function(data) {
  "use strict";
  return (function() {
    var __root;
    __root = require('hamlet.coffee')(this);
    __root.buffer(__root.element("form", this, {}, function(__root) {
      __root.buffer(__root.element("h1", this, {}, function(__root) {
        __root.buffer("Cool Form Bro\n");
      }));
      __root.buffer(__root.element("p", this, {}, function(__root) {
        __root.buffer(__root.element("a", this, {
          "href": "https://yolo.biz"
        }, function(__root) {
          __root.buffer("Yolo\n");
        }));
      }));
      __root.buffer(__root.element("input", this, {
        "name": "yolo"
      }, function(__root) {}));
      __root.buffer(__root.element("input", this, {
        "name": "x",
        "value": "Lorem"
      }, function(__root) {}));
      __root.buffer(__root.element("input", this, {
        "name": "y",
        "value": "florem"
      }, function(__root) {}));
      __root.buffer(__root.element("input", this, {
        "name": "z",
        "type": "number",
        "value": 5
      }, function(__root) {}));
      __root.buffer(__root.element("input", this, {
        "name": "file",
        "type": "file"
      }, function(__root) {}));
      __root.buffer(__root.element("textarea", this, {
        "name": "text"
      }, function(__root) {}));
      __root.buffer(__root.element("button", this, {}, function(__root) {
        __root.buffer("Submit\n");
      }));
    }));
    return __root.root;
  }).call(data);
};

},{"hamlet.coffee":9}],14:[function(require,module,exports){
var all, styles;

styles = {};

module.exports = styles;


},{}],15:[function(require,module,exports){
module.exports = function(data) {
  "use strict";
  return (function() {
    var __root;
    __root = require('hamlet.coffee')(this);
    __root.buffer(__root.element("input", this, {
      "value": this.value,
      "type": this.type
    }, function(__root) {}));
    return __root.root;
  }).call(data);
};

},{"hamlet.coffee":9}],16:[function(require,module,exports){
module.exports = function(data) {
  "use strict";
  return (function() {
    var __root;
    __root = require('hamlet.coffee')(this);
    __root.buffer(__root.element("menu-item", this, {
      "class": [this["class"]],
      "click": this.click,
      "mousemove": this.mousemove,
      "disabled": this.disabled
    }, function(__root) {
      __root.buffer(__root.element("label", this, {}, function(__root) {
        __root.buffer(this.title);
        __root.buffer(__root.element("span", this, {
          "class": ["hotkey"]
        }, function(__root) {
          __root.buffer(this.hotkey);
        }));
        __root.buffer(__root.element("span", this, {
          "class": ["decoration"]
        }, function(__root) {
          __root.buffer(this.decoration);
        }));
      }));
      __root.buffer(this.content);
    }));
    return __root.root;
  }).call(data);
};

},{"hamlet.coffee":9}],17:[function(require,module,exports){
module.exports = function(data) {
  "use strict";
  return (function() {
    var __root;
    __root = require('hamlet.coffee')(this);
    __root.buffer(__root.element("menu-item", this, {}, function(__root) {
      __root.buffer(__root.element("hr", this, {}, function(__root) {}));
    }));
    return __root.root;
  }).call(data);
};

},{"hamlet.coffee":9}],18:[function(require,module,exports){
module.exports = function(data) {
  "use strict";
  return (function() {
    var __root;
    __root = require('hamlet.coffee')(this);
    __root.buffer(__root.element("menu", this, {
      "class": [this["class"]],
      "click": this.click,
      "style": this.style
    }, function(__root) {
      __root.buffer(this.items);
    }));
    return __root.root;
  }).call(data);
};

},{"hamlet.coffee":9}],19:[function(require,module,exports){
module.exports = function(data) {
  "use strict";
  return (function() {
    var __root;
    __root = require('hamlet.coffee')(this);
    __root.buffer(__root.element("div", this, {
      id: ["modal"]
    }, function(__root) {}));
    return __root.root;
  }).call(data);
};

},{"hamlet.coffee":9}],20:[function(require,module,exports){
module.exports = function(data) {
  "use strict";
  return (function() {
    var __root;
    __root = require('hamlet.coffee')(this);
    __root.buffer(__root.element("form", this, {
      "submit": this.confirm,
      "tabindex": -1
    }, function(__root) {
      __root.buffer(__root.element("h1", this, {}, function(__root) {
        __root.buffer(this.title);
      }));
      __root.buffer(__root.element("p", this, {}, function(__root) {
        __root.buffer(this.message);
      }));
      if (this.defaultValue != null) {
        __root.buffer(__root.element("input", this, {
          "type": "text",
          "value": this.defaultValue
        }, function(__root) {}));
      }
      __root.buffer(__root.element("button", this, {}, function(__root) {
        __root.buffer("OK\n");
      }));
      if (this.cancel) {
        __root.buffer(__root.element("button", this, {
          "click": this.cancel
        }, function(__root) {
          __root.buffer("Cancel\n");
        }));
      }
    }));
    return __root.root;
  }).call(data);
};

},{"hamlet.coffee":9}],21:[function(require,module,exports){
module.exports = function(data) {
  "use strict";
  return (function() {
    var __root;
    __root = require('hamlet.coffee')(this);
    __root.buffer(__root.element("loader", this, {}, function(__root) {
      __root.buffer(__root.element("p", this, {}, function(__root) {
        __root.buffer(this.message);
      }));
      __root.buffer(__root.element("progress", this, {
        "class": [this["class"]],
        "value": this.value,
        "max": this.max
      }, function(__root) {}));
    }));
    return __root.root;
  }).call(data);
};

},{"hamlet.coffee":9}],22:[function(require,module,exports){
module.exports = function(data) {
  "use strict";
  return (function() {
    var __root;
    __root = require('hamlet.coffee')(this);
    __root.buffer(__root.element("container", this, {}, function(__root) {
      __root.buffer(__root.element("table", this, {
        "keydown": this.keydown
      }, function(__root) {
        __root.buffer(__root.element("thead", this, {}, function(__root) {
          __root.buffer(__root.element("tr", this, {}, function(__root) {
            this.headers.forEach(function(header) {
              return __root.buffer(__root.element("th", this, {}, function(__root) {
                __root.buffer(header);
              }));
            });
          }));
        }));
        __root.buffer(__root.element("tbody", this, {}, function(__root) {}));
      }));
    }));
    return __root.root;
  }).call(data);
};

},{"hamlet.coffee":9}],23:[function(require,module,exports){
module.exports = function(data) {
  "use strict";
  return (function() {
    var __root;
    __root = require('hamlet.coffee')(this);
    __root.buffer(__root.element("window", this, {}, function(__root) {
      __root.buffer(__root.element("resize", this, {
        "class": ["n", "h"]
      }, function(__root) {}));
      __root.buffer(__root.element("resize", this, {
        "class": ["e", "v"]
      }, function(__root) {}));
      __root.buffer(__root.element("resize", this, {
        "class": ["s", "h"]
      }, function(__root) {}));
      __root.buffer(__root.element("resize", this, {
        "class": ["w", "v"]
      }, function(__root) {}));
      __root.buffer(__root.element("resize", this, {
        "class": ["n", "e", "h"]
      }, function(__root) {}));
      __root.buffer(__root.element("resize", this, {
        "class": ["n", "e", "v"]
      }, function(__root) {}));
      __root.buffer(__root.element("resize", this, {
        "class": ["n", "w", "h"]
      }, function(__root) {}));
      __root.buffer(__root.element("resize", this, {
        "class": ["n", "w", "v"]
      }, function(__root) {}));
      __root.buffer(__root.element("resize", this, {
        "class": ["s", "e", "h"]
      }, function(__root) {}));
      __root.buffer(__root.element("resize", this, {
        "class": ["s", "e", "v"]
      }, function(__root) {}));
      __root.buffer(__root.element("resize", this, {
        "class": ["s", "w", "h"]
      }, function(__root) {}));
      __root.buffer(__root.element("resize", this, {
        "class": ["s", "w", "v"]
      }, function(__root) {}));
      __root.buffer(__root.element("header", this, {}, function(__root) {
        __root.buffer(__root.element("control", this, {}, function(__root) {
          __root.buffer("-\n");
        }));
        __root.buffer(__root.element("title-bar", this, {}, function(__root) {
          __root.buffer(this.title);
        }));
        __root.buffer(__root.element("close", this, {
          "click": this.close
        }, function(__root) {
          __root.buffer("X\n");
        }));
      }));
      __root.buffer(this.menuBar);
      __root.buffer(__root.element("viewport", this, {}, function(__root) {
        __root.buffer(this.content);
      }));
    }));
    return __root.root;
  }).call(data);
};

},{"hamlet.coffee":9}],24:[function(require,module,exports){
var A, F, Observable, S, accelerateItem, advance, asElement, elementView, empty, entityMap, formDataToObject, handle, isDescendant, o;

Observable = require("observable");

A = function(attr) {
  return function(x) {
    return x[attr];
  };
};

F = function(methodName) {
  return function(x) {
    return x[methodName]();
  };
};

o = function(object, name) {
  var attribute;
  attribute = Observable(object[name]);
  attribute.observe(function(newValue) {
    return object[name] = newValue;
  });
  return attribute;
};

handle = function(fn) {
  return function(e) {
    if (e != null ? e.defaultPrevented : void 0) {
      return;
    }
    if (e != null) {
      e.preventDefault();
    }
    return fn.call(this, e);
  };
};

S = function(object, method, defaultValue) {
  return function() {
    if (typeof (object != null ? object[method] : void 0) === 'function') {
      return object[method]();
    } else {
      return defaultValue;
    }
  };
};

asElement = A('element');

accelerateItem = function(items, key) {
  var acceleratedItem;
  acceleratedItem = items.filter(function(item) {
    return item.accelerator === key;
  })[0];
  if (acceleratedItem) {
    return acceleratedItem.click();
  }
};

isDescendant = function(element, ancestor) {
  var parent;
  if (!element) {
    return;
  }
  while ((parent = element.parentElement)) {
    if (element === ancestor) {
      return true;
    }
    element = parent;
  }
};

advance = function(list, amount) {
  var activeItemIndex, currentItem;
  currentItem = list.filter(function(item) {
    return item.active();
  })[0];
  activeItemIndex = list.indexOf(currentItem) + amount;
  if (activeItemIndex < 0) {
    activeItemIndex = list.length - 1;
  } else if (activeItemIndex >= list.length) {
    activeItemIndex = 0;
  }
  return list[activeItemIndex];
};

formDataToObject = function(formData) {
  return Array.from(formData.entries()).reduce(function(object, arg) {
    var key, value;
    key = arg[0], value = arg[1];
    object[key] = value;
    return object;
  }, {});
};

elementView = function(element) {
  if (!element) {
    return;
  }
  if (element.view) {
    return element.view;
  }
  return elementView(element.parentElement);
};

empty = function(node) {
  while (node.hasChildNodes()) {
    node.removeChild(node.lastChild);
  }
  return node;
};

module.exports = {
  htmlEscape: function(string) {
    return String(string).replace(/[&<>"'\/]/g, function(s) {
      return entityMap[s];
    });
  },
  A: A,
  F: F,
  S: S,
  o: o,
  advance: advance,
  asElement: asElement,
  accelerateItem: accelerateItem,
  elementView: elementView,
  empty: empty,
  formDataToObject: formDataToObject,
  handle: handle,
  isDescendant: isDescendant
};

entityMap = {
  "&": "&amp;",
  "<": "&lt;",
  ">": "&gt;",
  '"': '&quot;',
  "'": '&#39;',
  "/": '&#x2F;'
};


},{"observable":11}],25:[function(require,module,exports){

/*
ContextMenu

Display a context menu!

Questions:

Should we be able to update the options in the menu after creation?
 */
var MenuView, Observable, isDescendant;

Observable = require("observable");

MenuView = require("./menu");

isDescendant = require("../util").isDescendant;

module.exports = function(arg) {
  var activeItem, contextRoot, element, handlers, items, left, self, top;
  items = arg.items, handlers = arg.handlers;
  activeItem = Observable(null);
  top = Observable("");
  left = Observable("");
  contextRoot = {
    activeItem: activeItem,
    handlers: handlers
  };
  self = MenuView({
    items: items,
    contextRoot: contextRoot,
    classes: function() {
      return ["context", "options"];
    },
    style: function() {
      return "top: " + (top()) + "px; left: " + (left()) + "px";
    }
  });
  element = self.element;
  element.view = self;
  self.contextRoot = contextRoot;
  self.display = function(arg1) {
    var inElement, x, y;
    inElement = arg1.inElement, x = arg1.x, y = arg1.y;
    top(y);
    left(x);
    (inElement || document.body).appendChild(element);
    activeItem(self);
    return element.focus();
  };
  document.addEventListener("mousedown", function(e) {
    if (!isDescendant(e.target, element)) {
      return activeItem(null);
    }
  });
  element.setAttribute("tabindex", "-1");
  element.addEventListener("keydown", function(e) {
    var currentItem, direction, key;
    key = e.key;
    switch (key) {
      case "ArrowLeft":
      case "ArrowUp":
      case "ArrowRight":
      case "ArrowDown":
        e.preventDefault();
        direction = key.replace("Arrow", "");
        currentItem = activeItem();
        if (currentItem) {
          return currentItem.cursor(direction);
        }
        break;
      case "Escape":
        return activeItem(null);
    }
  });
  return self;
};


},{"../util":24,"./menu":29,"observable":11}],26:[function(require,module,exports){
var MenuView, Observable, advance, isDescendant, ref;

Observable = require("observable");

MenuView = require("./menu");

ref = require("../util"), isDescendant = ref.isDescendant, advance = ref.advance;

module.exports = function(arg) {
  var accelerateIfActive, acceleratorActive, activeItem, contextRoot, deactivate, element, handlers, items, previouslyFocusedElement, self;
  items = arg.items, handlers = arg.handlers;
  acceleratorActive = Observable(false);
  activeItem = Observable(null);
  previouslyFocusedElement = null;
  contextRoot = {
    activeItem: activeItem,
    handlers: handlers
  };
  self = MenuView({
    classes: function() {
      return ["bar", acceleratorActive() ? "accelerator-active" : void 0];
    },
    items: items,
    contextRoot: contextRoot
  });
  element = self.element;
  self.cursor = function(direction) {
    switch (direction) {
      case "Right":
        return self.advance(1);
      case "Left":
        return self.advance(-1);
    }
  };
  self.items.forEach(function(item) {
    item.horizontal = true;
    return item.cursor = function(direction) {
      var ref1, ref2;
      console.log("Item", direction);
      if (direction === "Down") {
        return (ref1 = item.submenu) != null ? ref1.advance(1) : void 0;
      } else if (direction === "Up") {
        return (ref2 = item.submenu) != null ? ref2.advance(-1) : void 0;
      } else {
        return item.parent.cursor(direction);
      }
    };
  });
  deactivate = function() {
    activeItem(null);
    acceleratorActive(false);
    return previouslyFocusedElement != null ? previouslyFocusedElement.focus() : void 0;
  };
  document.addEventListener("mousedown", function(e) {
    if (!isDescendant(e.target, element)) {
      acceleratorActive(false);
      return activeItem(null);
    }
  });
  document.addEventListener("keydown", function(e) {
    var key, menuIsActive, ref1;
    key = e.key;
    switch (key) {
      case "Enter":
        return (ref1 = activeItem()) != null ? ref1.click() : void 0;
      case "Alt":
        menuIsActive = false;
        if (acceleratorActive() || menuIsActive) {
          return deactivate();
        } else {
          previouslyFocusedElement = document.activeElement;
          element.focus();
          if (!activeItem()) {
            activeItem(self);
          }
          return acceleratorActive(true);
        }
    }
  });
  accelerateIfActive = function(key) {
    var ref1;
    if (acceleratorActive()) {
      return (ref1 = activeItem()) != null ? ref1.accelerate(key) : void 0;
    }
  };
  element.setAttribute("tabindex", "-1");
  element.addEventListener("keydown", function(e) {
    var accelerated, currentItem, direction, key;
    key = e.key;
    switch (key) {
      case "ArrowLeft":
      case "ArrowUp":
      case "ArrowRight":
      case "ArrowDown":
        e.preventDefault();
        direction = key.replace("Arrow", "");
        currentItem = activeItem();
        if (currentItem) {
          return currentItem.cursor(direction);
        }
        break;
      case "Escape":
        return deactivate();
      default:
        accelerated = accelerateIfActive(key.toLowerCase());
        if (accelerated != null) {
          return e.preventDefault();
        }
    }
  });
  return self;
};


},{"../util":24,"./menu":29,"observable":11}],27:[function(require,module,exports){
var F, MenuItemTemplate, S, accelerateItem, advance, asElement, formatAction, formatLabel, handle, htmlEscape, isDescendant, ref;

ref = require("../util"), advance = ref.advance, htmlEscape = ref.htmlEscape, asElement = ref.asElement, F = ref.F, S = ref.S, isDescendant = ref.isDescendant, accelerateItem = ref.accelerateItem, handle = ref.handle;

MenuItemTemplate = require("../templates/menu-item");

module.exports = function(arg) {
  var MenuView, accelerator, action, actionName, active, activeItem, click, content, contextRoot, disabled, element, handlers, hotkey, items, label, labelText, parent, ref1, ref2, self, submenu, title;
  label = arg.label, MenuView = arg.MenuView, items = arg.items, contextRoot = arg.contextRoot, parent = arg.parent;
  self = {};
  activeItem = contextRoot.activeItem, handlers = contextRoot.handlers;
  active = function() {
    var ref1;
    return isDescendant((ref1 = activeItem()) != null ? ref1.element : void 0, element);
  };
  self.active = active;
  if (items) {
    submenu = MenuView({
      items: items,
      contextRoot: contextRoot,
      parent: self
    });
    content = submenu.element;
  }
  ref1 = formatAction(label), labelText = ref1[0], actionName = ref1[1];
  ref2 = formatLabel(labelText), title = ref2[0], accelerator = ref2[1];
  action = handlers[actionName];
  disabled = S(action, "disabled", false);
  hotkey = S(action, "hotkey", "");
  click = function(e) {
    if (disabled()) {
      return;
    }
    if (e != null ? e.defaultPrevented : void 0) {
      return;
    }
    if (e != null) {
      e.preventDefault();
    }
    if (submenu) {
      activeItem(submenu);
      return;
    }
    console.log("Handling", actionName);
    if (action != null) {
      if (typeof action.call === "function") {
        action.call(handlers);
      }
    }
    return activeItem(null);
  };
  element = MenuItemTemplate({
    "class": function() {
      return [items ? "menu" : void 0, active() ? "active" : void 0];
    },
    click: click,
    mousemove: function(e) {
      if (!activeItem()) {
        return;
      }
      if (!e.defaultPrevented && isDescendant(e.target, element)) {
        e.preventDefault();
        return activeItem(self);
      }
    },
    title: title,
    content: content,
    decoration: items ? "▸" : void 0,
    hotkey: hotkey,
    disabled: disabled
  });
  Object.assign(self, {
    accelerator: accelerator,
    accelerate: function(key) {
      if (submenu) {
        return submenu.accelerate(key);
      } else {
        return parent.accelerate(key);
      }
    },
    click: click,
    parent: parent,
    element: element,
    submenu: submenu,
    cursor: function(direction) {
      console.log("Item Cursor", direction);
      if (submenu && direction === "Right") {
        return activeItem(submenu.navigableItems[0]);
      } else if (parent.parent && direction === "Left") {
        if (parent.parent.horizontal) {
          return parent.parent.cursor(direction);
        } else {
          return activeItem(parent.parent);
        }
      } else {
        return parent.cursor(direction);
      }
    }
  });
  return self;
};

formatAction = function(labelText) {
  var action, ref1, title;
  ref1 = labelText.split("->").map(F("trim")), title = ref1[0], action = ref1[1];
  if (action == null) {
    action = title.replace(/[^A-Za-z0-9]/g, "");
  }
  action = action.charAt(0).toLowerCase() + action.substring(1);
  return [title, action];
};

formatLabel = function(labelText) {
  var accelerator, span, titleHTML;
  accelerator = void 0;
  titleHTML = htmlEscape(labelText).replace(/\[([^\]]+)\]/, function(match, $1) {
    accelerator = $1.toLowerCase();
    return "<span class=\"accelerator\">" + $1 + "</span>";
  });
  span = document.createElement("span");
  span.innerHTML = titleHTML;
  return [span, accelerator];
};


},{"../templates/menu-item":16,"../util":24}],28:[function(require,module,exports){
var MenuSeparatorTemplate;

MenuSeparatorTemplate = require("../templates/menu-separator");

module.exports = function() {
  return {
    element: MenuSeparatorTemplate(),
    separator: true
  };
};


},{"../templates/menu-separator":17}],29:[function(require,module,exports){
var F, MenuItemTemplate, MenuItemView, MenuTemplate, MenuView, Observable, S, SeparatorView, accelerateItem, advance, asElement, assert, handle, htmlEscape, isDescendant, ref;

Observable = require("observable");

assert = require("../lib/assert");

ref = require("../util"), advance = ref.advance, accelerateItem = ref.accelerateItem, asElement = ref.asElement, F = ref.F, S = ref.S, htmlEscape = ref.htmlEscape, handle = ref.handle, isDescendant = ref.isDescendant;

MenuTemplate = require("../templates/menu");

MenuItemTemplate = require("../templates/menu-item");

SeparatorView = require("./menu-separator");

MenuItemView = require("./menu-item");

module.exports = MenuView = function(arg) {
  var active, activeItem, classes, contextRoot, items, navigableItems, parent, self, style;
  items = arg.items, classes = arg.classes, style = arg.style, contextRoot = arg.contextRoot, parent = arg.parent;
  self = {};
  if (classes == null) {
    classes = function() {
      return ["options"];
    };
  }
  activeItem = contextRoot.activeItem;
  items = items.map(function(item) {
    var label, submenuItems;
    switch (false) {
      case item !== "-":
        return SeparatorView();
      case !Array.isArray(item):
        assert(item.length === 2);
        label = item[0], submenuItems = item[1];
        return MenuItemView({
          label: label,
          items: submenuItems,
          MenuView: MenuView,
          contextRoot: contextRoot,
          parent: self
        });
      default:
        return MenuItemView({
          label: item,
          contextRoot: contextRoot,
          parent: self
        });
    }
  });
  navigableItems = items.filter(function(item) {
    return !item.separator;
  });
  active = function() {
    var ref1;
    return isDescendant((ref1 = activeItem()) != null ? ref1.element : void 0, self.element);
  };
  Object.assign(self, {
    accelerate: function(key) {
      return accelerateItem(items, key);
    },
    cursor: function(direction) {
      var ref1;
      switch (direction) {
        case "Up":
          return self.advance(-1);
        case "Down":
          return self.advance(1);
        default:
          return (ref1 = parent.parent) != null ? ref1.cursor(direction) : void 0;
      }
    },
    parent: parent,
    items: items,
    advance: function(n) {
      return activeItem(advance(navigableItems, n));
    },
    navigableItems: navigableItems,
    element: MenuTemplate({
      style: style,
      "class": function() {
        return [active() ? "active" : void 0].concat(classes());
      },
      click: handle(function(e) {
        return activeItem(self);
      }),
      items: items.map(asElement)
    })
  });
  return self;
};


},{"../lib/assert":4,"../templates/menu":18,"../templates/menu-item":16,"../util":24,"./menu-item":27,"./menu-separator":28,"observable":11}],30:[function(require,module,exports){
var Observable, Template;

Template = require("../templates/progress");

Observable = require("observable");

module.exports = function(params) {
  var element, max, message, value;
  if (params == null) {
    params = {};
  }
  value = params.value, max = params.max, message = params.message;
  value = Observable(value || 0);
  max = Observable(max);
  message = Observable(message);
  element = Template({
    value: value,
    max: max,
    message: message
  });
  return {
    element: element,
    value: value,
    message: message,
    max: max
  };
};


},{"../templates/progress":21,"observable":11}],31:[function(require,module,exports){
var TableTemplate, TableView, advanceRow, empty;

empty = require("../util").empty;

TableTemplate = require("../templates/table");

advanceRow = function(path, prev) {
  var cellIndex, input, nextRowElement, td, tr;
  td = path.filter(function(element) {
    return element.tagName === "TD";
  })[0];
  if (!td) {
    return;
  }
  tr = td.parentElement;
  cellIndex = Array.prototype.indexOf.call(tr.children, td);
  if (prev) {
    nextRowElement = tr.previousSibling;
  } else {
    nextRowElement = tr.nextSibling;
  }
  if (nextRowElement) {
    input = nextRowElement.children[cellIndex].querySelector('input');
    return input != null ? input.focus() : void 0;
  }
};

TableView = function(arg) {
  var RowElement, containerElement, data, filterAndSort, filterFn, headers, rowElements, tableBody, update;
  data = arg.data, headers = arg.headers, RowElement = arg.RowElement;
  if (headers == null) {
    headers = Object.keys(data[0]);
  }
  containerElement = TableTemplate({
    headers: headers,
    keydown: function(event) {
      var key, path;
      key = event.key, path = event.path;
      switch (key) {
        case "Enter":
        case "ArrowDown":
          event.preventDefault();
          return advanceRow(path);
        case "ArrowUp":
          event.preventDefault();
          return advanceRow(path, true);
      }
    }
  });
  tableBody = containerElement.querySelector('tbody');
  filterFn = function(datum) {
    return true;
  };
  filterAndSort = function(data, filterFn, sortFn) {
    var filteredData;
    if (filterFn == null) {
      filterFn = function() {
        return true;
      };
    }
    filteredData = data.filter(filterFn);
    if (sortFn) {
      return filteredData.sort(sortFn);
    } else {
      return filteredData;
    }
  };
  rowElements = function() {
    return filterAndSort(data, filterFn, null).map(RowElement);
  };
  update = function() {
    empty(tableBody);
    return rowElements().forEach(function(element) {
      return tableBody.appendChild(element);
    });
  };
  update();
  return {
    element: containerElement,
    render: update
  };
};

module.exports = TableView;


},{"../templates/table":22,"../util":24}],32:[function(require,module,exports){
var Bindable, Observable, WindowTemplate, activeDrag, activeResize, dragStart, elementView, frameGuard, raiseToTop, resizeInitial, resizeStart, styleBind, topIndex;

WindowTemplate = require("../templates/window");

elementView = require("../util").elementView;

frameGuard = document.createElement("frame-guard");

document.body.appendChild(frameGuard);

topIndex = 0;

raiseToTop = function(view) {
  var zIndex;
  if (typeof view.zIndex !== 'function') {
    return;
  }
  zIndex = view.zIndex();
  if (zIndex === topIndex) {
    return;
  }
  topIndex += 1;
  return view.zIndex(topIndex);
};

activeDrag = null;

dragStart = null;

document.addEventListener("mousedown", function(e) {
  var target, view;
  target = e.target;
  view = elementView(target);
  if (view) {
    raiseToTop(view);
  }
  if (target.tagName === "TITLE-BAR") {
    frameGuard.classList.add("active");
    dragStart = e;
    return activeDrag = view;
  }
});

document.addEventListener("mousemove", function(e) {
  var dx, dy, prevX, prevY, x, y;
  if (activeDrag) {
    prevX = dragStart.clientX, prevY = dragStart.clientY;
    x = e.clientX, y = e.clientY;
    dx = x - prevX;
    dy = y - prevY;
    activeDrag.x(activeDrag.x() + dx);
    activeDrag.y(activeDrag.y() + dy);
    return dragStart = e;
  }
});

activeResize = null;

resizeStart = null;

resizeInitial = null;

document.addEventListener("mousedown", function(e) {
  var height, ref, target, width, x, y;
  target = e.target;
  if (target.tagName === "RESIZE") {
    frameGuard.classList.add("active");
    resizeStart = e;
    activeResize = target;
    ref = elementView(activeResize), width = ref.width, height = ref.height, x = ref.x, y = ref.y;
    return resizeInitial = {
      width: width(),
      height: height(),
      x: x(),
      y: y()
    };
  }
});

document.addEventListener("mousemove", function(e) {
  var actualDeltaX, actualDeltaY, dx, dy, height, startX, startY, view, width, x, y;
  if (activeResize) {
    startX = resizeStart.clientX, startY = resizeStart.clientY;
    x = e.clientX, y = e.clientY;
    dx = x - startX;
    dy = y - startY;
    width = resizeInitial.width;
    height = resizeInitial.height;
    if (activeResize.classList.contains("e")) {
      width += dx;
    }
    if (activeResize.classList.contains("w")) {
      width -= dx;
    }
    if (activeResize.classList.contains("s")) {
      height += dy;
    }
    if (activeResize.classList.contains("n")) {
      height -= dy;
    }
    width = Math.max(width, 200);
    height = Math.max(height, 50);
    actualDeltaX = width - resizeInitial.width;
    actualDeltaY = height - resizeInitial.height;
    view = elementView(activeResize);
    if (activeResize.classList.contains("n")) {
      view.y(resizeInitial.y - actualDeltaY);
    }
    if (activeResize.classList.contains("w")) {
      view.x(resizeInitial.x - actualDeltaX);
    }
    view.width(width);
    view.height(height);
    return view.trigger("resize");
  }
});

document.addEventListener("mouseup", function() {
  activeDrag = null;
  activeResize = null;
  return frameGuard.classList.remove("active");
});

Bindable = require("bindable");

Observable = require("observable");

module.exports = function(params) {
  var element, height, ref, ref1, ref2, ref3, ref4, ref5, self, title, width, x, y, zIndex;
  self = Bindable();
  x = Observable((ref = params.x) != null ? ref : 50);
  y = Observable((ref1 = params.y) != null ? ref1 : 50);
  width = Observable((ref2 = params.width) != null ? ref2 : 400);
  height = Observable((ref3 = params.height) != null ? ref3 : 300);
  title = Observable((ref4 = params.title) != null ? ref4 : "Untitled");
  topIndex += 1;
  zIndex = Observable((ref5 = params.zIndex) != null ? ref5 : topIndex);
  element = WindowTemplate({
    title: title,
    menuBar: params.menuBar,
    content: params.content,
    close: function() {
      return self.close();
    }
  });
  styleBind(y, element, "top", "px");
  styleBind(x, element, "left", "px");
  styleBind(height, element, "height", "px");
  styleBind(width, element, "width", "px");
  styleBind(zIndex, element, "zIndex");
  Object.assign(self, {
    element: element,
    title: title,
    x: x,
    y: y,
    width: width,
    height: height,
    zIndex: zIndex,
    close: function() {
      return element.remove();
    }
  });
  element.view = self;
  return self;
};

styleBind = function(observable, element, attr, suffix) {
  var update;
  if (suffix == null) {
    suffix = "";
  }
  update = function(newValue) {
    newValue = parseInt(newValue);
    if (newValue != null) {
      return element.style[attr] = "" + newValue + suffix;
    }
  };
  observable.observe(update);
  return update(observable());
};


},{"../templates/window":23,"../util":24,"bindable":8,"observable":11}]},{},[6])(6)
});
