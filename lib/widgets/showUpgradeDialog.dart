import 'package:flutter/material.dart';
import 'package:my_tv/screens/upgradeScreen.dart';

Future<void> showUpgradeDialog({required BuildContext context, required String description}) async {
  showDialog(context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text(description),
        actions: <Widget>[
          OutlinedButton(
            child: Text("Нет"),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
          OutlinedButton(
            child: Text("Да"),
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UpgradeScreen.newUp()));
            },
          ),
        ],
      );
    },
  );
}