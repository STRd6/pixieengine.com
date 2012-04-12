# #= require jquery/jquery.min
# #= require jquery/jquery-ui.min
# #= require corelib
# #= require underscore
# #= require backbone
# #= require jquery.drop_image_reader
# #= require jquery.tmpl.min
# #= require sinon
# #= require jasmine-jquery
# #= require jasmine-sinon
# #= require jquery.simplemodal-1.3.5.min
# #= require jquery.form
# #= require jquery.tipsy
# #= require site
# #= require jquery.live_edit
# #= require pixie/ui
# #= require pixie/editor/base
# #= require pixie/view
#
# # fixtures
# beforeEach ->
#   @fixtures =
#     PaginatedCollection:
#       valid:
#         current_user_id: 4
#         page: 1
#         per_page: 5
#         total: 20
#         models: [
#           { id: 1, title: "Quest for Meaning" },
#           { id: 2, title: "Pixteroids" }
#         ]
#     SpriteCollection:
#       valid:
#         current_user_id: 4
#         page: 1
#         per_page: 5
#         total: 20
#         models: [
#           { id: 1, title: "Sprite 1" }
#           { id: 2, title: "Sprite 2" }
#           { id: 3, title: "Sprite 3" }
#         ]
#     TilesCollection:
#       valid:
#         models: [
#           { cid: "c1", src: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABfUlEQVQ4EYVSPUhDQQzOPRw7aAcVxEURXAQHizq+Qe1eC3YToSrOxdGhozgXpEs3RXT3Z3hvVHBwFMRJBF3EwdkzX/oSrxxiIFyS+5J8yZ3z3tN/4pwzEONdiB8KHdgAAxQmdRqzBtN7DQCttiRfHGzQ892lxErlcbv7+ngj+GMz81Rrn5IySRSByodrw/T+9EDTi1UJI0kVyXsnjxJHE2UYjYAE4iKjc3UBbx51i6QqdRok3dFIJSqwf/VJvVY/eWVpge0+tNbukiYCoyPAMGUoFuJ7raacr+fHHhrGYIc5tgO++K0K5w+xzsV99ApZllGapky9KRCMAZlY3xGmvDzxrZDS4ahQ5QIeqr6ejBPBeDoWB4Q2KkpQL7RIkTNwABsWsR3c3N6jkAhGgOR5Lgob1KFczeFpDQ8aUBajnVTOzNZ4svoisRALO1oiJ6PYoIwsi/99PRm/lDLQk5HWHUx2KyV8ceuuOD1tB9qSL8BK3mqbtmiqHH1Whcr5A0XSM3sdB/+tAAAAAElFTkSuQmCC" },
#           { cid: "c2", src: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAADHmlDQ1BJQ0MgUHJvZmlsZQAAeAGFVN9r01AU/tplnbDhizpnEQk+aJFuZFN0Q5y2a1e6zVrqNrchSJumbVyaxiTtfrAH2YtvOsV38Qc++QcM2YNve5INxhRh+KyIIkz2IrOemzRNJ1MDufe73/nuOSfn5F6g+XFa0xQvDxRVU0/FwvzE5BTf8gFeHEMr/GhNi4YWSiZHQA/Tsnnvs/MOHsZsdO5v36v+Y9WalQwR8BwgvpQ1xCLhWaBpXNR0E+DWie+dMTXCzUxzWKcECR9nOG9jgeGMjSOWZjQ1QJoJwgfFQjpLuEA4mGng8w3YzoEU5CcmqZIuizyrRVIv5WRFsgz28B9zg/JfsKiU6Zut5xCNbZoZTtF8it4fOX1wjOYA1cE/Xxi9QbidcFg246M1fkLNJK4RJr3n7nRpmO1lmpdZKRIlHCS8YlSuM2xp5gsDiZrm0+30UJKwnzS/NDNZ8+PtUJUE6zHF9fZLRvS6vdfbkZMH4zU+pynWf0D+vff1corleZLw67QejdX0W5I6Vtvb5M2mI8PEd1E/A0hCgo4cZCjgkUIMYZpjxKr4TBYZIkqk0ml0VHmyONY7KJOW7RxHeMlfDrheFvVbsrj24Pue3SXXjrwVhcW3o9hR7bWB6bqyE5obf3VhpaNu4Te55ZsbbasLCFH+iuWxSF5lyk+CUdd1NuaQU5f8dQvPMpTuJXYSWAy6rPBe+CpsCk+FF8KXv9TIzt6tEcuAcSw+q55TzcbsJdJM0utkuL+K9ULGGPmQMUNanb4kTZyKOfLaUAsnBneC6+biXC/XB567zF3h+rkIrS5yI47CF/VFfCHwvjO+Pl+3b4hhp9u+02TrozFa67vTkbqisXqUj9sn9j2OqhMZsrG+sX5WCCu0omNqSrN0TwADJW1Ol/MFk+8RhAt8iK4tiY+rYleQTysKb5kMXpcMSa9I2S6wO4/tA7ZT1l3maV9zOfMqcOkb/cPrLjdVBl4ZwNFzLhegM3XkCbB8XizrFdsfPJ63gJE722OtPW1huos+VqvbdC5bHgG7D6vVn8+q1d3n5H8LeKP8BqkjCtbCoV8yAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAtUlEQVQYGWP8//8/AwxwSzMiOEDBr0//M8LkWGAMkCKNKEaGn29ZGdiFf4NpkBhMMVghTBFI09X5v6B6fzEYlTAywBSzwBSBTAIpAknCwLme/3DFTDBBhEkwEQYUTWCrG3myGRgaEArqv0xFcKAssIkX7j5k0JCRgGOQRrFDqiiKGUHBA3LnxaYWBpuVNWBJw49qcEWHntwCBxNYIUgUpjh31iIMRSABuEIQB6QYRMMALAxBfAAQdlRUOCuHTwAAAABJRU5ErkJggg==" }
#         ]
#
# # server response helper
# beforeEach ->
#   @validResponse = (responseText) ->
#     return [
#       200,
#       {"Content-Type": "application/json"},
#       JSON.stringify(responseText)
#     ]
#
#
