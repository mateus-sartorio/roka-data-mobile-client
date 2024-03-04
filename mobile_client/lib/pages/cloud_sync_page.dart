import 'package:flutter/material.dart';
import 'package:mobile_client/components/big_button_tile.dart';

class CloudSyncPage extends StatelessWidget {
  const CloudSyncPage({Key? key}) : super(key: key);

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
          onPressed: () {},
          isSolid: true),
    );
  }
}
