(function(){
  var parseDate = function(dateTxt) {
    var m = dateTxt.match(/^(\d\d\d\d)\-(\d\d)?\-(\d\d)?/);
    var dt = new Date();
    if (m) {
      dt.setFullYear(parseInt(m[1],10));
      dt.setMonth(parseInt(m[2],10) - 1);
      dt.setDate(parseInt(m[3],10));
    }
    return dt;
  };

  $(document).delegate('a.jquery-simpledatepicker-CalendarBut','click',function(e) {
    e.preventDefault();
    var $t = $(this); 
    var $datepicker = $t.next('.jquery-simpledatepicker-datepicker');
    if ($datepicker.length == 1) {
      $datepicker.remove();
      return true;
    }
    var $inp = $t.prev('input');
    if ($inp.length == 0) return true;

    var dt = parseDate($inp.val());
    $datepicker = $('<div class=jquery-simpledatepicker-datepicker>');
    $datepicker.delegate('a','click',function(e){
      e.preventDefault();
      var cls = this.className;
      if (/prev/.test(cls)) {
        dt.setMonth(dt.getMonth()-1);
        $datepicker.html(getDayPicker(dt));
      } else if (/next/.test(cls)) {
        dt.setMonth(dt.getMonth()+1);
        $datepicker.html(getDayPicker(dt));
      }
      else if (/TodayBut/.test(cls)) {
        dt = new Date();
        var year = dt.getFullYear();
        var month = dt.getMonth() + 1;
        month = month.toString().replace(/^(\d)$/,"0$1");
        var day = dt.getDate().toString().replace(/^(\d)$/,"0$1");
        var newDate = year+'-'+month+'-'+day;
        var m = $.trim($inp.val()).match(/^\d{4}\-\d\d?\-\d\d?\b(.+)/);
        if (m) newDate += m[1];
        $inp.val(newDate);
        $datepicker.remove();
      }
      else if (/CloseBut/.test(cls)) {
        $datepicker.remove();
      }
      else {
        var year = dt.getFullYear();
        var month = dt.getMonth() + 1;
        if (/preday/.test(cls)) {
          if (month==1) { month=12; --year; }
          else --month;
        }
        else if (/postday/.test(cls)) {
          if (month==12) { month=1; ++year; }
          else ++month;
        }
        month = month.toString().replace(/^(\d)$/,"0$1");
        var day = $(this).text().replace(/^(\d)$/,"0$1");
        var newDate = year+'-'+month+'-'+day;
        var m = $.trim($inp.val()).match(/^\d{4}\-\d\d?\-\d\d?\b(.+)/);
        if (m) newDate += m[1];
        $inp.val(newDate);
        $datepicker.remove();
      }
      return false;
    });
    $datepicker.html(getDayPicker(dt));
    $t.after($datepicker);

    setTimeout(function(){
      $(document).one('click', function() {
        $datepicker.remove();
        return true;
      });
    },1);

    return true; 
  });
  var getDayPicker = function(dt) {
    var mon = dt.getMonth(), year = dt.getFullYear();
    var monTxt = dt.toDateString().match(/^\w+\ (\w+)/)[1];
    var startDayOfWeek = (new Date(year,mon,1)).getDay();
    var daysThisMonth = 32-new Date(year,mon,32).getDate();
    var daysLastMonth = 32-((mon==0)?new Date(year-1,1,32):new Date(year,mon-1,32)).getDate();
    var today = new Date();
    if (today.getFullYear() == year &&
        today.getMonth() == mon) today = today.getDate();
    else today = 0;
    var buf='<a class=jquery-simpledatepicker-prevmonthbut>&lt;</a><span class=jquery-simpledatepicker-datetxt>'+monTxt+' '+year+'</span><a class=jquery-simpledatepicker-nextmonthbut>&gt;</a><span>Sun</span><span>Mon</span><span>Tues</span><span>Wed</span><span>Thur</span><span>Fri</span><span>Sat</span>';
    for (var i=daysLastMonth-startDayOfWeek+1;i<=daysLastMonth;++i)
      buf+='<a class=jquery-simpledatepicker-preday>'+i+'</a>'; 
    for (var i=1;i<=daysThisMonth;++i)
      buf+='<a'+((i == today)?' class=jquery-simpledatepicker-datepickertoday':'')+'>'+i+'</a>';
    for (var i=1,l=42-startDayOfWeek-daysThisMonth;i<=l;++i)
      buf+='<a class=jquery-simpledatepicker-postday>'+i+'</a>'; 
    buf += '<a class=jquery-simpledatepicker-CalendarTodayBut>today</a><a class=jquery-simpledatepicker-CalendarCloseBut>close</a>';
    return buf;
  };
})();
