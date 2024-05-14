import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  // void _launchURL(Uri url) async {
  //   if (await canLaunchUrl(url)) {
  //     await launchUrl(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            scrolledUnderElevation: 0,
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
        body: Center(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: Image.asset(
                    "assets/images/logo.png",
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "A Roka é um projeto social focado em resolver o problema do plástico de forma inovadora. Através de educação ambiental e coleta personalizada, incentivamos a comunidade a se engajar na destinação adequada do plástico. Com nossa abordagem única, estamos criando um futuro mais sustentável para todos. Junte-se a nós nessa jornada! 🌍💚",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "Conheça mais sobre o projeto",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(FontAwesomeIcons.instagram, size: 30),
                    const SizedBox(
                      width: 10,
                    ),
                    RichText(
                      text: TextSpan(
                        text: "@projetoroka",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // String backendRoute =
                            // "https://www.instagram.com/projetoroka/";
                            // Uri uri = Uri.parse(backendRoute);
                            // _launchURL(uri);
                          },
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
