/* DO NOT MODIFY. This file was compiled Fri, 29 Jul 2011 00:31:47 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.animation_editor2.coffee
 */

(function() {
  $.fn.animationEditor = function() {
    var Animation, Controls, animationEditor, animationNumber, animationTemplate, animations, controls, editorTemplate, templates, updateUI;
    animationNumber = 1;
    animations = [];
    Controls = function() {
      var fps, fpsEl, intervalId, paused, scrubber, scrubberEl, self, updateFrame;
      paused = false;
      intervalId = null;
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
      updateFrame = function() {
        scrubber.val = (scrubber.val + 1) % scrubber.max;
        return self.update();
      };
      self = {
        fps: function(val) {
          if (val != null) {
            fps.val = val;
            return self;
          } else {
            return fps.val;
          }
        },
        play: function() {
          console.log(fps.val);
          if (!intervalId) {
            return intervalId = setInterval(updateFrame, 1000 / fps.val);
          }
        },
        stop: function() {
          scrubber.val = 0;
          self.update();
          clearInterval(intervalId);
          return intervalId = null;
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
        name: name
      };
      return self;
    };
    animations.push(Animation());
    animationEditor = $(this.get(0)).addClass("editor animation_editor");
    templates = $("#animation_editor_templates");
    editorTemplate = templates.find('.editor.template');
    animationTemplate = templates.find('.animation');
    editorTemplate.tmpl().appendTo(animationEditor);
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
    $('.play').mousedown(function() {
      return controls.play();
    });
    $('.stop').mousedown(function() {
      return controls.stop();
    });
    return $('.fps input').change(function() {
      var newValue;
      newValue = $(this).val();
      controls.stop();
      return controls.fps(newValue);
    });
  };
}).call(this);
