//var player, timer, timeSpent = [], display = document.getElementById('display');

//function onYouTubeIframeAPIReady() {
//    player = new YT.Player( 'player', {
//        events: { 'onStateChange': onPlayerStateChange }
//    });
//}

//function onPlayerStateChange(event) {
//    if(event.data === 1) { // Started playing
//        if(!timeSpent.length){
//            timeSpent = new Array( parseInt(player.getDuration()) );
//        }
//        timer = setInterval(record,100);
//    } else {
//        clearInterval(timer);
//    }
//}

//function record(){
//    timeSpent[ parseInt(player.getCurrentTime()) ] = true;
//    showPercentage();
//}

//function showPercentage(){
//    var percent = 0;
//    for(var i=0, l=timeSpent.length; i<l; i++){
//        if(timeSpent[i]) percent++;
//    }
//    percent = Math.round(percent / timeSpent.length * 100);
//    console.log(percent + "%");
//}
