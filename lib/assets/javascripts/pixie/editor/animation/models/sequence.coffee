namespace "Pixie.Editor.Animation.Models", (Models) ->
  class Models.Sequence extends Backbone.Model
    defaults:
      name: "New Sequence"
      frames: []

    constructStack: (includeName=true) =>
      name = @get('name')
      cid = @cid
      lastFrame = @get('frames').last()

      sequenceEl = $ "<div class=sequence data-cid=#{cid}></div>"
      nameEl = ""
      nameEl = "<span class=name>#{name}</span>" if includeName

      sequenceEl.append(nameEl)

      width = null
      height = null

      for frame in @get 'frames'
        if frame == lastFrame
          src = frame.src
          img = $ "<img src=#{src}>"
          height = img.get(0).height
          width = img.get(0).width

          sequenceEl.append img
        else
          sequenceEl.append '<div class="placeholder"></div>'

      sequenceEl.find('.placeholder').css
        width: width + 4
        height: height + 4

      return sequenceEl
