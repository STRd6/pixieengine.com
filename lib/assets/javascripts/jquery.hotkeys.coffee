###*
jQuery Hotkeys Plugin
Copyright 2010, John Resig
Dual licensed under the MIT or GPL Version 2 licenses.

Based upon the plugin by Tzury Bar Yochay:
http://github.com/tzuryby/hotkeys

Original idea by:
Binny V A, http://www.openjs.com/scripts/events/keyboard_shortcuts/
###

((jQuery) ->
  isTextAcceptingInput = (element) ->
    /textarea|select/i.test(element.nodeName) || element.type == "text" || element.type == "password"

  isFunctionKey = (event) ->
    (event.type != "keypress") && (112 <= event.which <= 123)

  jQuery.hotkeys =
    version: "0.8"

    specialKeys:
      8: "backspace"
      9: "tab"
      13: "return"
      16: "shift"
      17: "ctrl"
      18: "alt"
      19: "pause"
      20: "capslock"
      27: "esc"
      32: "space"
      33: "pageup"
      34: "pagedown"
      35: "end"
      36: "home"
      37: "left"
      38: "up"
      39: "right"
      40: "down"
      45: "insert"
      46: "del"
      96: "0"
      97: "1"
      98: "2"
      99: "3"
      100: "4"
      101: "5"
      102: "6"
      103: "7"
      104: "8"
      105: "9"
      106: "*"
      107: "+"
      109: "-"
      110: "."
      111 : "/"
      112: "f1"
      113: "f2"
      114: "f3"
      115: "f4"
      116: "f5"
      117: "f6"
      118: "f7"
      119: "f8"
      120: "f9"
      121: "f10"
      122: "f11"
      123: "f12"
      144: "numlock"
      145: "scroll"
      186: ";"
      187: "="
      188: ","
      189: "-"
      190: "."
      191: "/"
      219: "["
      220: "\\"
      221: "]"
      222: "'"
      224: "meta"

    shiftNums:
      "`": "~"
      "1": "!"
      "2": "@"
      "3": "#"
      "4": "$"
      "5": "%"
      "6": "^"
      "7": "&"
      "8": "*"
      "9": "("
      "0": ")"
      "-": "_"
      "=": "+"
      ";": ":"
      "'": "\""
      ",": "<"
      ".": ">"
      "/": "?"
      "\\": "|"

  keyHandler = (handleObj) ->
    # Only care when a possible input has been specified
    if typeof handleObj.data != "string"
      return

    origHandler = handleObj.handler
    keys = handleObj.data.toLowerCase().split(" ")

    handleObj.handler = (event) ->
      # Keypress represents characters, not special keys
      special = event.type != "keypress" && jQuery.hotkeys.specialKeys[ event.which ]
      character = String.fromCharCode( event.which ).toLowerCase()
      modif = ""
      possible = {}
      target = event.target

      # check combinations (alt|ctrl|shift+anything)
      if event.altKey && special != "alt"
        modif += "alt+"

      if event.ctrlKey && special != "ctrl"
        modif += "ctrl+"

      # TODO: Need to make sure this works consistently across platforms
      if event.metaKey && !event.ctrlKey && special != "meta"
        modif += "meta+"

      # Don't fire in text-accepting inputs that we didn't directly bind to
      # unless a non-shift modifier key or function key is pressed
      unless this == target
        if isTextAcceptingInput(target) && !modif && !isFunctionKey(event)
          return

      if event.shiftKey && special != "shift"
        modif += "shift+"

      if special
        possible[ modif + special ] = true
      else
        possible[ modif + character ] = true
        possible[ modif + jQuery.hotkeys.shiftNums[ character ] ] = true

        # "$" can be triggered as "Shift+4" or "Shift+$" or just "$"
        if modif == "shift+"
          possible[ jQuery.hotkeys.shiftNums[ character ] ] = true

      for key in keys
        if possible[key]
          return origHandler.apply( this, arguments )


  jQuery.each [ "keydown", "keyup", "keypress" ], ->
    jQuery.event.special[ this ] = { add: keyHandler }

)(jQuery)
