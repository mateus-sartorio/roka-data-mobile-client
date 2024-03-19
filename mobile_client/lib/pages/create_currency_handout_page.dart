import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_client/components/big_button_tile.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:mobile_client/models/currency_handout.dart';
import 'package:mobile_client/utils/integer_id_generator.dart';

class CreateCurrencyHandoutPage extends StatefulWidget {
  final CurrencyHandout? currencyHandout;
  final String text;

  const CreateCurrencyHandoutPage(
      {Key? key, this.currencyHandout, required this.text})
      : super(key: key);

  @override
  State<CreateCurrencyHandoutPage> createState() =>
      _CreateCurrencyHandoutPageState();
}

class _CreateCurrencyHandoutPageState extends State<CreateCurrencyHandoutPage> {
  GlobalDatabase db = GlobalDatabase();

  DateTime? selectedDate;
  bool isNewHandout = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    if (widget.currencyHandout != null) {
      selectedDate = widget.currencyHandout?.startDate;
      _titleController.text = widget.currencyHandout?.title ?? "";
      isNewHandout = false;
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
    if (_titleController.text.isEmpty) {
      warnInvalidRegistrationData("Título é obrigatório.");
      return false;
    }

    return true;
  }

  void saveNewCurrencyHandout() {
    if (!isFormOk()) {
      return;
    }

    CurrencyHandout newCurrencyHandout = CurrencyHandout(
        id: widget.currencyHandout?.id ?? generateIntegerId(),
        title: _titleController.text,
        startDate: selectedDate!,
        isNew: widget.currencyHandout?.isNew ?? isNewHandout,
        wasModified: isNewHandout ? false : true,
        isMarkedForRemoval: false);

    if (isNewHandout) {
      db.saveNewCurrencyHandout(newCurrencyHandout);
    } else {
      db.updateCurrencyHandout(newCurrencyHandout);
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
              "Entrega de moeda salva com sucesso",
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

  void deleteCurrencyHandout() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          title:
              "Tem certeza que deseja remover esta entrega de moeda? (esta operação não poderá ser revertida caso os dados sejam sincronizados com o servidor!)",
          onSave: () {
            db.deleteCurrencyHandout((widget.currencyHandout?.id)!);
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
                      "Entrega de moeda removida com sucesso",
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
    if (widget.currencyHandout?.isMarkedForRemoval ?? false) {
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
          IconButton(
              onPressed: saveNewCurrencyHandout,
              icon: const Icon(Icons.restore))
        ],
      );

      showTag = true;
    } else if (widget.currencyHandout?.isNew ?? false) {
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
    } else if (widget.currencyHandout?.wasModified ?? false) {
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
            "♻️ Dados da entrega da moeda",
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
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 22),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Visibility(visible: showTag, child: tag),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: _titleController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: "Título",
                      border: OutlineInputBorder(),
                      labelText: "Título",
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Data de início",
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
                      onPressed: saveNewCurrencyHandout,
                      isSolid: true),
                  const SizedBox(
                    height: 15,
                  ),
                  Visibility(
                    visible: !isNewHandout,
                    child: BigButtonTile(
                        color: Colors.red,
                        content: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete, color: Colors.white),
                            Text("  Removar permanentemente",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ],
                        ),
                        onPressed: deleteCurrencyHandout,
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
