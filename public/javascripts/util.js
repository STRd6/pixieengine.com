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
