import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';
import 'widgets/videoControls.dart';
import 'package:wakelock/wakelock.dart';

class ShowControls extends Intent {}
class PlayPause extends Intent {}
class SeekForward extends Intent {}
class SeekBackward extends Intent {}
class NextVideo extends Intent {}
class PreviousVideo extends Intent {}

class ChewiePlayer extends StatefulWidget {
  List<String> playlist;
  BehaviorSubject<bool> onPlay;
  bool isPlaying = true;
  int index;
  String filmName;
  String season;

  ChewiePlayer(this.isPlaying, {required this.playlist, required this.index, required this.filmName, required this.season}) : onPlay = BehaviorSubject<bool>.seeded(isPlaying);

  @override
  _ChewiePlayerState createState() => _ChewiePlayerState();
}

class _ChewiePlayerState extends State<ChewiePlayer> {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  bool playing = true;

  var controls = VideoControls(false, "", "", 0.0);

  late Timer _timer;

  late final VoidCallback onPlayPause = () {
    playPause();
    controls.isPlaying = playing;
    controls.showHideControls();
  };

  late final VoidCallback onSeekForward = () {
    forward();
  };

  late final VoidCallback onSeekBackward = () {
    backward();
  };

  late final VoidCallback onNextVideo = () {
    next();
  };

  late final VoidCallback onPrevVideo = () {
    previous();
  };
  
  late final VoidCallback onShowControls = () {
    showControls();
  };

  final playPauseKey = LogicalKeySet(LogicalKeyboardKey.mediaPlayPause);
  final seekForwardKey = LogicalKeySet(LogicalKeyboardKey.arrowRight);
  final seekBackwardKey = LogicalKeySet(LogicalKeyboardKey.arrowLeft);
  final playNextKey = LogicalKeySet(LogicalKeyboardKey.mediaFastForward);
  final playPrevKey = LogicalKeySet(LogicalKeyboardKey.mediaRewind);
  final showControlsKey = LogicalKeySet(LogicalKeyboardKey.select);
  final enterKey = LogicalKeySet(LogicalKeyboardKey.enter);

  bool isEnded = false;


  @override
  initState(){
    super.initState();
    initControllers(widget.index, context);
  }

  @override
  void dispose() {
    widget.playlist.clear();
    videoPlayerController!.dispose();
    chewieController!.dispose();
    _timer.cancel();
    Wakelock.disable();
    super.dispose();
  }

  void showControls() {
    if(playing) {
      controls.isPlaying = playing;
      controls.showHideControls();
    } else {
      onPlayPause.call();
    }
  }

  void progress() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      var percent = videoPlayerController!.value.position.inSeconds / videoPlayerController!.value.duration.inSeconds;
      controls.onProgress(percent);
      var progress = videoPlayerController!.value.position.toString();
      var remaining = (videoPlayerController!.value.duration - videoPlayerController!.value.position).toString();
      controls.strProgress = progress.substring(0, progress.indexOf('.'));
      controls.strRemaining = remaining.substring(0, remaining.indexOf('.'));
    });
  }

  void playPause() async {
    if(playing) {
        chewieController!.pause(); playing = false;
    } else {
      chewieController!.play(); playing = true;
    }
  }

  void forward() async {
    chewieController!.seekTo(Duration(seconds: videoPlayerController!.value.position.inSeconds + 10));
    controls.seeking();
  }

  void backward() async {
    chewieController!.seekTo(Duration(seconds: videoPlayerController!.value.position.inSeconds - 10));
    controls.seeking();
  }
  
  void next() {
    if (widget.index < widget.playlist.length - 1) {
      widget.index++;

      videoPlayerController!.dispose();
      chewieController!.dispose();
      initControllers(widget.index, context);
    } 
  }

  void previous() {
    if (widget.playlist.length > 1 && widget.index > 0) {
      widget.index--;

      videoPlayerController!.dispose();
      chewieController!.dispose();
      initControllers(widget.index, context);
    }
  }

  void _videoListener(BuildContext context) {
    if (!isEnded && videoPlayerController!.value.isInitialized) {
      if (!videoPlayerController!.value.isPlaying &&
          videoPlayerController!.value.position ==
              videoPlayerController!.value.duration) {
        isEnded = true;

        if (widget.index < widget.playlist.length - 1) {
          widget.index++;

          videoPlayerController!.dispose();
          chewieController!.dispose();
          initControllers(widget.index, context);
        } else {
          Navigator.of(context).pop();
        }
      }
    }
  }

  void initControllers(int index, BuildContext context) async {
    controls = VideoControls(false, widget.filmName, widget.season == "" ? "" : "(${widget.season} сезон ${widget.index + 1} серия)", 0.0);
    isEnded = false;
    videoPlayerController = VideoPlayerController.network(widget.playlist[index]);
    videoPlayerController!.addListener(
      () {
        _videoListener(context);
      },
    );
    await videoPlayerController!.initialize();
    chewieController = ChewieController(
      overlay: controls,
      fullScreenByDefault: true,
      showControlsOnInitialize: false,
      showControls: false,
      autoInitialize: true,
      aspectRatio: videoPlayerController!.value.size.aspectRatio,
      videoPlayerController: videoPlayerController!,
      autoPlay: true,
      looping: false,
    );

    chewieController!.play().then((value) {
      widget.onPlay.add(true);
    });

    progress();
  }

  @override
  Widget build(BuildContext context) {
    controls.filmName = widget.filmName;
    Wakelock.enable();

    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<bool>(
        stream: widget.onPlay,
        builder: (context, snapshot) {
          return FocusableActionDetector(
            autofocus: true,
            shortcuts: {
              showControlsKey: PlayPause(),
              playPauseKey: PlayPause(),
              enterKey: PlayPause(),
              seekForwardKey: SeekForward(),
              seekBackwardKey: SeekBackward(),
              playNextKey: NextVideo(),
              playPrevKey: PreviousVideo(),
            },
            actions: {
              ShowControls:
              CallbackAction(onInvoke: (e) => onShowControls.call()),
              PlayPause:
              CallbackAction(onInvoke: (e) => onPlayPause.call()),
              SeekForward:
              CallbackAction(onInvoke: (e) => onSeekForward.call()),
              SeekBackward:
              CallbackAction(onInvoke: (e) => onSeekBackward.call()),
              NextVideo:
              CallbackAction(onInvoke: (e) => onNextVideo.call()),
              PreviousVideo:
              CallbackAction(onInvoke: (e) => onPrevVideo.call()),
            },
            child: chewieController != null ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                onPlayPause.call();
                },
              child: Chewie(
                key: UniqueKey(),
                  controller: chewieController!),
            ) :
            Container(),
          );
        }
      ),
    );
  }
}
