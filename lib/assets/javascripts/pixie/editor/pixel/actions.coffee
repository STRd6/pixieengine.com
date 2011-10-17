# Default actions for the pixel editor

# Old school namespacing. Stuck with it until Sprockets supports exports
window.Pixie ||= {}
Pixie.Editor ||= {}
Pixie.Editor.Pixel ||= {}

Pixie.Editor.Pixel.actions = (($) ->
  return actions =
    undo:
      hotkeys: ['ctrl+z', 'meta+z']
      perform: (canvas) ->
        canvas.undo()
      undoable: false
    redo:
      hotkeys: ["ctrl+y", "meta+z"]
      perform: (canvas) ->
        canvas.redo()
      undoable: false
    clear:
      perform: (canvas) ->
        canvas.eachPixel (pixel) ->
          pixel.color(Color().toString(), "replace")
    preview:
      menu: false
      perform: (canvas) ->
        canvas.preview()
      undoable: false
    left:
      hotkeys: ["left"]
      menu: false
      perform: `function(canvas) {
        var deferredColors = [];

        canvas.height().times(function(y) {
          deferredColors[y] = canvas.getPixel(0, y).color();
        });

        canvas.eachPixel(function(pixel, x, y) {
          var rightPixel = canvas.getPixel(x + 1, y);

          if(rightPixel) {
            pixel.color(rightPixel.color(), 'replace');
          } else {
            pixel.color(Color(), 'replace')
          }
        });

        $.each(deferredColors, function(y, color) {
          canvas.getPixel(canvas.width() - 1, y).color(color);
        });
      }`
    right:
      hotkeys: ["right"]
      menu: false
      perform: `function(canvas) {
        var width = canvas.width();
        var height = canvas.height();

        var deferredColors = [];

        height.times(function(y) {
          deferredColors[y] = canvas.getPixel(width - 1, y).color();
        });

        for(var x = width-1; x >= 0; x--) {
          for(var y = 0; y < height; y++) {
            var currentPixel = canvas.getPixel(x, y);
            var leftPixel = canvas.getPixel(x - 1, y);

            if(leftPixel) {
              currentPixel.color(leftPixel.color(), 'replace');
            } else {
              currentPixel.color(Color(), 'replace');
            }
          }
        }

        $.each(deferredColors, function(y, color) {
          canvas.getPixel(0, y).color(color);
        });
      }`
    up:
      hotkeys: ["up"]
      menu: false
      perform: `function(canvas) {
        var deferredColors = [];

        canvas.width().times(function(x) {
          deferredColors[x] = canvas.getPixel(x, 0).color();
        });

        canvas.eachPixel(function(pixel, x, y) {
          var lowerPixel = canvas.getPixel(x, y + 1);

          if(lowerPixel) {
            pixel.color(lowerPixel.color(), 'replace');
          } else {
            pixel.color(Color(), 'replace');
          }
        });

        $.each(deferredColors, function(x, color) {
          canvas.getPixel(x, canvas.height() - 1).color(color);
        });
      }`
    down:
      hotkeys: ["down"]
      menu: false
      perform: `function(canvas) {
        var width = canvas.width();
        var height = canvas.height();

        var deferredColors = [];

        canvas.width().times(function(x) {
          deferredColors[x] = canvas.getPixel(x, height - 1).color();
        });

        for(var x = 0; x < width; x++) {
          for(var y = height-1; y >= 0; y--) {
            var currentPixel = canvas.getPixel(x, y);
            var upperPixel = canvas.getPixel(x, y-1);

            if(upperPixel) {
              currentPixel.color(upperPixel.color(), 'replace');
            } else {
              currentPixel.color(Color(), 'replace');
            }
          }
        }

        $.each(deferredColors, function(x, color) {
          canvas.getPixel(x, 0).color(color);
        });
      }`
    download:
      hotkeys: ["ctrl+s"]
      perform: (canvas) ->
        w = window.open()
        w.document.location = canvas.toDataURL()
      undoable: false
)(jQuery)
