import 'package:flutter/material.dart';
import 'package:mobile_client/store/global_state.dart';
import 'package:provider/provider.dart';

class ResidentsPage extends StatelessWidget {
  const ResidentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(
      builder: (context, value, child) => ListView.builder(
          itemCount: value.residents.length,
          itemBuilder: (context, index) => Text(value.residents[index].name)),
    );
  }
}
