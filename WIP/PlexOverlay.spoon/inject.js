// document.write(
//   unescape("%3Cscript src='https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js' type='text/javascript'%3E%3C/script%3E")
// );

/* css tweaks - overcast.com doesn't allow css injection via traditional means */

$('.navlink:eq(1), #speedcontrols').hide();
$('h2.ocseparatorbar:first()').css({
  marginTop: '0px',
});

if ($('#audioplayer').length > 0) {
  $('a.ocbutton[href="/podcasts"]').hide();
  $('h2').css({
    fontSize: '18px',
  });
  $('.titlestack')
    .prev()
    .removeClass('marginbottom1')
    .css({
      marginBottom: '8px',
    });
  $('#progressbar').css({
    marginTop: '8px',
  });
  $('.fullart_container').css({
    float: 'left',
    width: '20%',
  });
  $('#speedcontrols')
    .next()
    .css({
      clear: 'both',
      fontSize: '12px',
      marginTop: '20px',
    });
  $('#playcontrols_container').css({
    margin: '13px 0px 13px 20%',
    width: '80%',
  });
}

var progress = 0;

function sendProgress() {
  var isVideoPlaying = false;
  var isFinished = false;
  if ($('.show-video-player').length > 0) {
    if (!$('[aria-lable='Pause']') {
      isVideoPlaying = true;
    }
    var videoPlayerProgress = document.getElementById("data-qa-id='mediaDuration']").val();
    // progress = audioPlayer.currentTime / audioPlayer.duration;
    progress = parseInt(videoPlayerProgress)
    if (progress == 1) {
      isFinished = true;
    }
  }
  if (!progress) {
    progress = 0;
  }
  webkit.messageHandlers.plexoverlay.postMessage({
    hasPlayer: true,
    isPlaying: isVideoPlaying,
    isFinished: isFinished,
    progress: progress,
    // podcast: {
    //   name: $('h3 a').html(),
    //   episodeTitle: $('h2').html(),
    // },
  });
}

console.log("JS injected!")

function togglePlayPause() {
  if ($('#audioplayer').length > 0) {
    var audioPlayer = $('#audioplayer').first();
    if (audioPlayer.prop('paused')) {
      audioPlayer[0].play();
    } else {
      audioPlayer[0].pause();
    }
    sendProgress();
  }
}

if (window.location.href == thome) {
  webkit.messageHandlers.plexoverlay.postMessage({
    page: 'home',
  });
  setTimeout(function() {
    location.reload();
  }, 60 * 1000);
} else if ($('h3').length > 0) {
  sendProgress();
  setTimeout(function() {
    sendProgress();
  }, 2 * 1000);
  setInterval(function() {
    sendProgress();
  }, 5 * 1000);
}

var test = console.log("LOADED!")

if (window.location.href == thome) {
  webkit.messageHandlers.plexyoverlay.postMessage({
    page: 'home',
  });
  setTimeout(function() {
    location.reload();
  }, 60 * 1000);
} else if ($('.show-video.player').length > 0) {
  sendProgress();
  setTimeout(function() {
    sendProgress();
  }, 2 * 1000);
  setInterval(function() {
    sendProgress();
  }, 5 * 1000);
}
