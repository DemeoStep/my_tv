import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayPause extends Intent {}

class Player extends StatelessWidget {
  List<BetterPlayerDataSource> dataSourceList = [];
  bool playing = true;

  late final VoidCallback onPlayPause = () {
    playPause();
  };

  final playPauseKey = LogicalKeySet(LogicalKeyboardKey.mediaPlayPause);

  late var _controller = BetterPlayerPlaylistController(
    dataSourceList,
    betterPlayerConfiguration: BetterPlayerConfiguration(
        placeholderOnTop: false,
        showPlaceholderUntilPlay: false,
        autoPlay: true,
        fullScreenByDefault: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableFullscreen: false,
          enableSkips: true,
          showControlsOnInitialize: false,
          showControls: false,
          enableMute: false,
          enableProgressBarDrag: true,
          forwardSkipTimeInMilliseconds: 10000000,
        )),
    betterPlayerPlaylistConfiguration: const BetterPlayerPlaylistConfiguration(
      nextVideoDelay: const Duration(seconds: 0),
      loopVideos: false,
    ),
  );

  Player(this.dataSourceList);

  void playPause() async {
    print(playing);
    playing
        ? _controller.betterPlayerController!.pause()
        : _controller.betterPlayerController!.play();
  }

  @override
  Widget build(BuildContext context) {
    _controller.betterPlayerController!.play();

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: FocusableActionDetector(
        autofocus: true,
        shortcuts: {
          playPauseKey: PlayPause(),
        },
        actions: {
          PlayPause:
          CallbackAction(onInvoke: (e) => onPlayPause.call()),
        },
        child: Center(),
        // child: BetterPlayerPlaylist(
        //   betterPlayerConfiguration: _controller.betterPlayerConfiguration,
        //   betterPlayerDataSourceList: dataSourceList,
        //   betterPlayerPlaylistConfiguration:
        //       _controller.betterPlayerPlaylistConfiguration,
        // ),
      ),
    );
  }
}
