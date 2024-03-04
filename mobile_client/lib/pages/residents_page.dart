import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:mobile_client/pages/create_resident_page.dart';

class ResidentsPage extends StatefulWidget {
  const ResidentsPage({Key? key}) : super(key: key);

  @override
  State<ResidentsPage> createState() => _ResidentsPageState();
}

class _ResidentsPageState extends State<ResidentsPage> {
  GlobalDatabase db = GlobalDatabase();

  void deleteResident(int residentId) {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          title: "Tem certeza que deseja apagar este residente?",
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
                      "Residente removido com sucesso :(",
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
          final residents = box.get("RESIDENTS");

          if ((residents?.length ?? 0) == 0) {
            return const Center(
                child: Text(
              "Nenhum residente :(",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ));
          }

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Text(
                  "Residentes",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 25),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: residents?.length ?? 0,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 15.0),
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) =>
                                    deleteResident(residents?[index]?.id ?? -1),
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
                                  visible: (residents[index]?.isNew &&
                                      !residents[index]?.isMarkedForRemoval),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).primaryColorLight,
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
                                  visible:
                                      (residents[index]?.isMarkedForRemoval),
                                  child: Container(
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
                                ),
                                Visibility(
                                  visible: (!residents[index]?.isNew &&
                                      !residents[index]?.isMarkedForRemoval &&
                                      residents[index]?.wasModified),
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
                                Text(
                                  residents?[index]?.name ?? "",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                Text(
                                  "Rokete nº ${residents?[index]?.rokaId ?? ""}",
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
                                      builder: (context) => CreateResidentPage(
                                          text: "Dados do residente",
                                          resident: residents?[index])));
                            },
                            leading: const Icon(
                              Icons.person,
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
