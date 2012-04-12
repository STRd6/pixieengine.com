#= require underscore
#= require backbone

#= require templates/color_slider

class TestModel extends Backbone.Model
  defaults:
    red: 128
    green: 128
    blue: 255

  initialize: ->
    console.log this

window.testModel = new TestModel()

class TestView extends Backbone.View
  initialize: ->
    @el.html $.tmpl("tmpls/color_slider", [{
      name: "red"
    }, {
      name: "green"
    }, {
      name: "blue"
    }])

    @model.bind("change", @render, @)

    @render()

  render: ->
    for name, value of @model.attributes
      @el.find("[name=#{name}]").val(value)

    return @

  events:
    "change": "changed"

  changed: (event) =>
    target = $(event.target)

    data = {}

    data[target.attr('name')] = target.attr('value')

    @model.set data

    console.log @model

    return @

new TestView
  el: $("#testie")
  model: testModel

class TestModelView extends Backbone.View
  tagName: "li"

  render: ->
    $(@el).html($.tmpl("tmpls/test_item", @model.toJSON()))

    return @

  remove: ->
    $(@el).remove()

updateBg = ->
  {red, green, blue} = testModel.attributes

  $("body").css
    backgroundColor: "rgb(#{[red, green, blue].join(',')})"
    backgroundImage: "none"

testModel.bind 'change', updateBg

updateBg()
