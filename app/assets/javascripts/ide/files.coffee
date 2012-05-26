window.openFile = (file) ->
  trackEvent("IDE", "open file", file)

  {name, nodeType, type, path, size} = file.attributes
  extension = name.extension()
  selector = path.replace(/[^A-Za-z0-9_-]/g, "_")

  # TODO: Have docSelector be a generated attribute or method on files
  # In the meantime reset it every time we open to keep it correct.
  # TOOD: Dump jQueryUI Tabs and get rid of doc selector entirely
  docSelector = file.attributes.docSelector = "#file_#{selector}"
  extension = name.extension()

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

  return alert "Can't edit binary data... maybe there is a source file that can be edited." if type is "binary"
  return alert "This file is too large for our editor!" if size > MAX_FILE_SIZE

  # focus the tab if it already exists
  if (tab = $('#tabs ul li a[href="' + docSelector + '"]')).length
    tab.click()
  else
    unless fileName = name
      if match = path.match /\/([^\/]*)$/
        fileName = match[1]
      else
        fileName = path

    window.currentFile = file

    $("#tabs").tabs 'add', docSelector, fileName, 0

    # Focus Newly Created Tab
    $('#tabs ul li a[href="' + docSelector + '"]').click()


window.newFileNode = (inputData) ->
  {extension, forceSave, autoOpen, language, name, options, path, template, type} = inputData

  unless name
    alert "You need to enter a name!"
    return

  inputData.path = "#{path}/#{name}.#{extension}"
  docSelector = "#file_" + inputData.path.replace(/[^A-Za-z0-9_-]/g, "_")

  hideFile = false

  if inputData.type is 'binary' or inputData.contents?.substr(0, 8) is 'var App;'
    hideFile = true

  data = $.extend({
    docSelector: docSelector
    hidden: hideFile
  }, inputData)

  if template
    data.className = name.capitalize().camelize()
    data.contents ||= $("#file_templates .#{template}").tmpl(data).text()

  fullName = "#{path}/#{name}.#{extension}"

  # TODO remove global file tree reference. Pass it to the function instead
  file = tree.file fullName, data

  # TODO Get a JS test for this
  if forceSave
    window.saveFile
      contents: data.contents
      path: fullName

  return file

# on keyup check to see if a file with the same name exists
$('#new_file_modal input[name="name"]').keyup (e) ->
  target = $(e.currentTarget)
  value = target.val()

  directory = $('#new_file_modal button.active').data('params')['directory']

  aliasedDirectory = projectConfig.directories[directory]

  directory = tree.getDirectory(aliasedDirectory).first()

  removeWarnings target
  $('#new_file_modal .create').removeAttr 'disabled'

  if directory
    matchingFiles = directory.collection.select (file) ->
      # make sure the file names are really different, they
      # shouldn't be considered different if they only differ
      # in capitalization, non alphanumeric characters, or whitespace
      return normalizeFileName(file.get('name')) is normalizeFileName(value)
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
