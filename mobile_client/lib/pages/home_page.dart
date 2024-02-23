import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mobile_client/components/bottom_navbar.dart';
import 'package:mobile_client/enums/situation.dart';
import 'package:mobile_client/models/resident.dart';
import 'package:mobile_client/pages/collects_page.dart';
import 'package:mobile_client/pages/residents_page.dart';
import 'package:mobile_client/pages/upload_page.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_client/store/global_state.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    const String backendRoute = "http://10.0.2.2:3000/residents";
    Uri uri = Uri.parse(backendRoute);

    try {
      final Response response = await http.get(uri);
      List<dynamic> responseBody = jsonDecode(response.body);

      List<Resident> residents = [];

      for (dynamic residentMapObject in responseBody) {
        Resident resident = Resident(
            id: residentMapObject["id"],
            address: residentMapObject["address"],
            // birthdate: DateTime.parse(residentMapObject["birthdate"]),
            collects: [],
            // createdAt: DateTime.parse(residentMapObject["created_at"]),
            hasPlaque: residentMapObject["has_plaque"],
            isOnWhatsappGroup: residentMapObject["is_on_whatsapp_group"],
            livesInJN: residentMapObject["lives_in_JN"],
            name: residentMapObject["name"],
            observations: residentMapObject["observations"],
            phone: residentMapObject["phone"],
            profession: residentMapObject["profession"],
            referencePoint: residentMapObject["reference_point"],
            registrationYear: residentMapObject["registration_year"],
            residentsInTheHouse: residentMapObject["residents_in_the_house"],
            rokaId: residentMapObject["roka_id"],
            situation: Situation.active,
            // updatedAt: DateTime.parse(residentMapObject["updated_at"]),
            isNew: false);

        residents.add(resident);
      }

      saveData(residents);
    } catch (e) {
      // TODO: treat any problema that may occur with the HTTP request
      if (kDebugMode) {
        print("deu bosta");
      }
    }
  }

  void saveData(List<Resident> residents) {
    Provider.of<GlobalState>(context, listen: false).setState(residents);
  }

  int _selectedIndex = 0;

  navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    // shop page
    const ResidentsPage(),

    // upload page
    const UploadPage(),

    // cart page
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
