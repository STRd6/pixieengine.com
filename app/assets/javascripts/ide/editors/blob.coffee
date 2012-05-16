
# This is a meta editor that will open the correct editor for the file type
# probably just a temporary solution to github returning all files as type blob.

window.createBlobEditor = (options, file) ->
  {extension, contents, url} = file.attributes

  editor = switch extension
    when "coffee", "js"
      if contents?
        createTextEditor(options, file)
      else
        githubClient.fileContents url, (contents) ->
          file.set
            contents: contents

          # TODO: Spruce up the tabs and file opening to make this better
          # Reopen file once loaded
          $("#tabs").tabs 'remove', file.get("docSelector")
          openFile(file)

        null

  return editor
