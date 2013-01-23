# author : huxinghai
# describe : 附件前端模型

defind(["jquery", "backbone", "exports"], ($, Backbone, exports) ->

    class exports.Attachment extends Backbone.Model
        urlRoot : ""

    class exports.AttachmentList extends Backbone.Collection

)