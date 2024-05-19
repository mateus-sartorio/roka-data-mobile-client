import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_client/components/big_button_tile.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/enums/situation.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:mobile_client/models/currency_handout.dart';
import 'package:mobile_client/models/receipt.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:mobile_client/utils/integer_id_generator.dart';
import 'package:mobile_client/utils/list_conversions.dart';
import 'package:searchfield/searchfield.dart';

class CreateReceiptPage extends StatefulWidget {
  final Receipt? receipt;
  final String text;
  final bool isOldReceipt;

  const CreateReceiptPage(
      {Key? key, this.receipt, required this.text, required this.isOldReceipt})
      : super(key: key);

  @override
  State<CreateReceiptPage> createState() => _CreateReceiptPageState();
}

class _CreateReceiptPageState extends State<CreateReceiptPage> {
  GlobalDatabase db = GlobalDatabase();

  Resident? selectedResident;
  CurrencyHandout? selectedCurrencyHandout;
  DateTime? selectedDate;
  bool isNewReceipt = true;

  final focusNode1 = FocusNode();
  final focusNode2 = FocusNode();

  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    if (widget.receipt != null) {
      selectedDate = widget.receipt?.handoutDate;
      selectedResident = db.getResidentById(widget.receipt?.residentId ?? 0);
      selectedCurrencyHandout =
          db.getCurrencyHandoutById(widget.receipt?.currencyHandoutId ?? -1);
      _valueController.text = widget.receipt?.value.toString() ?? "";
      isNewReceipt = false;
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
    } else if (selectedCurrencyHandout == null) {
      warnInvalidRegistrationData("Selecione uma distribuição de moeda.");
      return false;
    } else if (selectedCurrencyHandout?.isMarkedForRemoval ?? false) {
      warnInvalidRegistrationData(
          "Distribuição de moeda marcada para remoção.");
      return false;
    } else if (!decimalPattern.hasMatch(_valueController.text)) {
      warnInvalidRegistrationData(
          "Valor inválido (deve ser um número decimal com no máximo duas casas decimais, separado por \".\" ou \",\").");
      return false;
    } else if (zeroPattern.hasMatch(_valueController.text)) {
      warnInvalidRegistrationData("O valor deve ser maior que zero.");
      return false;
    }

    return true;
  }

  void saveNewReceipt() {
    if (!isFormOk()) {
      return;
    }

    Receipt newReceipt = Receipt(
        id: widget.receipt?.id ?? generateIntegerId(),
        value: double.parse(_valueController.text.replaceAll(",", ".")),
        handoutDate: selectedDate!,
        residentId: (selectedResident?.id)!,
        currencyHandoutId: (selectedCurrencyHandout?.id)!,
        isNew: widget.receipt?.isNew ?? isNewReceipt,
        isMarkedForRemoval: false,
        wasModified: isNewReceipt ? false : true);

    var box = Hive.box('globalDatabase');
    final dynamicReceiptsList1 = box.get("RECEIPTS");
    final dynamicReceiptsList2 = box.get("ALL_DATABASE_RECEIPTS");
    List<Receipt> receipts =
        dynamicListToTList(dynamicReceiptsList1 + dynamicReceiptsList2);
    for (Receipt r in receipts) {
      if (r.currencyHandoutId == newReceipt.currencyHandoutId &&
          r.residentId == newReceipt.residentId) {
        warnInvalidRegistrationData(
            "Este morador já recebeu uma entrega cadastrada neste distribuição de moeda.");
        return;
      }
    }

    String message = "";
    bool isInactiveResident = false;
    if (selectedResident?.situation == Situation.inactive) {
      message =
          "Este residente está inativo, ao registrar uma entrega em seu nome, ele se tornará ativo novamente. Deseja continuar?";
      isInactiveResident = true;
    } else if (selectedResident?.situation == Situation.noContact) {
      message =
          "Este residente está sem contato, ao registrar uma entrega em seu nome, ele se tornará ativo novamente. Deseja continuar?";
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

              if (widget.isOldReceipt) {
                db.updateOldReceipt(newReceipt);
              } else if (isNewReceipt) {
                db.saveNewReceipt(newReceipt);
              } else {
                db.updateReceipt(newReceipt);
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
                        "Entrega salva com sucesso",
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
      if (widget.isOldReceipt) {
        db.updateOldReceipt(newReceipt);
      } else if (isNewReceipt) {
        db.saveNewReceipt(newReceipt);
      } else {
        db.updateReceipt(newReceipt);
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
                "Entrega salva com sucesso",
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

  void deleteReceipt() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          title: widget.isOldReceipt
              ? "Tem certeza que deseja remover esta entrega? (esta operação não poderá ser revertida caso os dados sejam sincronizados com o servidor!)"
              : "Tem certeza que deseja remover esta entrega?",
          onSave: () {
            if (widget.isOldReceipt) {
              db.deleteOldReceipt(widget.receipt!);
            } else {
              db.deleteReceipt(widget.receipt!);
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
                      "Entrega removida com sucesso",
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
    if (widget.receipt?.isMarkedForRemoval ?? false) {
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
          IconButton(onPressed: saveNewReceipt, icon: const Icon(Icons.restore))
        ],
      );

      showTag = true;
    } else if (widget.receipt?.isNew ?? false) {
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
    } else if (widget.receipt?.wasModified ?? false) {
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
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: const Text(
            "♻️ Dados da entrega",
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

          final List<dynamic> currencyHandoutsDynamic =
              box.get("CURRENCY_HANDOUTS") ?? [];
          final List<CurrencyHandout> currencyHandouts =
              dynamicListToTList(currencyHandoutsDynamic);

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
                    child: Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 20),
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
                        labelText: "Data da entrega",
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
                  SearchField(
                    focusNode: focusNode1,
                    suggestions: residents
                        .map((r) => SearchFieldListItem<Resident>(r.name,
                            child: Text(r.name), item: r))
                        .toList(),
                    hint: "Morador",
                    searchInputDecoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black))),
                    initialValue: (selectedResident != null)
                        ? SearchFieldListItem<Resident>(
                            (selectedResident?.name)!,
                            child: Text((selectedResident?.name)!),
                            item: selectedResident)
                        : null,
                    maxSuggestionsInViewPort: 6,
                    onSuggestionTap: (value) {
                      if (value.item != null) {
                        setState(() {
                          selectedResident = value.item;
                        });
                      }
                      focusNode1.unfocus();
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SearchField(
                    focusNode: focusNode2,
                    suggestions: currencyHandouts
                        .map((c) => SearchFieldListItem<CurrencyHandout>(
                            c.title,
                            child: Text(c.toStringFormat()),
                            item: c))
                        .toList(),
                    hint: "Entrega de moeda",
                    initialValue: (selectedCurrencyHandout != null)
                        ? SearchFieldListItem<CurrencyHandout>(
                            (selectedCurrencyHandout?.title)!,
                            child: Text(
                                (selectedCurrencyHandout?.toStringFormat())!),
                            item: selectedCurrencyHandout)
                        : null,
                    searchInputDecoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black))),
                    maxSuggestionsInViewPort: 6,
                    onSuggestionTap: (value) {
                      if (value.item != null) {
                        setState(() {
                          selectedCurrencyHandout = value.item;
                        });
                      }
                      focusNode2.unfocus();
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: _valueController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Valor [Rokas]",
                      border: OutlineInputBorder(),
                      labelText: "Valor [Rokas]",
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
                      onPressed: saveNewReceipt,
                      isSolid: true),
                  const SizedBox(
                    height: 15,
                  ),
                  Visibility(
                    visible: !isNewReceipt,
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
                        onPressed: deleteReceipt,
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
