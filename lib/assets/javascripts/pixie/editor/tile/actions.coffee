
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
