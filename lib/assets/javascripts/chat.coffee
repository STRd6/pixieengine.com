#= require templates/chat/recent
#= require templates/chat/active_user

namespace "Pixie.Chat", (Chat) ->
  Chat.create = (current_user) ->
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
      chatData = $(JST['templates/chat/recent'](chat))

      if chat.name == prevChatUser
        $(chatData).find('hr, .name, .time').remove()
      else if chat.user_id > 0
        $(chatData).find('.name').html('<a target="_blank" href="/' + chat.name + '">' + chat.name + '</a>')

      $(chatData).removeAttr('data-id') unless chat.id
      $('#chats').append(chatData)

    initialize = ->
      $.get '/chats/active_users.json', (activeUsers) ->
        for user in activeUsers
          $(JST['templates/chat/active_user'](user)).appendTo $('#active_users')

      $.get '/chats/recent.json', (chats) ->
        prevChatUser = null

        for chat in chats
          appendChat(chat, prevChatUser)

          prevChatUser = chat.name

        scrollChat()

    refreshData = ->
      $.get '/chats/active_users.json', (activeUsers) ->
        lastOnline = (parseInt($(userEl).attr('data-id')) for userEl in $('#active_users li'))
        currentlyOnline = (user.id for user in activeUsers)

        for id in lastOnline
          if $.inArray(id, currentlyOnline) < 0
            $('#active_users li[data-id=' + id + ']').remove()
        for user in activeUsers
          if $.inArray(user.id, lastOnline) < 0
            $(JST['templates/chat/active_user'](user)).appendTo $('#active_users')

      $.get '/chats/recent.json', (chats) ->
        $('#chats li:not([data-id])').remove()

        prevChatId = null
        prevChatUser = null
        newChats = false

        scroll = withinScrollBoundary()

        for chat in chats
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

      date = new Date()
      paddedMinutes = if date.getMinutes() < 10 then "0#{date.getMinutes()}" else date.getMinutes()
      current_time = "#{date.getHours() % 12}:#{paddedMinutes}#{if date.getHours() > 11 then 'pm' else 'am'}"

      $.post '/chats.json', { body: message }

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
        if current_user.admin
          chat_id = $(this).data('id')
          $('<a class="delete" href="/chats/' + chat_id + '" title="Delete">Delete</a>').appendTo $(this)

      mouseleave: ->
        $(this).find('.time').hide()
        $(this).find('.delete').remove()

    $('#chats .delete').live
      click: (e) ->
        e.preventDefault()

        if confirm "Are you sure you want to change history?"
          $(this).parent().remove()

          $.ajax
            type: "DELETE",
            url: $(this).attr('href'),
            data:
              id: $(this).parent().data('id')

    $(document).bind 'keydown', 'c', (e) ->
      e.preventDefault()
      $('#open_chat').mousedown()
