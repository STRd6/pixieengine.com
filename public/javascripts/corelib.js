;
var __slice = Array.prototype.slice;
Array.prototype.compact = function() {
  return this.select(function(element) {
    return element != null;
  });
};

/***
Creates and returns a copy of the array. The copy contains
the same objects.

@name copy
@methodOf Array#
@type Array
@returns A new array that is a copy of the array
*/
Array.prototype.copy = function() {
  return this.concat();
};
/***
Empties the array of its contents. It is modified in place.

@name clear
@methodOf Array#
@type Array
@returns this, now emptied.
*/
Array.prototype.clear = function() {
  this.length = 0;
  return this;
};
/***
Invoke the named method on each element in the array
and return a new array containing the results of the invocation.

<code><pre>
  [1.1, 2.2, 3.3, 4.4].invoke("floor")
  => [1, 2, 3, 4]

  ['hello', 'world', 'cool!'].invoke('substring', 0, 3)
  => ['hel', 'wor', 'coo']
</pre></code>

@param {String} method The name of the method to invoke.
@param [arg...] Optional arguments to pass to the method being invoked.

@name invoke
@methodOf Array#
@type Array
@returns A new array containing the results of invoking the
named method on each element.
*/
Array.prototype.invoke = function(method) {
  var args;
  args = __slice.call(arguments, 1);
  return this.map(function(element) {
    return element[method].apply(element, args);
  });
};
/***
Randomly select an element from the array.

@name rand
@methodOf Array#
@type Object
@returns A random element from an array
*/
Array.prototype.rand = function() {
  return this[rand(this.length)];
};
/***
Remove the first occurance of the given object from the array if it is
present.

@name remove
@methodOf Array#
@param {Object} object The object to remove from the array if present.
@returns The removed object if present otherwise undefined.
*/
Array.prototype.remove = function(object) {
  var index;
  index = this.indexOf(object);
  return index >= 0 ? this.splice(index, 1)[0] : undefined;
};
/***
Returns true if the element is present in the array.

@name include
@methodOf Array#
@param {Object} element The element to check if present.
@returns true if the element is in the array, false otherwise.
@type Boolean
*/
Array.prototype.include = function(element) {
  return this.indexOf(element) !== -1;
};
/***
Call the given iterator once for each element in the array,
passing in the element as the first argument, the index of
the element as the second argument, and this array as the
third argument.

@name each
@methodOf Array#
@param {Function} iterator Function to be called once for
each element in the array.
@param {Object} [context] Optional context parameter to be
used as `this` when calling the iterator function.

@type Array
@returns this to enable method chaining.
*/
Array.prototype.each = function(iterator, context) {
  var _len, _ref, element, i;
  if (this.forEach) {
    this.forEach(iterator, context);
  } else {
    _ref = this;
    for (i = 0, _len = _ref.length; i < _len; i++) {
      element = _ref[i];
      iterator.call(context, element, i, this);
    }
  }
  return this;
};
/***
Call the given iterator once for each element in the array,
passing in the given object as the first argument and the element
as the second argument. Additional arguments are passed similar to
<code>each</code>

@see Array#each

@name eachWithObject
@methodOf Array#

@param {Object} object The number of elements in each group.
@param {Function} iterator Function to be called once for
each element in the array.
@param {Object} [context] Optional context parameter to be
used as `this` when calling the iterator function.

@returns this
@type Array
*/
Array.prototype.eachWithObject = function(object, iterator, context) {
  this.each(function(element, i, self) {
    return iterator.call(context, element, object, i, self);
  });
  return object;
};
/***
Call the given iterator once for each group of elements in the array,
passing in the elements in groups of n. Additional argumens are
passed as in <code>each</each>.

@see Array#each

@name eachSlice
@methodOf Array#

@param {Number} n The number of elements in each group.
@param {Function} iterator Function to be called once for
each group of elements in the array.
@param {Object} [context] Optional context parameter to be
used as `this` when calling the iterator function.

@returns this
@type Array
*/
Array.prototype.eachSlice = function(n, iterator, context) {
  var i, len;
  if (n > 0) {
    len = (this.length / n).floor();
    i = -1;
    while (++i < len) {
      iterator.call(context, this.slice(i * n, (i + 1) * n), i * n, this);
    }
  }
  return this;
};
/***
Returns a new array with the elements all shuffled up.

@name shuffle
@methodOf Array#

@returns A new array that is randomly shuffled.
@type Array
*/
Array.prototype.shuffle = function() {
  var shuffledArray;
  shuffledArray = [];
  this.each(function(element) {
    return shuffledArray.splice(rand(shuffledArray.length + 1), 0, element);
  });
  return shuffledArray;
};
/***
Returns the first element of the array, undefined if the array is empty.

@name first
@methodOf Array#

@returns The first element, or undefined if the array is empty.
@type Object
*/
Array.prototype.first = function() {
  return this[0];
};
/***
Returns the last element of the array, undefined if the array is empty.

@name last
@methodOf Array#

@returns The last element, or undefined if the array is empty.
@type Object
*/
Array.prototype.last = function() {
  return this[this.length - 1];
};
/***
Returns an object containing the extremes of this array.
<pre>
[-1, 3, 0].extremes() # => {min: -1, max: 3}
</pre>

@name extremes
@methodOf Array#

@param {Function} [fn] An optional funtion used to evaluate
each element to calculate its value for determining extremes.
@returns {min: minElement, max: maxElement}
@type Object
*/
Array.prototype.extremes = function(fn) {
  var max, maxResult, min, minResult;
  fn || (fn = function(n) {
    return n;
  });
  min = (max = undefined);
  minResult = (maxResult = undefined);
  this.each(function(object) {
    var result;
    result = fn(object);
    if (typeof min !== "undefined" && min !== null) {
      if (result < minResult) {
        min = object;
        minResult = result;
      }
    } else {
      min = object;
      minResult = result;
    }
    if (typeof max !== "undefined" && max !== null) {
      if (result > maxResult) {
        max = object;
        return (maxResult = result);
      }
    } else {
      max = object;
      return (maxResult = result);
    }
  });
  return {
    min: min,
    max: max
  };
};
/***
Pretend the array is a circle and grab a new array containing length elements.
If length is not given return the element at start, again assuming the array
is a circle.

@name wrap
@methodOf Array#

@param {Number} start The index to start wrapping at, or the index of the
sole element to return if no length is given.
@param {Number} [length] Optional length determines how long result
array should be.
@returns The element at start mod array.length, or an array of length elements,
starting from start and wrapping.
@type Object or Array
*/
Array.prototype.wrap = function(start, length) {
  var end, i, result;
  if (typeof length !== "undefined" && length !== null) {
    end = start + length;
    i = start;
    result = [];
    while (i++ < end) {
      result.push(this[i.mod(this.length)]);
    }
    return result;
  } else {
    return this[start.mod(this.length)];
  }
};
/***
Partitions the elements into two groups: those for which the iterator returns
true, and those for which it returns false.

@name partition
@methodOf Array#

@param {Function} iterator
@param {Object} [context] Optional context parameter to be
used as `this` when calling the iterator function.

@type Array
@returns An array in the form of [trueCollection, falseCollection]
*/
Array.prototype.partition = function(iterator, context) {
  var falseCollection, trueCollection;
  trueCollection = [];
  falseCollection = [];
  this.each(function(element) {
    return iterator.call(context, element) ? trueCollection.push(element) : falseCollection.push(element);
  });
  return [trueCollection, falseCollection];
};
/***
Return the group of elements for which the return value of the iterator is true.

@name select
@methodOf Array#

@param {Function} iterator The iterator receives each element in turn as
the first agument.
@param {Object} [context] Optional context parameter to be
used as `this` when calling the iterator function.

@type Array
@returns An array containing the elements for which the iterator returned true.
*/
Array.prototype.select = function(iterator, context) {
  return this.partition(iterator, context)[0];
};
/***
Return the group of elements that are not in the passed in set.

@name without
@methodOf Array#

@param {Array} values List of elements to exclude.

@type Array
@returns An array containing the elements that are not passed in.
*/
Array.prototype.without = function(values) {
  return this.reject(function(element) {
    return values.include(element);
  });
};
/***
Return the group of elements for which the return value of the iterator is false.

@name reject
@methodOf Array#

@param {Function} iterator The iterator receives each element in turn as
the first agument.
@param {Object} [context] Optional context parameter to be
used as `this` when calling the iterator function.

@type Array
@returns An array containing the elements for which the iterator returned false.
*/
Array.prototype.reject = function(iterator, context) {
  return this.partition(iterator, context)[1];
};
/***
Combines all elements of the array by applying a binary operation.
for each element in the arra the iterator is passed an accumulator
value (memo) and the element.

@name inject
@methodOf Array#

@type Object
@returns The result of a
*/
Array.prototype.inject = function(initial, iterator) {
  this.each(function(element) {
    return (initial = iterator(initial, element));
  });
  return initial;
};
/***
Add all the elements in the array.

@name sum
@methodOf Array#

@type Number
@returns The sum of the elements in the array.
*/
Array.prototype.sum = function() {
  return this.inject(0, function(sum, n) {
    return sum + n;
  });
};
/***
Multiply all the elements in the array.

@name product
@methodOf Array#

@type Number
@returns The product of the elements in the array.
*/
Array.prototype.product = function() {
  return this.inject(1, function(product, n) {
    return product * n;
  });
};
Array.prototype.zip = function() {
  var args;
  args = __slice.call(arguments, 0);
  return this.map(function(element, index) {
    var output;
    output = args.map(function(arr) {
      return arr[index];
    });
    output.unshift(element);
    return output;
  });
};

var __slice = Array.prototype.slice;
var Core;
var __slice = Array.prototype.slice;
/***
The Core class is used to add extended functionality to objects without
extending the object class directly. Inherit from Core to gain its utility
methods.

@name Core
@constructor

@param {Object} I Instance variables
*/
/***
@name I
@memberOf Core#
*/
Core = function(I) {
  var self;
  I || (I = {});
  return (self = {
    I: I,
    /***
    Generates a public jQuery style getter / setter method for each
    String argument.

    @name attrAccessor
    @methodOf Core#
    */
    attrAccessor: function() {
      var attrNames;
      attrNames = __slice.call(arguments, 0);
      return attrNames.each(function(attrName) {
        return (self[attrName] = function(newValue) {
          if (typeof newValue !== "undefined" && newValue !== null) {
            I[attrName] = newValue;
            return self;
          } else {
            return I[attrName];
          }
        });
      });
    },
    /***
    Generates a public jQuery style getter method for each String argument.

    @name attrReader
    @methodOf Core#
    */
    attrReader: function() {
      var attrNames;
      attrNames = __slice.call(arguments, 0);
      return attrNames.each(function(attrName) {
        return (self[attrName] = function() {
          return I[attrName];
        });
      });
    },
    /***
    Extends this object with methods from the passed in object. `before` and
    `after` are special option names that glue functionality before or after
    existing methods.

    @name extend
    @methodOf Core#
    */
    extend: function(options) {
      var afterMethods, beforeMethods;
      afterMethods = options.after;
      beforeMethods = options.before;
      delete options.after;
      delete options.before;
      $.extend(self, options);
      if (beforeMethods) {
        $.each(beforeMethods, function(name, fn) {
          return (self[name] = self[name].withBefore(fn));
        });
      }
      if (afterMethods) {
        $.each(afterMethods, function(name, fn) {
          return (self[name] = self[name].withAfter(fn));
        });
      }
      return self;
    },
    /***
    Includes a module in this object.

    @name include
    @methodOf Core#

    @param {Module} Module the module to include. A module is a constructor
    that takes two parameters, I and self, and returns an object containing the
    public methods to extend the including object with.
    */
    include: function(Module) {
      return self.extend(Module(I, self));
    }
  });
};;
var DebugConsole;
DebugConsole = function() {
  var REPL, container, input, output, repl, runButton;
  REPL = function(input, output) {
    var print;
    print = function(message) {
      return output.append($("<li />", {
        text: message
      }));
    };
    return {
      run: function() {
        var code, result, source;
        source = input.val();
        try {
          code = CoffeeScript.compile(source, {
            noWrap: true
          });
          result = eval(code);
          print(" => " + (result));
          return input.val('');
        } catch (error) {
          return error.stack ? print(error.stack) : print(error.toString());
        }
      }
    };
  };
  container = $("<div />", {
    "class": "console"
  });
  input = $("<textarea />");
  output = $("<ul />");
  runButton = $("<button />", {
    text: "Run"
  });
  repl = REPL(input, output);
  container.append(output).append(input).append(runButton);
  return $(function() {
    runButton.click(function() {
      return repl.run();
    });
    return $("body").append(container);
  });
};;
Function.prototype.withBefore = function(interception) {
  var method;
  method = this;
  return function() {
    interception.apply(this, arguments);
    return method.apply(this, arguments);
  };
};
Function.prototype.withAfter = function(interception) {
  var method;
  method = this;
  return function() {
    var result;
    result = method.apply(this, arguments);
    interception.apply(this, arguments);
    return result;
  };
};;

var __slice = Array.prototype.slice, __hasProp = Object.prototype.hasOwnProperty;
/***
 * Merges properties from objects into target without overiding.
 * First come, first served.
 * @return target
*/
jQuery.extend({
  reverseMerge: function(target) {
    var _i, _j, _len, _ref, _ref2, name, object, objects;
    objects = __slice.call(arguments, 1);
    _ref = objects;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      _ref2 = object;
      for (name in _ref2) {
        if (!__hasProp.call(_ref2, name)) continue;
        _j = _ref2[name];
        if (!(target.hasOwnProperty(name))) {
          target[name] = object[name];
        }
      }
    }
    return target;
  }
});;
$(function() {
  var keyName;
  /***
  The global keydown property lets your query the status of keys.

  <pre>
  if keydown.left
    moveLeft()
  </pre>

  @name keydown
  @namespace
  */
  window.keydown = {};
  keyName = function(event) {
    return jQuery.hotkeys.specialKeys[event.which] || String.fromCharCode(event.which).toLowerCase();
  };
  $(document).bind("keydown", function(event) {
    return (keydown[keyName(event)] = true);
  });
  return $(document).bind("keyup", function(event) {
    return (keydown[keyName(event)] = false);
  });
});;
$(function() {
  return ["log", "info", "warn", "error"].each(function(name) {
    return typeof console !== "undefined" ? (window[name] = function(message) {
      return console[name] ? console[name](message) : null;
    }) : (window[name] = $.noop);
  });
});;
/***
* Matrix.js v1.3.0pre
*
* Copyright (c) 2010 STRd6
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*
* Loosely based on flash:
* http://www.adobe.com/livedocs/flash/9.0/ActionScriptLangRefV3/flash/geom/Matrix.html
*/
(function() {
  var Matrix, Point;
  /***
   * Create a new point with given x and y coordinates. If no arguments are given
   * defaults to (0, 0).
   * @name Point
   * @param {Number} [x]
   * @param {Number} [y]
   * @constructor
  */
  Point = function(x, y) {
    return {
      /***
       * The x coordinate of this point.
       * @name x
       * @fieldOf Point#
      */
      x: x || 0,
      /***
       * The y coordinate of this point.
       * @name y
       * @fieldOf Point#
      */
      y: y || 0,
      /***
       * Adds a point to this one and returns the new point.
       * @name add
       * @methodOf Point#
       *
       * @param {Point} other The point to add this point to.
       * @returns A new point, the sum of both.
       * @type Point
      */
      add: function(other) {
        return Point(this.x + other.x, this.y + other.y);
      },
      /***
       * Subtracts a point to this one and returns the new point.
       * @name subtract
       * @methodOf Point#
       *
       * @param {Point} other The point to subtract from this point.
       * @returns A new point, this - other.
       * @type Point
      */
      subtract: function(other) {
        return Point(this.x - other.x, this.y - other.y);
      },
      /***
       * Scale this Point (Vector) by a constant amount.
       * @name scale
       * @methodOf Point#
       *
       * @param {Number} scalar The amount to scale this point by.
       * @returns A new point, this * scalar.
       * @type Point
      */
      scale: function(scalar) {
        return Point(this.x * scalar, this.y * scalar);
      },
      /***
       * Determine whether this point is equal to another point.
       * @name equal
       * @methodOf Point#
       *
       * @param {Point} other The point to check for equality.
       * @returns true if the other point has the same x, y coordinates, false otherwise.
       * @type Boolean
      */
      equal: function(other) {
        return this.x === other.x && this.y === other.y;
      },
      /***
       * Calculate the magnitude of this Point (Vector).
       * @name magnitude
       * @methodOf Point#
       *
       * @returns The magnitude of this point as if it were a vector from (0, 0) -> (x, y).
       * @type Number
      */
      magnitude: function() {
        return Point.distance(Point(0, 0), this);
      },
      /***
       * Calculate the dot product of this point and another point (Vector).
       * @name dot
       * @methodOf Point#
       *
       * @param {Point} other The point to dot with this point.
       * @returns The dot product of this point dot other as a scalar value.
       * @type Number
      */
      dot: function(other) {
        return this.x * other.x + this.y * other.y;
      },
      /***
       * Calculate the cross product of this point and another point (Vector).
       * Usually cross products are thought of as only applying to three dimensional vectors,
       * but z can be treated as zero. The result of this method is interpreted as the magnitude
       * of the vector result of the cross product between [x1, y1, 0] x [x2, y2, 0]
       * perpendicular to the xy plane.
       * @name cross
       * @methodOf Point#
       *
       * @param {Point} other The point to cross with this point.
       * @returns The cross product of this point with the other point as scalar value.
       * @type Number
      */
      cross: function(other) {
        return this.x * other.y - other.x * this.y;
      },
      /***
       * The norm of a vector is the unit vector pointing in the same direction. This method
       * treats the point as though it is a vector from the origin to (x, y).
       * @name norm
       * @methodOf Point#
       *
       * @returns The unit vector pointing in the same direction as this vector.
       * @type Point
      */
      norm: function() {
        return this.scale(1.0 / this.length());
      },
      /***
       * Computed the length of this point as though it were a vector from (0,0) to (x,y)
       * @name length
       * @methodOf Point#
       *
       * @returns The length of the vector from the origin to this point.
       * @type Number
      */
      length: function() {
        return Math.sqrt(this.dot(this));
      },
      /***
       * Computed the Euclidean between this point and another point.
       * @name distance
       * @methodOf Point#
       *
       * @param {Point} other The point to compute the distance to.
       * @returns The distance between this point and another point.
       * @type Number
      */
      distance: function(other) {
        return Point.distance(this, other);
      }
    };
  };
  /***
   * @param {Point} p1
   * @param {Point} p2
   * @type Number
   * @returns The Euclidean distance between two points.
  */
  Point.distance = function(p1, p2) {
    return Math.sqrt(Math.pow(p2.x - p1.x, 2) + Math.pow(p2.y - p1.y, 2));
  };
  /***
   * Construct a point on the unit circle for the given angle.
   *
   * @param {Number} angle The angle in radians
   * @type Point
   * @returns The point on the unit circle.
  */
  Point.fromAngle = function(angle) {
    return Point(Math.cos(angle), Math.sin(angle));
  };
  /***
   * If you have two dudes, one standing at point p1, and the other
   * standing at point p2, then this method will return the direction
   * that the dude standing at p1 will need to face to look at p2.
   * @param {Point} p1 The starting point.
   * @param {Point} p2 The ending point.
   * @returns The direction from p1 to p2 in radians.
  */
  Point.direction = function(p1, p2) {
    return Math.atan2(p2.y - p1.y, p2.x - p1.x);
  };
  /***
   * <pre>
   *  _        _
   * | a  c tx  |
   * | b  d ty  |
   * |_0  0  1 _|
   * </pre>
   * Creates a matrix for 2d affine transformations.
   *
   * concat, inverse, rotate, scale and translate return new matrices with the
   * transformations applied. The matrix is not modified in place.
   *
   * Returns the identity matrix when called with no arguments.
   * @name Matrix
   * @param {Number} [a]
   * @param {Number} [b]
   * @param {Number} [c]
   * @param {Number} [d]
   * @param {Number} [tx]
   * @param {Number} [ty]
   * @constructor
  */
  Matrix = function(a, b, c, d, tx, ty) {
    a = (typeof a !== "undefined" && a !== null) ? a : 1;
    d = (typeof d !== "undefined" && d !== null) ? d : 1;
    return {
      /***
       * @name a
       * @fieldOf Matrix#
      */
      a: a,
      /***
       * @name b
       * @fieldOf Matrix#
      */
      b: b || 0,
      /***
       * @name c
       * @fieldOf Matrix#
      */
      c: c || 0,
      /***
       * @name d
       * @fieldOf Matrix#
      */
      d: d,
      /***
       * @name tx
       * @fieldOf Matrix#
      */
      tx: tx || 0,
      /***
       * @name ty
       * @fieldOf Matrix#
      */
      ty: ty || 0,
      /***
       * Returns the result of this matrix multiplied by another matrix
       * combining the geometric effects of the two. In mathematical terms,
       * concatenating two matrixes is the same as combining them using matrix multiplication.
       * If this matrix is A and the matrix passed in is B, the resulting matrix is A x B
       * http://mathworld.wolfram.com/MatrixMultiplication.html
       * @name concat
       * @methodOf Matrix#
       *
       * @param {Matrix} matrix The matrix to multiply this matrix by.
       * @returns The result of the matrix multiplication, a new matrix.
       * @type Matrix
      */
      concat: function(matrix) {
        return Matrix(this.a * matrix.a + this.c * matrix.b, this.b * matrix.a + this.d * matrix.b, this.a * matrix.c + this.c * matrix.d, this.b * matrix.c + this.d * matrix.d, this.a * matrix.tx + this.c * matrix.ty + this.tx, this.b * matrix.tx + this.d * matrix.ty + this.ty);
      },
      /***
       * Given a point in the pretransform coordinate space, returns the coordinates of
       * that point after the transformation occurs. Unlike the standard transformation
       * applied using the transformPoint() method, the deltaTransformPoint() method
       * does not consider the translation parameters tx and ty.
       * @name deltaTransformPoint
       * @methodOf Matrix#
       * @see #transformPoint
       *
       * @return A new point transformed by this matrix ignoring tx and ty.
       * @type Point
      */
      deltaTransformPoint: function(point) {
        return Point(this.a * point.x + this.c * point.y, this.b * point.x + this.d * point.y);
      },
      /***
       * Returns the inverse of the matrix.
       * http://mathworld.wolfram.com/MatrixInverse.html
       * @name inverse
       * @methodOf Matrix#
       *
       * @returns A new matrix that is the inverse of this matrix.
       * @type Matrix
      */
      inverse: function() {
        var determinant;
        determinant = this.a * this.d - this.b * this.c;
        return Matrix(this.d / determinant, -this.b / determinant, -this.c / determinant, this.a / determinant, (this.c * this.ty - this.d * this.tx) / determinant, (this.b * this.tx - this.a * this.ty) / determinant);
      },
      /***
       * Returns a new matrix that corresponds this matrix multiplied by a
       * a rotation matrix.
       * @name rotate
       * @methodOf Matrix#
       * @see Matrix.rotation
       *
       * @param {Number} theta Amount to rotate in radians.
       * @param {Point} [aboutPoint] The point about which this rotation occurs. Defaults to (0,0).
       * @returns A new matrix, rotated by the specified amount.
       * @type Matrix
      */
      rotate: function(theta, aboutPoint) {
        return this.concat(Matrix.rotation(theta, aboutPoint));
      },
      /***
       * Returns a new matrix that corresponds this matrix multiplied by a
       * a scaling matrix.
       * @name scale
       * @methodOf Matrix#
       * @see Matrix.scale
       *
       * @param {Number} sx
       * @param {Number} [sy]
       * @param {Point} [aboutPoint] The point that remains fixed during the scaling
       * @type Matrix
      */
      scale: function(sx, sy, aboutPoint) {
        return this.concat(Matrix.scale(sx, sy, aboutPoint));
      },
      /***
       * Returns the result of applying the geometric transformation represented by the
       * Matrix object to the specified point.
       * @name transformPoint
       * @methodOf Matrix#
       * @see #deltaTransformPoint
       *
       * @returns A new point with the transformation applied.
       * @type Point
      */
      transformPoint: function(point) {
        return Point(this.a * point.x + this.c * point.y + this.tx, this.b * point.x + this.d * point.y + this.ty);
      },
      /***
       * Translates the matrix along the x and y axes, as specified by the tx and ty parameters.
       * @name translate
       * @methodOf Matrix#
       * @see Matrix.translation
       *
       * @param {Number} tx The translation along the x axis.
       * @param {Number} ty The translation along the y axis.
       * @returns A new matrix with the translation applied.
       * @type Matrix
      */
      translate: function(tx, ty) {
        return this.concat(Matrix.translation(tx, ty));
      }
    };
  };
  /***
   * Creates a matrix transformation that corresponds to the given rotation,
   * around (0,0) or the specified point.
   * @see Matrix#rotate
   *
   * @param {Number} theta Rotation in radians.
   * @param {Point} [aboutPoint] The point about which this rotation occurs. Defaults to (0,0).
   * @returns
   * @type Matrix
  */
  Matrix.rotation = function(theta, aboutPoint) {
    var rotationMatrix;
    rotationMatrix = Matrix(Math.cos(theta), Math.sin(theta), -Math.sin(theta), Math.cos(theta));
    if (typeof aboutPoint !== "undefined" && aboutPoint !== null) {
      rotationMatrix = Matrix.translation(aboutPoint.x, aboutPoint.y).concat(rotationMatrix).concat(Matrix.translation(-aboutPoint.x, -aboutPoint.y));
    }
    return rotationMatrix;
  };
  /***
   * Returns a matrix that corresponds to scaling by factors of sx, sy along
   * the x and y axis respectively.
   * If only one parameter is given the matrix is scaled uniformly along both axis.
   * If the optional aboutPoint parameter is given the scaling takes place
   * about the given point.
   * @see Matrix#scale
   *
   * @param {Number} sx The amount to scale by along the x axis or uniformly if no sy is given.
   * @param {Number} [sy] The amount to scale by along the y axis.
   * @param {Point} [aboutPoint] The point about which the scaling occurs. Defaults to (0,0).
   * @returns A matrix transformation representing scaling by sx and sy.
   * @type Matrix
  */
  Matrix.scale = function(sx, sy, aboutPoint) {
    var scaleMatrix;
    sy = sy || sx;
    scaleMatrix = Matrix(sx, 0, 0, sy);
    if (aboutPoint) {
      scaleMatrix = Matrix.translation(aboutPoint.x, aboutPoint.y).concat(scaleMatrix).concat(Matrix.translation(-aboutPoint.x, -aboutPoint.y));
    }
    return scaleMatrix;
  };
  /***
   * Returns a matrix that corresponds to a translation of tx, ty.
   * @see Matrix#translate
   *
   * @param {Number} tx The amount to translate in the x direction.
   * @param {Number} ty The amount to translate in the y direction.
   * @return A matrix transformation representing a translation by tx and ty.
   * @type Matrix
  */
  Matrix.translation = function(tx, ty) {
    return Matrix(1, 0, 0, 1, tx, ty);
  };
  /***
   * A constant representing the identity matrix.
   * @name IDENTITY
   * @fieldOf Matrix
  */
  Matrix.IDENTITY = Matrix();
  /***
   * A constant representing the horizontal flip transformation matrix.
   * @name HORIZONTAL_FLIP
   * @fieldOf Matrix
  */
  Matrix.HORIZONTAL_FLIP = Matrix(-1, 0, 0, 1);
  /***
   * A constant representing the vertical flip transformation matrix.
   * @name VERTICAL_FLIP
   * @fieldOf Matrix
  */
  Matrix.VERTICAL_FLIP = Matrix(1, 0, 0, -1);
  window["Point"] = Point;
  return (window["Matrix"] = Matrix);
})();;
window.Mouse = (function() {
  var Mouse, buttons, set_button;
  Mouse = {
    left: false,
    right: false,
    middle: false,
    location: Point(0, 0)
  };
  buttons = [null, "left", "middle", "right"];
  set_button = function(index, state) {
    var button_name;
    button_name = buttons[index];
    return button_name ? (Mouse[button_name] = state) : null;
  };
  $(document).mousedown(function(event) {
    return set_button(event.which, true);
  });
  $(document).mouseup(function(event) {
    return set_button(event.which, false);
  });
  $(document).mousemove(function(event) {
    var x, y;
    x = event.pageX;
    y = event.pageY;
    Mouse.location = Point(x, y);
    Mouse.x = x;
    return (Mouse.y = y);
  });
  return Mouse;
})();;
/***
Returns the absolute value of this number.

@name abs
@methodOf Number#

@type Number
@returns The absolute value of the number.
*/
Number.prototype.abs = function() {
  return Math.abs(this);
};
/***
Returns the mathematical ceiling of this number.

@name ceil
@methodOf Number#

@type Number
@returns The number truncated to the nearest integer of greater than or equal value.

(4.9).ceil() # => 5
(4.2).ceil() # => 5
(-1.2).ceil() # => -1
*/
Number.prototype.ceil = function() {
  return Math.ceil(this);
};
/***
Returns the mathematical floor of this number.

@name floor
@methodOf Number#

@type Number
@returns The number truncated to the nearest integer of less than or equal value.

(4.9).floor() # => 4
(4.2).floor() # => 4
(-1.2).floor() # => -2
*/
Number.prototype.floor = function() {
  return Math.floor(this);
};
/***
Returns this number rounded to the nearest integer.

@name round
@methodOf Number#

@type Number
@returns The number rounded to the nearest integer.

(4.5).round() # => 5
(4.4).round() # => 4
*/
Number.prototype.round = function() {
  return Math.round(this);
};
/***
Returns a number whose value is limited to the given range.

Example: limit the output of this computation to between 0 and 255
<pre>
(x * 255).clamp(0, 255)
</pre>

@name clamp
@methodOf Number#

@param {Number} min The lower boundary of the output range
@param {Number} max The upper boundary of the output range

@returns A number in the range [min, max]
@type Number
*/
Number.prototype.clamp = function(min, max) {
  return Math.min(Math.max(this, min), max);
};
/***
A mod method useful for array wrapping. The range of the function is
constrained to remain in bounds of array indices.

<pre>
Example:
(-1).mod(5) == 4
</pre>

@name mod
@methodOf Number#

@param {Number} base
@returns An integer between 0 and (base - 1) if base is positive.
@type Number
*/
Number.prototype.mod = function(base) {
  var result;
  result = this % base;
  if (result < 0 && base > 0) {
    result += base;
  }
  return result;
};
/***
Get the sign of this number as an integer (1, -1, or 0).

@name sign
@methodOf Number#

@type Number
@returns The sign of this number, 0 if the number is 0.
*/
Number.prototype.sign = function() {
  if (this > 0) {
    return 1;
  } else if (this < 0) {
    return -1;
  } else {
    return 0;
  }
};
/***
Calls iterator the specified number of times, passing in the number of the
current iteration as a parameter: 0 on first call, 1 on the second call, etc.

@name times
@methodOf Number#

@param {Function} iterator The iterator takes a single parameter, the number
of the current iteration.
@param {Object} [context] The optional context parameter specifies an object
to treat as <code>this</code> in the iterator block.

@returns The number of times the iterator was called.
@type Number
*/
Number.prototype.times = function(iterator, context) {
  var i;
  i = -1;
  while (++i < this) {
    iterator.call(context, i);
  }
  return i;
};
/***
Returns the the nearest grid resolution less than or equal to the number.

  EX:
   (7).snap(8) => 0
   (4).snap(8) => 0
   (12).snap(8) => 8

@name snap
@methodOf Number#

@param {Number} resolution The grid resolution to snap to.
@returns The nearest multiple of resolution lower than the number.
@type Number
*/
Number.prototype.snap = function(resolution) {
  var n;
  n = this / resolution;
  1 / 1;
  return n.floor() * resolution;
};
/***
In number theory, integer factorization or prime factorization is the
breaking down of a composite number into smaller non-trivial divisors,
which when multiplied together equal the original integer.

Floors the number for purposes of factorization.

@name primeFactors
@methodOf Number#

@returns An array containing the factorization of this number.
@type Array
*/
Number.prototype.primeFactors = function() {
  var factors, i, iSquared, n;
  factors = [];
  n = Math.floor(this);
  if (n === 0) {
    return undefined;
  }
  if (n < 0) {
    factors.push(-1);
    n /= -1;
  }
  i = 2;
  iSquared = i * i;
  while (iSquared < n) {
    while ((n % i) === 0) {
      factors.push(i);
      n /= i;
    }
    i += 1;
    iSquared = i * i;
  }
  if (n !== 1) {
    factors.push(n);
  }
  return factors;
};
Number.prototype.toColorPart = function() {
  var s;
  s = parseInt(this.clamp(0, 255), 10).toString(16);
  if (s.length === 1) {
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
  while (target > this + Math.PI) {
    target -= Math.TAU;
  }
  while (target < this - Math.PI) {
    target += Math.TAU;
  }
  return (target - this).clamp(-maxDelta, maxDelta) + this;
};
/***
Constrains a rotation to between -PI and PI.

@name constrainRotation
@methodOf Number#

@returns This number constrained between -PI and PI.
@type Number
*/
Number.prototype.constrainRotation = function() {
  var target;
  target = this;
  while (target > Math.PI) {
    target -= Math.TAU;
  }
  while (target < -Math.PI) {
    target += MATH.TAU;
  }
  return target;
};
Number.prototype.d = function(sides) {
  var sum;
  sum = 0;
  this.times(function() {
    return sum += rand(sides) + 1;
  });
  return sum;
};
Number.isNumber = function (num) {
  return !isNaN(num);
};
Number.isFloat = function(num) {
  return !isNaN(num) && ("" + num).search(/\./) >= 0
};
/***
The mathematical circle constant of 1 turn.

@name TAU
@fieldOf Math
*/
Math.TAU = 2 * Math.PI;;
/***
* Checks whether an object is an array.
*
* @type Object
* @returns A boolean expressing whether the object is an instance of Array
*/
Object.isArray = function(object) {
  return Object.prototype.toString.call(object) === '[object Array]';
};;
Object.isObject = function(object) {
  return Object.prototype.toString.call(object) === '[object Object]';
};
var __hasProp = Object.prototype.hasOwnProperty, __slice = Array.prototype.slice;
(function($) {
  return ($.fn.powerCanvas = function(options) {
    var $canvas, canvas, context;
    options || (options = {});
    canvas = this.get(0);
    context = undefined;
    /***
    * PowerCanvas provides a convenient wrapper for working with Context2d.
    * @name PowerCanvas
    * @constructor
    */
    $canvas = $(canvas).extend({
      /***
       * Passes this canvas to the block with the given matrix transformation
       * applied. All drawing methods called within the block will draw
       * into the canvas with the transformation applied. The transformation
       * is removed at the end of the block, even if the block throws an error.
       *
       * @name withTransform
       * @methodOf PowerCanvas#
       *
       * @param {Matrix} matrix
       * @param {Function} block
       * @returns this
      */
      withTransform: function(matrix, block) {
        context.save();
        context.transform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
        try {
          block(this);
        } finally {
          context.restore();
        }
        return this;
      },
      clear: function() {
        context.clearRect(0, 0, canvas.width, canvas.height);
        return this;
      },
      clearRect: function(x, y, width, height) {
        context.clearRect(x, y, width, height);
        return this;
      },
      context: function() {
        return context;
      },
      element: function() {
        return canvas;
      },
      globalAlpha: function(newVal) {
        if (typeof newVal !== "undefined" && newVal !== null) {
          context.globalAlpha = newVal;
          return this;
        } else {
          return context.globalAlpha;
        }
      },
      compositeOperation: function(newVal) {
        if (typeof newVal !== "undefined" && newVal !== null) {
          context.globalCompositeOperation = newVal;
          return this;
        } else {
          return context.globalCompositeOperation;
        }
      },
      createLinearGradient: function(x0, y0, x1, y1) {
        return context.createLinearGradient(x0, y0, x1, y1);
      },
      createRadialGradient: function(x0, y0, r0, x1, y1, r1) {
        return context.createRadialGradient(x0, y0, r0, x1, y1, r1);
      },
      buildRadialGradient: function(c1, c2, stops) {
        var _ref, color, gradient, position;
        gradient = context.createRadialGradient(c1.x, c1.y, c1.radius, c2.x, c2.y, c2.radius);
        _ref = stops;
        for (position in _ref) {
          if (!__hasProp.call(_ref, position)) continue;
          color = _ref[position];
          gradient.addColorStop(position, color);
        }
        return gradient;
      },
      createPattern: function(image, repitition) {
        return context.createPattern(image, repitition);
      },
      drawImage: function(image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight) {
        context.drawImage(image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight);
        return this;
      },
      drawLine: function(x1, y1, x2, y2, width) {
        if (arguments.length === 3) {
          width = x2;
          x2 = y1.x;
          y2 = y1.y;
          y1 = x1.y;
          x1 = x1.x;
        }
        width || (width = 3);
        context.lineWidth = width;
        context.beginPath();
        context.moveTo(x1, y1);
        context.lineTo(x2, y2);
        context.closePath();
        context.stroke();
        return this;
      },
      fill: function(color) {
        $canvas.fillColor(color);
        context.fillRect(0, 0, canvas.width, canvas.height);
        return this;
      },
      /***
       * Fills a circle at the specified position with the specified
       * radius and color.
       *
       * @name fillCircle
       * @methodOf PowerCanvas#
       *
       * @param {Number} x
       * @param {Number} y
       * @param {Number} radius
       * @param {Number} color
       * @see PowerCanvas#fillColor
       * @returns this
      */
      fillCircle: function(x, y, radius, color) {
        $canvas.fillColor(color);
        context.beginPath();
        context.arc(x, y, radius, 0, Math.TAU, true);
        context.closePath();
        context.fill();
        return this;
      },
      /***
       * Fills a rectangle with the current fillColor
       * at the specified position with the specified
       * width and height

       * @name fillRect
       * @methodOf PowerCanvas#
       *
       * @param {Number} x
       * @param {Number} y
       * @param {Number} width
       * @param {Number} height
       * @see PowerCanvas#fillColor
       * @returns this
      */
      fillRect: function(x, y, width, height) {
        context.fillRect(x, y, width, height);
        return this;
      },
      fillShape: function() {
        var points;
        points = __slice.call(arguments, 0);
        context.beginPath();
        points.each(function(point, i) {
          return i === 0 ? context.moveTo(point.x, point.y) : context.lineTo(point.x, point.y);
        });
        context.lineTo(points[0].x, points[0].y);
        return context.fill();
      },
      /***
      * Adapted from http://js-bits.blogspot.com/2010/07/canvas-rounded-corner-rectangles.html
      */
      fillRoundRect: function(x, y, width, height, radius, strokeWidth) {
        radius || (radius = 5);
        context.beginPath();
        context.moveTo(x + radius, y);
        context.lineTo(x + width - radius, y);
        context.quadraticCurveTo(x + width, y, x + width, y + radius);
        context.lineTo(x + width, y + height - radius);
        context.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
        context.lineTo(x + radius, y + height);
        context.quadraticCurveTo(x, y + height, x, y + height - radius);
        context.lineTo(x, y + radius);
        context.quadraticCurveTo(x, y, x + radius, y);
        context.closePath();
        if (strokeWidth) {
          context.lineWidth = strokeWidth;
          context.stroke();
        }
        context.fill();
        return this;
      },
      fillText: function(text, x, y) {
        context.fillText(text, x, y);
        return this;
      },
      centerText: function(text, y) {
        var textWidth;
        textWidth = $canvas.measureText(text);
        return $canvas.fillText(text, (canvas.width - textWidth) / 2, y);
      },
      fillWrappedText: function(text, x, y, width) {
        var lineHeight, tokens, tokens2;
        tokens = text.split(" ");
        tokens2 = text.split(" ");
        lineHeight = 16;
        if ($canvas.measureText(text) > width) {
          if (tokens.length % 2 === 0) {
            tokens2 = tokens.splice(tokens.length / 2, tokens.length / 2, "");
          } else {
            tokens2 = tokens.splice(tokens.length / 2 + 1, (tokens.length / 2) + 1, "");
          }
          context.fillText(tokens.join(" "), x, y);
          return context.fillText(tokens2.join(" "), x, y + lineHeight);
        } else {
          return context.fillText(tokens.join(" "), x, y + lineHeight);
        }
      },
      fillColor: function(color) {
        if (color) {
          if (color.channels) {
            context.fillStyle = color.toString();
          } else {
            context.fillStyle = color;
          }
          return this;
        } else {
          return context.fillStyle;
        }
      },
      font: function(font) {
        if (typeof font !== "undefined" && font !== null) {
          context.font = font;
          return this;
        } else {
          return context.font;
        }
      },
      measureText: function(text) {
        return context.measureText(text).width;
      },
      putImageData: function(imageData, x, y) {
        context.putImageData(imageData, x, y);
        return this;
      },
      strokeColor: function(color) {
        if (color) {
          if (color.channels) {
            context.strokeStyle = color.toString();
          } else {
            context.strokeStyle = color;
          }
          return this;
        } else {
          return context.strokeStyle;
        }
      },
      strokeRect: function(x, y, width, height) {
        context.strokeRect(x, y, width, height);
        return this;
      },
      textAlign: function(textAlign) {
        context.textAlign = textAlign;
        return this;
      },
      height: function() {
        return canvas.height;
      },
      width: function() {
        return canvas.width;
      }
    });
    if ((typeof canvas === "undefined" || canvas === null) ? undefined : canvas.getContext) {
      context = canvas.getContext('2d');
      if (options.init) {
        options.init($canvas);
      }
      return $canvas;
    }
  });
})(jQuery);;
(function(window) {
  var Node, QuadTree;
  QuadTree = function(I) {
    var root, self;
    I || (I = {});
    $.reverseMerge(I, {
      bounds: {
        x: 0,
        y: 0,
        width: 480,
        height: 320
      },
      maxChildren: 5,
      maxDepth: 4
    });
    root = Node({
      bounds: I.bounds,
      maxDepth: I.maxDepth,
      maxChildren: I.maxChildren
    });
    self = {
      I: I,
      root: function() {
        return root;
      },
      clear: function() {
        return root.clear();
      },
      insert: function(obj) {
        return Object.isArray(obj) ? obj.each(function(item) {
          return root.insert(item);
        }) : root.insert(obj);
      },
      retrieve: function(item) {
        return root.retrieve(item).copy();
      }
    };
    return self;
  };
  Node = function(I) {
    var BOTTOM_LEFT, BOTTOM_RIGHT, TOP_LEFT, TOP_RIGHT, findQuadrant, halfHeight, halfWidth, self, subdivide;
    I || (I = {});
    $.reverseMerge(I, {
      bounds: {
        x: 0,
        y: 0,
        width: 120,
        height: 80
      },
      children: [],
      depth: 0,
      maxChildren: 5,
      maxDepth: 4,
      nodes: []
    });
    TOP_LEFT = 0;
    TOP_RIGHT = 1;
    BOTTOM_LEFT = 2;
    BOTTOM_RIGHT = 3;
    findQuadrant = function(item) {
      var bounds, index, left, top, x, x_midpoint, y, y_midpoint;
      bounds = I.bounds;
      x = bounds.x;
      y = bounds.y;
      x_midpoint = x + halfWidth();
      y_midpoint = y + halfHeight();
      left = item.x <= x_midpoint;
      top = item.y <= y_midpoint;
      index = TOP_LEFT;
      if (left) {
        if (!top) {
          index = BOTTOM_LEFT;
        }
      } else {
        if (top) {
          index = TOP_RIGHT;
        } else {
          index = BOTTOM_RIGHT;
        }
      }
      return index;
    };
    halfWidth = function() {
      return (I.bounds.width / 2).floor();
    };
    halfHeight = function() {
      return (I.bounds.height / 2).floor();
    };
    subdivide = function() {
      var half_height, half_width, increased_depth;
      increased_depth = I.depth + 1;
      half_width = halfWidth();
      half_height = halfHeight();
      return (4).times(function(n) {
        return (I.nodes[n] = Node({
          bounds: {
            x: half_width * (n % 2),
            y: half_height * (n < 2 ? 0 : 1),
            width: half_width,
            height: half_height
          },
          depth: increased_depth,
          maxChildren: I.maxChildren,
          maxDepth: I.maxDepth
        }));
      });
    };
    self = {
      I: I,
      clear: function() {
        I.children.clear();
        I.nodes.invoke('clear');
        return I.nodes.clear();
      },
      insert: function(item) {
        var index;
        if (I.nodes.length) {
          index = findQuadrant(item);
          I.nodes[index].insert(item);
          return true;
        }
        I.children.push(item);
        if ((I.depth < I.maxDepth) && (I.children.length > I.maxChildren)) {
          subdivide();
          I.children.each(function(child) {
            return self.insert(child);
          });
          return I.children.clear();
        }
      },
      retrieve: function(item) {
        var index;
        index = findQuadrant(item);
        return (I.nodes[index] == null ? undefined : I.nodes[index].retrieve(item)) || I.children;
      }
    };
    return self;
  };
  return (window.QuadTree = QuadTree);
})(window);;
(function($) {
  window.Random = $.extend(window.Random, {
    angle: function() {
      return rand() * Math.TAU;
    },
    color: function() {
      return Color.random();
    },
    often: function() {
      return rand(3);
    },
    sometimes: function() {
      return !rand(3);
    }
  });
  /***
  Returns random integers from [0, n) if n is given.
  Otherwise returns random float between 0 and 1.

  @param {Number} n
  */
  return (window.rand = function(n) {
    return n ? Math.floor(n * Math.random()) : Math.random();
  });
})(jQuery);;
(function($) {
  var retrieve, store;
  /***
  @name Local
  @namespace
  */
  /***
  Store an object in local storage.

  @name set
  @methodOf Local

  @param {String} key
  @param {Object} value
  @type Object
  @returns value
  */
  store = function(key, value) {
    localStorage[key] = JSON.stringify(value);
    return value;
  };
  /***
  Retrieve an object from local storage.

  @name get
  @methodOf Local

  @param {String} key
  @type Object
  @returns The object that was stored or undefined if no object was stored.
  */
  retrieve = function(key) {
    var value;
    value = localStorage[key];
    return (typeof value !== "undefined" && value !== null) ? JSON.parse(value) : null;
  };
  return (window.Local = $.extend(window.Local, {
    get: retrieve,
    set: store,
    put: store,
    /***
    Access an instance of Local with a specified prefix.

    @name new
    @methodOf Local

    @param {String} prefix
    @type Local
    @returns An interface to local storage with the given prefix applied.
    */
    "new": function(prefix) {
      prefix || (prefix = "");
      return {
        get: function(key) {
          return retrieve("" + (prefix) + "_key");
        },
        set: function(key, value) {
          return store("" + (prefix) + "_key", value);
        },
        put: function(key, value) {
          return store("" + (prefix) + "_key", value);
        }
      };
    }
  }));
})(jQuery);;
/***
Returns true if this string only contains whitespace characters.

@name blank
@methodOf String#

@returns Whether or not this string is blank.
@type Boolean
*/
String.prototype.blank = function() {
  return /^\s*$/.test(this);
};
/***
@name camelize
@methodOf String#
*/
String.prototype.camelize = function() {
  return this.trim().replace(/(\-|_|\s)+(.)?/g, function(match, separator, chr) {
    return chr ? chr.toUpperCase() : '';
  });
};
/***
@name capitalize
@methodOf String#
*/
String.prototype.capitalize = function() {
  return this.charAt(0).toUpperCase() + this.substring(1).toLowerCase();
};
/***
Return the class or constant named in this string.

@name constantize
@methodOf String#

@returns The class or constant named in this string.
@type Object
*/
String.prototype.constantize = function() {
  if (this.match(/[A-Z][A-Za-z0-9]*/)) {
    eval("var that = " + (this));
    return that;
  } else {
    return undefined;
  }
};
/***
@name humanize
@methodOf String#
*/
String.prototype.humanize = function() {
  return this.replace(/_id$/, "").replace(/_/g, " ").capitalize();
};
/***
Parse this string as though it is JSON and return the object it represents. If it
is not valid JSON returns the string itself.

@name parse
@methodOf String#

@returns Returns an object from the JSON this string contains. If it
is not valid JSON returns the string itself.
@type Object
*/
String.prototype.parse = function() {
  try {
    return JSON.parse(this);
  } catch (e) {
    return this.toString();
  }
};
/***
@name titleize
@methodOf String#
*/
String.prototype.titleize = function() {
  return this.split(/[- ]/).map(function(word) {
    return word.capitalize();
  }).join(' ');
};
