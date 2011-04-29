/* DO NOT MODIFY. This file was compiled Fri, 29 Apr 2011 01:44:42 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.animation_editor.coffee
 */

(function() {
  $.fn.animationEditor = function(options) {
    var createPixelEditor, loadData, pause_animation, play_animation, play_next, save, saveData, stop_animation, update_active_animation;
    options = $.extend({
      speed: 110
    }, options);
    return this.each(function() {
      var active_animation, active_animation_sprites, animationEditor, animation_id, clear_frame_sprites, clear_preview, frame_selected_sprite, frame_sprites, frame_sprites_container, preview_dirty;
      animationEditor = $(this.get(0)).addClass("animation_editor");
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
      return clear_preview = function() {
        return animationEditor.find('.preview_box img').remove();
      };
    });
    if ($.fn.pixie) {
      createPixelEditor = function(options) {
        var animationEditor, pixelEditor, url;
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
      save = function(event, data) {
        var postData, successCallback;
        notify("Saving...");
        $('.pixie').remove();
        animationEditor.show();
        successCallback = function(data) {
          var new_sprite, sprite_copy;
          notify("Saved!");
          new_sprite = $('#load_sprite').tmpl({
            alt: data.sprite.title,
            id: data.sprite.id,
            title: data.sprite.title,
            url: data.sprite.src
          });
          sprite_copy = new_sprite.clone();
          sprite_copy.appendTo('.user_sprites');
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
        return active_animation().parent().find('.speed').text($('input.speed').val());
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
      animationEditor.find('.animation').live('mousedown', function() {
        update_active_animation();
        animationEditor.find('.speed').val($(this).find('.speed').text());
        stop_animation();
        clear_frame_sprites();
        $(this).find('.sprites').children().clone().appendTo(frame_sprites_container());
        active_animation().removeClass('active');
        return $(this).find('.cover').addClass('active');
      });
      animationEditor.find('.new_animation').mousedown(function() {
        update_active_animation();
        stop_animation();
        active_animation().removeClass('active');
        clear_frame_sprites();
        $('#placeholder').tmpl().appendTo('.frame_sprites');
        return $('#create_animation').tmpl({
          name: "Animation " + ($('.animations .animation').length + 1)
        }).insertAfter($('.animations .animation').last());
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
        return animationEditor.find('.frame_sprites').sortable('refresh');
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
        var animation_id, preview_dirty, preview_sprites;
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
          var pixelEditor, target;
          target = $(event.target);
          if (!(target.is('.duplicate') || target.is('.x'))) {
            $(this).addClass('pixel_editor');
            if (!animationEditor.find('.pixie').length) {
              pixelEditor = createPixelEditor({
                width: 32,
                height: 32,
                image: $(this).find('img').attr('src').replace('http://images.pixie.strd6.com', '/s3')
              });
              pixelEditor.bind('save', save);
              $('#fullscreen').append(pixelEditor);
              animationEditor.hide();
              return {
                doSave: function() {
                  return pixelEditor.trigger('doSave');
                }
              };
            }
          }
        },
        mouseenter: function() {
          $('<div class="x" />').appendTo($(this));
          return $('<div class="duplicate" />').appendTo($(this));
        },
        mouseleave: function() {
          return $(this).find('.x, .duplicate').remove();
        }
      });
      animationEditor.mousedown(function() {
        return frame_selected_sprite().removeClass('selected');
      });
      $(document).bind("keydown", 'h', function(event) {
        var find_hit_circles, image_circles, image_src, selected_sprite;
        window.editorActive = true;
        event.preventDefault();
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
          Sprite.loadImage(image_src, image_circles);
          animationEditor.hide();
          return $('.hitcircle_editor').hitcircleEditor({
            width: image_src.width,
            height: image_src.height,
            sprite: image_src
          });
        }
      });
      $(document).bind("keydown", 'left', function(event) {
        var preview_dirty, selected_sprite;
        preview_dirty = true;
        event.preventDefault();
        selected_sprite = frame_selected_sprite();
        selected_sprite.find('.x, .duplicate').remove();
        if (selected_sprite.prev().length) {
          return selected_sprite.prev().before(selected_sprite);
        }
      });
      $(document).bind("keydown", 'right', function(event) {
        var preview_dirty, selected_sprite;
        preview_dirty = true;
        event.preventDefault();
        selected_sprite = frame_selected_sprite();
        selected_sprite.find('.x, .duplicate').remove();
        if (selected_sprite.next().length) {
          return selected_sprite.next().after(selected_sprite);
        }
      });
      animationEditor.find('.animations .name, .filename').liveEdit();
      animationEditor.find('.x').live('mousedown', function() {
        var parent;
        parent = $(this).parent();
        if (parent.next().length && !parent.next().find('.x').length && !parent.next().find('.duplicate').length) {
          parent.next().append('<div class= "x" />');
          parent.next().append('<div class= "duplicate" />');
        }
        return parent.fadeOut(150, function() {
          parent.remove();
          if (!frame_sprites().length) {
            return $('#placeholder').tmpl().appendTo('.frame_sprites');
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
      animationEditor.find(".save").click(function() {
        var postData;
        notify("Saving...");
        postData = {
          format: 'json',
          animation: {
            name: $(this).parent().find('.filename').text(),
            states: saveData().length,
            data_string: JSON.stringify(saveData())
          }
        };
        return $.post('/animations', postData, function(data) {
          var display_name, id, name;
          id = data.animation.id;
          name = postData.animation.name;
          display_name = (!name || name === "Title" ? "Animation " + id : name);
          return notify("Saved as <a href='/animations'>" + display_name + "</a>!");
        }, "json");
      });
      loadData = function(data) {
        if (data && data.animations.length) {
          $(data.animations).each(function(i, animation) {
            var animation_el, last_sprite_img;
            animation_el = $('#create_animation').tmpl({
              name: animation.name,
              speed: animation.speed
            }).insertBefore('nav.right .new_animation');
            $.each(animation.frames, function(i, frame) {
              active_animation().removeClass('active');
              return $('#load_sprite').tmpl({
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
          $('#create_animation').tmpl({
            name: "Animation 1",
            speed: $('.speed').val()
          }).insertBefore($('.new_animation'));
          return $('#placeholder').tmpl().appendTo('.frame_sprites');
        }
      };
      saveData = function() {
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
              name: $(this).prev().text(),
              speed: $(this).find('.speed').text(),
              frames: frames
            };
          }
          frames = [];
          return animation;
        }).get();
        return {
          version: "1.3",
          tileset: tiles,
          animations: animation_data
        };
      };
      return loadData(options.data);
    }
  };
}).call(this);
