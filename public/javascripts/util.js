/**
 * @returns The absolute value of the number.
 */
Number.prototype.abs = function() {
  return Math.abs(this);
};

/**
 * @returns The number truncated to the nearest integer of greater than or equal value.
 *
 * (4.9).ceil(); // => 5
 * (4.2).ceil(); // => 5
 * (-1.2).ceil(); // => -1
 */
Number.prototype.ceil = function() {
  return Math.ceil(this);
};

/**
 * Returns a number whose value is limited to the given range.
 *
 * Example: limit the output of this computation to between 0 and 255
 * <pre>
 * (x * 255).clamp(0, 255)
 * </pre>
 *
 * @param {Number} min The lower boundary of the output range
 * @param {Number} max The upper boundary of the output range
 * @returns A number in the range [min, max]
 * @type Number
 */
Number.prototype.clamp = function(min, max) {
  return Math.min(Math.max(this, min), max);
};

/**
 * @returns The number truncated to the nearest integer of less than or equal value.
 *
 * (4.9).floor(); // => 4
 * (4.2).floor(); // => 4
 * (-1.2).floor(); // => -2
 */
Number.prototype.floor = function() {
  return Math.floor(this);
};

/**
 * A mod method useful for array wrapping. The range of the function is
 * constrained to remain in bounds of array indices.
 *
 * <pre>
 * Example:
 * (-1).mod(5) === 4
 * </pre>
 *
 * @param {Number} base
 * @returns An integer between 0 and (base - 1) if base is positive.
 * @type Number
 */
Number.prototype.mod = function(base) {
  var result = this % base;

  if(result < 0 && base > 0) {
    result += base;
  }

  return result;
};

/**
 * @returns The number rounded to the nearest integer.
 *
 * (4.5).round(); // => 5
 * (4.4).round(); // => 4
 */
Number.prototype.round = function() {
  return Math.round(this);
};

/**
 * @returns The sign of this number, 0 if the number is 0.
 */
Number.prototype.sign = function() {
  if(this > 0) {
    return 1;
  } else if (this < 0) {
    return -1;
  } else {
    return 0;
  }
};

/**
 * Calls iterator the specified number of times, passing in the number of the
 * current iteration as a parameter: 0 on first call, 1 on the second call, etc.
 *
 * @param {Function} iterator The iterator takes a single parameter, the number
 * of the current iteration.
 * @param {Object} [context] The optional context parameter specifies an object
 * to treat as <code>this</code> in the iterator block.
 *
 * @returns The number of times the iterator was called.
 * @type Number
 */
Number.prototype.times = function(iterator, context) {
  for(var i = 0; i < this; i++) {
    iterator.call(context, i);
  }

  return i;
};

/**
 * Returns the the nearest grid resolution less than or equal to the number.
 *
 *   EX:
 *    (7).snap(8) => 0
 *    (4).snap(8) => 0
 *    (12).snap(8) => 8
 *
 * @param {Number} resolution The grid resolution to snap to.
 * @returns The nearest multiple of resolution lower than the number.
 * @type Number
 */
Number.prototype.snap = function(resolution) {
  return (this / resolution).floor() * resolution;
};

Number.prototype.toColorPart = function() {
  var s = parseInt(this.clamp(0, 255), 10).toString(16);
  if(s.length == 1) {
    s = '0' + s;
  }

  return s;
};

Number.prototype.approach = function(target, maxDelta) {
  return (target - this).clamp(-maxDelta, maxDelta) + this;
};

Number.prototype.approachByRatio = function(target, ratio) {
  return this.approach(target, this * ratio);
};

Number.prototype.approachRotation = function(target, maxDelta) {
  var twoPi = 2 * Math.PI;

  while(target > this + Math.PI) {
    target -= twoPi
  }

  while(target < this - Math.PI) {
    target += twoPi
  }

  return (target - this).clamp(-maxDelta, maxDelta) + this;
};

/**
 * @returns This number constrained between -PI and PI.
 */
Number.prototype.constrainRotation = function() {
  var twoPi = 2 * Math.PI;

  var target = this;

  while(target > Math.PI) {
    target -= twoPi
  }

  while(target < -Math.PI) {
    target += twoPi
  }

  return target;
};

Number.prototype.d = function(sides) {
  var sum = 0;

  this.times(function() {
    sum += rand(sides) + 1;
  });

  return sum;
};


/**
* Creates and returns a copy of the array. The copy contains
* the same objects.
*
* @type Array
* @returns A new array that is a copy of the array
*/
Array.prototype.copy = function() {
  return this.concat();
};

/**
* Invoke the named method on each element in the array
* and return a new array containing the results of the invocation.
*
<code><pre>
  [1.1, 2.2, 3.3, 4.4].invoke("floor")
  => [1, 2, 3, 4]

  ['hello', 'world', 'cool!'].invoke('substring', 0, 3)
  => ['hel', 'wor', 'coo']
</pre></code>
*
* @param {String} method The name of the method to invoke.
* @param [arg...] Optional arguments to pass to the method being invoked.
*
* @type Array
* @returns A new array containing the results of invoking the
* named method on each element.
*/
Array.prototype.invoke = function(method) {
  var args = Array.prototype.slice.call(arguments, 1);

  return this.map(function(element) {
    return element[method].apply(element, args);
  });
};

/**
* Randomly select an element from the array.
*
* @returns A random element from an array
*/
Array.prototype.rand = function() {
  return this[rand(this.length)];
};

/**
* Remove the first occurance of the given object from the array if it is
* present.
*
* @param {Object} object The object to remove from the array if present.
* @returns The removed object if present otherwise undefined.
*/
Array.prototype.remove = function(object) {
  var index = this.indexOf(object);
  if(index >= 0) {
    return this.splice(index, 1)[0];
  } else {
    return undefined;
  }
};

/**
 * Call the given iterator once for each element in the array,
 * passing in the element as the first argument, the index of
 * the element as the second argument, and this array as the
 * third argument.
 *
 * @param {Function} iterator Function to be called once for
 * each element in the array.
 * @param {Object} [context] Optional context parameter to be
 * used as `this` when calling the iterator function.
 *
 * @returns `this` to enable method chaining.
 */
Array.prototype.each = function(iterator, context) {
  if(this.forEach) {
    this.forEach(iterator, context);
  } else {
    var len = this.length;
    for(var i = 0; i < len; i++) {
      iterator.call(context, this[i], i, this);
    }
  }

  return this;
};

Array.prototype.eachSlice = function(n, iterator, context) {
  var len = Math.floor(this.length / n);

  for(var i = 0; i < len; i++) {
    iterator.call(context, this.slice(i*n, (i+1)*n), i*n, this);
  }

  return this;
};

/**
 * Returns a new array with the elements all shuffled up.
 *
 * @returns A new array that is randomly shuffled.
 * @type Array
 */
Array.prototype.shuffle = function() {
  var shuffledArray = [];

  this.each(function(element) {
    shuffledArray.splice(rand(shuffledArray.length + 1), 0, element);
  });

  return shuffledArray;
};

/**
 * Returns the first element of the array, undefined if the array is empty.
 *
 * @returns The first element, or undefined if the array is empty.
 * @type Object
 */
Array.prototype.first = function() {
  return this[0];
};

/**
 * Returns the last element of the array, undefined if the array is empty.
 *
 * @returns The last element, or undefined if the array is empty.
 * @type Object
 */
Array.prototype.last = function() {
  return this[this.length - 1];
};

Array.prototype.wrap = function(start, length) {
  var end = start + length;
  var result = [];

  for(var i = start; i < end; i++) {
    result.push(this[i.mod(this.length)]);
  }

  return result;
};

/**
 * Partitions the elements into two groups: those for which the iterator returns
 * true, and those for which it returns false.
 * @param {Function} iterator
 * @param {Object} [context] Optional context parameter to be
 * used as `this` when calling the iterator function.
 *
 * @type Array
 * @returns An array in the form of [trueCollection, falseCollection]
 */
Array.prototype.partition = function(iterator, context) {
  var trueCollection = [];
  var falseCollection = [];

  this.each(function(element) {
    if(iterator.call(context, element)) {
      trueCollection.push(element);
    } else {
      falseCollection.push(element);
    }
  });

  return [trueCollection, falseCollection];
};

/**
 * Return the group of elements for which the iterator's return value is true.
 *
 * @param {Function} iterator The iterator receives each element in turn as
 * the first agument.
 * @param {Object} [context] Optional context parameter to be
 * used as `this` when calling the iterator function.
 *
 * @type Array
 * @returns An array containing the elements for which the iterator returned true.
 */
Array.prototype.select = function(iterator, context) {
  return this.partition(iterator, context)[0];
};

/**
 * Return the group of elements for which the iterator's return value is false.
 *
 * @param {Function} iterator The iterator receives each element in turn as
 * the first agument.
 * @param {Object} [context] Optional context parameter to be
 * used as `this` when calling the iterator function.
 *
 * @type Array
 * @returns An array containing the elements for which the iterator returned false.
 */
Array.prototype.reject = function(iterator, context) {
  return this.partition(iterator, context)[1];
};

Array.prototype.inject = function(initial, iterator) {
  this.each(function(element) {
    initial = iterator(initial, element);
  });

  return initial;
};

Array.prototype.sum = function() {
  return this.inject(0, function(sum, n) {
    return sum + n;
  });
};

Array.prototype.zip = function(arr) {
  return results = this.map(function(element, i) {
    return [element, arr[i]]
  });
};

String.prototype.capitalize = function () {
  return this.charAt(0).toUpperCase() + this.substring(1).toLowerCase();
}

Object.isArray = function (object) {
  return Object.prototype.toString.call(object) == '[object Array]';
}