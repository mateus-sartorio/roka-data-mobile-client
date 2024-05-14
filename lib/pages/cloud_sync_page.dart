import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_client/components/big_button_tile.dart';
import 'package:mobile_client/data/database.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CloudSyncPage extends StatefulWidget {
  const CloudSyncPage({Key? key}) : super(key: key);

  @override
  State<CloudSyncPage> createState() => _CloudSyncPageState();
}

class _CloudSyncPageState extends State<CloudSyncPage> {
  GlobalDatabase db = GlobalDatabase();

  void showWarning() {
    Navigator.of(context).pop(true);
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
            title: const Text(
              "Erro ao enviar dados para o servidor, tente novamente.",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            contentPadding:
                const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 5),
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

  void showSyncingAnimation() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text(
            "Só um momento...",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          contentPadding:
              const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 5),
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

  void showSuccessMessage() {
    Navigator.of(context).pop(true);
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
            title: const Text(
              "Dados atualizados com sucesso.",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            contentPadding:
                const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 5),
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

  void syncData() async {
    try {
      showSyncingAnimation();
      await db.sendDataToBackend();
      await Future.delayed(const Duration(seconds: 2));
      await db.fetchDataFromBackend();
      showSuccessMessage();
    } catch (e) {
      showWarning();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        FadeEffect(
          duration: Duration(milliseconds: 200),
        )
      ],
      child: Center(
        child: BigButtonTile(
            color: Colors.black,
            content: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                Icons.cloud_sync,
                color: Colors.white,
              ),
              Text(
                "   Sincronizar dados",
                style: TextStyle(color: Colors.white),
              ),
            ]),
            onPressed: syncData,
            isSolid: true),
      ),
    );
  }
}
