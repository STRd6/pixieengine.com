require '/assets/jquery/jquery.min.js'
require '/assets/sinon.js'

# fixtures
beforeEach ->
  @fixtures =
    PaginatedCollection:
      valid:
        status: "OK"
        version: "1.0"
        response:
          owner_id: 1
          current_user_id: 4
          page: 1
          per_page: 5
          total: 20
          models: [
            { id: 1, title: "Quest for Meaning" },
            { id: 2, title: "Pixteroids" }
          ]

# server response helper
beforeEach ->
  @validResponse = (responseText) ->
    return [
      200,
      {"Content-Type": "application/json"},
      JSON.stringify(responseText)
    ]

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
