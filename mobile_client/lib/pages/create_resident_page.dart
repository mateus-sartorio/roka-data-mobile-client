import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_client/components/big_button_tile.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/enums/situation.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:mobile_client/models/resident.dart';

class CreateResidentPage extends StatefulWidget {
  final Resident? resident;
  final String text;

  const CreateResidentPage({Key? key, this.resident, required this.text})
      : super(key: key);

  @override
  State<CreateResidentPage> createState() => _CreateResidentPageState();
}

class _CreateResidentPageState extends State<CreateResidentPage> {
  GlobalDatabase db = GlobalDatabase();

  DateTime? selectedDate;
  bool isNewResident = true;
  bool wasModified = false;
  bool isMarkedForRemoval = false;
  bool isBeingCreated = true;

  bool livesInJN = false;
  bool isOnWhatsappGroup = false;
  bool hasPlaque = false;
  String selectedSituation = "Ativo";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _referencePointController =
      TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _registrationYearController =
      TextEditingController();
  final TextEditingController _residentsInTheHouseController =
      TextEditingController();
  final TextEditingController _observationsController = TextEditingController();
  final TextEditingController _rokaIdController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    if (widget.resident != null) {
      selectedDate = widget.resident?.birthdate;
      _nameController.text = widget.resident?.name ?? "";
      _addressController.text = widget.resident?.address ?? "";
      _referencePointController.text = widget.resident?.referencePoint ?? "";
      _referencePointController.text = widget.resident?.referencePoint ?? "";
      livesInJN = widget.resident?.livesInJN ?? false;
      _referencePointController.text = widget.resident?.referencePoint ?? "";
      _phoneController.text = widget.resident?.phone ?? "";
      isOnWhatsappGroup = widget.resident?.isOnWhatsappGroup ?? false;
      hasPlaque = widget.resident?.hasPlaque ?? false;
      _registrationYearController.text =
          widget.resident?.registrationYear.toString() ?? "";
      _residentsInTheHouseController.text =
          widget.resident?.residentsInTheHouse.toString() ?? "";
      _rokaIdController.text = widget.resident?.rokaId.toString() ?? "";
      _observationsController.text = widget.resident?.observations ?? "";
      _occupationController.text = widget.resident?.profession ?? "";
      isNewResident = false;
      wasModified = widget.resident?.wasModified ?? false;
      isMarkedForRemoval = widget.resident?.isMarkedForRemoval ?? false;
      isBeingCreated = false;
    } else {
      selectedDate = DateTime.now();
    }

    List<String> dayMonthYear =
        selectedDate.toString().split(" ")[0].split("-");
    _dateController.text =
        "${dayMonthYear[2]}/${dayMonthYear[1]}/${dayMonthYear[0]}";

    super.initState();
  }

  void saveNewResident() {
    Resident newResident = Resident(
        id: Random().nextInt(1000000),
        address: _addressController.text,
        collects: widget.resident?.collects ?? [],
        hasPlaque: hasPlaque,
        isOnWhatsappGroup: isOnWhatsappGroup,
        livesInJN: livesInJN,
        name: _nameController.text,
        observations: _observationsController.text,
        phone: _phoneController.text,
        profession: _occupationController.text,
        referencePoint: _referencePointController.text,
        registrationYear: int.parse(_registrationYearController.text),
        residentsInTheHouse: int.parse(_residentsInTheHouseController.text),
        rokaId: int.parse(_rokaIdController.text),
        situation: Situation.active,
        birthdate: selectedDate ?? DateTime.now(),
        isNew: isNewResident,
        isMarkedForRemoval: false,
        wasModified: isNewResident ? false : true);

    print("what");

    if (isNewResident) {
      print("save");
      db.saveNewResident(newResident);
    } else {
      db.updateResident(newResident);
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
              "Residente cadastrado com sucesso",
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

  void deleteResident() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          title: "Tem certeza que deseja remover este residente?",
          onSave: () {
            db.deleteResident((widget.resident?.id)!);
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
                      "Residente removido com sucesso :(",
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

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(" ")[0];
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            "♻️ ${widget.text}",
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
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
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 15,
                ),
                Visibility(
                  visible:
                      !isBeingCreated && isNewResident && !isMarkedForRemoval,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight,
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.all(5.0),
                    child: const Text(
                      "NOVO",
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: !isBeingCreated && isMarkedForRemoval,
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.all(5.0),
                        child: const Text(
                          "REMOVIDO",
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: saveNewResident,
                          icon: const Icon(Icons.restore))
                    ],
                  ),
                ),
                Visibility(
                  visible: !isBeingCreated &&
                      !isNewResident &&
                      !isMarkedForRemoval &&
                      wasModified,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.green[300],
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.all(5.0),
                    child: const Text(
                      "MODIFICADO",
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  "Informações básicas",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      hintText: "Nome completo",
                      border: OutlineInputBorder(),
                      labelText: "Nome completo",
                    )),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                    controller: _addressController,
                    keyboardType: TextInputType.streetAddress,
                    decoration: const InputDecoration(
                      hintText: "Endereço",
                      border: OutlineInputBorder(),
                      labelText: "Endereço",
                    )),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                    controller: _referencePointController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: "Ponto de referência",
                      border: OutlineInputBorder(),
                      labelText: "Ponto de referência",
                    )),
                const SizedBox(
                  height: 15,
                ),
                CheckboxListTile(
                  title: const Text("Mora em Jesus de Nazareth?"),
                  value: livesInJN,
                  onChanged: (bool? newValue) => setState(() {
                    livesInJN = newValue ?? false;
                  }),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: "Telefone",
                      border: OutlineInputBorder(),
                      labelText: "Telefone",
                    )),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "Informações internas da Roka",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                    controller: _rokaIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Id da Roka",
                      border: OutlineInputBorder(),
                      labelText: "Id da Roka",
                    )),
                const SizedBox(
                  height: 15,
                ),
                CheckboxListTile(
                  title: const Text("Tem plaquinha?"),
                  value: hasPlaque,
                  onChanged: (bool? newValue) => setState(() {
                    hasPlaque = newValue ?? false;
                  }),
                ),
                CheckboxListTile(
                  title: const Text("Está no grupo do WhatsApp da Roka?"),
                  value: isOnWhatsappGroup,
                  onChanged: (bool? newValue) => setState(() {
                    isOnWhatsappGroup = newValue ?? false;
                  }),
                ),
                const SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Situação",
                  ),
                  onChanged: (item) => selectedSituation = item ?? "",
                  value: selectedSituation,
                  items: const [
                    DropdownMenuItem(
                      value: "Ativo",
                      child: Text("Ativo"),
                    ),
                    DropdownMenuItem(
                      value: "Inativo",
                      child: Text("Inativo"),
                    ),
                    DropdownMenuItem(
                      value: "Sem contato",
                      child: Text("Sem contato"),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                    controller: _registrationYearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Ano de cadastro",
                      border: OutlineInputBorder(),
                      labelText: "Ano de cadastro",
                    )),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                    controller: _observationsController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: "Observações",
                      border: OutlineInputBorder(),
                      labelText: "Observações",
                    )),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "Informações adicionais",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                    controller: _occupationController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: "Ocupação",
                      border: OutlineInputBorder(),
                      labelText: "Ocupação",
                    )),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Data de nascimento",
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
                TextField(
                    controller: _residentsInTheHouseController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Quantidade de residentes na casa",
                      border: OutlineInputBorder(),
                      labelText: "Quantidade de residentes na casa",
                    )),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: BigButtonTile(
                      color: Colors.black,
                      content: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.save, color: Colors.white),
                          Text("  Salvar localmente",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      onPressed: saveNewResident,
                      isSolid: true),
                ),
                const SizedBox(
                  height: 15,
                ),
                Visibility(
                  visible: !isNewResident,
                  child: Center(
                    child: BigButtonTile(
                        color: Colors.red,
                        content: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete, color: Colors.white),
                            Text("  Removar residente",
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        onPressed: deleteResident,
                        isSolid: true),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
