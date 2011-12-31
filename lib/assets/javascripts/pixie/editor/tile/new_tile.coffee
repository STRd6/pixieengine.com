#= require underscore
#= require backbone

#= require_tree ./models
#= require_tree ./views

{Models, Views} = Pixie.Editor.Tile

editor = new Views.Editor

$("#testie").append(editor.el)
