import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_client/pages/create_receipt_page.dart';

class ReceiptsPage extends StatefulWidget {
  const ReceiptsPage({Key? key}) : super(key: key);

  @override
  State<ReceiptsPage> createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  GlobalDatabase db = GlobalDatabase();

  void deleteReceipt(int receiptId) {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          title: "Tem certeza que deseja apagar esta entrega?",
          onSave: () {
            db.deleteReceipt(receiptId);
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

          if ((receipts?.length ?? 0) == 0) {
            return Animate(
              effects: const [
                SlideEffect(
                  begin: Offset(1, 0),
                  end: Offset(0, 0),
                  duration: Duration(milliseconds: 200),
                )
              ],
              child: const Center(
                  child: Text(
                "Nenhuma entrega ainda :(",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
            );
          }

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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Text(
                    "Entregas",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: receipts?.length ?? 0,
                      itemBuilder: (context, index) {
                        String residentName = db
                                .getResidentById(
                                    receipts?[index].residentId ?? -1)
                                ?.name ??
                            "";

                        String value = receipts?[index]?.value.toString() ?? "";

                        List<String> dayMonthYear = receipts?[index]
                                ?.handoutDate
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
                                  onPressed: (context) =>
                                      deleteReceipt(receipts?[index]?.id ?? -1),
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
                                          style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                  Text(
                                    "${value.toString().replaceAll(".", ",")} rokas",
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
                                        builder: (context) => CreateReceiptPage(
                                            text: "Alterar dados da entrega",
                                            receipt: receipts?[index])));
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
