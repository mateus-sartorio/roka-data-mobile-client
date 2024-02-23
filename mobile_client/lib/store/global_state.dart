import 'package:flutter/material.dart';
import 'package:mobile_client/models/resident.dart';

class GlobalState extends ChangeNotifier {
  List<Resident> residents;

  GlobalState({required this.residents});

  void setState(List<Resident> residents) {
    this.residents = residents;
    notifyListeners();
  }
}
