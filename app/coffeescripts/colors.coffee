Color = (I) ->
  I ||= {}

  if I.hex
    rHex = parseInt(I.hex.substr(1, 2), 16)
    gHex = parseInt(I.hex.substr(3, 2), 16)
    bHex = parseInt(I.hex.substr(5, 2), 16)
  else
    rHex = gHex = bHex = undefined

  if I.array
    rArr = I.array[0]
    gArr = I.array[1]
    bArr = I.array[2]
    aArr = I.array[3]
  else
    rArr = gArr = bArr = aArr = 0

  $.reverseMerge I,
    r: rHex || rArr || 0
    g: gHex || gArr || 0
    b: bHex || bArr || 0
    a: aArr || 0

  channels: [
    typeof I.r == str && parseHex(I.r) || I.r
    typeof I.g == str && parseHex(I.g) || I.g
    typeof I.b == str && parseHex(I.b) || I.b
    (typeof I.a != str && typeof I.a != "number") && 1 || typeof I.a == str && parseFloat(I.a) || I.a
  ]

  getValue = ->
    (channels[0] * 0x10000) | (channels[1] * 0x100) | channels[2]

  self =
    channels: channels

    equals: (other) ->
      return other.r == I.r && other.g == I.g && other.b == I.b && other.a = I.a

    hexTriplet: ->
      return "#" + ("00000" + getValue().toString(16)).substr(-6)

    mix: (otherColor, amount) ->
      percent = if amount then amount.round / 100.0 else 0.5

      newColors = channels.zip(color2.channels).map (element) ->
        return (element[0] * percent) + (element[1] * (1 - percent))

      return Color(
        array: newColors
      )

    rgba: ->
      return "rgba(#{I.channels.join(',')})"

    toString: ->
      return (if channels[3] == 1 then self.hexTriplet() else self.rgba())

  return self