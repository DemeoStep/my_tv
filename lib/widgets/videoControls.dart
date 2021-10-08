import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class VideoControls extends StatelessWidget {
  bool isShowing;
  String filmName;

  BehaviorSubject<bool> show;

  VideoControls(this.isShowing, this.filmName) : show = BehaviorSubject<bool>.seeded(isShowing);

  Future<void> showHideControls() async {
    isShowing = !isShowing;
    show.add(isShowing);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: show,
      builder: (context, snapshot) {
        if(snapshot.data == true) {
          return Stack(
            fit: StackFit.loose,
            children: [
              Positioned.directional(
                textDirection: TextDirection.rtl,
                start: MediaQuery.of(context).size.width / 2 - 40,
                top: MediaQuery.of(context).size.height / 2 - 40,
                child: Container(
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.3), borderRadius: BorderRadius.circular(50)),
                  height: 80,
                  width: 80,
                  child: Icon(Icons.pause, size: 60, color: Colors.black,),
                ),
              ),
             Text(filmName, style: TextStyle(color: Colors.white),),
            ],
          );
        } else return Container();
      }
    );
  }
}
