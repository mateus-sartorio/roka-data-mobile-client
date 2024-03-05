import 'package:flutter/material.dart';
import 'package:mobile_client/components/bottom_navbar.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/pages/about.dart';
import 'package:mobile_client/pages/collects_page.dart';
import 'package:mobile_client/pages/create_collect_page.dart';
import 'package:mobile_client/pages/create_resident_page.dart';
import 'package:mobile_client/pages/residents_page.dart';
import 'package:mobile_client/pages/cloud_sync_page.dart';

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
      const ResidentsPage(),
      const CloudSyncPage(),
      const CollectsPage(),
    ];

    final List<Widget?> floatingActionButtons = [
      FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CreateResidentPage(
                        text: "Cadastrar novo residente",
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
                  builder: (context) => const CreateCollectPage(
                        text: "Cadastrar nova coleta",
                      )));
        },
        child: const Icon(Icons.add),
      )
    ];

    return Scaffold(
      bottomNavigationBar:
          BottomNavbar(onTabChange: (index) => navigateBottomBar(index)),
      body: SafeArea(child: pages[_selectedIndex]),
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "♻️ Roka",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
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
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const HomePage()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text("Sobre"),
              onTap: () {
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
