pagePartId = '#page_part_' + '<%= @page_part.id %>'
pagePartNavId = '#' + '<%= @page_part.id %>' + '_nav'

if $(pagePartId).length
  $(pagePartId).fadeToggle 'slow', 'linear', ->
    $(this).next().remove()
    $(this).remove()
  
  $(pagePartNavId).fadeToggle 'slow', 'linear', ->
    $(this).remove()
    $('#page_parts_nav .tab').last().addClass('page_part_selected').addClass('selected')
    $('ul.page_part').last().removeClass('hidden')
    $('.delete_page_part').html('<%= delete_page_part %>')

