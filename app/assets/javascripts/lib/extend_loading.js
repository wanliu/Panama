$.loading.initImg = function(l){
  var self = this;
  l.img = $('<img src="'+l.img+'"/>');
  l.display.addClass(l.imgClass).append(l.img);
  l.init.call(self, l);
}

$.extend($.loading.maskCss, { backgroundColor: "white", opacity: "0.4" })

$.loading.working.text = "请耐心等待...."
$.loading.error.text = "你的请求可能出错，请重新请求..."
$.loading.img = '/assets/loading.gif'