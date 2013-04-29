
define ["jquery", "timeago"], ($) ->

  $.extend($.timeago.settings.strings, {
    suffixAgo: "前",
    suffixFromNow: "刚刚",
    seconds: "不到1分钟",
    minute: "约1分钟",
    minutes: "%d分钟",
    hour: "1小时",
    hours: "%d小时",
    day: "1天",
    days: "%d天",
    month: "1月",
    months: "%d月",
    year: "1年",
    years: "%d年",
  })