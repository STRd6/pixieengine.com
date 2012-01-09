
namespace "Pixie.Editor.Tile", (Tile) ->
  Tile.actions =
    save:
      hotkeys: "ctrl+s"
      perform: (editor) ->
        console.log editor.toJSON()

    undo:
      hotkeys: "ctrl+z"
      perform: (editor) ->
        editor.undo()

    redo:
      hotkeys: "ctrl+y"
      perform: (editor) ->
        editor.redo()
