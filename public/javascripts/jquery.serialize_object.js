/* DO NOT MODIFY. This file was compiled Fri, 04 Mar 2011 22:12:06 GMT from
 * /home/daniel/apps/pixie.strd6.com/app/coffeescripts/jquery.serialize_object.coffee
 */

(function() {
  jQuery.fn.serializeObject = function() {
    var arrayData, objectData;
    arrayData = this.serializeArray();
    objectData = {};
    $.each(arrayData, function() {
      if (objectData[this.name]) {
        if (!objectData[this.name].push) {
          objectData[this.name] = [objectData[this.name]];
        }
        return objectData[this.name].push(this.value || '');
      } else {
        return objectData[this.name] = this.value || '';
      }
    });
    return objectData;
  };
}).call(this);
