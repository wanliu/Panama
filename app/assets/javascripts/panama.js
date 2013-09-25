//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require core_extend/core
//= require lib/jquery.raty
//= require lib/jquery.resize
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
//= require lib/jquery.slimscroll
//= require lib/bootstrap-datetimepicker.min
//= require lib/colorpicker/js/bootstrap-colorpicker
//= require lib/depend_select
//= require lib/spinner
//= require lib/notify
//= require lib/at_who
//= require lib/stroll
//= require lib/jquery.treeview
//= require lib/jquery.cookie
//= require left_sidebar
//= require topbar
//= require social_networking/transaction_chat_remind
//= require social_networking/right_sidebar
//= require social_networking/right_sidebar_friends
//= require social_networking/right_sidebar_notifications
//= require pick_product
//= require typeaheadExtension
//= require lib/activity_base_info
//= require ask_buy
//= require bootstrap-editable
//= require activity


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