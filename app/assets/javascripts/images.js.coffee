initConfirmDelete = ->
  $('#finish_delete').removeAttr('disabled')
  $('#finish_delete').on 'click', (e) ->
    e.preventDefault()
    confirmationMessage = 'This will delete the selected images. Are you sure you want to continue?'
    bootbox.confirm confirmationMessage, (confirmed) ->
      if confirmed then deleteSelected() else cleanupDelete()

    $('#delete_instructions').remove()

initSelection = ->
  $('#content').drag('start', (ev, dd) ->
    $('<div class="selection" />').css('opacity', .65)
                                  .appendTo($('#content'))
  ).drag((ev, dd) ->
    $(dd.proxy).css(
      top: Math.min(ev.pageY, dd.startY)
      left: Math.min(ev.pageX, dd.startX)
      height: Math.abs(ev.pageY - dd.startY)
      width: Math.abs(ev.pageX - dd.startX)
    )
  ).drag 'end', (ev, dd) ->
    $(dd.proxy).remove()

  $('.thumbnail').drop('start', ->
    $(this).addClass 'selecting'
  ).drop((ev, dd) ->
    $(this).toggleClass 'selected'
  ).drop 'end', ->
    $(this).removeClass 'selecting'

  $.drop multi: true

cleanupDelete = ->
  $('#finish_delete').attr('disabled', true)
  $('.selected').removeClass('selected')

deleteSelected = ->
  $('.selected').each((i, item) ->
    $item = $(item)
    destroyUrl = "#{window.location.pathname}/images/#{$item.data('image_id')}"
    $.post(destroyUrl, _method: 'delete')
    $item.parent().fadeOut(500).remove()
  )
  cleanupDelete()

$ ->
  $imagesContainer = $('#images')

  $('#toggle_selection').click (e) ->
    e.preventDefault()
    if $(this).hasClass('active')
      $('#content').off()
      cleanupDelete()
      $('#delete_instructions').remove()
    else
      $('#content').prepend(JST['templates/delete_instructions'])
      initSelection()
      initConfirmDelete()

  $('#uploader').fileupload(
    url: "#{window.location.pathname}/images.json"
    maxFileSize: 20000000
    acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i
    downloadTemplateId: false
    done: (e, data) ->
      image = JST['templates/image'](image: data.result.image, id: data.result.id)
      $imagesContainer.append(image)
      data.context.find('.progress').replaceWith("<span class='label label-success'>Success</span>")
    fail: (e, data) ->
      response = JSON.parse(data.xhr().response)
      error = "<td class='error' colspan='2'><span class='label label-important'>Error</span> #{response.errors}</td>"
      data.context.find('.progress').replaceWith(error)
  )
