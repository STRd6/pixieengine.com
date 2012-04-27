#= require coffee-script.js

describe "Autocomplete model", ->
  beforeEach ->
    @autocomplete = new Pixie.Models.Autocomplete
      suggestions: {
        I: ['color', 'height', 'width']
        self: ['attack', 'collides', 'die', 'hit', 'wait', 'win']
      }

  it 'should set filtered suggestions with a context of I', ->
    @autocomplete.setFilterType('I.', '')

    expect(@autocomplete.get('filteredSuggestions').length).toEqual(3)

  it 'should set filtered suggestions correctly for instance properties', ->
    @autocomplete.setFilterType('I.', 'co')

    expect(@autocomplete.get('filteredSuggestions').length).toEqual(1)
    expect(@autocomplete.get('filteredSuggestions')[0]).toEqual('color')

  it 'should set filtered suggestions with only a context of self', ->
    @autocomplete.setFilterType('self.', '')

    expect(@autocomplete.get('filteredSuggestions').length).toEqual(6)

  it 'should set filtered suggestions for methods of self', ->
    @autocomplete.setFilterType('self.', 'w')

    expect(@autocomplete.get('filteredSuggestions').length).toEqual(2)
    expect(@autocomplete.get('filteredSuggestions')[0]).toEqual('wait')
    expect(@autocomplete.get('filteredSuggestions')[1]).toEqual('win')

