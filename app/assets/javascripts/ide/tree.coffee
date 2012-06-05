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
    renameFile(file, file.get('path'))

tree.bind 'rename', (file, newName) ->
  {docSelector, path} = file.attributes
  name = file.name()

  openedTab = $('#tabs ul li a[href="' + docSelector + '"]').parent()

  # Abort if unsaved
  if openedTab.is(".unsaved")
    notify "Save #{name} before renaming"
    return
  else
    openedTab.find(".ui-icon-close").click()

  # this works because we are secretly inside a change event
  oldPath = file.previous('path')

  postData =
    path: oldPath
    new_path: path
    format: 'json'
    message: $(".actions .status .message").val()

  $.post "/projects/#{projectId}/rename_file", postData, -> # Assuming success
  notify "Renamed #{oldPath} => #{path}"

  # Close and reopen file if open
  if openedTab.length
    openFile(file)

tree.bind 'remove', (file) ->
  {docSelector, path} = file.attributes
  name = file.name()
  notify "Removing #{name}..."

  # Close the tab if open
  $('#tabs ul li a[href="' + docSelector + '"]').parent().find(".ui-icon-close").click()

  message = $(".actions .status .message").val()

  postData =
    path: path
    format: 'json'
    message: message

  successCallback = (data) ->
    notify "#{name} removed!"

  $.post "/projects/#{projectId}/remove_file", postData, successCallback

$('.sidebar').append(tree.render().$el)
