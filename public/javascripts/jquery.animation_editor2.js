/* DO NOT MODIFY. This file was compiled Wed, 10 Aug 2011 03:00:58 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.animation_editor2.coffee
 */

(function() {
  $.fn.animationEditor = function(options) {
    var Animation, Controls, animationEditor, animationNumber, animationTemplate, animations, controls, currentAnimation, editorTemplate, lastClickedSprite, loadSpriteSheet, spriteTemplate, templates, updateUI;
    animationNumber = 1;
    lastClickedSprite = null;
    animationEditor = $(this.get(0)).addClass("editor animation_editor");
    templates = $("#animation_editor_templates");
    editorTemplate = templates.find('.editor.template');
    animationTemplate = templates.find('.animation');
    spriteTemplate = templates.find('.sprite');
    loadSpriteSheet = function(src, rows, columns, loadedCallback) {
      var canvas, context, image;
      canvas = $('<canvas>').get(0);
      context = canvas.getContext('2d');
      image = new Image();
      image.onload = function() {
        var tileHeight, tileWidth;
        tileWidth = image.width / rows;
        tileHeight = image.height / columns;
        canvas.width = tileWidth;
        canvas.height = tileHeight;
        return columns.times(function(col) {
          return rows.times(function(row) {
            var destHeight, destWidth, destX, destY, sourceHeight, sourceWidth, sourceX, sourceY;
            sourceX = row * tileWidth;
            sourceY = col * tileHeight;
            sourceWidth = tileWidth;
            sourceHeight = tileHeight;
            destWidth = tileWidth;
            destHeight = tileHeight;
            destX = 0;
            destY = 0;
            context.clearRect(0, 0, tileWidth, tileHeight);
            context.drawImage(image, sourceX, sourceY, sourceWidth, sourceHeight, destX, destY, destWidth, destHeight);
            return typeof loadedCallback === "function" ? loadedCallback(canvas.toDataURL()) : void 0;
          });
        });
      };
      return image.src = src;
    };
    Controls = function() {
      var changePlayIcon, fpsEl, intervalId, nextFrame, scrubber, scrubberEl, self;
      intervalId = null;
      fpsEl = animationEditor.find('.fps input');
      scrubberEl = animationEditor.find('.scrubber');
      scrubber = {
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
            currentAnimation.currentFrameIndex(newValue);
            return scrubber;
          } else {
            return parseInt(scrubberEl.val());
          }
        }
      };
      nextFrame = function() {
        return scrubber.val((scrubber.val() + 1) % (scrubber.max() + 1));
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
            return self;
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
              intervalId = setInterval(nextFrame, 1000 / self.fps());
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
      var clearFrames, currentFrameIndex, findTileIndex, frames, name, pushSequence, self, sequences, tileset;
      tileset = {};
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
      animationEditor.bind('clearFrames', function() {
        return animationEditor.find('.frame_sprites').children().remove();
      });
      animationEditor.bind('loadAnimation', function(e, animationIndex) {});
      animationEditor.bind('removeFrame', function(e, frameIndex) {
        return animationEditor.find('.frame_sprites img').eq(frameIndex).remove();
      });
      animationEditor.bind('updateLastFrame', function() {
        var spriteSrc;
        spriteSrc = tileset[frames.last()];
        return spriteTemplate.tmpl({
          src: spriteSrc
        }).appendTo(animationEditor.find('.frame_sprites'));
      });
      animationEditor.bind('updateLastFrameSequence', function(e, sequence) {
        return sequence.appendTo(animationEditor.find('.frame_sprites'));
      });
      animationEditor.bind('updateCurrentAnimationTitle', function() {
        return animationEditor.find('.player .animation_name').text(currentAnimation.name());
      });
      animationEditor.bind('updateAnimations', function() {
        animationEditor.trigger('updateCurrentAnimationTitle');
        animationEditor.find('.sequences').children().remove();
        animationEditor.find('.frame_sprites').children().remove();
        animationEditor.find('.player img').remove();
        return animationEditor.find('.player').append('<img />');
      });
      animationEditor.bind('disableSave', function() {
        return animationEditor.find('.save_sequence, .save_reverse_sequence, .save_animation').attr({
          disabled: true,
          title: 'Add frames to save'
        });
      });
      animationEditor.bind('enableSave', function() {
        return animationEditor.find('.save_sequence, .save_reverse_sequence, .save_animation').removeAttr('disabled').attr('title', 'Save frames');
      });
      clearFrames = function() {
        frames.clear();
        animationEditor.trigger('clearFrames');
        return animationEditor.trigger('disableSave');
      };
      pushSequence = function(frameArray) {
        sequences.push(frameArray);
        return animationEditor.trigger('updateSequence');
      };
      self = {
        addFrame: function(imgSrc) {
          frames.push(findTileIndex(imgSrc));
          controls.scrubberMax(frames.length - 1);
          animationEditor.trigger('updateLastFrame');
          return animationEditor.trigger('enableSave');
        },
        addSequenceToFrames: function(index) {
          var sequence, spriteIndex, spriteSrc, _i, _len, _ref, _results;
          sequence = $('<div class="sequence"></div>');
          _ref = sequences[index];
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            spriteIndex = _ref[_i];
            spriteSrc = tileset[spriteIndex];
            spriteTemplate.tmpl({
              src: spriteSrc
            }).appendTo(sequence);
            frames.push(findTileIndex(spriteSrc));
            controls.scrubberMax(frames.length - 1);
            animationEditor.trigger('updateLastFrameSequence', [sequence]);
            _results.push(animationEditor.trigger('enableSave'));
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
          if (frames.length) {
            pushSequence(frames.copy());
            return clearFrames();
          }
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
          controls.scrubberMax(controls.scrubberMax() - 1);
          animationEditor.trigger('removeFrame', [frameIndex]);
          if (frames.length === 0) {
            return animationEditor.trigger('disableSave');
          }
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
      var animation, animationsEl, index, spritesEl, src, _i, _len, _ref;
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
        for (index in _ref) {
          src = _ref[index];
          spriteTemplate.tmpl({
            src: src
          }).appendTo(spritesEl);
        }
        return animationEditor.trigger('disableSave');
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
      animationEditor.trigger('updateAnimations');
      return updateUI();
    });
    $(document).bind('keydown', function(e) {
      var framesLength, index;
      if (!(e.which === 37 || e.which === 39)) {
        return;
      }
      index = currentAnimation.currentFrameIndex();
      framesLength = currentAnimation.frames.length;
      if (e.which === 37) {
        controls.scrubber((index - 1).mod(framesLength));
      }
      if (e.which === 39) {
        return controls.scrubber((index + 1).mod(framesLength));
      }
    });
    animationEditor.find('.sprites img').live({
      dblclick: function(e) {
        var $this;
        $this = $(this);
        (4).times(function() {
          return currentAnimation.addFrame($this.attr('src'));
        });
        return lastClickedSprite = $this;
      },
      mousedown: function(e) {
        var $this, currentIndex, lastIndex, sprite, sprites, _i, _len, _results;
        $this = $(this);
        sprites = [];
        if (e.shiftKey && lastClickedSprite) {
          lastIndex = lastClickedSprite.index();
          currentIndex = $this.index();
          if (currentIndex > lastIndex) {
            sprites = animationEditor.find('.sprites img').filter(function() {
              var imgIndex;
              imgIndex = $(this).index();
              return (lastIndex < imgIndex && imgIndex <= currentIndex);
            }).get();
          } else if (currentIndex <= lastIndex) {
            sprites = animationEditor.find('.sprites img').filter(function() {
              var imgIndex;
              imgIndex = $(this).index();
              return (currentIndex <= imgIndex && imgIndex < lastIndex);
            }).get().reverse();
          }
        } else {
          sprites.push($this);
        }
        lastClickedSprite = $this;
        _results = [];
        for (_i = 0, _len = sprites.length; _i < _len; _i++) {
          sprite = sprites[_i];
          _results.push(currentAnimation.addFrame($(sprite).attr('src')));
        }
        return _results;
      }
    });
    animationEditor.find('.left .sequence').live({
      mousedown: function() {
        var index;
        index = $(this).index();
        return currentAnimation.addSequenceToFrames(index);
      }
    });
    animationEditor.find('.frame_sprites img').live({
      mousedown: function() {
        var index;
        index = animationEditor.find('.frame_sprites img').index($(this));
        return controls.scrubber(index);
      }
    });
    animationEditor.find('.animations h4').live({
      mousedown: function() {
        var $this, index;
        $this = $(this);
        index = $this.index();
        currentAnimation = animations[index];
        $this.parent().children().removeClass('selected');
        $this.addClass('selected');
        animationEditor.trigger('loadAnimation', [index]);
        return animationEditor.trigger('updateCurrentAnimationTitle');
      }
    });
    animationEditor.find('.save_sequence').click(currentAnimation.createSequence);
    animationEditor.find('.fps input').change(function() {
      var newValue;
      newValue = $(this).val();
      controls.pause();
      controls.fps(newValue);
      return controls.play();
    });
    animationEditor.find('.player .animation_name').liveEdit().live({
      change: function() {
        var $this, prevValue, updatedStateName;
        $this = $(this);
        prevValue = $this.get(0).defaultValue;
        updatedStateName = $this.val();
        currentAnimation.name(updatedStateName);
        return animationEditor.find('.animations h4').filter(function() {
          return $(this).text() === prevValue;
        }).text(updatedStateName);
      }
    });
    animationEditor.dropImageReader(function(file, event) {
      var dimensions, name, src, tileHeight, tileWidth, _ref;
      if (event.target.readyState === FileReader.DONE) {
        src = event.target.result;
        name = file.fileName;
        _ref = name.match(/x(\d*)y(\d*)/) || [], dimensions = _ref[0], tileWidth = _ref[1], tileHeight = _ref[2];
        if (tileWidth && tileHeight) {
          return loadSpriteSheet(src, parseInt(tileWidth), parseInt(tileHeight), function(sprite) {
            return currentAnimation.addTile(sprite);
          });
        } else {
          return currentAnimation.addTile(src);
        }
      }
    });
    return $(document).bind('keydown', 'del backspace', function(e) {
      e.preventDefault();
      return currentAnimation.removeFrame(currentAnimation.currentFrameIndex());
    });
  };
}).call(this);
