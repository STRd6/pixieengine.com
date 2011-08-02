/* DO NOT MODIFY. This file was compiled Tue, 02 Aug 2011 23:56:12 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.animation_editor2.coffee
 */

(function() {
  $.fn.animationEditor = function(options) {
    var Animation, Controls, animationEditor, animationNumber, animationTemplate, animations, controls, currentAnimation, editorTemplate, spriteTemplate, templates, updateUI;
    animationNumber = 1;
    animationEditor = $(this.get(0)).addClass("editor animation_editor");
    templates = $("#animation_editor_templates");
    editorTemplate = templates.find('.editor.template');
    animationTemplate = templates.find('.animation');
    spriteTemplate = templates.find('.sprite');
    Controls = function() {
      var changePlayIcon, fpsEl, intervalId, scrubber, scrubberEl, self, updateFrame;
      intervalId = null;
      fpsEl = animationEditor.find('.fps input');
      scrubberEl = animationEditor.find('.scrubber');
      scrubber = {
        min: function(newMin) {
          if (newMin != null) {
            scrubberEl.get(0).min = newMin;
            return scrubber;
          } else {
            return parseInt(scrubberEl.get(0).min);
          }
        },
        max: function(newMax) {
          if (newMax != null) {
            scrubberEl.get(0).max = newMax;
            return scrubber;
          } else {
            return parseInt(scrubberEl.get(0).max);
          }
        },
        val: function(newValue) {
          if (newValue != null) {
            scrubberEl.val(newValue);
            return scrubber;
          } else {
            return parseInt(scrubberEl.val());
          }
        }
      };
      updateFrame = function() {
        animationEditor.trigger('updateFrames');
        scrubber.val((scrubber.val() + 1) % (scrubber.max() + 1));
        return currentAnimation.currentFrameIndex(scrubber.val());
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
        fps: function(newValue) {
          if (newValue != null) {
            fpsEl.val(newValue);
            return fps;
          } else {
            return parseInt(fpsEl.val());
          }
        },
        pause: function() {
          changePlayIcon('play');
          clearInterval(intervalId);
          return intervalId = null;
        },
        play: function() {
          if (currentAnimation.frames.length > 0) {
            if (!intervalId) {
              intervalId = setInterval(updateFrame, 1000 / self.fps());
            }
            return changePlayIcon('pause');
          }
        },
        scrubber: function(val) {
          return scrubber.val(val);
        },
        scrubberMax: function(val) {
          return scrubber.max(val);
        },
        scrubberPosition: function() {
          return "" + (scrubber.val()) + " / " + (scrubber.max());
        },
        stop: function() {
          scrubber.val(0);
          clearInterval(intervalId);
          intervalId = null;
          changePlayIcon('play');
          return currentAnimation.currentFrameIndex(-1);
        }
      };
      return self;
    };
    Animation = function() {
      var currentFrameIndex, findTileIndex, frames, name, self, sequences, tileset;
      tileset = {};
      [323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338].each(function(n) {
        return tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/" + n + "/original.png";
      });
      sequences = [];
      frames = [];
      currentFrameIndex = 0;
      name = "State " + animationNumber;
      animationNumber += 1;
      findTileIndex = function(tileSrc) {
        var src, uuid;
        for (uuid in tileset) {
          src = tileset[uuid];
          if (src === tileSrc) {
            return uuid;
          }
        }
      };
      animationEditor.bind('updateSequence', function() {
        var array, sequence, sequencesEl, spriteIndex, spriteSrc, _i, _len, _results;
        sequencesEl = animationEditor.find('.sequences');
        sequencesEl.children().remove();
        _results = [];
        for (_i = 0, _len = sequences.length; _i < _len; _i++) {
          array = sequences[_i];
          sequence = $('<div class="sequence"></div>').appendTo(sequencesEl);
          _results.push((function() {
            var _j, _len2, _results2;
            _results2 = [];
            for (_j = 0, _len2 = array.length; _j < _len2; _j++) {
              spriteIndex = array[_j];
              spriteSrc = tileset[spriteIndex];
              _results2.push(spriteTemplate.tmpl({
                src: spriteSrc
              }).appendTo(sequence));
            }
            return _results2;
          })());
        }
        return _results;
      });
      animationEditor.bind('updateFrames', function() {
        var frame_index, spriteSrc, _i, _len, _results;
        animationEditor.find('.frame_sprites').children().remove();
        _results = [];
        for (_i = 0, _len = frames.length; _i < _len; _i++) {
          frame_index = frames[_i];
          spriteSrc = tileset[frame_index];
          _results.push(spriteTemplate.tmpl({
            src: spriteSrc
          }).appendTo(animationEditor.find('.frame_sprites')));
        }
        return _results;
      });
      self = {
        addFrame: function(imgSrc) {
          frames.push(findTileIndex(imgSrc));
          controls.scrubberMax(frames.length - 1);
          return animationEditor.trigger('updateFrames');
        },
        addSequenceToFrames: function(index) {
          var imageIndex, _i, _len, _ref, _results;
          _ref = sequences[index];
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            imageIndex = _ref[_i];
            _results.push(self.addFrame(tileset[imageIndex]));
          }
          return _results;
        },
        addTile: function(src) {
          var spritesEl;
          tileset[Math.uuid(32, 16)] = src;
          spritesEl = animationEditor.find('.sprites');
          return spriteTemplate.tmpl({
            src: src
          }).appendTo(spritesEl);
        },
        createSequence: function() {
          sequences.push(frames.copy());
          animationEditor.trigger('updateSequence');
          frames.clear();
          return animationEditor.trigger('updateFrames');
        },
        currentFrameIndex: function(val) {
          if (val != null) {
            currentFrameIndex = val;
            self.updateSelected(val);
            return self;
          } else {
            return currentFrameIndex;
          }
        },
        frames: frames,
        name: function(val) {
          if (val != null) {
            name = val;
            return self;
          } else {
            return name;
          }
        },
        tileset: tileset,
        removeFrame: function(frameIndex) {
          var tilesetIndex;
          tilesetIndex = frames[frameIndex];
          frames.splice(frameIndex, 1);
          if ($.inArray(tilesetIndex, frames) === -1) {
            delete tileset[tilesetIndex];
          }
          return animationEditor.trigger('updateFrames');
        },
        updateSelected: function(frameIndex) {
          var player, tilesetIndex;
          tilesetIndex = frames[frameIndex];
          animationEditor.find('.frame_sprites img').removeClass('current');
          player = $('.player img');
          if (frameIndex === -1) {
            return player.removeAttr('src');
          } else {
            player.attr('src', tileset[tilesetIndex]);
            return animationEditor.find('.frame_sprites img').eq(frameIndex).addClass('current');
          }
        }
      };
      return self;
    };
    editorTemplate.tmpl().appendTo(animationEditor);
    controls = Controls();
    currentAnimation = Animation();
    animations = [currentAnimation];
    updateUI = function() {
      var animation, animationsEl, index, spritesEl, src, _i, _len, _ref, _results;
      animationsEl = animationEditor.find('.animations');
      animationsEl.children().remove();
      spritesEl = animationEditor.find('.sprites');
      for (_i = 0, _len = animations.length; _i < _len; _i++) {
        animation = animations[_i];
        animationTemplate.tmpl({
          name: animation.name()
        }).appendTo(animationsEl);
      }
      if (spritesEl.find('img').length === 0) {
        _ref = currentAnimation.tileset;
        _results = [];
        for (index in _ref) {
          src = _ref[index];
          _results.push(spriteTemplate.tmpl({
            src: src
          }).appendTo(spritesEl));
        }
        return _results;
      }
    };
    updateUI();
    animationEditor.find('.play').mousedown(function() {
      if ($(this).hasClass('pause')) {
        return controls.pause();
      } else {
        return controls.play();
      }
    });
    animationEditor.find('.scrubber').change(function() {
      var newValue;
      newValue = $(this).val();
      controls.scrubber(newValue);
      return currentAnimation.currentFrameIndex(newValue);
    });
    animationEditor.find('.stop').mousedown(function() {
      return controls.stop();
    });
    animationEditor.find('.new_animation').mousedown(function() {
      animations.push(Animation());
      currentAnimation = animations.last();
      animationEditor.find('.sequences').children().remove();
      animationEditor.find('.frame_sprites').children().remove();
      animationEditor.find('.player img').removeAttr('src');
      return updateUI();
    });
    animationEditor.find('.sprites img').live({
      mousedown: function() {
        var imgSrc;
        imgSrc = $(this).attr('src');
        return currentAnimation.addFrame(imgSrc);
      }
    });
    animationEditor.find('.sequence').live({
      mousedown: function() {
        var index;
        index = $(this).index();
        return currentAnimation.addSequenceToFrames(index);
      },
      mouseenter: function() {
        $(this).find('img:first-child').addClass('rotate_left');
        return $(this).find('img:last-child').addClass('rotate_right');
      },
      mouseleave: function() {
        return $(this).find('img').removeClass('rotate_left').removeClass('rotate_right');
      }
    });
    animationEditor.find('.frame_sprites img').live({
      mousedown: function() {
        var index;
        index = $(this).index();
        return currentAnimation.currentFrameIndex(index);
      }
    });
    animationEditor.find('.save_sequence').click(function() {
      return currentAnimation.createSequence();
    });
    animationEditor.find('.fps input').change(function() {
      var newValue;
      newValue = $(this).val();
      controls.stop();
      return controls.fps(newValue);
    });
    animationEditor.find('input.state_name').live({
      change: function() {
        var updatedStateName;
        updatedStateName = $(this).val();
        return currentAnimation.name(updatedStateName);
      }
    });
    animationEditor.find('.state_name').liveEdit();
    animationEditor.dropImageReader(function(file, event) {
      var src;
      if (event.target.readyState === FileReader.DONE) {
        src = event.target.result;
        return currentAnimation.addTile(src);
      }
    });
    return $(document).bind('keydown', 'del backspace', function(e) {
      e.preventDefault();
      return currentAnimation.removeFrame(currentAnimation.currentFrameIndex());
    });
  };
}).call(this);
