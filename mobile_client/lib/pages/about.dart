import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const Text(
              "Sobre",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_outlined),
              ),
            )),
        body: const Center(
          child: Text("Sobre a Roka...",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 25)),
        ));
  }
}
