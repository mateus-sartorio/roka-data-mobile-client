import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/modals/dialog_box.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_client/models/currency_handout.dart';
import 'package:mobile_client/pages/create_currency_handout_page.dart';
import 'package:mobile_client/utils/list_conversions.dart';

class CurrencyHandoutsPage extends StatefulWidget {
  const CurrencyHandoutsPage({Key? key}) : super(key: key);

  @override
  State<CurrencyHandoutsPage> createState() => _CurrencyHandoutsPageState();
}

class _CurrencyHandoutsPageState extends State<CurrencyHandoutsPage> {
  GlobalDatabase db = GlobalDatabase();

  void deleteCurrencyHandout(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          title:
              "Tem certeza que deseja remover esta entrega de moeda? (esta operação não poderá ser revertida caso os dados sejam sincronizados com o servidor!)",
          onSave: () {
            db.deleteCurrencyHandout(id);
            Navigator.of(context).pop(true);

            showDialog(
                context: context,
                builder: (context) {
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    Navigator.of(context).pop(true);
                  });

                  return AlertDialog(
                    title: const Text(
                      "Distribuição de moeda removida com sucesso",
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
          final currencyHandoutsDynamicList = box.get("CURRENCY_HANDOUTS");

          List<CurrencyHandout> currencyHandouts =
              dynamicListToTList(currencyHandoutsDynamicList);

          currencyHandouts.sort((CurrencyHandout a, CurrencyHandout b) =>
              b.startDate.compareTo(a.startDate));

          Widget body;
          if (currencyHandouts.isEmpty) {
            body = Animate(
              effects: const [
                SlideEffect(
                  begin: Offset(1, 0),
                  end: Offset(0, 0),
                  duration: Duration(milliseconds: 200),
                )
              ],
              child: const Center(
                  child: Text(
                "Nenhuma distribuição de moeda ainda :(",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )),
            );
          } else {
            body = Animate(
              effects: const [
                SlideEffect(
                  begin: Offset(1, 0),
                  end: Offset(0, 0),
                  duration: Duration(milliseconds: 200),
                )
              ],
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: currencyHandouts.length,
                        itemBuilder: (context, index) {
                          List<String> dayMonthYear = currencyHandouts[index]
                              .startDate
                              .toString()
                              .split(" ")[0]
                              .split("-");

                          String date =
                              "${dayMonthYear[2]}/${dayMonthYear[1]}/${dayMonthYear[0]}";

                          Widget tag = Container();
                          bool showTag = false;
                          if (currencyHandouts[index].isMarkedForRemoval) {
                            tag = Container(
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.all(5.0),
                              child: const Text(
                                "MARCADO PARA REMOÇÃO",
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            );

                            showTag = true;
                          } else if (currencyHandouts[index].isNew) {
                            tag = Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorLight,
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.all(5.0),
                              child: const Text(
                                "SALVO LOCALMENTE",
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            );

                            showTag = true;
                          } else if (currencyHandouts[index].wasModified) {
                            tag = Container(
                              decoration: BoxDecoration(
                                  color: Colors.green[300],
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.all(5.0),
                              child: const Text(
                                "MODIFICADO",
                                style: TextStyle(
                                  fontSize: 10,
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
                                        deleteCurrencyHandout(
                                      currencyHandouts[index].id,
                                    ),
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
                                    Visibility(visible: showTag, child: tag),
                                    Text(
                                      currencyHandouts[index].title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),
                                      textAlign: TextAlign.left,
                                    ),
                                    Text(date,
                                        style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CreateCurrencyHandoutPage(
                                                  text:
                                                      "Alterar dados da distribuição de moeda",
                                                  currencyHandout:
                                                      currencyHandouts[
                                                          index])));
                                },
                                leading: const Icon(
                                  Icons.wallet,
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
                    "♻️ Distribuições da moeda",
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
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateCurrencyHandoutPage(
                                text: "Cadastrar nova entrega da moeda",
                              )));
                },
                child: const Icon(Icons.add),
              ),
              body: body);
        });
  }
}
