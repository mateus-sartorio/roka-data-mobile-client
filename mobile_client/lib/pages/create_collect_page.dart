import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_client/components/big_button_tile.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/enums/situation.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:mobile_client/models/collect.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:mobile_client/utils/integer_id_generator.dart';
import 'package:mobile_client/utils/list_conversions.dart';

class CreateCollectPage extends StatefulWidget {
  final Collect? collect;
  final String text;
  final bool isOldCollect;

  const CreateCollectPage(
      {Key? key, this.collect, required this.text, required this.isOldCollect})
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
    RegExp zeroPattern = RegExp(r'^0+(?:[.,]0{1,2})?$');

    if (selectedResident == null) {
      warnInvalidRegistrationData("Selecione um residente.");
      return false;
    } else if (!decimalPattern.hasMatch(_weightController.text)) {
      warnInvalidRegistrationData(
          "Peso inválido (deve ser um número decimal com no máximo duas casas decimais, separado por \".\" ou \",\").");
      return false;
    } else if (zeroPattern.hasMatch(_weightController.text)) {
      warnInvalidRegistrationData("O peso deve ser maior que zero.");
      return false;
    }

    return true;
  }

  void saveNewCollect() {
    if (!isFormOk()) {
      return;
    }

    Collect newCollect = Collect(
        id: widget.collect?.id ?? generateIntegerId(),
        ammount: double.parse(_weightController.text.replaceAll(",", ".")),
        collectedOn: selectedDate!,
        residentId: (selectedResident?.id)!,
        isNew: widget.collect?.isNew ?? isNewCollect,
        isMarkedForRemoval: false,
        wasModified: isNewCollect ? false : true);

    var box = Hive.box('globalDatabase');
    final dynamicCollectsList1 = box.get("COLLECTS");
    final dynamicCollectsList2 = box.get("ALL_DATABASE_COLLECTS");
    List<Collect> collects =
        dynamicListToTList(dynamicCollectsList1 + dynamicCollectsList2);
    for (Collect c in collects) {
      if (DateUtils.isSameDay(c.collectedOn, newCollect.collectedOn) &&
          c.residentId == newCollect.residentId) {
        warnInvalidRegistrationData(
            "Este morador já possui uma coleta cadastrada neste dia.");
        return;
      }
    }

    String message = "";
    bool isInactiveResident = false;
    if (selectedResident?.situation == Situation.inactive) {
      message =
          "Este residente está inativo, ao registrar uma coleta em seu nome, ele se tornará ativo novamente. Deseja continuar?";
      isInactiveResident = true;
    } else if (selectedResident?.situation == Situation.noContact) {
      message =
          "Este residente está sem contato, ao registrar uma coleta em seu nome, ele se tornará ativo novamente. Deseja continuar?";
      isInactiveResident = true;
    }

    if (isInactiveResident) {
      showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
            title: message,
            onSave: () {
              selectedResident?.situation = Situation.active;
              db.updateResident(selectedResident!);

              if (widget.isOldCollect) {
                db.updateOldCollect(newCollect);
              } else if (isNewCollect) {
                db.saveNewCollect(newCollect);
              } else {
                db.updateCollect(newCollect);
              }

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
                        "Coleta salva com sucesso",
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
    } else {
      if (widget.isOldCollect) {
        db.updateOldCollect(newCollect);
      } else if (isNewCollect) {
        db.saveNewCollect(newCollect);
      } else {
        db.updateCollect(newCollect);
      }

      Navigator.of(context).pop(true);

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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            );
          });
    }
  }

  void deleteCollect() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          title: widget.isOldCollect
              ? "Tem certeza que deseja remover esta coleta? (esta operação não poderá ser revertida caso os dados sejam sincronizados com o servidor!)"
              : "Tem certeza que deseja remover esta coleta?",
          onSave: () {
            if (widget.isOldCollect) {
              db.deleteOldCollect(widget.collect?.id ?? -1);
            } else {
              db.deleteCollect(widget.collect?.id ?? -1);
            }

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
    Widget tag = Container();
    bool showTag = false;
    if (widget.collect?.isMarkedForRemoval ?? false) {
      tag = Row(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(5.0),
            child: const Text(
              "MARCADO PARA REMOÇÃO",
              style: TextStyle(
                fontSize: 10,
              ),
            ),
          ),
          IconButton(onPressed: saveNewCollect, icon: const Icon(Icons.restore))
        ],
      );

      showTag = true;
    } else if (widget.collect?.isNew ?? false) {
      tag = Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(5.0),
        child: const Text(
          "SALVO LOCALMENTE",
          style: TextStyle(
            fontSize: 10,
          ),
        ),
      );

      showTag = true;
    } else if (widget.collect?.wasModified ?? false) {
      tag = Container(
        decoration: BoxDecoration(
            color: Colors.green[300], borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(5.0),
        child: const Text(
          "MODIFICADO",
          style: TextStyle(
            fontSize: 10,
          ),
        ),
      );

      showTag = true;
    }

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
                  const SizedBox(
                    height: 15,
                  ),
                  Visibility(visible: showTag, child: tag),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 15),
                    child: Text(widget.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 22)),
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
                            Text("  Remover",
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
