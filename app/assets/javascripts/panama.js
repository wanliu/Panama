define(function(require, exports, module){
    var $ = require('jquery');      
    var $ = require('jquery-ui');
    var h5bp = require('h5bp');
    var chosen = require('lib/chosen.ex');
    var pm = require("lib/postmessage");
    var ajax_auth = require('wanliu/ajax_auth_client');    

    AjaxAuthClient.setupRetrieveLoginUrlCallback(function(url){ 
        var panle = $("#login-modal");
        panle.find("iframe").attr("src", url);
        panle.modal("show");               
    })

    AjaxAuthClient.registreLoginSuccess(function(user){
        $("#login-modal").modal("hide");        
    })

    var load_modal_head = function(title, height){
        $("#login-modal").find(".modal-header>.context").html(title);
        $("#login-modal").find(".modal-body>iframe").animate({
            height : height
        })
    }

    AjaxAuthClient.registreLoadUserLogin(function(){
        load_modal_head("用户登陆", "200px");
    })

    AjaxAuthClient.registreLoadForgotPassword(function(){
        load_modal_head("找回密码", "130px");
    })

    AjaxAuthClient.registreLoadCreateUser(function(){
        load_modal_head("用户注册", "310px");
    })
    
    exports.loadPage = function(query, url){
        $.get(url, {ajaxify: true}, function(data){
            $(query).replaceWith(data);
        });
    }   
});

