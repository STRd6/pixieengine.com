window.updateLibs = (callback) ->
  nonGithub = []

  n = 0
  libCount = 0

  for fileName, url of projectConfig.libs
    do (fileName, url) ->
      libCount += 1

      if libData = parseGithubUrl(url)
        Object.extend libData,
          callback: (contents) ->
            path = "#{projectConfig.directories.lib}/#{fileName}"
            tree.add path,
              size: contents.length
              type: "blob"

            saveFile
              contents: contents
              path: path

            n += 1
            if n is libCount
              callback?()

        githubClient.getFile libData
      else
        nonGithub.push [{fileName, url}]

  if nonGithub.length
    log nonGithub

  if n is libCount
    callback?()

parseGithubUrl = (url) ->
  # url = "https://raw.github.com/PixieEngine/PixieDust/pixie/game.js"
  if result = url.match(/raw\.github\.com\/([^\/]+)\/([^\/]+)\/([^\/]+)\/(.+)$/)
    [match, user, repo, sha, path] = result
    return {user, repo, sha, path}

  # url = "https://github.com/STRd6/browserlib/raw/pixie/game.js"
  if result = url.match(/github\.com\/([^\/]+)\/([^\/]+)\/raw\/([^\/]+)\/(.+)$/)
    [match, user, repo, sha, path] = result
    return {user, repo, sha, path}
