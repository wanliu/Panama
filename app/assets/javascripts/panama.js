//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require lib/jquery.raty
//= require lib/underscore
//= require backbone
//= require twitter/bootstrap
//= require h5bp
//= require lib/hogan
//= require lib/chosen.ex
//= require lib/postmessage
//= require lib/dnd
//= require wanliu/ajax_auth_client
//= require lib/realtime_client
//= require lib/image_natural_size
//= require lib/JNMagnifier
//= require lib/jquery.raty
//= require lib/jquery.columnview
//= require lib/bootstrap-datetimepicker.min
//= require lib/colorpicker/js/bootstrap-colorpicker
//= require lib/depend_select
//= require lib/spinner
//= require lib/notify
//= require lib/at_who
//= require lib/jquery.treeview
//= require lib/jquery.cookie

root = window || this;

var panle_modal = $("#login-modal");
AjaxAuthClient.setupRetrieveLoginUrlCallback(function(url){
    panle_modal.find("iframe").attr("src", url);
    panle_modal.modal("show");
})

AjaxAuthClient.registreLoginSuccess(function(user){
    panle_modal.modal("hide");
})

var load_modal_head_with_height = function(title, height){
    panle_modal.find(".modal-header>.context").html(title);
    panle_modal.find(".modal-body>iframe").animate({
        height : height
    })
}

AjaxAuthClient.registreLoadUserLogin(function(){
    load_modal_head_with_height("用户登陆", "200px");
})

AjaxAuthClient.registreLoadForgotPassword(function(){
    load_modal_head_with_height("找回密码", "130px");
})

AjaxAuthClient.registreLoadCreateUser(function(){
    load_modal_head_with_height("用户注册", "310px");
})

root.loadPage = function(query, url){
    $.get(url, {ajaxify: true}, function(data){
        $(query).replaceWith(data);
    });
}

$.ajaxSetup({
    beforeSend: function(xhr){
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
    }
})

