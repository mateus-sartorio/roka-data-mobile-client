import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void showWarning(context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
          title: Text(
            message,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          contentPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 5),
          children: [
            MaterialButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  "Ok",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
          ]);
    },
  );
}

void showSyncingAnimation(context) {
  showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: const Text(
          "Só um momento...",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        contentPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 5),
        children: [
          Center(
            child: LoadingAnimationWidget.newtonCradle(
              color: Colors.black,
              size: 200,
            ),
          ),
        ],
      );
    },
  );
}
