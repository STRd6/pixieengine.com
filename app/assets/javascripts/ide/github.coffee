namespace "Github", (Github) ->
  API_ROOT = "https://api.github.com"

  Github.Client = (token) ->
    # Raw API call, just setting up jsonp and adding the token
    callAPI: (url, data, callback)->
      # Attach our access token
      data = $.extend
        access_token: token
      , data

      console.log "GITHUB GET: ", url, data

      # Add the jsonp callback to the url
      $.getJSON "#{url}?callback=?", data, (data) ->
          console.log "GITHUB RESPONSE: ", data
          # Ignoring metadata for now, just returning the main data
          callback(data.data)

    get: (path, data, callback) ->
      if typeof data is "function"
        callback = data
        data = {}

      @callAPI("#{API_ROOT}#{path}", data, callback)

    fileContents: (url, callback) ->
      @callAPI url, {}, ({content, encoding}) ->

        if encoding is "base64"
          content = Base64.decode(content)

        callback(content)

    # TODO: Clean these up to integrate with BoneTree better
    getRepo: (user, repo, callback, sha="pixie") ->
      @get "/repos/#{user}/#{repo}/git/trees/#{sha}",
        recursive: 1
      , (data) ->
        tree = new BoneTree.Views.Tree

        # Add each file
        for file in data.tree
          tree.file(file.path, $.extend({}, file))

        #TODO Get file contents

        #TODO Local Storage

        callback(tree)

  Github.test = ->
    client = Github.Client(githubToken)

    client.getRepo "STRd6", "PixieDust", (tree) ->
      $('.sidebar').empty()
      $('.sidebar').append(tree.render().$el)

      tree.bind 'openFile', (file) ->
        openFile(file)
