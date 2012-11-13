function go_url(url){
  window.location.href = url
}

function open_url(url){
  window.open(url)
}

function confirm_url(txt,url){
  if(confirm(txt)) go_url(url)
}

function cancel(){
  var n = ($.browser.msie ? 0 : 1)
  history.length>n ? history.back() : window.close()
}