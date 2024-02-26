import 'package:flutter/material.dart';
import 'package:mobile_client/components/big_button_tile.dart';

class CloudSyncPage extends StatelessWidget {
  const CloudSyncPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BigButtonTile(
              content: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  Icons.download,
                  color: Colors.white,
                ),
                Text(
                  "Baixar dados",
                  style: TextStyle(color: Colors.white),
                )
              ]),
              onPressed: () {},
              isSolid: true),
          const SizedBox(
            height: 20,
          ),
          BigButtonTile(
              content: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  Icons.upload,
                  color: Colors.white,
                ),
                Text(
                  "Salvar dados",
                  style: TextStyle(color: Colors.white),
                ),
              ]),
              onPressed: () {},
              isSolid: true)
        ],
      ),
    );
  }
}
