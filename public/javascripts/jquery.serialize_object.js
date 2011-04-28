/* DO NOT MODIFY. This file was compiled Thu, 28 Apr 2011 03:39:04 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/jquery.serialize_object.coffee
 */

(function() {
  jQuery.fn.serializeObject = function() {
    var arrayData, objectData;
    arrayData = this.serializeArray();
    objectData = {};
    $.each(arrayData, function() {
      var name, object, paths, value;
      name = this.name;
      if (this.value != null) {
        value = this.value;
      } else {
        value = '';
      }
      paths = name.split("[").map(function(e, i) {
        if (i === 0) {
          return e;
        } else {
          return e.substr(0, e.length - 1);
        }
      });
      object = objectData;
      return paths.each(function(key, i) {
        if (key === paths.last()) {
          return object[key] = value;
        } else {
          return object = (object[key] || (object[key] = {}));
        }
      });
    });
    return objectData;
  };
}).call(this);
