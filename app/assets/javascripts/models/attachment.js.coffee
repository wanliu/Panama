# author : huxinghai
# describe : 附件前端模型

define(["jquery", "backbone", "exports"], ($, Backbone, exports) ->

    class exports.Attachment extends Backbone.Model
        urlRoot : ""
        idAttribute : "_id"

    class exports.AttachmentList extends Backbone.Collection
    	model : exports.Attachment

    exports
)