import 'package:flutter/material.dart';
import 'package:mobile_client/components/big_button_tile.dart';
import 'package:mobile_client/data/database.dart';

class CloudSyncPage extends StatefulWidget {
  const CloudSyncPage({Key? key}) : super(key: key);

  @override
  State<CloudSyncPage> createState() => _CloudSyncPageState();
}

class _CloudSyncPageState extends State<CloudSyncPage> {
  GlobalDatabase db = GlobalDatabase();

  void showWarning() {
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

  void showSuccessMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
            title: const Text(
              "Dados atualizados com sucesso.",
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

  void syncData() async {
    try {
      await db.syncDataWithBackend();
      await Future.delayed(const Duration(seconds: 1));
      await db.fetchDataFromBackend();
      showSuccessMessage();
    } catch (e) {
      showWarning();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}
