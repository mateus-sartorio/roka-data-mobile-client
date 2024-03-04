import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:mobile_client/pages/create_collect_page.dart';

class CollectsPage extends StatefulWidget {
  const CollectsPage({Key? key}) : super(key: key);

  @override
  State<CollectsPage> createState() => _CollectsPageState();
}

class _CollectsPageState extends State<CollectsPage> {
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box('globalDatabase').listenable(),
        builder: (context, Box box, _) {
          final collects = box.get("COLLECTS");

          if ((collects?.length ?? 0) == 0) {
            return const Center(
                child: Text(
              "Nenhuma coleta :(",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ));
          }

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Text(
                  "Coletas",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 25),
                ),
              ),
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
                            // tileColor: Theme.of(context).highlightColor,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  residentName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
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
                                      builder: (context) => CreateCollectPage(
                                          text: "Alterar dados da coleta",
                                          collect: collects?[index])));
                            },
                            leading: const Icon(
                              Icons.shopping_bag,
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
          );
        });
  }
}
