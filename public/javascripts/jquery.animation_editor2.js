/* DO NOT MODIFY. This file was compiled Sat, 30 Jul 2011 01:11:37 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.animation_editor2.coffee
 */

(function() {
  $.fn.animationEditor = function(options) {
    var Animation, Controls, animation, animationEditor, animationNumber, animationTemplate, animations, controls, editorTemplate, spriteTemplate, templates, updateUI;
    animationNumber = 1;
    animationEditor = $(this.get(0)).addClass("editor animation_editor");
    templates = $("#animation_editor_templates");
    editorTemplate = templates.find('.editor.template');
    animationTemplate = templates.find('.animation');
    spriteTemplate = templates.find('.sprite');
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
        self.update();
        scrubber.val = (scrubber.val + 1) % scrubber.max;
        return animation.currentFrameIndex(scrubber.val);
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
          if (!intervalId) {
            intervalId = setInterval(updateFrame, 1000 / fps.val);
          }
          return changePlayIcon('pause');
        },
        scrubber: function(val) {
          if (val != null) {
            scrubber.val = val;
            return self;
          } else {
            return scrubber.val;
          }
        },
        scrubberMax: function(val) {
          if (val != null) {
            scrubber.max = val;
            return self;
          } else {
            return scrubber.max;
          }
        },
        scrubberPosition: function() {
          return "" + scrubber.val + " / " + scrubber.max;
        },
        stop: function() {
          scrubber.val = 0;
          self.update();
          clearInterval(intervalId);
          intervalId = null;
          changePlayIcon('play');
          return animation.currentFrameIndex(-1);
        },
        update: function() {
          scrubberEl.val(scrubber.val);
          return scrubberEl.get(0).max = scrubber.max;
        }
      };
      return self;
    };
    Animation = function(name) {
      var currentFrameIndex, frames, self, sequences, tileset, updateSelected;
      tileset = [];
      sequences = [];
      frames = [];
      currentFrameIndex = 0;
      name || (name = "Animation " + animationNumber);
      animationNumber += 1;
      updateSelected = function(val) {
        $('.frame_sprites .sprite_container').removeClass('current');
        if (val !== -1) {
          $('.frame_sprites .sprite_container').eq(val).addClass('current');
        }
        return $('.player img').attr('src', tileset[currentFrameIndex]);
      };
      self = {
        addFrame: function(imgSrc) {
          if ($.inArray(imgSrc, tileset) === -1) {
            tileset.push(imgSrc);
          }
          frames.push(tileset.indexOf(imgSrc));
          controls.scrubberMax(frames.length);
          return self.update();
        },
        currentFrameIndex: function(val) {
          if (val != null) {
            currentFrameIndex = val;
            updateSelected(val);
            return self;
          } else {
            return currentFrameIndex;
          }
        },
        name: name,
        update: function() {
          var frame_index, spriteSrc, _i, _len, _results;
          $('.frame_sprites').children().remove();
          _results = [];
          for (_i = 0, _len = frames.length; _i < _len; _i++) {
            frame_index = frames[_i];
            spriteSrc = tileset[frame_index];
            _results.push(spriteTemplate.tmpl({
              src: spriteSrc
            }).appendTo($('.frame_sprites')));
          }
          return _results;
        }
      };
      return self;
    };
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
      spritesSrc = ["http://dev.pixie.strd6.com/sprites/323/original.png", "http://dev.pixie.strd6.com/sprites/324/original.png", "http://dev.pixie.strd6.com/sprites/325/original.png", "http://dev.pixie.strd6.com/sprites/326/original.png", "http://dev.pixie.strd6.com/sprites/327/original.png", "http://dev.pixie.strd6.com/sprites/328/original.png", "http://dev.pixie.strd6.com/sprites/329/original.png", "http://dev.pixie.strd6.com/sprites/330/original.png", "http://dev.pixie.strd6.com/sprites/331/original.png", "http://dev.pixie.strd6.com/sprites/332/original.png", "http://dev.pixie.strd6.com/sprites/333/original.png", "http://dev.pixie.strd6.com/sprites/334/original.png", "http://dev.pixie.strd6.com/sprites/335/original.png", "http://dev.pixie.strd6.com/sprites/336/original.png", "http://dev.pixie.strd6.com/sprites/337/original.png", "http://dev.pixie.strd6.com/sprites/338/original.png"];
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
    $('.scrubber').change(function() {
      var newValue;
      newValue = $(this).val();
      controls.scrubber(newValue);
      return animation.currentFrameIndex(newValue);
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
