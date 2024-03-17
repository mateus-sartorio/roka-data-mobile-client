import 'package:flutter/material.dart';
import 'package:mobile_client/components/big_button_tile.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/enums/situation.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:mobile_client/utils/integer_id_generator.dart';

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
  String _previousPhoneNumberString = "";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
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

      List<String> addressTokens =
          widget.resident?.address.split(",") ?? ["", "", ""];

      _neighborhoodController.text = addressTokens[0];
      _streetController.text = addressTokens[1];
      _houseNumberController.text = addressTokens[2];

      _referencePointController.text = widget.resident?.referencePoint ?? "";
      _referencePointController.text = widget.resident?.referencePoint ?? "";

      livesInJN = widget.resident?.livesInJN ?? false;

      _referencePointController.text = widget.resident?.referencePoint ?? "";
      _phoneController.text = widget.resident?.phone ?? "";

      isOnWhatsappGroup = widget.resident?.isOnWhatsappGroup ?? false;

      Situation residentSituation =
          widget.resident?.situation ?? Situation.active;
      if (residentSituation == Situation.active) {
        selectedSituation = "Ativo";
      } else if (residentSituation == Situation.inactive) {
        selectedSituation = "Inativo";
      } else if (residentSituation == Situation.noContact) {
        selectedSituation = "Sem contato";
      }

      hasPlaque = widget.resident?.hasPlaque ?? false;

      _registrationYearController.text =
          widget.resident?.registrationYear.toString() ?? "";
      if (_registrationYearController.text == "0") {
        _registrationYearController.text = "";
      }

      _residentsInTheHouseController.text =
          widget.resident?.residentsInTheHouse.toString() ?? "";
      if (_residentsInTheHouseController.text == "0") {
        _residentsInTheHouseController.text = "";
      }

      _rokaIdController.text = widget.resident?.rokaId.toString() ?? "";
      if (_rokaIdController.text == "0") {
        _rokaIdController.text = "";
      }

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

  void onPhoneChange(String value) {
    String newValue = "";

    if (value.length < _previousPhoneNumberString.length) {
      newValue = value;
    } else if (value.length == 1) {
      newValue = "($value";
    } else if (value.length == 3) {
      newValue = "$value) ";
    } else if (value.length == 10) {
      newValue = "$value-";
    } else if (value.length > 15) {
      newValue = _previousPhoneNumberString;
    } else {
      newValue = value;
    }

    setState(() {
      _phoneController.text = newValue;
      _previousPhoneNumberString = newValue;
    });
  }

  void warnInvalidRegistrationData(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
            title: Text(
              message,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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

  bool isFormDataOk() {
    RegExp phoneNumberPattern = RegExp(r'\(\d{2}\) \d{5}-\d{4}');
    RegExp isNumberPattern = RegExp(r'\d+');
    RegExp registrationYearPattern = RegExp(r'20\d{2}');
    RegExp neighborhoodPattern1 = RegExp(r'^bairro ', caseSensitive: false);
    RegExp streetPattern1 = RegExp(r'^rua ', caseSensitive: false);

    if (_nameController.text.isEmpty) {
      warnInvalidRegistrationData("Nome completo do morador é obrigatório");
      return false;
    } else if (_phoneController.text.isEmpty) {
      warnInvalidRegistrationData("Número de telefone é obrigatório.");
      return false;
    } else if (!phoneNumberPattern.hasMatch(_phoneController.text)) {
      warnInvalidRegistrationData(
          "Formato inválido para número de telofone ( (XX) XXXXX-XX ).");
      return false;
    } else if (_neighborhoodController.text.isEmpty) {
      warnInvalidRegistrationData("Bairro é obrigatório.");
      return false;
    } else if (neighborhoodPattern1.hasMatch(_neighborhoodController.text)) {
      warnInvalidRegistrationData(
          "Não precisa digitar \"${_neighborhoodController.text.split(" ")[0]}\" antes do nome do bairro.");
      return false;
    } else if (_streetController.text.isEmpty) {
      warnInvalidRegistrationData("Rua é obrigatória.");
      return false;
    } else if (streetPattern1.hasMatch(_streetController.text)) {
      warnInvalidRegistrationData(
          "Não precisa digitar \"${_streetController.text.split(" ")[0]}\" antes do nome da rua.");
      return false;
    } else if (_houseNumberController.text.isEmpty) {
      warnInvalidRegistrationData("Número da residência é obrigatório.");
      return false;
    } else if (!isNumberPattern.hasMatch(_houseNumberController.text)) {
      warnInvalidRegistrationData(
          "Formato inválido para o número da residência.");
    } else if (_rokaIdController.text.isNotEmpty &&
        !isNumberPattern.hasMatch(_rokaIdController.text)) {
      warnInvalidRegistrationData("Id da Roka inválido.");
      return false;
    } else if (_registrationYearController.text.isNotEmpty &&
        !registrationYearPattern.hasMatch(_registrationYearController.text)) {
      warnInvalidRegistrationData("Ano de cadastro inválido (20XX).");
      return false;
    } else if (_residentsInTheHouseController.text.isNotEmpty &&
        !isNumberPattern.hasMatch(_residentsInTheHouseController.text)) {
      warnInvalidRegistrationData("Quantidade de residentes na casa inválido.");
      return false;
    }

    return true;
  }

  void saveNewResident() {
    if (!isFormDataOk()) {
      return;
    }

    int id = widget.resident?.id ?? generateIntegerId();

    Situation situation = Situation.active;
    if (selectedSituation == "Ativo") {
      situation = Situation.active;
    } else if (selectedSituation == "Inativo") {
      situation = Situation.inactive;
    } else if (selectedSituation == "Sem contato") {
      situation = Situation.noContact;
    }

    Resident newResident = Resident(
        id: id,
        address:
            "${_neighborhoodController.text},${_streetController.text},${_houseNumberController.text}",
        collects: widget.resident?.collects ?? [],
        hasPlaque: hasPlaque,
        isOnWhatsappGroup: isOnWhatsappGroup,
        livesInJN: livesInJN,
        name: _nameController.text,
        observations: _observationsController.text,
        phone: _phoneController.text,
        profession: _occupationController.text,
        referencePoint: _referencePointController.text,
        registrationYear: int.tryParse(_registrationYearController.text) ?? 0,
        residentsInTheHouse:
            int.tryParse(_residentsInTheHouseController.text) ?? 0,
        rokaId: int.tryParse(_rokaIdController.text) ?? 0,
        situation: situation,
        birthdate: selectedDate ?? DateTime.now(),
        isNew: widget.resident?.isNew ?? isNewResident,
        isMarkedForRemoval: false,
        wasModified: isNewResident ? false : true);

    if (isNewResident) {
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
          title:
              "Tem certeza que deseja remover este residente? (esta operação não poderá ser revertida caso os dados sejam sincronizados com o servidor!)",
          onSave: () {
            db.deleteResident((widget.resident?.id)!, true);
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
    Widget tag = Container();
    bool showTag = false;
    if (widget.resident?.isMarkedForRemoval ?? false) {
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
              onPressed: saveNewResident, icon: const Icon(Icons.restore))
        ],
      );

      showTag = true;
    } else if (widget.resident?.situation == Situation.inactive) {
      tag = Container(
        decoration: BoxDecoration(
            color: Colors.orange, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(5.0),
        child: const Text(
          "INATIVO",
          style: TextStyle(
            fontSize: 10,
          ),
        ),
      );

      showTag = true;
    } else if (widget.resident?.situation == Situation.noContact) {
      tag = Container(
        decoration: BoxDecoration(
            color: Colors.orange, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(5.0),
        child: const Text(
          "SEM CONTATO",
          style: TextStyle(
            fontSize: 10,
          ),
        ),
      );

      showTag = true;
    } else if (widget.resident?.isNew ?? false) {
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
    } else if (wasModified) {
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
                Visibility(visible: showTag, child: tag),
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
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    onChanged: (String value) => onPhoneChange(value),
                    decoration: const InputDecoration(
                      hintText: "Telefone",
                      border: OutlineInputBorder(),
                      labelText: "Telefone",
                    )),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "Endereço",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                    controller: _neighborhoodController,
                    keyboardType: TextInputType.streetAddress,
                    decoration: const InputDecoration(
                      hintText: "Bairro",
                      border: OutlineInputBorder(),
                      labelText: "Bairro",
                    )),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                    controller: _streetController,
                    keyboardType: TextInputType.streetAddress,
                    decoration: const InputDecoration(
                      hintText: "Rua",
                      border: OutlineInputBorder(),
                      labelText: "Rua",
                    )),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                    controller: _houseNumberController,
                    keyboardType: TextInputType.streetAddress,
                    decoration: const InputDecoration(
                      hintText: "Número da residência",
                      border: OutlineInputBorder(),
                      labelText: "Número da residência",
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
                            Text("  Removar permanentemente",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
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
