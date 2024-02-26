import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class CollectsPage extends StatefulWidget {
  const CollectsPage({Key? key}) : super(key: key);

  @override
  _CollectsPageState createState() => _CollectsPageState();
}

class _CollectsPageState extends State<CollectsPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box('globalDatabase').listenable(),
        builder: (context, Box box, _) {
          final collects = box.get("COLLECTS");
          final residents = box.get("RESIDENTS");
          return ListView.builder(
              itemCount: collects?.length ?? 0,
              itemBuilder: (context, index) {
                String residentName = residents?[index].name ?? "";
                String weight = collects?[index]?.ammount.toString() ?? "";
                return ListTile(
                  title: Text("${residentName} - ${weight} kg"),
                  onTap: () {},
                  leading: const Icon(Icons.person),
                  trailing: const Icon(Icons.assignment),
                );
              });
        });
  }
}
