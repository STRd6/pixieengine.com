window.onerror = (message, url, lineNumber) ->

  $.post "/js_errors",
    format: 'json'
    js_error:
      url: url
      message: message
      line_number: lineNumber
      user_agent: navigator.userAgent
