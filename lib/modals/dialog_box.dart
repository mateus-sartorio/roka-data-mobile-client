import 'package:flutter/material.dart';

class DialogBox extends StatelessWidget {
  final String title;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const DialogBox(
      {Key? key,
      required this.title,
      required this.onSave,
      required this.onCancel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
        title: Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        contentPadding:
            const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 5),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                      onPressed: onSave,
                      child: const Text(
                        "Sim",
                        style: TextStyle(fontSize: 16),
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  MaterialButton(
                      onPressed: onCancel,
                      child: const Text("Cancelar",
                          style: TextStyle(fontSize: 16))),
                ],
              )
            ],
          ),
        ]);
  }
}
