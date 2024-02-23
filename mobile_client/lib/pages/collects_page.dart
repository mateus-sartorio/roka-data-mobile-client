import 'package:flutter/material.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:mobile_client/store/global_state.dart';
import 'package:provider/provider.dart';

class CollectsPage extends StatefulWidget {
  const CollectsPage({Key? key}) : super(key: key);

  @override
  State<CollectsPage> createState() => _CollectsPageState();
}

class _CollectsPageState extends State<CollectsPage> {
  Resident? currentlySelected;

  final TextEditingController _weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(
        builder: (context, value, child) => Center(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownButtonFormField<Resident>(
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  width: 3, color: Colors.blue))),
                      onChanged: (item) => currentlySelected = item,
                      value: currentlySelected,
                      items: value.residents
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e.name)))
                          .toList(),
                    ),
                    TextField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                          hintText: "Peso [kg]", border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
            ));
  }
}
