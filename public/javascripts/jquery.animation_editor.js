/* DO NOT MODIFY. This file was compiled Wed, 17 Aug 2011 21:13:08 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.animation_editor.coffee
 */

(function() {
  $.fn.animationEditor = function(options) {
    var Animation, Controls, addTile, animationEditor, animationNumber, animationTemplate, animations, controls, createSequence, currentAnimation, editorTemplate, frameSpriteTemplate, lastClickedSprite, loadSpriteSheet, pushSequence, removeSequence, sequences, spriteTemplate, templates, tileIndex, tilemap, tileset;
    animationNumber = 1;
    tileIndex = 0;
    lastClickedSprite = null;
    tileset = {};
    tilemap = {};
    sequences = [];
    animationEditor = $(this.get(0)).addClass("editor animation_editor");
    templates = $("#animation_editor_templates");
    editorTemplate = templates.find('.editor.template');
    animationTemplate = templates.find('.animation');
    spriteTemplate = templates.find('.sprite');
    frameSpriteTemplate = templates.find('.frame_sprite');
    window.exportAnimationCSV = function() {
      var animation, frame, output, _i, _len;
      output = "";
      for (_i = 0, _len = animations.length; _i < _len; _i++) {
        animation = animations[_i];
        output = output + animation.name() + ": " + ((function() {
          var _j, _len2, _ref, _results;
          _ref = animation.frames;
          _results = [];
          for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
            frame = _ref[_j];
            _results.push(tilemap[frame]);
          }
          return _results;
        })()).join(",") + "\n";
      }
      return output;
    };
    window.exportAnimationJSON = function() {
      var animation, animationData, array, frame, sequenceData, tileId, tileSrc;
      animationData = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = animations.length; _i < _len; _i++) {
          animation = animations[_i];
          _results.push({
            frames: (function() {
              var _j, _len2, _ref, _results2;
              _ref = animation.frames;
              _results2 = [];
              for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
                frame = _ref[_j];
                _results2.push(tilemap[frame]);
              }
              return _results2;
            })(),
            name: animation.name()
          });
        }
        return _results;
      })();
      sequenceData = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = sequences.length; _i < _len; _i++) {
          array = sequences[_i];
          _results.push((function() {
            var _j, _len2, _results2;
            _results2 = [];
            for (_j = 0, _len2 = array.length; _j < _len2; _j++) {
              frame = array[_j];
              _results2.push(tilemap[frame]);
            }
            return _results2;
          })());
        }
        return _results;
      })();
      return JSON.stringify({
        sequences: sequenceData,
        tileset: (function() {
          var _results;
          _results = [];
          for (tileId in tileset) {
            tileSrc = tileset[tileId];
            _results.push(tileSrc);
          }
          return _results;
        })(),
        animations: animationData
      });
    };
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
    addTile = function(src) {
      var id, spritesEl;
      id = Math.uuid(32, 16);
      tileset[id] = src;
      tilemap[id] = tileIndex;
      tileIndex += 1;
      spritesEl = animationEditor.find('.sprites');
      return spriteTemplate.tmpl({
        src: src
      }).appendTo(spritesEl);
    };
    removeSequence = function(sequenceIndex) {
      sequences.splice(sequenceIndex, 1);
      return animationEditor.trigger('removeSequence', [sequenceIndex]);
    };
    animationEditor.bind({
      checkExportStatus: function() {
        var animation, framesEmpty, _i, _len;
        framesEmpty = true;
        for (_i = 0, _len = animations.length; _i < _len; _i++) {
          animation = animations[_i];
          if (animation.frames.length) {
            framesEmpty = false;
          }
        }
        console.log(framesEmpty);
        $(this).find('.player button:not(.new_animation)').removeAttr('disabled').attr('title', 'Export animation');
        if (framesEmpty) {
          return $(this).find('.player button:not(.new_animation)').attr({
            disabled: true,
            title: 'Add frames to export'
          });
        }
      },
      clearFrames: function() {
        return $(this).find('.frame_sprites').children().remove();
      },
      currentAnimationTitle: function(e, title) {
        return $(this).find('.player .animation_name').text(title);
      },
      disableSave: function() {
        return $(this).find('.bottom .module_header > button').attr({
          disabled: true,
          title: 'Add frames to save'
        });
      },
      enableSave: function() {
        return $(this).find('.bottom .module_header > button').removeAttr('disabled').attr('title', 'Save frames');
      },
      init: function() {
        var animation, animationsEl, index, spritesEl, src, _i, _len;
        animationsEl = animationEditor.find('.animations');
        animationsEl.children().remove();
        spritesEl = animationEditor.find('.sprites');
        for (_i = 0, _len = animations.length; _i < _len; _i++) {
          animation = animations[_i];
          animationTemplate.tmpl({
            stateId: animation.stateId,
            name: animation.name()
          }).appendTo(animationsEl);
        }
        if (spritesEl.find('img').length === 0) {
          for (index in tileset) {
            src = tileset[index];
            spriteTemplate.tmpl({
              src: src
            }).appendTo(spritesEl);
          }
          animationEditor.trigger('disableSave');
          return animationEditor.trigger('checkExportStatus');
        }
      },
      removeFrame: function(e, frameIndex) {
        var parent;
        if ($(this).find('.frame_sprites img').eq(frameIndex).parent().hasClass('frame_sprite')) {
          $(this).find('.frame_sprites img').eq(frameIndex).parent().remove();
        }
        if ($(this).find('.frame_sprites img').eq(frameIndex).parent().hasClass('sequence')) {
          parent = $(this).find('.frame_sprites img').eq(frameIndex).parent();
          $(this).find('.frame_sprites img').eq(frameIndex).remove();
          if (parent.children().length === 0) {
            return parent.remove();
          }
        }
      },
      removeSequence: function(e, sequenceIndex) {
        return $(this).find('.sequences .sequence').eq(sequenceIndex).remove();
      },
      loadCurrentAnimation: function() {
        var $this;
        $this = $(this);
        $this.trigger('clearFrames');
        $this.trigger('currentAnimationTitle', [currentAnimation.name()]);
        $this.find('.player img').removeAttr('src');
        return currentAnimation.load();
      },
      updateFrame: function(e, index) {
        var frameSprites, spriteSrc;
        frameSprites = $(this).find('.frame_sprites');
        spriteSrc = tileset[index];
        return frameSpriteTemplate.tmpl({
          src: spriteSrc
        }).appendTo(frameSprites);
      },
      updateLastFrame: function() {
        var frameSprites, spriteSrc;
        frameSprites = $(this).find('.frame_sprites');
        spriteSrc = tileset[currentAnimation.frames.last()];
        return frameSpriteTemplate.tmpl({
          src: spriteSrc
        }).appendTo(frameSprites);
      },
      updateLastFrameSequence: function(e, sequence) {
        var frameSprites;
        frameSprites = $(this).find('.frame_sprites');
        return sequence.appendTo(frameSprites);
      },
      updateLastSequence: function() {
        var sequence, sequenceFrameArray, sequencesEl, spriteIndex, spriteSrc, _i, _len;
        sequencesEl = $(this).find('.sequences');
        sequenceFrameArray = sequences.last();
        sequence = $('<div class="sequence" />').appendTo(sequencesEl);
        for (_i = 0, _len = sequenceFrameArray.length; _i < _len; _i++) {
          spriteIndex = sequenceFrameArray[_i];
          spriteSrc = tileset[spriteIndex];
          spriteTemplate.tmpl({
            src: spriteSrc
          }).appendTo(sequence);
        }
        return sequence.appendTo(sequencesEl);
      }
    });
    pushSequence = function(frameArray) {
      sequences.push(frameArray);
      return animationEditor.trigger('updateLastSequence');
    };
    createSequence = function() {
      if (currentAnimation.frames.length) {
        pushSequence(currentAnimation.frames.copy());
        return currentAnimation.clearFrames();
      }
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
          intervalId = null;
          return self;
        },
        play: function() {
          if (currentAnimation.frames.length > 0) {
            if (!intervalId) {
              intervalId = setInterval(nextFrame, 1000 / self.fps());
            }
            changePlayIcon('pause');
          }
          return self;
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
      var currentFrameIndex, findTileIndex, frames, name, self, stateId;
      frames = [];
      currentFrameIndex = 0;
      stateId = Math.uuid(32, 16);
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
      self = {
        addFrame: function(imgSrc) {
          var event, _i, _len, _ref, _results;
          frames.push(findTileIndex(imgSrc));
          controls.scrubberMax(frames.length - 1);
          _ref = ['checkExportStatus', 'enableSave', 'updateLastFrame'];
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            event = _ref[_i];
            _results.push(animationEditor.trigger(event));
          }
          return _results;
        },
        addSequenceToFrames: function(index) {
          var sequence, spriteIndex, spriteSrc, _i, _len, _ref;
          sequence = $('<div class="sequence" />');
          _ref = sequences[index];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            spriteIndex = _ref[_i];
            spriteSrc = tileset[spriteIndex];
            spriteTemplate.tmpl({
              src: spriteSrc
            }).appendTo(sequence);
            frames.push(findTileIndex(spriteSrc));
            controls.scrubberMax(frames.length - 1);
          }
          animationEditor.trigger('updateLastFrameSequence', [sequence]);
          animationEditor.trigger('enableSave');
          return animationEditor.trigger('checkExportStatus');
        },
        clearFrames: function() {
          var event, _i, _len, _ref, _results;
          frames.clear();
          _ref = ['checkExportStatus', 'clearFrames', 'disableSave'];
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            event = _ref[_i];
            _results.push(animationEditor.trigger(event));
          }
          return _results;
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
        stateId: stateId,
        load: function() {
          var frameIndex, _i, _len;
          for (_i = 0, _len = frames.length; _i < _len; _i++) {
            frameIndex = frames[_i];
            animationEditor.trigger('updateFrame', [frameIndex]);
          }
          return controls.scrubberMax(frames.length - 1);
        },
        name: function(val) {
          if (val != null) {
            name = val;
            return self;
          } else {
            return name;
          }
        },
        removeFrame: function(frameIndex) {
          frames.splice(frameIndex, 1);
          controls.scrubberMax(controls.scrubberMax() - 1);
          animationEditor.trigger('removeFrame', [frameIndex]);
          if (frames.length === 0) {
            animationEditor.trigger('disableSave');
          }
          return animationEditor.trigger('checkExportStatus');
        },
        removeFrameSequence: function(sequenceIndex) {
          var frameImages, image, index, sequenceImages, _i, _len;
          sequenceImages = animationEditor.find('.frame_sprites .sequence').eq(sequenceIndex).children();
          frameImages = animationEditor.find('.frame_sprites img');
          for (_i = 0, _len = sequenceImages.length; _i < _len; _i++) {
            image = sequenceImages[_i];
            index = $(image).index(frameImages);
            self.removeFrame(index);
          }
          return animationEditor.trigger('removeFrameSequence', [sequenceIndex]);
        },
        updateSelected: function(frameIndex) {
          var player, tilesetIndex;
          tilesetIndex = frames[frameIndex];
          animationEditor.find('.frame_sprites img').removeClass('selected');
          player = $('.player img');
          if (frameIndex === -1) {
            return player.removeAttr('src');
          } else {
            player.attr('src', tileset[tilesetIndex]);
            return animationEditor.find('.frame_sprites img:not(.x)').eq(frameIndex).addClass('selected');
          }
        }
      };
      return self;
    };
    editorTemplate.tmpl().appendTo(animationEditor);
    controls = Controls();
    currentAnimation = Animation();
    animations = [currentAnimation];
    animationEditor.trigger('init');
    animationEditor.find('.state_name').addClass('selected');
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
      var event, _i, _len, _ref;
      animations.push(Animation());
      currentAnimation = animations.last();
      _ref = ['init', 'loadCurrentAnimation'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        event = _ref[_i];
        animationEditor.trigger(event);
      }
      return animationEditor.find('.animations .state_name:last').takeClass('selected');
    });
    $(document).bind('keydown', function(e) {
      var framesLength, index, keyMapping;
      if (!(e.which === 37 || e.which === 39)) {
        return;
      }
      index = currentAnimation.currentFrameIndex();
      framesLength = currentAnimation.frames.length;
      keyMapping = {
        "37": -1,
        "39": 1
      };
      return controls.scrubber((index + keyMapping[e.which]).mod(framesLength));
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
          lastClickedSprite = null;
        } else {
          sprites.push($this);
          lastClickedSprite = $this;
        }
        _results = [];
        for (_i = 0, _len = sprites.length; _i < _len; _i++) {
          sprite = sprites[_i];
          _results.push(currentAnimation.addFrame($(sprite).attr('src')));
        }
        return _results;
      }
    });
    animationEditor.find('.right .sequence').live({
      mousedown: function() {
        var index;
        index = $(this).index();
        return currentAnimation.addSequenceToFrames(index);
      }
    });
    animationEditor.find('.edit_sequences').mousedown(function() {
      var $this, img, text;
      $this = $(this);
      text = $this.text();
      $this.text(text === "Edit" ? "Done" : "Edit");
      if (text === "Edit") {
        img = $('<img />', {
          "class": 'x',
          src: '/images/x.png'
        });
        return $('.right .sequence').append(img);
      } else {
        return $('.right .x').remove();
      }
    });
    animationEditor.find('.edit_frames').mousedown(function() {
      var $this, img, text;
      $this = $(this);
      text = $this.text();
      $this.text(text === "Edit" ? "Done" : "Edit");
      if (text === "Edit") {
        img = $('<img />', {
          "class": 'x',
          src: '/images/x.png'
        });
        return $('.bottom .sequence, .bottom .frame_sprite').append(img);
      } else {
        return $('.bottom .x').remove();
      }
    });
    animationEditor.find('.right .x').live({
      mousedown: function(e) {
        e.stopPropagation();
        return removeSequence($(this).parent().index());
      }
    });
    animationEditor.find('.bottom .x').live({
      mousedown: function(e) {
        var parent;
        e.stopPropagation();
        parent = $(this).parent();
        if (parent.hasClass('sequence')) {
          currentAnimation.removeFrameSequence(parent.index());
        }
        if (parent.hasClass('frame_sprite')) {
          return currentAnimation.removeFrame(parent.index());
        }
      }
    });
    animationEditor.find('.frame_sprites img').live({
      mousedown: function() {
        var index;
        index = animationEditor.find('.frame_sprites img').index($(this));
        return controls.scrubber(index);
      }
    });
    animationEditor.find('.animations .state_name').live({
      mousedown: function() {
        var index;
        index = $(this).takeClass('selected').index();
        currentAnimation = animations[index];
        return animationEditor.trigger('loadCurrentAnimation');
      }
    });
    animationEditor.find('.save_sequence').click(function() {
      return createSequence();
    });
    animationEditor.find('.clear_frames').click(function() {
      currentAnimation.clearFrames();
      return controls.stop();
    });
    animationEditor.find('.fps input').change(function() {
      var newValue;
      newValue = $(this).val();
      return controls.pause().fps(newValue).play();
    });
    animationEditor.find('.player .state_name').liveEdit().live({
      change: function() {
        var $this, updatedStateName;
        $this = $(this);
        updatedStateName = $this.val();
        return currentAnimation.name(updatedStateName);
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
            return addTile(sprite);
          });
        } else {
          return addTile(src);
        }
      }
    });
    return $(document).bind('keydown', 'del backspace', function(e) {
      e.preventDefault();
      return currentAnimation.removeFrame(currentAnimation.currentFrameIndex());
    });
  };
}).call(this);
