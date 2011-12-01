# sinon matchers
((global) ->
  spyMatchers = [
    "called"
    "calledOnce"
    "calledTwice"
    "calledThrice"
    "calledBefore"
    "calledAfter"
    "calledOn"
    "alwaysCalledOn"
    "calledWith"
    "alwaysCalledWith"
    "calledWithExactly"
    "alwaysCalledWithExactly"
  ]

  i = spyMatchers.length

  spyMatcherHash = {}

  unusualMatchers =
    returned: "toHaveReturned"
    alwaysReturned: "toHaveAlwaysReturned"

  getMatcherFunction = (sinonName) ->
    ->
      sinonProperty = @actual[sinonName]
      (if (typeof sinonProperty is "function") then sinonProperty.apply(@actual, arguments) else sinonProperty)

  while i--
    sinonName = spyMatchers[i]
    matcherName = "toHaveBeen" + sinonName.charAt(0).toUpperCase() + sinonName.slice(1)
    spyMatcherHash[matcherName] = getMatcherFunction(sinonName)

  for j of unusualMatchers
    spyMatcherHash[unusualMatchers[j]] = getMatcherFunction(j)

  global.sinonJasmine = getMatchers: ->
    spyMatcherHash
)(window)

beforeEach ->
  @addMatchers sinonJasmine.getMatchers()
