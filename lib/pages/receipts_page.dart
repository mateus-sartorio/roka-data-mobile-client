import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_client/models/receipt.dart';
import 'package:mobile_client/pages/all_receipts_page.dart';
import 'package:mobile_client/pages/create_receipt_page.dart';

class ReceiptsPage extends StatefulWidget {
  const ReceiptsPage({Key? key}) : super(key: key);

  @override
  State<ReceiptsPage> createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  GlobalDatabase db = GlobalDatabase();

  void deleteReceipt(Receipt receipt) {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          title: "Tem certeza que deseja remover esta entrega?",
          onSave: () {
            db.deleteReceipt(receipt);
            Navigator.of(context).pop(true);

            showDialog(
                context: context,
                builder: (context) {
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    Navigator.of(context).pop(true);
                  });

                  return AlertDialog(
                    title: const Text(
                      "Entrega removida com sucesso",
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
          final receipts = box.get("RECEIPTS");

          return Animate(
            effects: const [
              SlideEffect(
                begin: Offset(1, 0),
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
                                      const AllReceiptsPage()));
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
                (receipts?.length ?? 0) == 0
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 200,
                          ),
                          Text(
                            "Nenhuma entrega ainda :(",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Expanded(
                        child: ListView.builder(
                            itemCount: receipts?.length ?? 0,
                            itemBuilder: (context, index) {
                              String residentName = db
                                      .getResidentById(
                                          receipts?[index].residentId ?? -1)
                                      ?.name ??
                                  "";

                              String value =
                                  "RK\$ ${receipts[index].value.toStringAsFixed(2).replaceAll(".", ",")}";

                              List<String> dayMonthYear = receipts?[index]
                                      ?.handoutDate
                                      .toString()
                                      .split(" ")[0]
                                      .split("-") ??
                                  ["", "", ""];

                              String date =
                                  "${dayMonthYear[2]}/${dayMonthYear[1]}/${dayMonthYear[0]}";

                              Widget tag = Container();
                              bool showTag = false;
                              if (receipts[index]?.isMarkedForRemoval ??
                                  false) {
                                tag = const Text(
                                  "MARCADO PARA REMOÇÃO",
                                  style: TextStyle(
                                    fontSize: 8,
                                  ),
                                );

                                showTag = true;
                              } else if (receipts[index]?.isNew ?? false) {
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
                              } else if (receipts[index]?.wasModified ??
                                  false) {
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
                                    vertical: 8.0, horizontal: 15.0),
                                child: Slidable(
                                  endActionPane: ActionPane(
                                    motion: const StretchMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) =>
                                            deleteReceipt(receipts?[index]!),
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
                                              fontSize: 17),
                                          textAlign: TextAlign.left,
                                        ),
                                        Text(date,
                                            style:
                                                const TextStyle(fontSize: 13)),
                                        Text(
                                          value,
                                          style: const TextStyle(
                                              fontSize: 15,
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
                                                  CreateReceiptPage(
                                                      isOldReceipt: false,
                                                      text:
                                                          "Alterar dados da entrega",
                                                      receipt:
                                                          receipts?[index])));
                                    },
                                    leading: const Icon(
                                      Icons.monetization_on_rounded,
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
