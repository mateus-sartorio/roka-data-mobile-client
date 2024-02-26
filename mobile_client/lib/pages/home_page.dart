import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mobile_client/components/bottom_navbar.dart';
import 'package:mobile_client/data/database.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:mobile_client/pages/collects_page.dart';
import 'package:mobile_client/pages/residents_page.dart';
import 'package:mobile_client/pages/upload_page.dart';
import 'package:mobile_client/store/global_state.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box('globalDatabase');
  GlobalDatabase db = GlobalDatabase();

  @override
  void initState() {
    if (_myBox.get("LOCALSTORAGE") == null) {
      if (kDebugMode) {
        print("nice");
      }
      db.fetchDataFromBackend();
    } else {
      db.loadData();
    }

    setStoreState(db.residents);

    super.initState();
  }

  void setStoreState(List<Resident> residents) {
    Provider.of<GlobalState>(context, listen: false).setState(residents);
  }

  int _selectedIndex = 0;
  navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const ResidentsPage(),
    const UploadPage(),
    const CollectsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:
          BottomNavbar(onTabChange: (index) => navigateBottomBar(index)),
      body: _pages[_selectedIndex],
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "♻️ Roka",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu),
            ),
          )),
      drawer: const Drawer(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          // logo

          Padding(
            padding: EdgeInsets.all(8.0),
            child: ListTile(leading: Icon(Icons.home), title: Text("Home")),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.info),
              title: Text("Sobre"),
            ),
          ),

          //other pages
        ]),
      ),
    );
  }
}
