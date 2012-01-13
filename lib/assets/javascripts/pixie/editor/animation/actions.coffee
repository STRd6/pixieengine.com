namespace "Pixie.Editor.Animation", (Animation) ->
  Animation.actions =
    save:
      hotkeys: ["ctrl+s", "meta+s"]
      perform: (editor) ->
        #console.log editor.toJSON()
        console.log 'saving'

    undo:
      hotkeys: ["ctrl+z", "meta+z"]
      perform: (editor) ->
        #editor.settings.undo()
        console.log 'undo'

    redo:
      hotkeys: ["ctrl+y", "meta+y"]
      perform: (editor) ->
        #editor.settings.redo()
        console.log 'redo'

    previous:
      hotkeys: "left"
      perform: (editor) ->
        player = editor.playerView.model

        player.pause()
        player.previousFrame()

    next:
      hotkeys: "right"
      perform: (editor) ->
        player = editor.playerView.model

        player.pause()
        player.nextFrame(true)

    deleteFrame:
      hotkeys: ["del", "backspace"]
      perform: (editor) ->
        editor.framesView.removeSelected()

    cut:
      hotkeys: ["ctrl+x", "meta+x"]
      perform: (editor) ->
        console.log 'cut'

    copy:
      hotkeys: ["ctrl+c", "meta+c"]
      perform: (editor) ->
        console.log 'copy'

    paste:
      hotkeys: ["ctrl+v", "meta+v"]
      perform: (editor) ->
        console.log 'paste'

    selectAll:
      hotkeys: ["ctrl+a", "meta+a"]
      perform: (editor) ->
        console.log 'select all'
