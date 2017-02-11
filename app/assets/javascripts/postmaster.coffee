###

Postmaster wraps the `postMessage` API with promises.

###

defaultReceiver = self
ackTimeout = 1000

window.Postmaster = (self={}) ->
  send = (data) ->
    target = self.remoteTarget()
    if !Worker? or target instanceof Worker
      target.postMessage data
    else
      target.postMessage data, "*"

  dominant = Postmaster.dominant()
  self.remoteTarget ?= -> dominant
  self.receiver ?= -> defaultReceiver
  self.ackTimeout ?= -> ackTimeout

  self.receiver().addEventListener "message", (event) ->
    # Only listening to messages from `opener`
    if event.source is self.remoteTarget() or !event.source
      data = event.data
      {type, method, params, id} = data

      switch type
        when "ack"
          pendingResponses[id]?.ack = true
        when "response"
          pendingResponses[id].resolve data.result
        when "error"
          pendingResponses[id].reject data.error
        when "message"
          send
            type: "ack"
            id: id

          Promise.resolve()
          .then ->
            if typeof self[method] is "function"
              self[method](params...)
            else
              throw new Error "`#{method}` is not a function"
          .then (result) ->
            send
              type: "response"
              id: id
              result: result
          .catch (error) ->
            if typeof error is "string"
              message = error
            else
              message = error.message

            send
              type: "error"
              id: id
              error:
                message: message
                stack: error.stack

  pendingResponses = {}
  remoteId = 0

  self.invokeRemote = (method, params...) ->
    id = remoteId++

    send
      type: "message"
      method: method
      params: params
      id: id

    new Promise (resolve, reject) ->
      clear = ->
        clearTimeout pendingResponses[id].timeout
        delete pendingResponses[id]

      ackWait = self.ackTimeout()
      timeout = setTimeout ->
        pendingResponse = pendingResponses[id]
        if pendingResponse and !pendingResponse.ack
          clear()
          reject new Error "No ack received within #{ackWait}"
      , ackWait

      pendingResponses[id] =
        timeout: timeout
        resolve: (result) ->
          clear()
          resolve(result)
        reject: (error) ->
          clear()
          reject(error)

  return self

Postmaster.dominant = ->
  if window? # iframe or child window context
    opener or ((parent != window) and parent) or undefined
  else # Web Worker Context
    self
