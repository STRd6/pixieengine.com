namespace "Pixie.Editor.Animation", (Animation) ->
  Animation.actions =
    save:
      hotkeys: ["ctrl+s", "meta+s"]
      name: "Export as JSON"
      perform: (editor) ->
        editor.toJSON()
      icon: 'save'

    undo:
      hotkeys: ["ctrl+z", "meta+z"]
      perform: (editor) ->
        editor.settings.undo()
      icon: 'undo'

    redo:
      hotkeys: ["ctrl+y", "meta+y"]
      perform: (editor) ->
        editor.settings.redo()
      icon: 'redo'

    previous:
      hotkeys: "left"
      menu: false
      perform: (editor) ->
        player = editor.playerView.model

        player.pause()
        player.previousFrame()

    next:
      hotkeys: "right"
      menu: false
      perform: (editor) ->
        player = editor.playerView.model

        player.pause()
        player.nextFrame(true)

    deleteFrame:
      hotkeys: ["del", "backspace"]
      menu: false
      perform: (editor) ->
        editor.framesView.removeSelected()

    cut:
      hotkeys: ["ctrl+x", "meta+x"]
      menu: false
      perform: (editor) ->
        console.log 'cut'

    copy:
      hotkeys: ["ctrl+c", "meta+c"]
      menu: false
      perform: (editor) ->
        console.log 'copy'

    paste:
      hotkeys: ["ctrl+v", "meta+v"]
      menu: false
      perform: (editor) ->
        console.log 'paste'

    selectAll:
      hotkeys: ["ctrl+a", "meta+a"]
      menu: false
      perform: (editor) ->
        console.log 'select all'

    help:
      hotkeys: ["ctrl+h", "meta+h"]
      icon: 'help'
      perform: (editor) ->
        console.log 'show the modal help dialog'

