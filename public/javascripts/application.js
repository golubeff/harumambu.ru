// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//
$(document).ready(function(){
    
  $(window).scroll(function(){
    if ($(window).scrollTop() == $(document).height() - $(window).height()){
      if(!window.loading_more){
        window.loading_more = true;
        $('div#ris').html('<img src="/images/bigLoader.gif">');

        window.setTimeout( function(){
          var url = '/projects.js?last_id=' + $('.project:last').attr('id');
          if( document.location.href.match(/strict=1/) ) { url += '&strict=1&q=' + $('#stop_words').val() }
          $.get(url,
          function(data){
            if (data != "") {
              appendProject(eval('(' + data + ')'), true);
            }
            $('div#ris').empty();
            window.loading_more = false;
          });
        }, 0 );
      }
    }
  });

  setInterval( function(){
    if($('#pause:checked').val()){return false}
    var url = '/projects.js?first_id=' + $('.project:first').attr('id');
    if( document.location.href.match(/strict=1/) ) { url += '&strict=1&q=' + $('#stop_words').val() }
    $.ajax({
      'url': url, 
      'success': function(data){
        appendProject( eval('(' + data + ')') );
      }
    });
  }, 5000 );
});

function updateActivity(){
  window.activity_at = new Date;
}

$(document).keydown(updateActivity);
$(document).keyup(updateActivity);
$(document).mouseover(updateActivity);
$(document).mousemove(updateActivity);
$(window).load(updateActivity);
$(document).keydown(handlePause);

function handlePause(e){
  /*if(e.keyCode == 32){*/
  /*$('#pause').click();*/
  /*return false;*/
  /*}*/
}

function inactivityTime() { return (new Date - (isNaN(window.activity_at) ? 0 : window.activity_at)) / 1000; }

function removeProjects(amount){
  var projects = $('.project');
  if (projects.length > amount){
    for(var i=amount;i<projects.length;i++){
      $(projects[i]).remove();
    }
  }
}

function appendProject(json, after){
  if(!after&&inactivityTime() > 60*5&&inactivityTime() < 60 * 1000){
    removeProjects( 100 );
    /*if(!$('#pause:checked').val()){$('#pause').click()}*/
  }

  $(json).each( function(i, project) {
      /*if(!after || $('#source_' + project.klass + ':checked').length > 0){*/
      var r = 150 + Math.floor(Math.random() * 100);
      var g = 150 + Math.floor(Math.random() * 100)
      var b = 150 + Math.floor(Math.random() * 100);

      var strict = document.location.href.match(/strict=1/);
      var matches = false;
      if (!strict){
        var stop_words = $('#stop_words').val().replace(/,/g, ' ').replace(/ё/, 'е').split(/ +/);
        for(var i=0; !matches && i<stop_words.length; i++) {
          if(stop_words[i].match(/[^ ]/)){
            matches = (project.title + ' ' + project.desc).replace(/ё/, 'е').match(new RegExp(stop_words[i], 'i'));
          }
        }

        if (matches) { sound() }
      }

      html = 
        '<div style="background-color: ' + (window.first_id >= project.id ? '#cfcfcf' : 'rgb('+r+','+g+','+b+')') + '" class="project' + (matches ? ' match' : '') +'" id="' + project.id + '">' + 
        '<div id="projectop"></div>'+
        '<div id="projectzag"><img src="/images/icons/'+ project.icon +'.gif" alt="" />' + 
        '<h3>'+ (project.category != '' ? (project.category +' &raquo; ') : '') + '<a onclick="if($(\'#new_window:checked\').val()){window.open($(this).attr(\'href\'));return false;}else{return true}" href="' + project.url + '">' + project.title + '</a></h3>' +
        '</div>' +
        '<div id="projectzag_txt">'+
        '<p>' + project.desc + '</p>' +
        '</div>' +
        '<div id="projectcena">' + project.budjet+ '</div>' +
        '<div id="projectdata">' + project.created_at + '</div>' +
        '<div id="projectbottom"></div>'+
      '</div>';

      if( $('.project').length == 0 ) {
        $('#projects').html(html);
      }else if(after){
        $('.project:last').after(html);
      }else{
        document.title = '➘ ' + (project.budjet.match(/[^ ]/) ? project.budjet + " — " : "") + project.title.replace(/<.+?>/g, ' ');
        $('.project:first').before(html);
      }
      /*}else{*/
      /*window.console.log('skip: ' + project.klass);*/
      /*}*/
  } );
}

function sound(){
  var so = new SWFObject('/player.swf','flashContent','300','250','9');
  so.addParam('allowfullscreen','true');
  so.addParam('allowscriptaccess','always');
  so.addParam('bgcolor','#FFFFFF');
  so.addParam('flashvars','file=message.mp3&autostart=true');
  so.write('flashbanner');
}
