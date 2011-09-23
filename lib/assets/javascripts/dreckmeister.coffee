#= require underscore
#= require backbone

#= require tmpls/test

class TestModel extends Backbone.Model
  initialize: ->
    console.log this

new TestModel()

class TestView extends Backbone.View
  initialize: ->
    @render()

  render: ->
    @el.html $.tmpl("test")

  events:
    "click button": "iceIt"

  iceIt: (event) =>
    alert(@el.find("input").val())

new TestView
  el: $("#testie")
