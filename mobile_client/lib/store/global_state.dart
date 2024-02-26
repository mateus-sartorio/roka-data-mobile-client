import 'package:flutter/material.dart';
import 'package:mobile_client/models/collect.dart';
import 'package:mobile_client/models/resident.dart';

class GlobalState extends ChangeNotifier {
  List<Resident> residents;
  List<Collect> collects;

  GlobalState({required this.residents, required this.collects});

  void setState(List<Resident> residents, List<Collect> collects) {
    this.residents = residents;
    this.collects = collects;
    notifyListeners();
  }
}
