/* DO NOT MODIFY. This file was compiled Fri, 04 Mar 2011 22:20:14 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/jquery.serialize_object.coffee
 */

(function() {
  jQuery.fn.serializeObject = function() {
    var arrayData, objectData;
    arrayData = this.serializeArray();
    objectData = {};
    $.each(arrayData, function() {
      var value;
      if (this.value != null) {
        value = this.value;
      } else {
        value = '';
      }
      if (objectData[this.name] != null) {
        if (!objectData[this.name].push) {
          objectData[this.name] = [objectData[this.name]];
        }
        return objectData[this.name].push(value);
      } else {
        return objectData[this.name] = value;
      }
    });
    return objectData;
  };
}).call(this);
