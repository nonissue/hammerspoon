console.log('JS injected!');

function testInjectJS() {
  console.log('LOADED!');
}

function togglePlayPause() {
  if ($('.show-video-player')) {
    var videoPlayer = $('.show-video-player');
    console.log('Toggle called!');
    sendProgress();
  }
}

function sendProgress() {
    var playerDetected = false;
    var isVideoPlaying = false;
    var isFinished = false;
    if ($('.show-video-player')) {
        playerDetected = true
    };


    webkit.messageHandlers.plexoverlay.postMessage({
        hasPlayer: playerDetected,
        isPlaying: isVideoPlaying,
        isFinished: isFinished,
  });
}
