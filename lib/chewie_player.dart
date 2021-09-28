import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';

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

  ChewiePlayer(this.isPlaying, {required this.playlist, required this.index}) : onPlay = BehaviorSubject<bool>.seeded(isPlaying);

  @override
  _ChewiePlayerState createState() => _ChewiePlayerState();
}

class _ChewiePlayerState extends State<ChewiePlayer> {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  bool playing = true;

  late final VoidCallback onPlayPause = () {
    playPause();
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
  final controlsShowKey = LogicalKeySet(LogicalKeyboardKey.select);
  final playNextKey = LogicalKeySet(LogicalKeyboardKey.mediaFastForward);
  final playPrevKey = LogicalKeySet(LogicalKeyboardKey.mediaRewind);
  final showControlsKey = LogicalKeySet(LogicalKeyboardKey.select);

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
    super.dispose();
  }

  void showControls() {
    print('SHOW COLTROLS!!!!!');
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
  }

  void backward() async {
    chewieController!.seekTo(Duration(seconds: videoPlayerController!.value.position.inSeconds - 10));
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
        print('is ended');

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
    isEnded = false;
    videoPlayerController = VideoPlayerController.network(widget.playlist[index]);
    videoPlayerController!.addListener(
      () {
        _videoListener(context);
      },
    );
    await videoPlayerController!.initialize();
    chewieController = ChewieController(
      showControlsOnInitialize: true,
      showControls: true,
      autoInitialize: true,
      aspectRatio: videoPlayerController!.value.size.aspectRatio,
      videoPlayerController: videoPlayerController!,
      autoPlay: true,
      looping: false,
    );

    chewieController!.play().then((value) {
      widget.onPlay.add(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<bool>(
        stream: widget.onPlay,
        builder: (context, snapshot) {
          return FocusableActionDetector(
            autofocus: true,
            shortcuts: {
              showControlsKey: ShowControls(),
              playPauseKey: PlayPause(),
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
            child: chewieController != null ? Chewie(
              key: UniqueKey(),
                controller: chewieController!) :
            Container(),
          );
        }
      ),
    );
  }
}
