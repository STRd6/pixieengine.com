describe "Autocomplete model", ->
  beforeEach ->
    @autocomplete = new Pixie.Models.Autocomplete

  it "should generate suggestions based on the object's code", ->
    @autocomplete = new Pixie.Models.Autocomplete
      text: """
        Player = (I={}) ->
          Object.reverseMerge I,
            x: 50
            y: 36

          self = GameObject(I)

          return self
      """

    expect(@autocomplete.get('suggestions').self.length).toExist()
    expect(@autocomplete.get('suggestions').I.length).toExist()

