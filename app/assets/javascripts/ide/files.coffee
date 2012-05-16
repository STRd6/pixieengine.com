
    window.openFile = (file) ->
      trackEvent("IDE", "open file", file)

      {name, nodeType, type, path, size} = file.attributes
      selector = path.replace(/[^A-Za-z0-9_-]/g, "_")

      # TODO: Have docSelector be a generated attribute or method on files
      # In the meantime reset it every time we open to keep it correct.
      # TOOD: Dump jQueryUI Tabs and get rid of doc selector entirely
      docSelector = file.attributes.docSelector = '#' + nodeType + '_' + selector

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
