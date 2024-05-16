import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:mobile_client/models/collect.dart';
import 'package:mobile_client/pages/all_collects_page.dart';
import 'package:mobile_client/pages/create_collect_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_client/utils/collects/total_weight.dart';

class CollectsPage extends StatefulWidget {
  const CollectsPage({Key? key}) : super(key: key);

  @override
  State<CollectsPage> createState() => _CollectsPageState();
}

class _CollectsPageState extends State<CollectsPage> {
  GlobalDatabase db = GlobalDatabase();

  void deleteCollect(int collectId) {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          title: "Tem certeza que deseja remover esta coleta?",
          onSave: () {
            db.deleteCollect(collectId);
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
          final List<dynamic> collectsDynamic = box.get("COLLECTS");

          final List<Collect> collects = [];
          for (dynamic c in collectsDynamic) {
            collects.add(c as Collect);
          }

          final String totalWeightAmmount =
              totalWeight(collects).toString().replaceAll(".", ",");

          return Animate(
            effects: const [
              SlideEffect(
                begin: Offset(-1, 0),
                end: Offset(0, 0),
                duration: Duration(milliseconds: 200),
              )
            ],
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Salvas localmente",
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AllCollectsPage()));
                        },
                        child: const Text(
                          "Ver todas",
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 6),
                  child: Visibility(
                      visible: collects.isNotEmpty,
                      child: Text(
                        "Total: $totalWeightAmmount kg",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                ),
                // ignore: prefer_is_empty
                (collects.length) == 0
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 200,
                          ),
                          Text(
                            "Nenhuma coleta ainda :(",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Expanded(
                        child: ListView.builder(
                            itemCount: collects.length,
                            itemBuilder: (context, index) {
                              String residentName = db
                                      .getResidentById(
                                          collects[index].residentId)
                                      ?.name ??
                                  "";

                              String weight =
                                  collects[index].ammount.toString();

                              List<String> dayMonthYear = collects[index]
                                  .collectedOn
                                  .toString()
                                  .split(" ")[0]
                                  .split("-");

                              String date =
                                  "${dayMonthYear[2]}/${dayMonthYear[1]}/${dayMonthYear[0]}";

                              Widget tag = Container();
                              bool showTag = false;
                              if (collects[index].isMarkedForRemoval) {
                                tag = const Text(
                                  "MARCADO PARA REMOÇÃO",
                                  style: TextStyle(
                                    fontSize: 8,
                                  ),
                                );
                                showTag = true;
                              } else if (collects[index].isNew) {
                                tag = Container(
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.all(5.0),
                                  child: const Text(
                                    "SALVO LOCALMENTE",
                                    style: TextStyle(
                                      fontSize: 8,
                                    ),
                                  ),
                                );
                                showTag = true;
                              } else if (collects[index].wasModified) {
                                tag = Container(
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
                                );
                                showTag = true;
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 15.0),
                                child: Slidable(
                                  endActionPane: ActionPane(
                                    motion: const StretchMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) =>
                                            deleteCollect(collects[index].id),
                                        icon: Icons.delete,
                                        backgroundColor: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      )
                                    ],
                                  ),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    // tileColor: Theme.of(context).highlightColor,
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          residentName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        Text(date,
                                            style:
                                                const TextStyle(fontSize: 13)),
                                        Text(
                                          "${weight.toString().replaceAll(".", ",")} kg",
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Visibility(
                                            visible: showTag, child: tag),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CreateCollectPage(
                                                      isOldCollect: false,
                                                      text:
                                                          "Alterar dados da coleta",
                                                      collect:
                                                          collects[index])));
                                    },
                                    leading: const Icon(
                                      Icons.shopping_bag,
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
        });
  }
}
