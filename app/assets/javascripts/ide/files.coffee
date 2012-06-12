window.renameFile = (file, oldPath) ->
  docSelector = file.get('docSelector')
  name = file.name()

  openedTab = $('#tabs ul li a[href="' + docSelector + '"]').parent()

  # Abort if unsaved
  if openedTab.is(".unsaved")
    notify "Save #{name} before renaming"
    return
  else
    openedTab.find(".ui-icon-close").click()

  newName = prompt "Rename #{name} to:", name

  return unless newName

  file.set
    path: oldPath.replace(file.name(), newName)

  # not the nicest way to reorder the tree
  tree.root.directories().each (dir) ->
    dir.collection.sort()

  tree.render()

  path = file.get('path')

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

window.deleteFile = (file) ->
  {docSelector, path} = file.attributes
  name = file.name()
  notify "Removing #{name}..."

  # Close the tab if open
  $('#tabs ul li a[href="' + docSelector + '"]').parent().find(".ui-icon-close").click()

  message = $(".actions .status .message").val()

  tree.remove(path)

  postData =
    path: path
    format: 'json'
    message: message

  successCallback = (data) ->
    notify "#{name} removed!"

  $.post "/projects/#{projectId}/remove_file", postData, successCallback

window.closeFile = (file) ->
  {path} = file.attributes

  selector = path.replace(/[^A-Za-z0-9_-]/g, "_")

  docSelector = file.attributes.docSelector = "#file_#{selector}"

  # focus the tab if it already exists
  if (tab = $('#tabs ul li a[href="' + docSelector + '"]')).length
    tab.parent().find('.ui-icon-close').click()

window.openFile = (file) ->
  trackEvent("IDE", "open file", file)

  {path, size} = file.attributes
  name = file.name()
  extension = name.extension()
  selector = path.replace(/[^A-Za-z0-9_-]/g, "_")

  # TODO: Have docSelector be a generated attribute or method on files
  # In the meantime reset it every time we open to keep it correct.
  # TOOD: Dump jQueryUI Tabs and get rid of doc selector entirely
  docSelector = file.attributes.docSelector = "#file_#{selector}"

  # Set types based on extension and names, etc.
  switch extension
    when "tilemap", "entity", "json"
      file.set type: extension
    when "png"
      file.set type: "image"

  if name is "README"
    file.set type: "text"

  #TODO load contents from remote data as needed

  if ['wav', 'mp3', 'ogg'].include(extension)
    $('.preview source').remove()
    source = "<source src='/production/projects/#{projectId}/#{path}' type='audio/#{extension}'></source>"
    $('.preview').append(source).get(0).play()

    return

  if name is 'game.js'
    $('#run').click()

    return

  return alert "This file is too large for our editor!" if size > MAX_FILE_SIZE

  # focus the tab if it already exists
  if (tab = $('#tabs ul li a[href="' + docSelector + '"]')).length
    tab.click()
  else
    fileName = name.withoutExtension()

    window.currentFile = file

    $("#tabs").tabs 'add', docSelector, fileName, 0

    # Focus Newly Created Tab
    $('#tabs ul li a[href="' + docSelector + '"]').click()


window.newFileNode = (inputData) ->
  {forceSave, autoOpen, path, template} = inputData
  name = path.split('/').last()

  if template
    inputData.className = name.withoutExtension().capitalize().camelize()
    inputData.contents ||= $("#file_templates .#{template}").tmpl(inputData).text()

  # TODO remove global file tree reference. Pass it to the function instead
  file = tree.add inputData.path, inputData

  if autoOpen
    openFile file

  # TODO Get a JS test for this
  if forceSave
    window.saveFile
      contents: inputData.contents
      path: inputData.path

  return file

normalizeFileName = (name) ->
  return name.toLowerCase().replace(/\s/g, '').replace(/[^A-Za-z0-9\s]/g, '')

removeWarnings = (element) ->
  element.tipsy 'hide'
  element.css
    border: '1px solid rgb(170, 170, 170)'

# on keyup check to see if a file with the same name exists
$('#new_file_modal input[name="name"]').keyup (e) ->
  target = $(e.currentTarget)
  value = target.val()

  directory = $('#new_file_modal button.active').data('params')['directory']

  aliasedDirectory = projectConfig.directories[directory]

  directory = tree.getDirectory(aliasedDirectory)

  removeWarnings target
  $('#new_file_modal .create').removeAttr 'disabled'

  if directory
    matchingFiles = directory.collection.select (file) ->
      # make sure the file names are really different, they
      # shouldn't be considered different if they only differ
      # in capitalization, non alphanumeric characters, or whitespace
      return normalizeFileName(file.name()) is normalizeFileName(value)
    if matchingFiles.length
      addWarnings target
      $('#new_file_modal .create').attr 'disabled', 'disabled'

window.newFileModal = ->
  $("#new_file_modal").modal
    onClose: ->
      $('#new_file_modal input[name="name"]').tipsy 'hide'
      $.modal.close()
    onShow: (modal) ->
      $(modal.container).css
        height: 'auto'
        width: '425px'

window.saveFile = (data) ->
  requireLogin ->
    message = $(".actions .status .message").val()

    postData = $.extend(
      format: 'json'
      message: message
    , data)

    delete postData.success
    delete postData.error

    {success:successMethod, error:errorMethod} = data

    $.post("/projects/#{projectId}/save_file", postData)
      .success ->
        successMethod?()
      .error ->
        errorMethod?()

params = null

$("#new_file_modal button.choice").click (event) ->
  event.preventDefault()

  $(this).takeClass("active")

  $("#new_file_modal .details").show()

  params = $(this).data('params')
  params.path = projectConfig.directories[params.directory]

  fields = $("#new_file_modal .fields").empty()

  for name, value of $(this).data('fields')
    $("#new_file_modal .field.template").tmpl(
      name: name
      inputType: if $.isNumeric(value) then 'number' else 'text'
      value: value
    ).appendTo(fields)

  $("#new_file_modal .details input[name='name']").focus()

  # Trigger a fake window resize event to re-center the modal
  $(window).resize()

$("#new_file_modal button.create").click (event) ->
  event.preventDefault()

  formData = $("#new_file_modal").serializeObject()

  # Special case to make entities use UUIDs
  if params.type is "entity"
    formData.uuid = Math.uuid(32, 16)

  data = $.extend(formData, params)
  data.path = "#{data.path}/#{data.name}.#{data.extension}"

  file = newFileNode data
  openFile file

  # Don't close the modal unless we've created a file.
  # Fixes bug where the modal closes with a blank name.
  if file
    $.modal.close()

$("#new_file_modal input").keydown (event) ->
  if event.which is 13
    $("#new_file_modal button.create").click()
