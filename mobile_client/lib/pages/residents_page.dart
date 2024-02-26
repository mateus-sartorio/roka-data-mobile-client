import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_client/data/database.dart';

class ResidentsPage extends StatefulWidget {
  const ResidentsPage({Key? key}) : super(key: key);

  @override
  State<ResidentsPage> createState() => _ResidentsPageState();
}

class _ResidentsPageState extends State<ResidentsPage> {
  GlobalDatabase db = GlobalDatabase();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box('globalDatabase').listenable(),
        builder: (context, Box box, _) {
          final value = box.get("RESIDENTS");
          return ListView.builder(
              itemCount: value?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(value?[index]?.name ?? ""),
                  onTap: () {},
                  leading: const Icon(Icons.person),
                  trailing: const Icon(Icons.assignment),
                );
              });
        });
  }
}
