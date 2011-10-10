window.ColorUtil =
  # http://stackoverflow.com/questions/726549/algorithm-for-additive-color-mixing-for-rgb-values/727339#727339
  additive: (c1, c2) ->
    [R, G, B, A] = c1.channels()
    [r, g, b, a] = c2.channels()

    return c1 if a == 0
    return c2 if A == 0

    ax = 1 - (1 - a) * (1 - A)
    rx = (r * a / ax + R * A * (1 - a) / ax).round().clamp(0, 255)
    gx = (g * a / ax + G * A * (1 - a) / ax).round().clamp(0, 255)
    bx = (b * a / ax + B * A * (1 - a) / ax).round().clamp(0, 255)

    return Color(rx, gx, bx, ax)

  replace: (c1, c2) ->
    c2
