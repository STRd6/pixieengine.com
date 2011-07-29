/* DO NOT MODIFY. This file was compiled Fri, 29 Jul 2011 22:04:52 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.animation_editor2.coffee
 */

(function() {
  $.fn.animationEditor = function(options) {
    var Animation, Controls, animation, animationEditor, animationNumber, animationTemplate, animations, controls, editorTemplate, spriteTemplate, templates, updateUI;
    animationNumber = 1;
    Controls = function() {
      var changePlayIcon, fps, fpsEl, intervalId, scrubber, scrubberEl, self, updateFrame;
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
      changePlayIcon = function(icon) {
        var el;
        el = $('.play');
        el.css("background-image", "url(/images/" + icon + ".png)");
        if (icon === 'pause') {
          return el.addClass('pause');
        } else {
          return el.removeClass('pause');
        }
      };
      self = {
        fps: function(val) {
          if (val != null) {
            fps.val = val;
            scrubber.max = val;
            return self;
          } else {
            return fps.val;
          }
        },
        pause: function() {
          changePlayIcon('play');
          clearInterval(intervalId);
          return intervalId = null;
        },
        play: function() {
          var stopped;
          if (!intervalId) {
            intervalId = setInterval(updateFrame, 1000 / fps.val);
          }
          changePlayIcon('pause');
          return stopped = false;
        },
        scrubberPosition: function() {
          return "" + scrubber.val + " / " + scrubber.max;
        },
        stop: function() {
          var stopped;
          scrubber.val = 0;
          self.update();
          clearInterval(intervalId);
          intervalId = null;
          changePlayIcon('play');
          return stopped = true;
        },
        update: function() {
          scrubberEl.val(scrubber.val);
          return scrubberEl.get(0).max = scrubber.max;
        }
      };
      return self;
    };
    Animation = function(name) {
      var currentFrameIndex, frames, self, sequences, tileset;
      tileset = [];
      sequences = [];
      frames = [];
      currentFrameIndex = 0;
      name || (name = "Animation " + animationNumber);
      animationNumber += 1;
      self = {
        addFrame: function(imgSrc) {
          if ($.inArray(imgSrc, tileset) === -1) {
            tileset.push(imgSrc);
          }
          return frames.push(tileset.indexOf(imgSrc));
        },
        name: name
      };
      return self;
    };
    animationEditor = $(this.get(0)).addClass("editor animation_editor");
    templates = $("#animation_editor_templates");
    editorTemplate = templates.find('.editor.template');
    animationTemplate = templates.find('.animation');
    spriteTemplate = templates.find('.sprite');
    editorTemplate.tmpl().appendTo(animationEditor);
    controls = Controls();
    animation = Animation();
    animations = [animation];
    updateUI = function() {
      var animation, sprites, spritesSrc, src, _i, _j, _len, _len2, _results;
      sprites = $('.sprites');
      for (_i = 0, _len = animations.length; _i < _len; _i++) {
        animation = animations[_i];
        animations = $('.animations');
        animations.children().remove();
        animationTemplate.tmpl(animation.name).appendTo(animations);
      }
      spritesSrc = ["http://dev.pixie.strd6.com/sprites/15408/original.png", "http://dev.pixie.strd6.com/sprites/15407/original.png", "http://dev.pixie.strd6.com/sprites/15406/original.png", "http://dev.pixie.strd6.com/sprites/15405/original.png", "http://dev.pixie.strd6.com/sprites/15404/original.png", "http://dev.pixie.strd6.com/sprites/15403/original.png", "http://dev.pixie.strd6.com/sprites/15402/original.png", "http://dev.pixie.strd6.com/sprites/15401/original.png", "http://dev.pixie.strd6.com/sprites/15400/original.png", "http://dev.pixie.strd6.com/sprites/15399/original.png", "http://dev.pixie.strd6.com/sprites/15398/original.png", "http://dev.pixie.strd6.com/sprites/15397/original.png", "http://dev.pixie.strd6.com/sprites/15396/original.png", "http://dev.pixie.strd6.com/sprites/15395/original.png", "http://dev.pixie.strd6.com/sprites/15394/original.png", "http://dev.pixie.strd6.com/sprites/15393/original.png"];
      _results = [];
      for (_j = 0, _len2 = spritesSrc.length; _j < _len2; _j++) {
        src = spritesSrc[_j];
        _results.push(spriteTemplate.tmpl({
          src: src
        }).appendTo(sprites));
      }
      return _results;
    };
    updateUI();
    $('.play').mousedown(function() {
      if ($(this).hasClass('pause')) {
        return controls.pause();
      } else {
        return controls.play();
      }
    });
    $('.stop').mousedown(function() {
      return controls.stop();
    });
    $('.sprites .sprite_container').mousedown(function() {
      var imgSrc;
      imgSrc = $(this).find('img').attr('src');
      return animation.addFrame(imgSrc);
    });
    return $('.fps input').change(function() {
      var newValue;
      newValue = $(this).val();
      controls.stop();
      return controls.fps(newValue);
    });
  };
}).call(this);
