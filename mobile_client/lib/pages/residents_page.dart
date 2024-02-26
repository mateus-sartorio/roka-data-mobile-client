import 'package:flutter/material.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/store/global_state.dart';
import 'package:provider/provider.dart';

class ResidentsPage extends StatefulWidget {
  const ResidentsPage({Key? key}) : super(key: key);

  @override
  State<ResidentsPage> createState() => _ResidentsPageState();
}

class _ResidentsPageState extends State<ResidentsPage> {
  GlobalDatabase db = GlobalDatabase();

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(
      builder: (context, value, child) => ListView.builder(
          itemCount: value.residents.length,
          itemBuilder: (context, index) => Center(
                child: Text(
                    "${value.residents[index].name} - ${value.residents[index].rokaId}"),
              )),
    );
  }
}
