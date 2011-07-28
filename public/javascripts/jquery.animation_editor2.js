/* DO NOT MODIFY. This file was compiled Tue, 26 Jul 2011 19:18:07 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.animation_editor2.coffee
 */

(function() {
  $.fn.animationEditor = function() {
    var animationEditor, animationNumber, templates;
    animationNumber = 1;
    ({
      animation: {
        name: "Animation " + animationNumber,
        tileset: [],
        sequences: []
      },
      addAnimation: function() {
        return animationNumber += 1;
      }
    });
    animationEditor = $(this.get(0)).addClass("editor animation_editor");
    templates = $("#animation_editor_templates");
    return templates.find(".editor.template").tmpl().appendTo(animationEditor);
  };
}).call(this);
