$('#comments-list').prepend("<%=j render(partial: 'comment', object: @comment) %>")