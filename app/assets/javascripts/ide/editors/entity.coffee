#= require templates/editors/entity

window.createEntityEditor = (options, file) ->
  {panel} = options
  {uuid, path, contents, name} = file.attributes

  panel.find('.editor').remove()

  defaults =
    color: '#0000FF'
    height: 32
    width: 32
    class: name.capitalize().camelize()

  try
    data = JSON.parse(contents) or defaults
  catch e
    console?.warn? e
    data = defaults

  entityEditor = $(JST["templates/editors/entity"]()).appendTo(panel)

  propertyEditor = entityEditor.find('table').propertyEditor(data)

  entityCode = data.__CODE

  textEditor = codeEditor
    panel: entityEditor.find(".content > section")
    code: entityCode
    save: (code) ->
      entityCode = code

  textEditor.bind 'dirty', ->
    entityEditor.trigger 'dirty'

  entityEditor.bind 'save', ->
    textEditor.trigger("save")

    entityData = propertyEditor.getProps()
    entityData.__CODE = entityCode
    entityData.uuid ||= name

    # Propagate changes back to IDE
    if existingEntity = entities.findByUUID(entityData.uuid)
      existingEntity.set entityData
    else
      entities.add entityData

    dataString = JSON.stringify(entityData, null, 2)

    indentedData = dataString.split("\n").map (line, i) ->
      if i > 0
        "  " + line
      else
        line
    .join("\n")

    indentedCode = entityCode.split("\n").map (line, i) ->
      "  " + line
    .join("\n")

    if entityData.class
      entitySrc = $("#file_templates .entity_class.template").tmpl(
        className: entityData.class
        parentClass: entityData.parentClass || "GameObject"
        code: indentedCode
        entityData: indentedData
      ).text()

      hotSwap(entitySrc, "coffee")

      # TODO Handle file move when renaming entity
      newFileNode
        name: "_#{name}"
        type: "text"
        extension: "coffee"
        language: "coffeescript"
        path: projectConfig.directories.source
        contents: entitySrc
        autoOpen: false
        forceSave: true

    entityEditor.trigger "clean"

    file.set
      contents: dataString

    saveFile
      contents: dataString
      path: path
      success: ->

  return entityEditor
