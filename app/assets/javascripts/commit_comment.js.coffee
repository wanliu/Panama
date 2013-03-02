define ["jquery", "backbone", "exports", "comment"], ($, Backbone, exports, view) ->  
  class CommitComment extends view.CommentActivity

    initialize : (options) ->
      _.extend(this, options)

      @$comments = @$(".comments")
      $("#comment_template").hide()
      @all(this.targeable_id, (data, xhr) =>
        @$comments.html(data)
        @bind_event()
      )

    bind_event: () ->
      @$("form").on('submit', _.bind(@commitComment, @))


    commitComment: () ->
      array = @$("form").serializeArray()
      @send_comment(array, (data, xhr) =>
        $(".comment").before(@template.render(data))
      )
      false

  exports.CommitComment = CommitComment
  exports
