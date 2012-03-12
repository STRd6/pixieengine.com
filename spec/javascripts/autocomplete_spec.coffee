Pixie ||= {}

require '/assets/javascripts/models/autocomplete.js'

describe "Autocomplete model", ->
  beforeEach ->
    @autocomplete = new Pixie.Models.Autocompleter

  it "should initialize filteredSuggestions to match suggestions", ->
    {filteredSuggestions, suggestions} = @autocomplete.attributes

    expect(filteredSuggestions).toEqual(suggestions)

  it "should filter the suggestions list based on currentToken input", ->
    @autocomplete.set
      suggestsions: [
        "TAU",
        "timer"
        "times"
        "toColorPart"
        "toString"
      ]

    currentToken = "to"

    @autocomplete.filterSuggestions(currentToken)

    expect(@autocomplete.get('filteredSuggetions')).toEqual([
      "toColorPart"
      "toString"
    ])

