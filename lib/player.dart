import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Player extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  bool looping = false;

  Player({required this.videoPlayerController, required this.looping});

  @override
  _Player createState() => _Player();
}

class _Player extends State<Player> {
  var videosController;

  @override
  void initState() {
    super.initState();

    videosController = ChewieController(
      fullScreenByDefault: true,
      autoPlay: true,
      videoPlayerController: widget.videoPlayerController,
      aspectRatio: 16 / 9,
      autoInitialize: true,
      looping: widget.looping,
      errorBuilder: (context, errorMessage) {
        return Center(child: progressBar());
      },
    );
  }

  Widget progressBar() {
    return CircularProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Chewie(
        controller: videosController,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    // IMPORTANT to dispose of all the used resources
    // widget.videoPlayerController.dispose();
    videosController.dispose();
  }
}
