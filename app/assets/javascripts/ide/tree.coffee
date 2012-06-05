#= require bone_tree

window.tree = new BoneTree.Views.Tree

fileTreeData = JSON.parse($('#code_content').val())

fileTreeData.each (file) ->
  tree.add file.path, file

# Use special docs link
tree.remove "docs"
tree.add "Documentation.documentation",
  type: "documentation"
  path: "docs"

tree.bind 'openFile', (e, file) ->
  if e.which is 1
    openFile(file)
  else if e.which is 3
    menu = new Boner.Views.Menu
      items:
        rename: ->
          renameFile(file, file.get('path'))
        delete: ->
          deleteFile(file)
      event: e

    $('body').append(menu.render().el)

$('.sidebar').append(tree.render().$el)

# ideally we should only prevent the
# context menu on the particular element
$(document).on 'contextmenu', (e) ->
  false
