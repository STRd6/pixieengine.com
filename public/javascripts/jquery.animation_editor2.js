/* DO NOT MODIFY. This file was compiled Thu, 28 Jul 2011 23:52:37 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.animation_editor2.coffee
 */

(function() {
  $.fn.animationEditor = function() {
    var Animation, Controls, animationEditor, animationNumber, animationTemplate, animations, controls, templates, updateUI;
    animationNumber = 1;
    animations = [];
    Controls = function() {
      var fps, fpsEl, paused, playing, scrubber, scrubberEl, self;
      playing = false;
      paused = false;
      scrubberEl = $('.scrubber');
      scrubber = {
        min: scrubberEl.get(0).min,
        max: scrubberEl.get(0).max,
        val: scrubberEl.val()
      };
      fpsEl = $('.fps input');
      fps = {
        min: fpsEl.get(0).min,
        max: fpsEl.get(0).max,
        val: fpsEl.val()
      };
      self = {
        play: function() {
          return scrubber.val = (scrubber.val + 1) % scrubber.max;
        },
        stop: function() {
          return scrubber.val = 0;
        },
        update: function() {
          return scrubberEl.val(scrubber.val);
        }
      };
      return self;
    };
    Animation = function(name) {
      var currentFrameIndex, self, sequences, tileset;
      tileset = [];
      sequences = [];
      currentFrameIndex = 0;
      name || (name = "Animation " + animationNumber);
      animationNumber += 1;
      self = {
        addFrame: function(image) {
          return tileset.push(image);
        },
        advanceFrame: function() {
          return currentFrameIndex = (currentFrameIndex + 1) % tileset.length;
        },
        name: name,
        removeFrame: function(image) {
          return tileset.remove(image);
        }
      };
      return self;
    };
    animations.push(Animation());
    animationEditor = $(this.get(0)).addClass("editor animation_editor");
    templates = $("#animation_editor_templates");
    animationTemplate = templates.find('.animation');
    templates.find(".editor.template").tmpl().appendTo(animationEditor);
    controls = Controls();
    updateUI = function() {
      var animation, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = animations.length; _i < _len; _i++) {
        animation = animations[_i];
        animations = $('.animations');
        animations.children().remove();
        _results.push(animationTemplate.tmpl(animation.name).appendTo(animations));
      }
      return _results;
    };
    updateUI();
    controls.play();
    return controls.update();
  };
}).call(this);
