var root = window || this

root.ShopAuthView = Backbone.View.extend({
  events: {
    'change #shop_auth_shop_name' : 'shop_url_by_shop_name'
  },

  shop_url_by_shop_name: function(e){
    var shop_name = $('#shop_auth_shop_name').val();
    $('#shop_auth_shop_url').val(shop_name);
  }
});