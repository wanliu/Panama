define(["jquery", "backbone", "exports", "comment"], ($, Backbone, exports, view) ->  
  class CommitComment extends view.CommentActivity
    
    initialize : (options) ->
      _.extend(this, options)
      @$("form").on('submit', _.bind(@commitComment, @))
      

    commitComment: () ->
      # $.ajax{
      #   url:  "new_activity_person_comments",
      #   success: function (){
          
      #   }
      # }
      # array = @$("form").serializeArray()

  exports.CommitComment = CommitComment
  exports
)