/* DO NOT MODIFY. This file was compiled Sun, 08 May 2011 05:30:59 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.animation_editor.coffee
 */

(function() {
  $.fn.animationEditor = function(options) {
    var active_animation, active_animation_sprites, animationCount, animationEditor, animation_id, clear_frame_sprites, clear_preview, createHitcircleEditor, createPixelEditor, editFrameCircles, frame_selected_sprite, frame_sprites, frame_sprites_container, loadData, pause_animation, pixelEditFrame, play_animation, play_next, preview_dirty, save, stop_animation, templates, update_active_animation;
    options = $.extend({
      speed: 110
    }, options);
    animationCount = 1;
    animationEditor = $(this.get(0)).addClass("animation_editor");
    templates = $("#animation_editor_templates");
    templates.find(".editor.template").tmpl().appendTo(animationEditor);
    animationEditor.find('input.speed').val(options.speed);
    animationEditor.mousedown(function() {
      return window.currentComponent = animationEditor;
    });
    animation_id = null;
    preview_dirty = false;
    clear_frame_sprites = function() {
      return frame_sprites().remove();
    };
    frame_sprites = function() {
      return frame_sprites_container().children();
    };
    frame_sprites_container = function() {
      return animationEditor.find('.frame_sprites');
    };
    frame_selected_sprite = function() {
      return animationEditor.find('.frame_sprites .sprite_container.selected');
    };
    active_animation = function() {
      return animationEditor.find('.animations .animation .active');
    };
    active_animation_sprites = function() {
      return active_animation().parent().find('.sprites');
    };
    clear_preview = function() {
      return animationEditor.find('.preview_box img').remove();
    };
    if ($.fn.hitcircleEditor) {
      createHitcircleEditor = function(options) {
        var hitcircleEditor;
        animationEditor = options.animationEditor;
        hitcircleEditor = $('<div />').hitcircleEditor({
          width: 640,
          height: 480,
          animationEditor: options.animationEditor,
          sprite: options.sprite,
          hitcircles: options.hitcircles
        });
        animationEditor.hide().after(hitcircleEditor);
        window.currentComponent = hitcircleEditor;
        return hitcircleEditor;
      };
    }
    if ($.fn.pixie) {
      createPixelEditor = function(options) {
        var pixelEditor, url;
        url = options.url;
        animationEditor = options.animationEditor;
        pixelEditor = $('<div />').pixie({
          width: options.width,
          height: options.height,
          initializer: function(canvas) {
            if (url) {
              canvas.fromDataURL(url);
            }
            canvas.addAction({
              name: "Save Frame",
              icon: "/images/icons/database_save.png",
              perform: function(canvas) {
                pixelEditor.trigger('save', canvas.toDataURL());
                pixelEditor.remove();
                return animationEditor.show();
              },
              undoable: false
            });
            return canvas.addAction({
              name: "Back to Animation",
              icon: "/images/icons/arrow_left.png",
              perform: function(canvas) {
                pixelEditor.remove();
                return animationEditor.show();
              },
              undoable: false
            });
          }
        });
        animationEditor.hide().after(pixelEditor);
        window.currentComponent = pixelEditor;
        return pixelEditor;
      };
    }
    pixelEditFrame = function(selectedFrame) {
      var imgSource, pixelEditor;
      if (createPixelEditor) {
        imgSource = selectedFrame.attr('src');
        pixelEditor = createPixelEditor({
          width: selectedFrame.get(0).width,
          height: selectedFrame.get(0).height,
          animationEditor: animationEditor,
          url: imgSource.replace('http://images.pixie.strd6.com', '/s3')
        });
        return pixelEditor.bind('save', save);
      }
    };
    editFrameCircles = function(sprite, hitcircles) {
      var hitcircleEditor, imgSource;
      if (createHitcircleEditor) {
        imgSource = sprite.find('img').attr('src');
        return hitcircleEditor = createHitcircleEditor({
          width: 640,
          height: 480,
          animationEditor: animationEditor,
          sprite: imgSource,
          hitcircles: hitcircles
        });
      }
    };
    save = function(event, data) {
      var postData, successCallback;
      notify("Saving...");
      $('.pixie').remove();
      animationEditor.show();
      successCallback = function(data) {
        var new_sprite, sprite_copy;
        notify("Saved!");
        new_sprite = templates.find('.load_sprite').tmpl({
          alt: data.sprite.title,
          id: data.sprite.id,
          title: data.sprite.title,
          url: data.sprite.src
        });
        sprite_copy = new_sprite.clone();
        sprite_copy.appendTo(animationEditor.find('.user_sprites'));
        animationEditor.find(".frame_sprites .sprite_container.pixel_editor").before(sprite_copy).remove();
        return animationEditor.find('.animations .animation .cover.active img').before(new_sprite.find('img')).remove();
      };
      if (data) {
        postData = $.extend({
          format: 'json'
        }, data);
        return $.post('/sprites', postData, successCallback);
      }
    };
    update_active_animation = function() {
      active_animation_sprites().parent().find('.sprites').children().remove();
      frame_sprites().clone().appendTo(active_animation_sprites());
      active_animation().parent().find('.complete').text(animationEditor.find('.goto option:selected').val());
      return active_animation().parent().find('.speed').text(animationEditor.find('input.speed').val());
    };
    animationEditor.find(".frame_sprites").dropImageReader(function(file, event) {
      var img, sprite_container;
      if (event.target.readyState === FileReader.DONE) {
        sprite_container = $("<div class='sprite_container'></div>");
        img = $("<img/>", {
          alt: file.name,
          src: event.target.result,
          title: file.name
        });
        img.attr('data-hit_circles', JSON.stringify({
          circles: []
        }));
        sprite_container.append(img);
        animationEditor.find('.frame_sprites .demo, .frame_sprites p').remove();
        return $(this).append(sprite_container);
      }
    });
    animationEditor.find('.animation').live({
      mousedown: function() {
        update_active_animation();
        animationEditor.find('.speed').val($(this).find('.speed').text());
        animationEditor.find('.goto select').val($(this).find('.complete').text());
        stop_animation();
        clear_frame_sprites();
        $(this).find('.sprites').children().clone().appendTo(frame_sprites_container());
        active_animation().removeClass('active');
        $(this).find('.cover').addClass('active');
        if ($(this).find('.cover').hasClass('locked')) {
          return animationEditor.find('.lock').css('opacity', 1);
        } else {
          return animationEditor.find('.lock').css('opacity', 0.5);
        }
      },
      mouseenter: function() {
        if (animationEditor.find('.animations .animation').length > 1) {
          return $(this).find('.cover').append('<div class="x" />');
        }
      },
      mouseleave: function() {
        return $(this).find('.x').remove();
      }
    });
    animationEditor.find('.animation .x').live({
      mousedown: function() {
        var animation;
        animation = $(this).parent().parent();
        animationEditor.find(".goto option[value='" + (animation.prev().text()) + "']").remove();
        animation.prev().fadeOut(150, function() {
          return animation.prev().remove();
        });
        return animation.fadeOut(150, function() {
          return animation.remove();
        });
      }
    });
    animationEditor.find('.lock').tipsy({
      delayIn: 500,
      delayOut: 500,
      fade: 50,
      gravity: 'sw'
    }).live({
      mousedown: function() {
        var $this, animation;
        $this = $(this);
        animation = active_animation();
        animation.toggleClass('locked');
        if (animation.hasClass('locked')) {
          return $this.css('opacity', 1);
        } else {
          return $this.css('opacity', 0.5);
        }
      }
    });
    animationEditor.find('.new_animation').mousedown(function() {
      var animation, animation_name;
      update_active_animation();
      stop_animation();
      active_animation().removeClass('active');
      clear_frame_sprites();
      templates.find('.placeholder').tmpl().appendTo('.frame_sprites');
      animation_name = "Animation " + ++animationCount;
      animation = templates.find('.create_animation').tmpl({
        name: animation_name,
        complete: animation_name
      });
      animation.insertBefore(animationEditor.find('.new_animation'));
      animationEditor.find('.goto select').append("<option value='" + animation_name + "'>" + animation_name + "</option>");
      animationEditor.find('.goto select').val(animation_name);
      return animation.mousedown();
    });
    animationEditor.find('.frame_sprites').sortable({
      axis: "x",
      out: function() {
        return $(this).removeClass('highlight');
      },
      over: function() {
        $(this).addClass('highlight');
        return animationEditor.find('.frame_sprites .demo, .frame_sprites p').remove();
      },
      receive: function(event, ui) {
        $(this).removeClass('highlight');
        active_animation().children().remove();
        return active_animation().append(ui.item.find('img').clone());
      }
    });
    $(window).resize(function() {
      if (window.currentComponent === animationEditor) {
        return animationEditor.find('.frame_sprites').sortable('refresh');
      }
    });
    animationEditor.find('.user_sprites .sprite_container').draggable({
      addClasses: false,
      connectToSortable: '.frame_sprites',
      containment: 'window',
      helper: 'clone',
      opacity: 0.7,
      refreshPositions: true,
      zIndex: 200
    });
    animationEditor.find('.animation_editor img, .user_sprites .sprite_container').live('click mousedown mousemove', function(event) {
      return event.preventDefault();
    });
    play_next = function() {
      var active, active_index, length, preview_sprites;
      preview_sprites = animationEditor.find('.preview_box img');
      active = animationEditor.find('.preview_box img.active').removeClass('active');
      active_index = active.index();
      length = preview_sprites.length;
      return preview_sprites.eq((active_index + 1) % length).addClass('active');
    };
    play_animation = function() {
      var preview_sprites;
      clearInterval(animation_id);
      if ((animationEditor.find('.preview_box img').length !== animationEditor.find('.frame_sprites img').length) || preview_dirty) {
        preview_dirty = false;
        clear_preview();
        preview_sprites = animationEditor.find('.frame_sprites img').attr('style', '').clone();
        animationEditor.find('.preview_box .sprites').append(preview_sprites);
        preview_sprites.first().addClass('active');
      }
      return animation_id = setInterval(play_next, animationEditor.find('input.speed').val());
    };
    pause_animation = function() {
      return clearInterval(animation_id);
    };
    stop_animation = function() {
      clearInterval(animation_id);
      clear_preview();
      return animationEditor.find('.play').removeClass("pause");
    };
    animationEditor.find('.play').mousedown(function() {
      if ($(this).hasClass("pause")) {
        pause_animation();
      } else {
        play_animation();
      }
      if (!frame_sprites_container().find('.demo').length) {
        return $(this).toggleClass("pause");
      }
    });
    animationEditor.find('.stop').mousedown(function() {
      return stop_animation();
    });
    animationEditor.find('.frame_sprites .sprite_container').live({
      click: function() {
        return $(this).addClass('selected');
      },
      dblclick: function(event) {
        return pixelEditFrame($(this).find('img'));
      },
      mouseenter: function() {
        $('<div class="x" />').appendTo($(this));
        return $('<div class="duplicate" />').appendTo($(this));
      },
      mouseleave: function() {
        return $(this).find('.x, .duplicate').remove();
      }
    });
    animationEditor.find('.animations input').live({
      change: function() {
        var selected_name;
        animationEditor.find('.goto option').remove();
        selected_name = $(this).prev().val() === "" ? $(this).prev().text() : $(this).prev().val();
        return animationEditor.find('.animations .animation').each(function(i, animation) {
          var animation_name;
          animation_name = $(animation).prev().val() === "" ? $(animation).prev().text() : $(animation).prev().val();
          if (animation_name === selected_name) {
            animationEditor.find('.goto select option').removeAttr('selected');
            return animationEditor.find('.goto select').append("<option selected='selected' value='" + animation_name + "'>" + animation_name + "</option>");
          } else {
            return animationEditor.find('.goto select').append("<option value='" + animation_name + "'>" + animation_name + "</option>");
          }
        });
      }
    });
    animationEditor.find('.goto select').change(function() {
      var selected_value;
      selected_value = animationEditor.find('.goto options:selected').val();
      return active_animation().parent().find('.complete').text(selected_value);
    });
    animationEditor.mousedown(function() {
      return frame_selected_sprite().removeClass('selected');
    });
    $(document).bind("keydown", 'h', function(event) {
      var find_hit_circles, image_circles, image_src, selected_sprite;
      if (window.currentComponent === animationEditor) {
        window.editorActive = true;
        event.preventDefault();
      }
      find_hit_circles = function(sprite_el) {
        if ($(sprite_el).length && $(sprite_el).find('img[data-hit_circles]').length && sprite_el.find('img').attr('data-hit_circles').length) {
          return JSON.parse($(sprite_el).find('img').attr('data-hit_circles')).circles;
        }
        return null;
      };
      selected_sprite = frame_selected_sprite();
      if ($(selected_sprite).length) {
        image_src = $(selected_sprite).find('img').attr('src').replace('http://images.pixie.strd6.com', '/s3');
        image_circles = find_hit_circles(selected_sprite);
        return editFrameCircles(selected_sprite, image_circles);
      }
    });
    $(document).bind("keydown", 'left', function(event) {
      var selected_sprite;
      if (window.currentComponent === animationEditor) {
        preview_dirty = true;
        event.preventDefault();
        selected_sprite = frame_selected_sprite();
        selected_sprite.find('.x, .duplicate').remove();
        if (selected_sprite.prev().length) {
          return selected_sprite.prev().before(selected_sprite);
        }
      }
    });
    $(document).bind("keydown", 'right', function(event) {
      var selected_sprite;
      if (window.currentComponent === animationEditor) {
        preview_dirty = true;
        event.preventDefault();
        selected_sprite = frame_selected_sprite();
        selected_sprite.find('.x, .duplicate').remove();
        if (selected_sprite.next().length) {
          return selected_sprite.next().after(selected_sprite);
        }
      }
    });
    animationEditor.find('.animations .name, .filename').liveEdit();
    animationEditor.find('.frame_sprites .x').live('mousedown', function() {
      var parent;
      parent = $(this).parent();
      if (parent.next().length && !parent.next().find('.x').length && !parent.next().find('.duplicate').length) {
        parent.next().append('<div class= "x" />');
        parent.next().append('<div class= "duplicate" />');
      }
      return parent.fadeOut(150, function() {
        parent.remove();
        if (!frame_sprites().length) {
          return templates.find('.placeholder').tmpl().appendTo('.frame_sprites');
        }
      });
    });
    animationEditor.find('.duplicate').live('mousedown', function() {
      var newEl, parent;
      parent = $(this).parent();
      newEl = parent.clone();
      newEl.find('.x, .duplicate').remove();
      return newEl.insertAfter(parent);
    });
    animationEditor.find("button.save").click(function() {
      return typeof options.save === "function" ? options.save(saveData()) : void 0;
    });
    loadData = function(data) {
      if (data && data.animations.length) {
        animationEditor.find('.goto select').children().remove();
        $(data.animations).each(function(i, animation) {
          var animation_el, last_sprite_img;
          animationEditor.find('.goto select').append("<option value='" + animation.complete + "'>" + animation.complete + "</option>");
          animation_el = templates.find('.create_animation').tmpl({
            name: animation.name,
            speed: animation.speed,
            complete: animation.complete
          }).insertBefore('nav.right .new_animation');
          if (!animation.interruptible) {
            animation_el.find('.cover').addClass('locked');
          }
          active_animation().removeClass('active');
          $.each(animation.frames, function(i, frame) {
            return templates.find('.load_sprite').tmpl({
              url: data.tileset[frame].src,
              alt: data.tileset[frame].title,
              title: data.tileset[frame].title,
              id: data.tileset[frame].id,
              circles: JSON.stringify({
                circles: data.tileset[frame].circles
              })
            }).appendTo(animationEditor.find('.animations .name:contains("' + animation.name + '")').next().find('.sprites'));
          });
          last_sprite_img = animationEditor.find('.animations .name:contains("' + animation.name + '")').next().find('.sprites').children().last().find('img');
          return animationEditor.find('.animations .name:contains("' + animation.name + '")').next().find('.cover').append(last_sprite_img.clone());
        });
        animationEditor.find('.speed').val(active_animation().find('.speed').text());
        stop_animation();
        clear_frame_sprites();
        active_animation().find('.sprites').children().clone().appendTo(frame_sprites_container());
        return animationEditor.find('.animations .animation').first().mousedown();
      } else {
        templates.find('.create_animation').tmpl({
          name: "Animation 1",
          speed: animationEditor.find('.speed').val(),
          complete: "Animation 1"
        }).insertBefore(animationEditor.find('.new_animation'));
        return templates.find('.placeholder').tmpl().appendTo(animationEditor.find('.frame_sprites'));
      }
    };
    window.saveData = function() {
      var animation_data, frames, ids, tiles;
      update_active_animation();
      frames = [];
      ids = [];
      tiles = [];
      animationEditor.find('.animations .animation').find('.sprites img').each(function(i, img) {
        var circles, tile;
        circles = $(img).data('hit_circles') ? $(img).data('hit_circles').circles : [];
        tile = {
          id: $(img).data('id'),
          src: $(img).attr('src'),
          title: $(img).attr('title') || $(img).attr('alt'),
          circles: circles
        };
        if ($.inArray(tile.id, ids) === -1) {
          ids.push(tile.id);
          return tiles.push(tile);
        }
      });
      animation_data = animationEditor.find('.animations .animation').map(function() {
        var animation, frame_data;
        frame_data = $(this).find('.sprites img').each(function(i, img) {
          var tile_id;
          tile_id = $(this).data('id');
          return frames.push(ids.indexOf(tile_id));
        });
        if (frames.length) {
          animation = {
            complete: $(this).find('.complete').text(),
            name: $(this).prev().text(),
            interruptible: !$(this).find('.cover').hasClass('locked'),
            speed: $(this).find('.speed').text(),
            frames: frames
          };
        }
        frames = [];
        return animation;
      }).get();
      return {
        version: "1.4",
        name: animationEditor.find('nav.right .filename').text(),
        tileset: tiles,
        animations: animation_data
      };
    };
    loadData(options.data);
    return $.extend(animationEditor, {
      animationData: saveData
    });
  };
}).call(this);
