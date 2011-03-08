Color = (color) ->
  if typeof color == "string"
    if color[0] = '#'
      parseHex(color)
    else if color.substr(0, 4) == 'rgb('
      parseRGB(color)
    else if color.substr(0, 4) == 'rgba'
      parseRGBA(color)
  if typeof color == "array"
    Color(color[0], color[1], color[2], if color[3] then color[3] else 1)

  channels: [
    typeof I.r == 'string' && parseHex(I.r) || I.r
    typeof I.g == 'string' && parseHex(I.g) || I.g
    typeof I.b == 'string' && parseHex(I.b) || I.b
    (typeof I.a != 'string' && typeof I.a != 'number') && 1 || typeof I.a == 'string' && parseFloat(I.a) || I.a
  ]

  getValue = ->
    (channels[0] * 0x10000) | (channels[1] * 0x100) | channels[2]

  self =
    channels: channels

    equals: (other) ->
      return other.r == I.r && other.g == I.g && other.b == I.b && other.a = I.a

    hexTriplet: ->
      return "#" + ("00000" + getValue().toString(16)).substr(-6)

    rgba: ->
      return "rgba(#{I.channels.join(',')})"

    toString: ->
      return (if channels[3] == 1 then self.hexTriplet() else self.rgba())

  return self