import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:mobile_client/components/big_button_tile.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/models/collect.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:mobile_client/store/global_state.dart';
import 'package:provider/provider.dart';

class CollectsPage extends StatefulWidget {
  const CollectsPage({Key? key}) : super(key: key);

  @override
  State<CollectsPage> createState() => _CollectsPageState();
}

class _CollectsPageState extends State<CollectsPage> {
  GlobalDatabase db = GlobalDatabase();

  Resident? selectedResident;
  DateTime? date;

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(" ")[0];
        date = picked;
      });
    }
  }

  Future<void> saveNewCollect() async {
    Collect newCollect = Collect(
        ammount: double.parse(_weightController.text),
        collectedOn: date!,
        id: -1,
        residentId: (selectedResident?.id)!,
        isNew: true);

    db.saveNewCollect(newCollect);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalState>(
        builder: (context, value, child) => Center(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                          labelText: "Data",
                          filled: true,
                          prefix: Icon(Icons.calendar_today),
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue))),
                      onTap: _selectDate,
                    ),
                    DropdownButtonFormField<Resident>(
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  width: 3, color: Colors.blue))),
                      onChanged: (item) => selectedResident = item,
                      value: selectedResident,
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
                    BigButtonTile(
                        content: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Salvar localmente",
                                style: TextStyle(color: Colors.white)),
                            Icon(Icons.save, color: Colors.white),
                          ],
                        ),
                        onPressed: saveNewCollect,
                        isSolid: true)
                  ],
                ),
              ),
            ));
  }
}
