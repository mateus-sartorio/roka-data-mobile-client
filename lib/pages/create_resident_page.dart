import 'package:flutter/material.dart';
import 'package:mobile_client/components/big_button_tile.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/enums/shift.dart';
import 'package:mobile_client/enums/situation.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:mobile_client/pages/all_collects_of_resident_page.dart';
import 'package:mobile_client/pages/all_receipts_of_resident_page.dart';
import 'package:mobile_client/utils/enum_conversion/situation.dart';
import 'package:mobile_client/utils/integer_id_generator.dart';

class CreateResidentPage extends StatefulWidget {
  final Resident? resident;
  final String text;
  final bool showCoin;
  final bool showBag;

  const CreateResidentPage({Key? key, this.resident, required this.text, required this.showCoin, required this.showBag}) : super(key: key);

  @override
  State<CreateResidentPage> createState() => _CreateResidentPageState();
}

class _CreateResidentPageState extends State<CreateResidentPage> {
  GlobalDatabase db = GlobalDatabase();

  DateTime? selectedBirthdayDate;
  DateTime? selectedRegistrationDate;
  bool isNewResident = true;
  bool wasModified = false;
  bool isMarkedForRemoval = false;
  bool isBeingCreated = true;

  bool livesInJN = true;
  bool isOnWhatsappGroup = false;
  bool hasPlaque = false;
  bool needsCollectOnTheHouse = false;
  Shift? selectedShift;
  String selectedSituation = "Ativo";
  String previousPhoneNumberString = "";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController neighborhoodController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController houseNumberController = TextEditingController();
  final TextEditingController referencePointController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController residentsInTheHouseController = TextEditingController();
  final TextEditingController observationsController = TextEditingController();
  final TextEditingController rokaIdController = TextEditingController();
  final TextEditingController birthdayDateController = TextEditingController();
  final TextEditingController registrationDateController = TextEditingController();

  @override
  void initState() {
    if (widget.resident != null) {
      isBeingCreated = false;
    }

    selectedBirthdayDate = widget.resident?.birthdate ?? DateTime.now();
    nameController.text = widget.resident?.name ?? "";
    descriptionController.text = widget.resident?.description ?? "";

    List<String> addressTokens = widget.resident?.address.split(",") ?? ["", "", ""];

    neighborhoodController.text = addressTokens[0];
    streetController.text = addressTokens[1];
    houseNumberController.text = addressTokens[2];

    referencePointController.text = widget.resident?.referencePoint ?? "";

    livesInJN = widget.resident?.livesInJN ?? false;
    needsCollectOnTheHouse = widget.resident?.needsCollectOnTheHouse ?? false;
    selectedShift = widget.resident?.shiftForCollectionOnTheHouse;

    referencePointController.text = widget.resident?.referencePoint ?? "";
    phoneController.text = widget.resident?.phone ?? "";

    isOnWhatsappGroup = widget.resident?.isOnWhatsappGroup ?? false;

    selectedSituation = situationToString(widget.resident?.situation ?? Situation.active);

    hasPlaque = widget.resident?.hasPlaque ?? false;

    selectedRegistrationDate = widget.resident?.registrationDate ?? DateTime.now();

    residentsInTheHouseController.text = widget.resident?.residentsInTheHouse.toString() ?? "";
    if (residentsInTheHouseController.text == "0") {
      residentsInTheHouseController.text = "";
    }

    rokaIdController.text = widget.resident?.rokaId.toString() ?? "";
    if (rokaIdController.text == "0") {
      rokaIdController.text = "";
    }

    observationsController.text = widget.resident?.observations ?? "";
    occupationController.text = widget.resident?.profession ?? "";

    isNewResident = widget.resident?.isNew ?? true;
    wasModified = widget.resident?.wasModified ?? false;
    isMarkedForRemoval = widget.resident?.isMarkedForRemoval ?? false;

    List<String> dayMonthYear = selectedBirthdayDate.toString().split(" ")[0].split("-");
    birthdayDateController.text = "${dayMonthYear[2]}/${dayMonthYear[1]}/${dayMonthYear[0]}";

    dayMonthYear = selectedRegistrationDate.toString().split(" ")[0].split("-");
    registrationDateController.text = "${dayMonthYear[2]}/${dayMonthYear[1]}/${dayMonthYear[0]}";

    super.initState();
  }

  void onPhoneChange(String value) {
    String newValue = "";

    if (value.length < previousPhoneNumberString.length) {
      newValue = value;
    } else if (value.length == 1) {
      newValue = "($value";
    } else if (value.length == 3) {
      newValue = "$value) ";
    } else if (value.length == 10) {
      newValue = "$value-";
    } else if (value.length > 15) {
      newValue = previousPhoneNumberString;
    } else {
      newValue = value;
    }

    setState(() {
      phoneController.text = newValue;
      previousPhoneNumberString = newValue;
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

  bool isFormDataOk() {
    RegExp phoneNumberPattern = RegExp(r'\(\d{2}\) \d{5}-\d{4}');
    RegExp isNumberPattern = RegExp(r'^[1-9]\d*$');
    RegExp zeroPattern = RegExp(r'^0+');
    RegExp neighborhoodPattern1 = RegExp(r'^bairro ', caseSensitive: false);
    RegExp streetPattern1 = RegExp(r'^rua ', caseSensitive: false);

    if (nameController.text.isEmpty) {
      warnInvalidRegistrationData("Nome completo do morador é obrigatório");
      return false;
    } else if (phoneController.text.isNotEmpty && !phoneNumberPattern.hasMatch(phoneController.text)) {
      warnInvalidRegistrationData("Formato inválido para número de telofone ( (XX) XXXXX-XX ).");
      return false;
    } else if (neighborhoodController.text.isNotEmpty && neighborhoodPattern1.hasMatch(neighborhoodController.text)) {
      warnInvalidRegistrationData("Não precisa digitar \"${neighborhoodController.text.split(" ")[0]}\" antes do nome do bairro.");
      return false;
    } else if (streetController.text.isNotEmpty && streetPattern1.hasMatch(streetController.text)) {
      warnInvalidRegistrationData("Não precisa digitar \"${streetController.text.split(" ")[0]}\" antes do nome da rua.");
      return false;
    } else if (houseNumberController.text.isNotEmpty && !isNumberPattern.hasMatch(houseNumberController.text)) {
      warnInvalidRegistrationData("Formato inválido para o número da residência.");
    } else if (needsCollectOnTheHouse == true && selectedShift == null) {
      warnInvalidRegistrationData("Selecione um turno de coleta.");
      return false;
    } else if (rokaIdController.text.isNotEmpty && !isNumberPattern.hasMatch(rokaIdController.text)) {
      if (zeroPattern.hasMatch(rokaIdController.text)) {
        warnInvalidRegistrationData("Id da Roka não pode ser zero.");
      } else {
        warnInvalidRegistrationData("Id da Roka inválido.");
      }
      return false;
    } else if (db.isRokaIdTakenByAnotherResident(widget.resident?.id ?? -1, int.tryParse(rokaIdController.text) ?? -1).$1) {
      warnInvalidRegistrationData("Id da Roka ${int.parse(rokaIdController.text)} já está sendo usado por ${db.isRokaIdTakenByAnotherResident(widget.resident?.id ?? -1, int.parse(rokaIdController.text)).$2}.");
      return false;
    } else if (residentsInTheHouseController.text.isEmpty) {
      warnInvalidRegistrationData("Quantidade de residentes na casa é obrigatório.");
      return false;
    } else if (!isNumberPattern.hasMatch(residentsInTheHouseController.text)) {
      warnInvalidRegistrationData("Quantidade de residentes na casa deve ser um número.");
      return false;
    }

    return true;
  }

  void saveNewResident() {
    if (!isFormDataOk()) {
      return;
    }

    int id = widget.resident?.id ?? generateIntegerId();

    Situation situation = stringToSituation(selectedSituation);

    if (needsCollectOnTheHouse == false) {
      selectedShift = null;
    }

    Resident newResident = Resident(
        id: id,
        address: "${neighborhoodController.text},${streetController.text},${houseNumberController.text}",
        collects: widget.resident?.collects ?? [],
        receipts: widget.resident?.receipts ?? [],
        hasPlaque: hasPlaque,
        isOnWhatsappGroup: isOnWhatsappGroup,
        livesInJN: livesInJN,
        name: nameController.text,
        description: descriptionController.text,
        observations: observationsController.text,
        phone: phoneController.text,
        profession: occupationController.text,
        referencePoint: referencePointController.text,
        registrationDate: selectedRegistrationDate ?? DateTime.now(),
        residentsInTheHouse: int.tryParse(residentsInTheHouseController.text) ?? 0,
        rokaId: int.tryParse(rokaIdController.text) ?? 0,
        situation: situation,
        birthdate: selectedBirthdayDate ?? DateTime.now(),
        needsCollectOnTheHouse: needsCollectOnTheHouse,
        shiftForCollectionOnTheHouse: selectedShift,
        isNew: widget.resident?.isNew ?? isNewResident,
        isMarkedForRemoval: false,
        wasModified: isNewResident ? false : true,
        wasSuccessfullySentToBackendOnLastSync: false);

    if (isBeingCreated) {
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
              textAlign: TextAlign.center,
            ),
            surfaceTintColor: Colors.transparent,
            elevation: 0.0,
            alignment: Alignment.bottomCenter,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          );
        });
  }

  void deleteResident() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          title: "Tem certeza que deseja remover este residente? (esta operação não poderá ser revertida caso os dados sejam sincronizados com o servidor!)",
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
                      textAlign: TextAlign.center,
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

  Future<void> selectDate(TextEditingController controller, void Function(DateTime) setDateVariable) async {
    DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        List<String> date = picked.toString().split(" ")[0].split("-");
        controller.text = "${date[2]}/${date[1]}/${date[0]}";

        setDateVariable(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tags = <Widget>[];
    bool showTags = false;
    if (widget.resident?.situation == Situation.inactive) {
      tags.add(Container(
        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(5.0),
        child: const Text(
          "INATIVO",
          style: TextStyle(
            fontSize: 10,
          ),
        ),
      ));
      tags.add(const SizedBox(
        width: 5,
      ));
      showTags = true;
    } else if (widget.resident?.situation == Situation.noContact) {
      tags.add(Container(
        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(5.0),
        child: const Text(
          "SEM CONTATO",
          style: TextStyle(
            fontSize: 10,
          ),
        ),
      ));
      tags.add(const SizedBox(
        width: 5,
      ));
      showTags = true;
    }
    if (widget.resident?.isMarkedForRemoval ?? false) {
      tags.add(Row(
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
          IconButton(onPressed: saveNewResident, icon: const Icon(Icons.restore))
        ],
      ));
      showTags = true;
    } else if (widget.resident?.isNew ?? false) {
      tags.add(Container(
        decoration: BoxDecoration(color: Theme.of(context).primaryColorLight, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(5.0),
        child: const Text(
          "SALVO LOCALMENTE",
          style: TextStyle(
            fontSize: 10,
          ),
        ),
      ));
      showTags = true;
    } else if (wasModified) {
      tags.add(Container(
        decoration: BoxDecoration(color: Colors.green[300], borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(5.0),
        child: const Text(
          "MODIFICADO",
          style: TextStyle(
            fontSize: 10,
          ),
        ),
      ));
      showTags = true;
    }

    return Scaffold(
      appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            widget.text,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: widget.showCoin,
                      child: const Icon(
                        Icons.monetization_on_rounded,
                        color: Color.fromARGB(255, 255, 215, 0),
                      ),
                    ),
                    Visibility(
                        visible: widget.showBag,
                        child: const Icon(
                          Icons.shopping_bag,
                          size: 20,
                        )),
                  ],
                ),
                Visibility(
                  visible: showTags && (widget.showCoin || widget.showBag),
                  child: const SizedBox(
                    height: 15,
                  ),
                ),
                Visibility(visible: showTags, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: tags)),
                Visibility(
                    visible: !isBeingCreated,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  // Adjust padding to remove any extra space around the icon
                                  minimumSize: const Size(0, 0), // Optional: Adjust button minimum size
                                ),
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AllCollectsOfResidentPage(
                                              resident: widget.resident!,
                                            ))),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Coletas",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.black,
                                    ),
                                  ],
                                )),
                            const SizedBox(
                              width: 15,
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  minimumSize: const Size(0, 0),
                                ),
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AllReceiptsOfResidentPage(
                                              resident: widget.resident!,
                                            ))),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Entregas de moeda",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.black,
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "Informações básicas",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                    controller: nameController,
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
                    controller: descriptionController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: "Descrição",
                      border: OutlineInputBorder(),
                      labelText: "Descrição",
                    )),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                    controller: phoneController,
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
                    controller: neighborhoodController,
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
                    controller: streetController,
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
                    controller: houseNumberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Número da residência",
                      border: OutlineInputBorder(),
                      labelText: "Número da residência",
                    )),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                    controller: referencePointController,
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
                CheckboxListTile(
                  title: const Text("Precisa de coleta na casa?"),
                  value: needsCollectOnTheHouse,
                  onChanged: (bool? newValue) => setState(() {
                    needsCollectOnTheHouse = newValue ?? true;
                  }),
                ),
                Visibility(
                  visible: needsCollectOnTheHouse,
                  child: DropdownButtonFormField<Shift>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Turno da coleta na casa",
                    ),
                    onChanged: (item) => selectedShift = item,
                    value: selectedShift,
                    items: const [
                      DropdownMenuItem(
                        value: Shift.morning,
                        child: Text("Manhã"),
                      ),
                      DropdownMenuItem(
                        value: Shift.afternoon,
                        child: Text("Tarde"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                    controller: rokaIdController,
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
                  controller: registrationDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Data de cadastro",
                      prefix: Padding(
                        padding: EdgeInsets.only(left: 0, right: 10, bottom: 0, top: 0),
                        child: Icon(
                          Icons.calendar_month,
                        ),
                      ),
                      prefixStyle: TextStyle()),
                  onTap: () => selectDate(registrationDateController, (DateTime picked) => selectedRegistrationDate = picked),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                    controller: observationsController,
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
                    controller: occupationController,
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
                  controller: birthdayDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Data de nascimento",
                      prefix: Padding(
                        padding: EdgeInsets.only(left: 0, right: 10, bottom: 0, top: 0),
                        child: Icon(
                          Icons.calendar_month,
                        ),
                      ),
                      prefixStyle: TextStyle()),
                  onTap: () => selectDate(birthdayDateController, (DateTime picked) => selectedBirthdayDate = picked),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                    controller: residentsInTheHouseController,
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
                          Text("  Salvar localmente", style: TextStyle(color: Colors.white)),
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
                            Text("  Remover", style: TextStyle(color: Colors.white, fontSize: 12)),
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
