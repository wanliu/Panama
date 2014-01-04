(function($){
  $.fn.columnview = function(options){
    this.settings = $.extend({}, $.fn.columnview.defaults, options);
    this.origid = this.attr('id');
    this.hide();
    var that = this
    
    function initialize(){      
      that.attr('id', that.origid + "-processed");
      generate_view();
      if($.browser.msie) { this.topdiv.width('150px'); }
      generate_item(that.children('li'))
      bind_event();
    }

    function generate_view(){
      that.container = $('<div></div>').addClass('containerobj').attr('id', that.origid).insertAfter(that);
      that.topdiv = $('<div class="top"></div>').appendTo(that.container)
    }

    function generate_item(items){
      $.each(items, function(i, item){
        var $item = $(item)

        var topitem = $(':eq(0)',$item).clone().data('sub', $item.children('ul')).appendTo(that.topdiv);
        if($(topitem).data('sub').length){
          $(topitem).addClass('hasChildMenu');
          addWidget(topitem);
        }
      });
    }



    function bind_event(){
      that.container.on("click", "a", function(event){
        var el = $(event.currentTarget)        
        var level = $('div',that.container).index(el.parents('div'));
        // Remove blocks to the right in the tree, and 'deactivate' other
        // links within the same level, if metakey is not being used
        $('div:gt('+level+')', that.container).remove();
        if (!event.metaKey && !event.shiftKey) {
          $('div:eq('+level+') a', that.container).removeClass('active').removeClass('inpath');
          $('.active', that.container).addClass('inpath')
          $('div:lt('+level+') a', that.container).removeClass('active');
        }
        // Select intermediate items when shift clicking
        // Sorry, only works with jQuery 1.4 due to changes in the .index() function
        if (event.shiftKey) {
          var first = $('a.active:first', el.parent()).index(),
              cur = el.index(),
              range = [first, cur].sort(function(a, b){return a - b;});

          $('div:eq('+level+') a', that.container).slice(range[0], range[1]).addClass('active');
        }

        el.addClass('active');
        if (el.data('sub').children('li').length && !event.metaKey) {
          // Menu has children, so add another submenu
          submenu(that.container, el);
        }
        event.preventDefault();
      })

      init();

      that.container.on("click", "a", function(event){
        var divs = that.container.find(">div:not(.feature)");
        var results = [], current_data = {};
        divs.each(function(){
          var $node = $(this).find(">a.active, >a.inpath");
          if($node){
            var data = {id:  $node.attr("data-id"), name: $node.attr("data-name") }
            $node.hasClass("active") ? current_data = data : results.push(data);
          }
        });
        if("" != options['ihid']){
          $("#" + that.origid + " input[id=" + options['ihid'] + "_id]").val(current_data.id);
        } else{
          that.settings.selector(results, current_data);
        }
      })

    }

    function event_dispose(event){
      if (!that.settings.multi) {
        delete event.shiftKey;
        delete event.metaKey;
      }
    }

    initialize()

    function init(){
      if("" != options['ihid']){
        $("<input type='hidden' id="+ options['ihid'] + "_id name="+ options['ihname'] +" value= "+ options['category_id'] +" >").appendTo("#" + that.origid);
        if(1 != options['length']){
          for (var i = 1; i <= options['length']; i++) {
            $("#" + that.origid + " a[data-id="+ options['ancestry'].split('/')[i] + "]").trigger("click");
          }
        }
        $("#" + that.origid + " a[data-id="+ options['category_id'] + "]").trigger("click");
      }
    }
    
  };
  
  $.fn.columnview.defaults = {
    multi: false,
    selector: function(data, current_data){ }
  };

  // Generate deeper level menus
  function submenu(container,item){
    var leftPos = 0;
    $.each($(container).children('div'),function(i,mydiv){
      leftPos += $(mydiv).width();
    });
    var submenu = $('<div/>').css({'top':0,'left':leftPos}).appendTo(container);
    if($.browser.msie) { $(submenu).width('200px'); } // Cuz IE don't support auto width
    var subitems = $(item).data('sub').children('li');
    $.each(subitems,function(i,subitem){
      var subsubitem = $(':eq(0)',subitem).clone().data('sub',$(subitem).children('ul')).appendTo(submenu);
      if($(subsubitem).data('sub').length) {
        $(subsubitem).addClass('hasChildMenu');
        addWidget(subsubitem);
      }
    });
  }

  // Uses canvas, if available, to draw a triangle to denote that item is a parent
  function addWidget(item, color){
    var triheight = $(item).height();
    var canvas = $("<canvas></canvas>").attr({height:triheight,width:10}).addClass('widget').appendTo(item);    
    if(!color){ color = $(canvas).css('color'); }
    canvas = $(canvas).get(0);
    if(canvas.getContext){
      var context = canvas.getContext('2d');
      context.fillStyle = color;
      context.beginPath();
      context.moveTo(3,(triheight/2 - 3));
      context.lineTo(10,(triheight/2));
      context.lineTo(3,(triheight/2 + 3));
      context.fill();
    } else {
      /**
       * Canvas not supported - put something in there anyway that can be
       * suppressed later if desired. We're using a decimal character here
       * representing a "black right-pointing pointer" in Windows since IE
       * is the likely case that doesn't support canvas.
       */
      $("<span>&#9658;</span>").addClass('widget').css({'height':triheight,'width':10}).prependTo(item);
    }
    $('.widget').bind('click', function(event){
      event.preventDefault();
    });
  }


})(jQuery);