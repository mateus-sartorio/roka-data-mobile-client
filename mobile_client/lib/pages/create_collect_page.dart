import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_client/components/big_button_tile.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:mobile_client/models/collect.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:mobile_client/utils/integer_id_generator.dart';

class CreateCollectPage extends StatefulWidget {
  final Collect? collect;
  final String text;

  const CreateCollectPage({Key? key, this.collect, required this.text})
      : super(key: key);

  @override
  State<CreateCollectPage> createState() => _CreateCollectPageState();
}

class _CreateCollectPageState extends State<CreateCollectPage> {
  GlobalDatabase db = GlobalDatabase();

  Resident? selectedResident;
  DateTime? selectedDate;
  bool isNewCollect = true;

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    if (widget.collect != null) {
      selectedDate = widget.collect?.collectedOn;
      selectedResident = db.getResidentById(widget.collect?.residentId ?? 0);
      _weightController.text = widget.collect?.ammount.toString() ?? "";
      isNewCollect = false;
    } else {
      selectedDate = DateTime.now();
    }

    List<String> dayMonthYear =
        selectedDate.toString().split(" ")[0].split("-");
    _dateController.text =
        "${dayMonthYear[2]}/${dayMonthYear[1]}/${dayMonthYear[0]}";

    super.initState();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        List<String> dayMonthYear = picked.toString().split(" ")[0].split("-");
        _dateController.text =
            "${dayMonthYear[2]}/${dayMonthYear[1]}/${dayMonthYear[0]}";
        selectedDate = picked;
      });
    }
  }

  void warnInvalidRegistrationData(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
            title: Text(
              message,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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

  bool isFormOk() {
    RegExp decimalPattern = RegExp(r'^\d+(?:[.,]\d{1,2})?$');

    if (!decimalPattern.hasMatch(_weightController.text)) {
      warnInvalidRegistrationData(
          "Peso inválido (deve ser um número decimal com no máximo duas casas decimais, separado por \".\" ou \",\")");
      return false;
    }

    return true;
  }

  void saveNewCollect() {
    if (!isFormOk()) {
      return;
    }

    Collect newCollect = Collect(
        ammount: double.parse(_weightController.text.replaceAll(",", ".")),
        collectedOn: selectedDate!,
        id: generateIntegerId(),
        residentId: (selectedResident?.id)!,
        isNew: true);

    if (isNewCollect) {
      db.saveNewCollect(newCollect);
    } else {
      db.updateCollect(newCollect);
    }

    Navigator.pop(context);

    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            Navigator.of(context).pop(true);
          });

          return AlertDialog(
            title: const Text(
              "Coleta salva com sucesso",
              style: TextStyle(fontSize: 14),
            ),
            surfaceTintColor: Colors.transparent,
            elevation: 0.0,
            alignment: Alignment.bottomCenter,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          );
        });
  }

  void deleteCollect() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          title: "Tem certeza que deseja apagar esta coleta?",
          onSave: () {
            db.deleteCollect((selectedResident?.id)!);
            Navigator.of(context).pop(true);
            Navigator.of(context).pop(true);
            showDialog(
                context: context,
                builder: (context) {
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    Navigator.of(context).pop(true);
                  });

                  return AlertDialog(
                    title: const Text(
                      "Coleta removida com sucesso",
                      style: TextStyle(fontSize: 14),
                    ),
                    surfaceTintColor: Colors.transparent,
                    elevation: 0.0,
                    alignment: Alignment.bottomCenter,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  );
                });
          },
          onCancel: () => Navigator.of(context).pop(true),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "♻️ Dados de coleta",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_outlined),
            ),
          )),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('globalDatabase').listenable(),
        builder: (context, Box box, _) {
          final residents = box.get("RESIDENTS");

          List<DropdownMenuItem<Resident>> residentsDropdownList = [];
          for (dynamic r in residents) {
            residentsDropdownList.add(DropdownMenuItem<Resident>(
                value: r as Resident, child: Text(r.name)));
          }

          return Center(
            child: FractionallySizedBox(
              widthFactor: 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 15),
                    child: Text(
                      widget.text,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 25),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Data",
                        prefix: Padding(
                          padding: EdgeInsets.only(
                              left: 0, right: 10, bottom: 0, top: 0),
                          child: Icon(
                            Icons.calendar_month,
                          ),
                        ),
                        prefixStyle: TextStyle()),
                    onTap: _selectDate,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  DropdownButtonFormField<Resident>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Morador",
                      prefix: Padding(
                        padding: EdgeInsets.only(
                            left: 0, right: 10, bottom: 0, top: 0),
                        child: Icon(
                          Icons.person,
                        ),
                      ),
                    ),
                    onChanged: (item) => selectedResident = item,
                    value: selectedResident,
                    items: residentsDropdownList,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Peso [kg]",
                      border: OutlineInputBorder(),
                      labelText: "Peso [kg]",
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BigButtonTile(
                      color: Colors.black,
                      content: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.save, color: Colors.white),
                          Text("  Salvar localmente",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      onPressed: saveNewCollect,
                      isSolid: true),
                  const SizedBox(
                    height: 15,
                  ),
                  Visibility(
                    visible: !isNewCollect,
                    child: BigButtonTile(
                        color: Colors.red,
                        content: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete, color: Colors.white),
                            Text("  Apagar",
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        onPressed: deleteCollect,
                        isSolid: true),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
