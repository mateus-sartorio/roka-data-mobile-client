import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:mobile_client/models/collect.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:mobile_client/pages/create_collect_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_client/utils/collects/total_weight.dart';
import 'package:mobile_client/utils/dates/compare.dart';
import 'package:mobile_client/utils/dates/to_date_string.dart';

class AllCollectsOfResidentPage extends StatefulWidget {
  final Resident resident;

  const AllCollectsOfResidentPage({Key? key, required this.resident})
      : super(key: key);

  @override
  State<AllCollectsOfResidentPage> createState() =>
      _AllCollectsOfResidentPageState();
}

class _AllCollectsOfResidentPageState extends State<AllCollectsOfResidentPage> {
  GlobalDatabase db = GlobalDatabase();

  void deleteCollect(Collect collect) {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          title:
              "Tem certeza que deseja remover esta coleta? (esta operação não poderá ser revertida caso os dados sejam sincronizados com o servidor!)",
          onSave: () {
            db.deleteOldCollect(collect);
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
          List<Collect> collects = widget.resident.collects;

          collects.sort(
              (Collect a, Collect b) => b.collectedOn.compareTo(a.collectedOn));

          final String totalWeightAmmount =
              totalWeight(collects).toStringAsFixed(2).replaceAll(".", ",");

          Map<String, double> totalWeightByCollectedOnDate =
              totalWeightByMonth(collects);

          Widget body;
          if (collects.isEmpty) {
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
                "Nenhuma coleta ainda :(",
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
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Total: $totalWeightAmmount kg",
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: collects.length,
                        itemBuilder: (context, index) {
                          String day =
                              toDateString(collects[index].collectedOn);

                          String weight =
                              collects[index].ammount.toStringAsFixed(2);

                          String month =
                              toMonthString(collects[index].collectedOn);

                          Widget tag = Container();
                          bool showTag = false;
                          if (collects[index].isMarkedForRemoval) {
                            tag = Container(
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
                            );

                            showTag = true;
                          } else if (collects[index].isNew) {
                            tag = Container(
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

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Visibility(
                                  visible: index == 0 ||
                                      !isSameMonth(collects[index].collectedOn,
                                          collects[index - 1].collectedOn),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 25, top: (index == 0 ? 10 : 25)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          month,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                          textAlign: TextAlign.left,
                                        ),
                                        Text(
                                            "${totalWeightByCollectedOnDate[toMonthString(collects[index].collectedOn)]?.toStringAsFixed(2).replaceAll(".", ",")} kg")
                                      ],
                                    ),
                                  )),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Slidable(
                                  endActionPane: ActionPane(
                                    motion: const StretchMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) =>
                                            deleteCollect(collects[index]),
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
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          day,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17),
                                          textAlign: TextAlign.left,
                                        ),
                                        Text(
                                          "${weight.toString().replaceAll(".", ",")} kg",
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500),
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
                                                      isOldCollect: true,
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
                              ),
                            ],
                          );
                        }),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            );
          }

          return Scaffold(
              appBar: AppBar(
                  scrolledUnderElevation: 0,
                  centerTitle: true,
                  title: const Text(
                    "Coletas",
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
