import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/enums/situation.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:mobile_client/models/currency_handout.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:mobile_client/pages/create_resident_page.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ResidentsThatNeedCollectOnTheHousePage extends StatefulWidget {
  const ResidentsThatNeedCollectOnTheHousePage({Key? key}) : super(key: key);

  @override
  State<ResidentsThatNeedCollectOnTheHousePage> createState() =>
      _ResidentsThatNeedCollectOnTheHousePageState();
}

class _ResidentsThatNeedCollectOnTheHousePageState
    extends State<ResidentsThatNeedCollectOnTheHousePage> {
  GlobalDatabase db = GlobalDatabase();

  void deleteResident(int residentId) {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          title:
              "Tem certeza que deseja remover este residente? (esta operação não poderá ser revertida caso os dados sejam sincronizados com o servidor!)",
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
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
          List<Resident> allResidents = [];
          for (dynamic r in allResidentsDynamicList) {
            if (r.needsCollectOnTheHouse) {
              allResidents.add(r as Resident);
            }
          }

          Widget body;
          if (allResidents.isEmpty) {
            body = Animate(
              effects: const [
                SlideEffect(
                  begin: Offset(-1, 0),
                  end: Offset(0, 0),
                  duration: Duration(milliseconds: 200),
                )
              ],
              child: const Center(
                  child: Text(
                "Nenhum residente :(",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
            );
          } else {
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
                  Expanded(
                    child: ListView.builder(
                        itemCount: allResidents.length,
                        itemBuilder: (context, index) {
                          final CurrencyHandout? lastCurrencyHandout = box
                              .get("LAST_CURRENCY_HANDOUT") as CurrencyHandout?;

                          bool displayCoin = false;
                          if (allResidents[index].receipts.isNotEmpty &&
                              allResidents[index]
                                      .receipts[0]
                                      .currencyHandoutId ==
                                  lastCurrencyHandout?.id) {
                            displayCoin = true;
                          }

                          List<Widget> tags = <Widget>[];
                          bool showTag = false;
                          if (allResidents[index].situation ==
                              Situation.inactive) {
                            tags.add(Container(
                              decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(8)),
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
                          } else if (allResidents[index].situation ==
                              Situation.noContact) {
                            tags.add(Container(
                              decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(8)),
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

                          if (allResidents[index].isMarkedForRemoval) {
                            tags.add(Container(
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8)),
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
                          } else if (allResidents[index].isNew) {
                            tags.add(Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorLight,
                                  borderRadius: BorderRadius.circular(8)),
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
                          } else if (allResidents[index].wasModified) {
                            tags.add(Container(
                              decoration: BoxDecoration(
                                  color: Colors.green[300],
                                  borderRadius: BorderRadius.circular(8)),
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

                          int roketeDisplayNumber = allResidents[index].rokaId;
                          String roketeDisplayNumberString = "";
                          if (roketeDisplayNumber > 0) {
                            roketeDisplayNumberString =
                                "ROKETE Nº ${allResidents[index].rokaId}";
                          } else {
                            roketeDisplayNumberString =
                                "ROKETE SEM IDENTIFICAÇÃO";
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 15.0),
                            child: Slidable(
                              endActionPane: ActionPane(
                                motion: const StretchMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) =>
                                        deleteResident(allResidents[index].id),
                                    icon: Icons.delete,
                                    backgroundColor: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  )
                                ],
                              ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Visibility(
                                        visible: displayCoin,
                                        child: const Icon(
                                          Icons.monetization_on_rounded,
                                          color:
                                              Color.fromARGB(255, 255, 215, 0),
                                          size: 20,
                                        )),
                                    Text(
                                      allResidents[index].name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    Text(
                                      roketeDisplayNumberString,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Visibility(
                                        visible: showTag,
                                        child: Row(children: tags)),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CreateResidentPage(
                                                  text: "Dados do residente",
                                                  resident:
                                                      allResidents[index])));
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
                ],
              ),
            );
          }

          return Scaffold(
              appBar: AppBar(
                  centerTitle: true,
                  title: const Text(
                    "♻️ Rota",
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
