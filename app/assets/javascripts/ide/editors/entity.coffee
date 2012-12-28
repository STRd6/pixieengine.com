#= require templates/editors/entity

entityClassTemplate = (locals) ->
  """
    # HEY LISTEN!
    # This file is auto-generated, so editing it directly is a bad idea.
    # Modify the entity that generated it instead!
    #{locals.className} = (I={}) ->
      Object.defaults I, #{locals.entityData}

      self = #{locals.parentClass}(I)

    #{locals.code}

      return self
  """


$ ->
  window.entities = new Pixie.Editor.Tile.Models.EntityList()

  # Populate initial entities
  tree.getDirectory(projectConfig.directories.entities)?.files().each (file) ->
    {contents} = file.attributes
    name = file.name()

    return unless name.extension() is "entity"

    entityData = contents.parse()

    # TODO: Make sure entities get created with uuids to prevent
    # collisions from multiple people making the same file name
    # and importing/merging projects
    #
    # In the meantime just treat the file name as the uuid
    # because within a single project the file name must be
    # unique
    entityData.uuid ||= name

    window.entities.add entityData

window.createEntityEditor = (options, file) ->
  {panel} = options
  {uuid, path, contents} = file.attributes
  name = file.name().withoutExtension()

  panel.find('.editor').remove()

  defaults =
    class: name.capitalize().camelize()
    parentClass: "GameObject"

  try
    data = JSON.parse(contents) or defaults
  catch e
    console?.warn? e
    console?.warn? "Occurred in #{contents}"
    data = defaults

  entityEditor = $(JST["editors/entity"]()).appendTo(panel)

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
      entitySrc = entityClassTemplate
        className: entityData.class
        parentClass: entityData.parentClass || "GameObject"
        code: indentedCode
        entityData: indentedData

      hotSwap(entitySrc, "coffee")

      # TODO Handle file move when renaming entity
      newFileNode
        type: 'text'
        path: "#{projectConfig.directories.source}/_#{name}.coffee"
        contents: entitySrc
        forceSave: true

    entityEditor.trigger "clean"

    file.set
      contents: dataString

    saveFile
      contents: dataString
      path: path
      success: ->

  return entityEditor
