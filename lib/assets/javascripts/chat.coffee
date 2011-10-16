#= require tmpls/chat/recent
#= require tmpls/chat/active_user

window.Pixie ||= {}
Pixie.Chat ||= {}

Pixie.Chat.create = (current_user) ->
  chatSound = $("#chat_sound").get(0)

  if getVal('chatNotificationEnabled')
    $('#notification_toggle').attr('checked', 'checked')
  else
    $('#notification_toggle').removeAttr('checked')

  withinScrollBoundary = ->
    $('#chats').scrollTop() >= $.scrollTo.max($('#chats').get(0), 'y') * 0.90

  scrollChat = ->
    setTimeout ->
      $('#chats').scrollTo
        left: '0%'
        top: '100%'
    , 100

  appendChat = (chat, prevChatUser) ->
    chatData = $.tmpl('chat/recent', chat)

    if chat.name == prevChatUser
      $(chatData).find('hr, .name, .time').remove()
    else if chat.user_id > 0
      $(chatData).find('.name').html('<a target="_blank" href="/people/' + chat.user_id + '">' + chat.name + '</a>')

    $(chatData).removeAttr('data-id') unless chat.id
    $('#chats').append(chatData)

  initialize = ->
    $.get '/chats/active_users', (data) ->
      for user in data.users
        $.tmpl('chat/active_user', user).appendTo $('#active_users')

    $.get '/chats/recent', (data) ->
      prevChatUser = null

      for chat in data.chats
        appendChat(chat, prevChatUser)

        prevChatUser = chat.name

      scrollChat()

  refreshData = ->
    $.get '/chats/active_users', (data) ->
      lastOnline = (parseInt($(userEl).attr('data-id')) for userEl in $('#active_users li'))
      currentlyOnline = (user.id for user in data.users)

      for id in lastOnline
        if $.inArray(id, currentlyOnline) < 0
          $('#active_users li[data-id=' + id + ']').remove()
      for user in data.users
        if $.inArray(user.id, lastOnline) < 0
          $.tmpl('chat/active_user', user).appendTo $('#active_users')

    $.get '/chats/recent', (data) ->
      $('#chats li:not([data-id])').remove()

      prevChatId = null
      prevChatUser = null
      newChats = false

      scroll = withinScrollBoundary()

      for chat in data.chats
        if prevChatId && chat.id > prevChatId
          appendChat(chat, prevChatUser)

          newChats = true unless chat.name == (current_user.name)

        prevChatId = parseInt($('#chats li[data-id]:last').attr('data-id'))
        prevChatUser = chat.name

      if newChats && getVal('chatNotificationEnabled')
        chatSound.play()
        $('#chat_zone .header, #open_chat').css('backgroundColor', '#CE5A10')
        newChats = false

      scrollChat() if scroll

  initialize()

  setInterval(refreshData, 30000)

  send = (field) ->
    return unless message = field.val()

    # TODO replace @user_name with link to user and avatar
    #if message.match(/^@\w*/g)
    #  console.log message.match(/@\w*/g)

    date = new Date()
    current_time = "#{date.getHours() % 12}:#{date.getMinutes()}#{if date.getHours() > 11 then 'pm' else 'am'}"

    $.post '/chats', { body: message }

    prevChatUser = $('#chats li span.name:last').text()

    newMessage =
      name: current_user.name
      time: current_time
      message: message
      user_id: current_user.id

    scroll = withinScrollBoundary()

    appendChat(newMessage, prevChatUser)

    scrollChat() if scroll

    $('#chat_body').val("")

  $("#chat_zone").dropImageReader (file, event) ->
    if event.target.readyState == FileReader.DONE
      wrapper = $("<div />")
      img = $ "<img/>",
        alt: file.name
        src: event.target.result
        title: file.name

      img.appendTo(wrapper)

      $.post '/chats', { body: wrapper.html() }, ->
        refreshData()

  $('#chat_zone #chat_body').keypress (e) ->
    textBox = $('#chat_copy_html')

    if e.keyCode == 13 && !e.shiftKey
      e.preventDefault()
      send(textBox)

  $('#notification_toggle').change ->
    setVal('chatNotificationEnabled', $(this).attr('checked') == 'checked')

  $('#notification_toggle, #notification_label').mousedown (e) ->
    e.stopPropagation()

  $('#open_chat, #chat_zone .header').mousedown ->
    $('#open_chat').toggleClass('straight')
    $('#chat_zone').toggleClass('visible')

  $("#chat_zone").bind "show", ->
    $('#open_chat').addClass('straight')
    $('#chat_zone').addClass('visible')

  $('#open_chat, #chat_zone').mousedown (e) ->
    $('#chat_zone .header, #open_chat').css('backgroundColor', '#1084CE')

  $('#chats li').live
    mouseenter: ->
      $(this).find('.time').css('display', 'inline-block')
    mouseleave: ->
      $(this).find('.time').hide()

  $(document).bind 'keydown', 'c', (e) ->
    e.preventDefault()
    $('#open_chat').mousedown()
