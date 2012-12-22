#= require_tree ../templates/files

# Hack to enable us to remove jQuery.tmpl. hamljs was having trouble
# dealing with template whitespace preservation

scriptTemplate = (locals) ->
  """
    #{locals.className} = (I={}) ->
      # Set some default properties
      Object.defaults I,
        color: "blue"
        height: 32
        width: 32
        # sprite: "block" # Use the name of a sprite in the images folder

      # Inherit from game object
      self = GameObject(I)

      # Add events and methods here
      self.on "update", ->
        # Add update method behavior

      # We must always return self as the last line
      return self
  """

testTemplate = (locals) ->
  """
    module '#{locals.className}'

    test "testing for equality", ->
      one = 1

      # Test for equality of two objects
      equals one, 1

    test "testing boolean values", ->
      someFunction = ->
        return true

      # Test if someFunction returns true
      ok someFunction()

    # Clear out the module
    module()
  """

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

  newName = prompt "Rename #{name.withoutExtension()} to:", name.withoutExtension()

  return unless newName

  file.set
    path: oldPath.replace(file.name().withoutExtension(), newName)

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
    source = "<source src='/#{railsEnv}/projects/#{projectId}/#{path}' type='audio/#{extension}'></source>"
    $('audio.preview').append(source).get(0).play()

    return

  if name is 'game.js'
    $('#run').click()

    return

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

    if template is 'script'
      inputData.contents ||= scriptTemplate(inputData)
    else if template is 'test'
      inputData.contents ||= testTemplate(inputData)

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
      $('.modal').modal('hide')
    onShow: (modal) ->
      $(modal.container).css
        height: 'auto'
        width: '440px'

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
    $(JST["templates/files/field"]
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
    $('.modal').modal('hide')

$("#new_file_modal input").keydown (event) ->
  if event.which is 13
    $("#new_file_modal button.create").click()
