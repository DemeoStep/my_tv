import 'package:download_assets/download_assets.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:rxdart/rxdart.dart';

class UpgradeScreen extends StatelessWidget {

  bool downloaded = false;
  double percents = 0.0;

  BehaviorSubject<double> onPercents;

  UpgradeScreen(this.percents) : onPercents = BehaviorSubject<double>.seeded(percents);

  UpgradeScreen.newUp() : this(0);

  void changePercents(double percents) {
    onPercents.add(percents);
    this.percents = percents;
  }

  Future _downloadAssets(BuildContext context) async {
    try {
      await DownloadAssetsController.startDownload(
          assetsUrl: 'http://demeo.euronet.dn.ua/mytv/app-release.zip',
          onProgress: (progressValue) {
            downloaded = false;
            changePercents(progressValue);
          },
          onComplete: () {
            downloaded = true;
          },
          onError: (exception) {
            downloaded = false;
            print("Error: ${exception.toString()}");
          });
    } on DownloadAssetsException catch (e) {
      print(e.toString());
    }
  }

  Future<void> download(BuildContext context) async {
    _downloadAssets(context).then((value) {
      DownloadAssetsController.assetsFileExists('app-release.apk')
          .then((exist) {
        if (exist && downloaded) {
          OpenFile.open(
              '${DownloadAssetsController.assetsDir}/app-release.apk').then((value) {
                Navigator.of(context).pop();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    download(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 6, color: Colors.red,),
            Container(
              margin: EdgeInsets.only(left: 20),
                child: StreamBuilder<double>(
                  stream: onPercents,
                  builder: (context, snapshot) {
                    return Text('Скачиваю обновление ${snapshot.data!.toStringAsFixed(2)}%', style: TextStyle(color: Colors.white, fontSize: 20),);
                  }
                )),
          ],
        ),
      ),
    );
  }
}
