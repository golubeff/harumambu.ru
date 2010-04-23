// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//
$(document).ready(function(){
  $(window).scroll(function(){
    if ($(window).scrollTop() == $(document).height() - $(window).height()){
      $('div#loader').html('<img src="/images/bigLoader.gif">');

      window.setTimeout( function(){
        $.get("/projects.js?last_id=" + $('.project:last').attr('id'),
        function(data){
          if (data != "") {
            appendProject(eval('(' + data + ')'), true);
          }
          $('div#loader').empty();
        });
      }, 0 );
    }
  });

  setInterval( function(){
    $.ajax({
      'url': '/projects.js?first_id=' + $('.project:first').attr('id'), 
      'success': function(data){
        appendProject( eval('(' + data + ')') );
      }
    });
  }, 5000 );
});

function appendProject(json, after){
  $(json).each( function(i, project) {
    var r = 150 + Math.floor(Math.random() * 100);
    var g = 150 + Math.floor(Math.random() * 100)
    var b = 150 + Math.floor(Math.random() * 100);

    var stop_words = $('#stop_words').val().replace(/,/, ' ').split(/ +/);
    var matches = false;
    for(var i=0; !matches && i<stop_words.length; i++) {
      matches = (project.url + ' ' + project.budjet + ' ' + project.title + ' ' + project.desc).match(new RegExp(stop_words[i], 'i'));
    }

    if (matches) { sound() }

    html = '<div style="background: rgb('+r+','+g+','+b+')" class="project '+ (matches ? 'match' : '') +'" id="' + project.id + '">' + 
      '<strong>' + project.budjet + '</strong>' +
      '<h3><a href="' + project.url + '">' + project.title + '</a></h3>' +
      '<p>' + project.desc + '</p>' +
      '<div class="created_at">' + project.created_at + '</div>' +
    '</div>';

    if( $('.project').length == 0 ) {
      $('#projects').html(html);
    }else if(after){
      $('.project:last').after(html);
    }else{
      document.title = '➘ ' + (project.budjet.match(/[^ ]/) ? project.budjet + " — " : "") + project.title;
      $('.project:first').before(html);
    }
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
