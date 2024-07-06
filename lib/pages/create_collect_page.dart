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
import 'package:searchfield/searchfield.dart';

class CreateCollectPage extends StatefulWidget {
  final Collect? collect;
  final String text;
  final bool isOldCollect;

  const CreateCollectPage({Key? key, this.collect, required this.text, required this.isOldCollect}) : super(key: key);

  @override
  State<CreateCollectPage> createState() => _CreateCollectPageState();
}

class _CreateCollectPageState extends State<CreateCollectPage> {
  GlobalDatabase db = GlobalDatabase();

  Resident? selectedResident;
  DateTime? selectedDate;
  bool isNewCollect = true;

  final focusNode = FocusNode();

  final TextEditingController _dateController = TextEditingController();

  final List<TextEditingController> _weightControllers = [TextEditingController()];

  final List<Widget> _weightColumnTextFields = [];

  @override
  void initState() {
    if (widget.collect != null) {
      selectedDate = widget.collect?.collectedOn;
      selectedResident = db.getResidentById(widget.collect?.residentId ?? 0);
      _weightControllers[0].text = (widget.collect?.ammount.toStringAsFixed(2) ?? "").replaceAll(".", ",");
      isNewCollect = false;
    } else {
      selectedDate = DateTime.now();
    }

    List<String> dayMonthYear = selectedDate.toString().split(" ")[0].split("-");
    _dateController.text = "${dayMonthYear[2]}/${dayMonthYear[1]}/${dayMonthYear[0]}";

    _weightColumnTextFields.add(
      TextField(
        controller: _weightControllers[0],
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: "Peso [kg]",
          border: OutlineInputBorder(),
          labelText: "Peso [kg]",
        ),
      ),
    );

    super.initState();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        List<String> dayMonthYear = picked.toString().split(" ")[0].split("-");
        _dateController.text = "${dayMonthYear[2]}/${dayMonthYear[1]}/${dayMonthYear[0]}";
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
            contentPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 5),
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
    }

    if (_weightControllers[0].text.isEmpty) {
      warnInvalidRegistrationData("O primeiro peso não pode estar vazio");
      return false;
    } else if (zeroPattern.hasMatch(_weightControllers[0].text)) {
      warnInvalidRegistrationData("O primeiro peso deve ser maior que zero.");
      return false;
    }

    for (var weightController in _weightControllers) {
      if (weightController.text.isNotEmpty) {
        if (!decimalPattern.hasMatch(weightController.text)) {
          warnInvalidRegistrationData("Peso inválido (deve ser um número decimal com no máximo duas casas decimais, separado por \".\" ou \",\").");
          return false;
        } else if ((double.tryParse(weightController.text.replaceAll(",", ".")) ?? 0) < 0) {
          warnInvalidRegistrationData("Não podem haver pesos negativos.");
          return false;
        }
      }
    }

    return true;
  }

  void saveNewCollect() {
    if (!isFormOk()) {
      return;
    }

    double totalWeight = 0;
    for (var weightController in _weightControllers) {
      totalWeight += double.tryParse(weightController.text.replaceAll(",", ".")) ?? 0;
    }

    Collect newCollect = Collect(
        id: widget.collect?.id ?? generateIntegerId(),
        ammount: totalWeight,
        collectedOn: selectedDate!,
        residentId: (selectedResident?.id)!,
        isNew: widget.collect?.isNew ?? isNewCollect,
        isMarkedForRemoval: false,
        wasModified: isNewCollect ? false : true,
        wasSuccessfullySentToBackendOnLastSync: false);

    var box = Hive.box('globalDatabase');

    final List<dynamic> dynamicCollectsList1 = box.get("COLLECTS") ?? [];
    final List<Collect> collectsList1 = dynamicListToTList(dynamicCollectsList1);

    final List<dynamic> dynamicCollectsList2 = box.get("ALL_DATABASE_COLLECTS") ?? [];
    final List<Collect> collectsList2 = dynamicListToTList(dynamicCollectsList2);

    List<Collect> collects = collectsList1 + collectsList2;

    for (Collect c in collects) {
      if (DateUtils.isSameDay(c.collectedOn, newCollect.collectedOn) && c.residentId == newCollect.residentId && c.id != newCollect.id) {
        warnInvalidRegistrationData("Este morador já possui uma coleta cadastrada neste dia.");
        return;
      }
    }

    String message = "";
    bool isInactiveResident = false;
    if (selectedResident?.situation == Situation.inactive) {
      message = "Este residente está inativo, ao registrar uma coleta em seu nome, ele se tornará ativo novamente. Deseja continuar?";
      isInactiveResident = true;
    } else if (selectedResident?.situation == Situation.noContact) {
      message = "Este residente está sem contato, ao registrar uma coleta em seu nome, ele se tornará ativo novamente. Deseja continuar?";
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            );
          });
    }
  }

  void deleteCollect() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          title: widget.isOldCollect ? "Tem certeza que deseja remover esta coleta? (esta operação não poderá ser revertida caso os dados sejam sincronizados com o servidor!)" : "Tem certeza que deseja remover esta coleta?",
          onSave: () {
            if (widget.isOldCollect) {
              db.deleteOldCollect(widget.collect!);
            } else {
              db.deleteCollect(widget.collect!);
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  );
                });
          },
          onCancel: () => Navigator.of(context).pop(true),
        );
      },
    );
  }

  // Tombstone method of deletion
  void deleteWeightField(int index) {
    setState(() {
      _weightColumnTextFields[index] = const Visibility(visible: false, child: Text("This text is not visible"));
      _weightControllers[index].text = "0";
    });
  }

  void createNewWeightField() {
    setState(() {
      _weightControllers.add(TextEditingController());
      int length = _weightControllers.length;
      FocusNode f = FocusNode();

      _weightColumnTextFields.add(
        Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    focusNode: f,
                    controller: _weightControllers[length - 1],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Peso [kg]",
                      border: OutlineInputBorder(),
                      labelText: "Peso [kg]",
                    ),
                  ),
                ),
                IconButton(onPressed: () => deleteWeightField(length - 1), icon: const Icon(Icons.remove)),
              ],
            ),
          ],
        ),
      );

      Future.delayed(const Duration(milliseconds: 100), () {
        f.requestFocus(); // Focus again to open keyboard
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget tag = Container();
    bool showTag = false;
    if (widget.collect?.isMarkedForRemoval ?? false) {
      tag = Row(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
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
        decoration: BoxDecoration(color: Theme.of(context).primaryColorLight, borderRadius: BorderRadius.circular(8)),
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
        decoration: BoxDecoration(color: Colors.green[300], borderRadius: BorderRadius.circular(8)),
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
            "Dados de coleta",
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
          final List<dynamic> residentsDynamic = box.get("RESIDENTS") ?? [];
          final List<Resident> residents = dynamicListToTList(residentsDynamic);

          return Center(
            child: FractionallySizedBox(
              widthFactor: 0.8,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Visibility(visible: showTag, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [tag])),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                      child: Text(widget.text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22)),
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
                            padding: EdgeInsets.only(left: 0, right: 10, bottom: 0, top: 0),
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
                    SearchField(
                      focusNode: focusNode,
                      suggestions: residents.map((r) => SearchFieldListItem<Resident>(r.name, child: Text(r.name), item: r)).toList(),
                      hint: "Morador",
                      initialValue: (selectedResident != null) ? SearchFieldListItem<Resident>((selectedResident?.name)!, child: Text((selectedResident?.name)!), item: selectedResident) : null,
                      searchInputDecoration: const InputDecoration(focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black))),
                      maxSuggestionsInViewPort: 6,
                      onSuggestionTap: (value) {
                        if (value.item != null) {
                          setState(() {
                            selectedResident = value.item;
                          });
                        }
                        focusNode.unfocus();
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Column(children: _weightColumnTextFields),
                    IconButton(
                      onPressed: createNewWeightField,
                      icon: const Icon(Icons.add),
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
                            Text("  Salvar localmente", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        onPressed: saveNewCollect,
                        isSolid: true),
                    const SizedBox(
                      height: 15,
                    ),
                    Visibility(
                      visible: !isNewCollect,
                      child: Column(
                        children: [
                          BigButtonTile(
                              color: Colors.red,
                              content: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.delete, color: Colors.white),
                                  Text("  Remover", style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              onPressed: deleteCollect,
                              isSolid: true),
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
