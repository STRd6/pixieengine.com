window.Easing =
  sinusoidal: (begin, end) ->
    change = end - begin
    (t) -> begin + change * (1 - Math.cos(t * Math.TAU / 4))

  sinusoidalOut: (begin, end) ->
    change = end - begin
    (t) -> begin + change * (0 + Math.sin(t * Math.TAU / 4))

polynomialEasings = ["linear", "quadratic", "cubic", "quartic", "quintic"]

polynomialEasings.each (easing, i) ->
  exponent = i + 1
  sign = if exponent % 2 then 1 else -1

  Easing[easing] = (begin, end) ->
    change = (end - begin)
    (t) -> begin + change * Math.pow(t, exponent)

  Easing["#{easing}Out"] = (begin, end) ->
    change = end - begin
    (t) -> begin + change * (1 + sign * Math.pow(t - 1, exponent))

["sinusoidal"].concat(polynomialEasings).each (easing) ->
  Easing["#{easing}InOut"] = (begin, end) ->
    midpoint = (begin + end)/2
    easeIn = Easing[easing](begin, midpoint)
    easeOut = Easing["#{easing}Out"](midpoint, end)

    (t) ->
      if t < 0.5
        easeIn(2 * t)
      else
        easeOut(2 * t - 1)
