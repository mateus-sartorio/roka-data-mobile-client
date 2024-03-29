import 'package:flutter/material.dart';
import 'package:mobile_client/components/bottom_navbar.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/pages/about.dart';
import 'package:mobile_client/pages/collects_page.dart';
import 'package:mobile_client/pages/create_collect_page.dart';
import 'package:mobile_client/pages/create_receipt_page.dart';
import 'package:mobile_client/pages/currency_handouts_page.dart';
import 'package:mobile_client/pages/receipts_page.dart';
import 'package:mobile_client/pages/residents_page.dart';
import 'package:mobile_client/pages/cloud_sync_page.dart';
import 'package:mobile_client/pages/residents_that_need_collect_in_the_house_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalDatabase db = GlobalDatabase();

  @override
  void initState() {
    super.initState();
  }

  int _selectedIndex = 0;
  navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const CollectsPage(),
      const CloudSyncPage(),
      const ReceiptsPage(),
    ];

    final List<Widget?> floatingActionButtons = [
      FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CreateCollectPage(
                        isOldCollect: false,
                        text: "Cadastrar nova coleta",
                      )));
        },
        child: const Icon(Icons.add),
      ),
      null,
      FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CreateReceiptPage(
                        isOldReceipt: false,
                        text: "Cadastrar nova entrega",
                      )));
        },
        child: const Icon(Icons.add),
      ),
    ];

    final List<String> titles = [
      "♻️ Coletas",
      "♻️ Sincronizar dados",
      "♻️ Entregas",
    ];

    return Scaffold(
      bottomNavigationBar:
          BottomNavbar(onTabChange: (index) => navigateBottomBar(index)),
      body: SafeArea(child: pages[_selectedIndex]),
      appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            titles[_selectedIndex],
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu),
            ),
          )),
      drawer: Drawer(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          // logo
          DrawerHeader(child: Image.asset("assets/images/logo.png")),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Início"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const HomePage()));
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Residentes"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ResidentsPage()));
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: ListTile(
              leading: const Icon(Icons.wallet),
              title: const Text("Entregas da moeda"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CurrencyHandoutsPage()));
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: ListTile(
              leading: const Icon(Icons.route),
              title: const Text("Rota"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ResidentsThatNeedCollectOnTheHousePage()));
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text("Sobre"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const About()));
              },
            ),
          ),
          //other pages
        ]),
      ),
      floatingActionButton: floatingActionButtons[_selectedIndex],
    );
  }
}
