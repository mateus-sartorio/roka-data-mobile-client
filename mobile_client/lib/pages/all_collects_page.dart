import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:mobile_client/pages/create_collect_page.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AllCollectsPage extends StatefulWidget {
  const AllCollectsPage({Key? key}) : super(key: key);

  @override
  State<AllCollectsPage> createState() => _AllCollectsPageState();
}

class _AllCollectsPageState extends State<AllCollectsPage> {
  GlobalDatabase db = GlobalDatabase();

  void deleteCollect(int residentId) {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          title: "Tem certeza que deseja apagar esta coleta?",
          onSave: () {
            db.deleteCollect(residentId);
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

  void showWarning() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
            title: const Text(
              "Erro ao baixar coletas do servidor, tente novamente.",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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

  void showSyncingAnimation(context) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text(
            "Só um momento...",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          contentPadding:
              const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 5),
          children: [
            Center(
              child: LoadingAnimationWidget.newtonCradle(
                color: Colors.black,
                size: 200,
              ),
            ),
          ],
        );
      },
    );
  }

  void closeAnimation() {
    Navigator.of(context).pop();
  }

  Future<void> getAllCollects(context) async {
    try {
      await db.fetchDataFromBackend();
      await db.fetchAllCollects();
    } catch (e) {
      showWarning();
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => getAllCollects(context));

    return ValueListenableBuilder(
        valueListenable: Hive.box('globalDatabase').listenable(),
        builder: (context, Box box, _) {
          final collects = box.get("ALL_DATABASE_COLLECTS");

          Widget body;
          if ((collects?.length ?? 0) == 0) {
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
                "Nenhuma coleta  :(",
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
                        itemCount: collects?.length ?? 0,
                        itemBuilder: (context, index) {
                          String residentName = db
                                  .getResidentById(
                                      collects?[index].residentId ?? -1)
                                  ?.name ??
                              "";

                          String weight =
                              collects?[index]?.ammount.toString() ?? "";

                          List<String> dayMonthYear = collects?[index]
                                  ?.collectedOn
                                  .toString()
                                  .split(" ")[0]
                                  .split("-") ??
                              ["", "", ""];

                          String date =
                              "${dayMonthYear[2]}/${dayMonthYear[1]}/${dayMonthYear[0]}";

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 15.0),
                            child: Slidable(
                              endActionPane: ActionPane(
                                motion: const StretchMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) => deleteCollect(
                                        collects?[index]?.residentId ?? -1),
                                    icon: Icons.delete,
                                    backgroundColor: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  )
                                ],
                              ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          residentName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17),
                                          textAlign: TextAlign.left,
                                        ),
                                        Text(date,
                                            style:
                                                const TextStyle(fontSize: 13)),
                                      ],
                                    ),
                                    Text(
                                      "${weight.toString().replaceAll(".", ",")} kg",
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CreateCollectPage(
                                                  text:
                                                      "Alterar dados da coleta",
                                                  collect: collects?[index])));
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
          }

          return Scaffold(
              appBar: AppBar(
                  centerTitle: true,
                  title: const Text(
                    "♻️ Todas coletas",
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
