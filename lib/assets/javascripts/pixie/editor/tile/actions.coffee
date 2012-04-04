
namespace "Pixie.Editor.Tile", (Tile) ->
  Tile.actions =
    undo:
      hotkeys: "ctrl+z"
      perform: (editor) ->
        editor.undo()

    redo:
      hotkeys: "ctrl+y"
      perform: (editor) ->
        editor.redo()

    stamp:
      hotkeys: "1 p"
      perform: (editor) ->
        editor.settings.set
          activeTool: 'stamp'

    eraser:
      hotkeys: "2 e"
      perform: (editor) ->
        editor.settings.set
          activeTool: 'eraser'

    fill:
      hotkeys: "3 f"
      perform: (editor) ->
        editor.settings.set
          activeTool: 'fill'

    selection:
      hotkeys: "4 m"
      perform: (editor) ->
        editor.settings.set
          activeTool: 'selection'

    pointer:
      hotkeys: "5 v"
      perform: (editor) ->
        editor.settings.set
          activeTool: 'pointer'
