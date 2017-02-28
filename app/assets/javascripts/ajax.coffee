# Extend promises with `finally`
# From: https://github.com/domenic/promises-unwrapping/issues/18
Promise.prototype.finally ?= (callback) ->
  # We don’t invoke the callback in here,
  # because we want then() to handle its exceptions
  this.then(
    # Callback fulfills: pass on predecessor settlement
    # Callback rejects: pass on rejection (=omit 2nd arg.)
    (value) ->
      Promise.resolve(callback())
      .then -> return value
    (reason) ->
      Promise.resolve(callback())
      .then -> throw reason
  )

# HACK: I really would prefer not to modify the native Promise prototype, but I
# know no other way...

Promise.prototype._notify ?= (event) ->
  @_progressHandlers.forEach (handler) ->
    try
      handler(event)

Promise.prototype.progress ?= (handler) ->
  @_progressHandlers ?= []
  @_progressHandlers.push handler

  return this

window.ProgressPromise = (fn) ->
  p = new Promise (resolve, reject) ->
    notify = ->
      p._progressHandlers?.forEach (handler) ->
        try
          handler(event)

    fn(resolve, reject, notify)

  p.then = (onFulfilled, onRejected) ->
    result = Promise.prototype.then.call(p, onFulfilled, onRejected)
    # Pass progress through
    p.progress result._notify.bind(result)

    return result

  return p


window.Ajax = ->
  ajax = (options={}) ->
    {data, headers, method, overrideMimeType, password, url, responseType, timeout, user, withCredentials} = options
    data ?= ""
    headers ?= {}
    method ?= "GET"
    password ?= ""
    responseType ?= ""
    timeout ?= 0
    user ?= ""
    withCredentials ?= false

    # Set up Rails token
    headers['X-CSRF-Token'] ?= $('meta[name="csrf-token"]').attr('content')

    new ProgressPromise (resolve, reject, progress) ->
      xhr = new XMLHttpRequest()
      xhr.open(method, url, true, user, password)
      xhr.responseType = responseType
      xhr.timeout = timeout
      xhr.withCredentialls = withCredentials

      if headers
        Object.keys(headers).forEach (header) ->
          value = headers[header]
          xhr.setRequestHeader header, value

      if overrideMimeType
        xhr.overrideMimeType overrideMimeType

      xhr.onload = (e) ->
        if (200 <= this.status < 300) or this.status is 304
          resolve this.response
          complete e, xhr, options
        else
          reject xhr
          complete e, xhr, options

      xhr.onerror = (e) ->
        reject xhr
        complete e, xhr, options

      xhr.onprogress = progress

      xhr.send(data)

  complete = (args...) ->
    completeHandlers.forEach (handler) ->
      handler args...

  configure = (optionDefaults) ->
    (url, options={}) ->
      if typeof url is "object"
        options = url
      else
        options.url = url

      defaults options, optionDefaults

      ajax(options)

  completeHandlers = []

  Object.assign ajax,
    ajax: configure {}
    complete: (handler) ->
      completeHandlers.push handler

    getJSON: configure
      responseType: "json"

    getBlob: configure
      responseType: "blob"

defaults = (target, objects...) ->
  for object in objects
    for name of object
      unless target.hasOwnProperty(name)
        target[name] = object[name]

  return target
