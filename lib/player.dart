import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class Player extends StatelessWidget {
  List<BetterPlayerDataSource> dataSourceList;

  Player({required this.dataSourceList});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: BetterPlayerPlaylist(
          betterPlayerConfiguration: BetterPlayerConfiguration(
            autoPlay: true,
            fullScreenByDefault: true,
            controlsConfiguration: BetterPlayerControlsConfiguration(
              enableFullscreen: false,
              enableSkips: false,
              showControlsOnInitialize: false,
            )
          ),
          betterPlayerPlaylistConfiguration: const BetterPlayerPlaylistConfiguration(
            nextVideoDelay: const Duration(seconds: 0),
            loopVideos: false,
          ),
          betterPlayerDataSourceList: dataSourceList),
    );
  }
}

