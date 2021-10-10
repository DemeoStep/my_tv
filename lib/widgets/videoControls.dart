import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pausable_timer/pausable_timer.dart';

class VideoControls extends StatelessWidget {
  bool isShowing;
  String filmName;
  String season;
  double progress;
  String strProgress = "";
  String strRemaining = "";
  bool isPlaying = true;
  late PausableTimer timer;

  BehaviorSubject<bool> show;
  BehaviorSubject<double> percent;

  VideoControls(this.isShowing, this.filmName, this.season, this.progress)
      : show = BehaviorSubject<bool>.seeded(isShowing),
        percent = BehaviorSubject<double>.seeded(progress);

  Future<void> showHideControls() async {
    isShowing = !isShowing;
    show.add(isShowing);
    if(isShowing && isPlaying) {
      timer..reset()..start();
    } else if(isShowing && !isPlaying) {
      timer..reset()..pause();
    }
  }

  Future<void> seeking() async {
    if(!isShowing) {
      show.add(true);
      timer..reset()..start();
    }
  }

  Future<void> onProgress(double progress) async{
    percent.add(progress);
    this.progress = progress;
  }

  void onTimer(){
    showHideControls();
  }

  @override
  Widget build(BuildContext context) {
    timer = PausableTimer(Duration(seconds: 3), () {
      onTimer();
    });

    return StreamBuilder<bool>(
        stream: show,
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return Stack(
              fit: StackFit.loose,
              children: [
                !isPlaying
                    ? Positioned.directional(
                  textDirection: TextDirection.ltr,
                  start: MediaQuery.of(context).size.width / 2 - 40,
                  top: MediaQuery.of(context).size.height / 2 - 40,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(50)),
                    height: 80,
                    width: 80,
                    child: Icon(
                      Icons.pause,
                      size: 60,
                      color: Colors.black,
                    ),
                  ),
                )
                : Container(),
                Positioned.directional(
                  textDirection: TextDirection.ltr,
                  top: 10,
                  start: 10,
                  child: Text(
                    "$filmName $season",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                Positioned.directional(
                  bottom: 10,
                  start: 10,
                  textDirection: TextDirection.ltr,
                  child: StreamBuilder<double>(
                    stream: percent,
                    builder: (context, snapshot) {
                      if(snapshot.data != null) {
                        var progress = snapshot.data;
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(strProgress, style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.86,
                            child: LinearProgressIndicator(
                                  value: progress,
                                  color: Colors.teal,
                                  backgroundColor: Colors.white.withOpacity(0.5),
                                )
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            child: Text('-$strRemaining', style: TextStyle(color: Colors.white)),
                          ),
                        ]
                      );
                    }
                  ),
                ),
              ],
            );
          } else
            return Container();
        });
  }
}
