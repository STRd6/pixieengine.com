# TODO these are broken because jhw can't seem to find coffee-script when required
# describe "Autocomplete model", ->
#   beforeEach ->
#     @autocomplete = new Pixie.Models.Autocomplete

#   it 'should set up some default suggestions', ->
#     expect(@autocomplete.get('suggestions').self.length).toBeTruthy()
#     expect(@autocomplete.get('suggestions').I.length).toBeTruthy()

#   it 'should have a list of suggestions within the context of instance variables', ->
#     expect(@autocomplete.suggestions('I').length).toBeTruthy()

#     expect(_.include(@autocomplete.suggestions('I'), 'width')).toBeTruthy()
#     expect(_.include(@autocomplete.suggestions('I'), 'height')).toBeTruthy()
#     expect(_.include(@autocomplete.suggestions('I'), 'color')).toBeTruthy()

#   it 'should have a list of suggestions within the context of methods on self', ->
#     expect(@autocomplete.suggestions('self').length).toBeTruthy()

#     expect(_.include(@autocomplete.suggestions('self'), 'bind')).toBeTruthy()
#     expect(_.include(@autocomplete.suggestions('self'), 'bounds')).toBeTruthy()
