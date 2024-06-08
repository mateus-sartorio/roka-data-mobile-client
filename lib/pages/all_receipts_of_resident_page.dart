import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:mobile_client/models/receipt.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:mobile_client/pages/create_receipt_page.dart';
import 'package:mobile_client/utils/collects/total_rokas.dart';
import 'package:mobile_client/utils/dates/to_date_string.dart';

class AllReceiptsOfResidentPage extends StatefulWidget {
  final Resident resident;

  const AllReceiptsOfResidentPage({Key? key, required this.resident})
      : super(key: key);

  @override
  State<AllReceiptsOfResidentPage> createState() =>
      _AllReceiptsOfResidentPageState();
}

class _AllReceiptsOfResidentPageState extends State<AllReceiptsOfResidentPage> {
  GlobalDatabase db = GlobalDatabase();

  void showUnavailableOldReceiptsModificationMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
            title: const Text(
              "Não é possível modificar entregas de moeda antigas por enquanto.",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
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

  void deleteReceipt(Receipt receipt) {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          title:
              "Tem certeza que deseja remover esta entrega? (esta operação não poderá ser revertida caso os dados sejam sincronizados com o servidor!)",
          onSave: () {
            db.deleteOldReceipt(receipt);
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
          List<Receipt> receipts = widget.resident.receipts;

          receipts.sort(
              (Receipt a, Receipt b) => b.handoutDate.compareTo(a.handoutDate));

          final String totalRokasAmmount =
              totalRokasValue(receipts).toStringAsFixed(2).replaceAll(".", ",");

          Widget body;
          if (receipts.isEmpty) {
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
                "Nenhuma entrega ainda :(",
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
                    "Total: RK\$ $totalRokasAmmount",
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: receipts.length,
                        itemBuilder: (context, index) {
                          String value =
                              "RK\$ ${receipts[index].value.toStringAsFixed(2).replaceAll(".", ",")}";

                          String date =
                              toDateString(receipts[index].handoutDate);

                          Widget tag = Container();
                          bool showTag = false;
                          if (receipts[index].isMarkedForRemoval) {
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
                          } else if (receipts[index].isNew) {
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
                          } else if (receipts[index].wasModified) {
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
                                        deleteReceipt(receipts[index]),
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
                                    Text(
                                      date,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),
                                      textAlign: TextAlign.left,
                                    ),
                                    Text(
                                      value,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Visibility(visible: showTag, child: tag),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CreateReceiptPage(
                                                  isOldReceipt: true,
                                                  text:
                                                      "Alterar dados da entrega",
                                                  receipt: receipts[index])));
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
                  scrolledUnderElevation: 0,
                  centerTitle: true,
                  title: const Text(
                    "♻️ Entregas de moeda",
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
