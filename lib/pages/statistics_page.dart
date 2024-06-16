import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_client/models/collect.dart';
import 'package:mobile_client/models/receipt.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:mobile_client/utils/collects/total_weight.dart';
import 'package:mobile_client/utils/list_conversions.dart';
import 'package:mobile_client/utils/receipts/total_rokas.dart';
import 'package:mobile_client/utils/residents/ressidents_statistics.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsState();
}

class _StatisticsState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box('globalDatabase').listenable(),
        builder: (context, Box box, _) {
          final dynamicResisentsList = box.get("RESIDENTS");
          final List<Resident> residents =
              dynamicListToTList(dynamicResisentsList);

          final List<dynamic> collectsListDynamic = box.get("COLLECTS") ?? [];
          final List<Collect> collectsList =
              dynamicListToTList(collectsListDynamic);

          final List<dynamic> oldCollectsListDynamic =
              box.get("ALL_DATABASE_COLLECTS") ?? [];
          final List<Collect> oldCollectsList =
              dynamicListToTList(oldCollectsListDynamic);

          final List<Collect> collects = [...collectsList, ...oldCollectsList];

          final List<dynamic> oldReceiptsListDynamic =
              box.get("ALL_DATABASE_RECEIPTS") ?? [];
          final List<Receipt> oldReceiptsList =
              dynamicListToTList(oldReceiptsListDynamic);
          final List<dynamic> receiptsListDynamic = box.get("RECEIPTS") ?? [];
          final List<Receipt> receiptsList =
              dynamicListToTList(receiptsListDynamic);

          final List<Receipt> receipts = [...receiptsList, ...oldReceiptsList];

          final int registeredHouses = residents.length;
          final int impactedLives = totalLivesImpacted(residents);
          final double totalOfCollectedPlastic = totalWeight(collects);
          final double totalOfDistributedRokas = totalRokasValue(receipts);

          return Scaffold(
              appBar: AppBar(
                  scrolledUnderElevation: 0,
                  centerTitle: true,
                  title: const Text(
                    "Estatísticas",
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
              body: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Total de casas cadastradas",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$registeredHouses",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Total de vidas impactadas",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$impactedLives",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Total de resíduo coletado",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${totalOfCollectedPlastic.toStringAsFixed(2).replaceAll(".", ",")} kg",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Total de rokas distribuídas",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "RK\$ ${totalOfDistributedRokas.toStringAsFixed(2).replaceAll(".", ",")}",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ));
        });
  }
}
