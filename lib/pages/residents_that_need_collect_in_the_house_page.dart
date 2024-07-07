import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/enums/shift.dart';
import 'package:mobile_client/enums/situation.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:mobile_client/models/currency_handout.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:mobile_client/pages/create_resident_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_client/utils/dates/compare.dart';
import 'package:mobile_client/utils/list_conversions.dart';
import 'package:mobile_client/utils/residents/resident_filter.dart';

class ResidentsThatNeedCollectOnTheHousePage extends StatefulWidget {
  const ResidentsThatNeedCollectOnTheHousePage({Key? key}) : super(key: key);

  @override
  State<ResidentsThatNeedCollectOnTheHousePage> createState() => _ResidentsThatNeedCollectOnTheHousePageState();
}

class _ResidentsThatNeedCollectOnTheHousePageState extends State<ResidentsThatNeedCollectOnTheHousePage> {
  GlobalDatabase db = GlobalDatabase();
  List<Resident> filteredResidents = [];
  Shift? selectedShift;

  final TextEditingController _searchController = TextEditingController();

  void deleteResident(int residentId) {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          title: "Tem certeza que deseja remover este residente? (esta operação não poderá ser revertida caso os dados sejam sincronizados com o servidor!)",
          onSave: () {
            db.deleteResident(residentId);
            Navigator.of(context).pop(true);

            showDialog(
                context: context,
                builder: (context) {
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    Navigator.of(context).pop(true);
                  });

                  return AlertDialog(
                    title: const Text(
                      "Residente removido :(",
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    surfaceTintColor: Colors.transparent,
                    elevation: 0.0,
                    alignment: Alignment.bottomCenter,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    return ValueListenableBuilder(
        valueListenable: Hive.box('globalDatabase').listenable(),
        builder: (context, Box box, _) {
          final allResidentsDynamicList = box.get("RESIDENTS");
          List<Resident> residents = dynamicListToTList(allResidentsDynamicList);
          filteredResidents = residentFilterForPeopleThatNeedCollectOnTheHouse(residents, _searchController.text);
          filteredResidents = residentFilterForPeopleWithShiftForCollectOnTheHouse(filteredResidents, selectedShift);

          Widget body;

          body = Animate(
            effects: const [
              SlideEffect(
                begin: Offset(-1, 0),
                end: Offset(0, 0),
                duration: Duration(milliseconds: 200),
              )
            ],
            child: Column(
              children: [
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: CupertinoSearchTextField(
                    controller: _searchController,
                    placeholder: " Pesquisar",
                    onChanged: (value) {
                      setState(() {
                        filteredResidents = residentFilterForPeopleThatNeedCollectOnTheHouse(residents, value);
                        filteredResidents = residentFilterForPeopleWithShiftForCollectOnTheHouse(filteredResidents, selectedShift);
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                IntrinsicWidth(
                  child: DropdownButtonFormField<Shift>(
                    decoration: const InputDecoration(
                      // filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (item) {
                      selectedShift = item;

                      setState(() {
                        filteredResidents = residentFilterForPeopleThatNeedCollectOnTheHouse(residents, _searchController.text);
                        filteredResidents = residentFilterForPeopleWithShiftForCollectOnTheHouse(filteredResidents, item);
                      });
                    },
                    value: selectedShift,
                    items: const [
                      DropdownMenuItem(value: null, child: Text("Todos")),
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
                filteredResidents.isEmpty
                    ? const Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Nenhum residente :(",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                            itemCount: filteredResidents.length,
                            itemBuilder: (context, index) {
                              final CurrencyHandout? lastCurrencyHandout = box.get("LAST_ACTIVE_CURRENCY_HANDOUT") as CurrencyHandout?;

                              bool displayCoin = false;
                              if (filteredResidents[index].receipts.isNotEmpty && filteredResidents[index].receipts[0].currencyHandoutId == lastCurrencyHandout?.id) {
                                displayCoin = true;
                              }

                              bool displayBag = false;
                              if (filteredResidents[index].collects.isNotEmpty && isSameDay(filteredResidents[index].collects[0].collectedOn, DateTime.now()) && !filteredResidents[index].collects[0].isMarkedForRemoval) {
                                displayBag = true;
                              }

                              bool displayHasBeenVisited = false;
                              if (filteredResidents[index].lastVisited != null && isSameDay(filteredResidents[index].lastVisited!, DateTime.now())) {
                                displayHasBeenVisited = true;
                              }

                              List<Widget> tags = <Widget>[];
                              bool showTag = false;
                              if (filteredResidents[index].situation == Situation.inactive) {
                                tags.add(Container(
                                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.all(5.0),
                                  child: const Text(
                                    "INATIVO",
                                    style: TextStyle(
                                      fontSize: 8,
                                    ),
                                  ),
                                ));
                                tags.add(const SizedBox(
                                  width: 5,
                                ));
                                showTag = true;
                              } else if (filteredResidents[index].situation == Situation.noContact) {
                                tags.add(Container(
                                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.all(5.0),
                                  child: const Text(
                                    "SEM CONTATO",
                                    style: TextStyle(
                                      fontSize: 8,
                                    ),
                                  ),
                                ));
                                tags.add(const SizedBox(
                                  width: 5,
                                ));
                                showTag = true;
                              }

                              if (filteredResidents[index].isMarkedForRemoval) {
                                tags.add(Container(
                                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.all(5.0),
                                  child: const Text(
                                    "MARCADO PARA REMOÇÃO",
                                    style: TextStyle(
                                      fontSize: 8,
                                    ),
                                  ),
                                ));
                                tags.add(const SizedBox(
                                  width: 5,
                                ));
                                showTag = true;
                              } else if (filteredResidents[index].isNew) {
                                tags.add(Container(
                                  decoration: BoxDecoration(color: Theme.of(context).primaryColorLight, borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.all(5.0),
                                  child: const Text(
                                    "SALVO LOCALMENTE",
                                    style: TextStyle(
                                      fontSize: 8,
                                    ),
                                  ),
                                ));
                                tags.add(const SizedBox(
                                  width: 5,
                                ));
                                showTag = true;
                              } else if (filteredResidents[index].wasModified) {
                                tags.add(Container(
                                  decoration: BoxDecoration(color: Colors.green[300], borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.all(5.0),
                                  child: const Text(
                                    "MODIFICADO",
                                    style: TextStyle(
                                      fontSize: 8,
                                    ),
                                  ),
                                ));
                                tags.add(const SizedBox(
                                  width: 5,
                                ));
                                showTag = true;
                              }

                              int roketeDisplayNumber = filteredResidents[index].rokaId;
                              String roketeDisplayNumberString = "";
                              if (roketeDisplayNumber > 0) {
                                roketeDisplayNumberString = "ROKETE Nº ${filteredResidents[index].rokaId}";
                              } else {
                                roketeDisplayNumberString = "ROKETE SEM IDENTIFICAÇÃO";
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                                child: Slidable(
                                  endActionPane: ActionPane(
                                    motion: const StretchMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) => deleteResident(filteredResidents[index].id),
                                        icon: Icons.delete,
                                        backgroundColor: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      )
                                    ],
                                  ),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Visibility(
                                                    visible: displayCoin,
                                                    child: const Icon(
                                                      Icons.monetization_on_rounded,
                                                      color: Color.fromARGB(255, 255, 215, 0),
                                                      size: 20,
                                                    )),
                                                Visibility(
                                                    visible: displayBag,
                                                    child: const Icon(
                                                      Icons.shopping_bag,
                                                      size: 20,
                                                    )),
                                                Visibility(
                                                    visible: displayHasBeenVisited,
                                                    child: const Icon(
                                                      Icons.location_on_rounded,
                                                      size: 20,
                                                    )),
                                              ],
                                            ),
                                            Text(
                                              filteredResidents[index].name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                            ),
                                            Visibility(
                                              visible: filteredResidents[index].description.isNotEmpty,
                                              child: Text(
                                                filteredResidents[index].description,
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                                              ),
                                            ),
                                            Text(
                                              roketeDisplayNumberString,
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                                            ),
                                            Visibility(
                                                visible: showTag,
                                                child: Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(children: tags),
                                                  ],
                                                )),
                                          ],
                                        ),
                                        Visibility(
                                          visible: displayBag || displayHasBeenVisited,
                                          child: const Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.green,
                                            size: 30.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => CreateResidentPage(showCoin: displayCoin, showBag: displayBag, showHasBeenVisited: displayHasBeenVisited, text: "Dados do residente", resident: filteredResidents[index])));
                                    },
                                    leading: const Icon(
                                      Icons.person,
                                      size: 30,
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          );

          return Scaffold(
              appBar: AppBar(
                  scrolledUnderElevation: 0,
                  centerTitle: true,
                  title: const Text(
                    "Rota",
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
              body: body);
        });
  }
}
