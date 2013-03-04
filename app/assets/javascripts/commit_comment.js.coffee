define ["jquery", "backbone", "exports", "comment"], ($, Backbone, exports, view) ->  
  class CommitComment extends view.CommentActivity


    initialize : (options) ->
      _.extend(@, options)

      @$comments = @$(".comments")
      @all(@targeable_id, 3, (data, xhr) =>
        @data_and_event(data)
      )


    bind_event: () ->
      @$("form").on('submit', _.bind(@commitComment, @))
      @$(".more").on("click", _.bind(@comment_all, @))


    comment_all: () ->
      @all(@targeable_id, 0, (data, xhr) =>
        @data_and_event(data)
        @$(".more").hide()
      )


    data_and_event: (data) ->
      @$comments.html(data)
      @bind_event()


    commitComment: () ->
      array = @$("form").serializeArray()
      @send_comment(array, (data, xhr) =>
        @$(".comments_div").append(@template.render(data))
        @$("textarea").val("")
      )
      false

  exports.CommitComment = CommitComment
  exports
