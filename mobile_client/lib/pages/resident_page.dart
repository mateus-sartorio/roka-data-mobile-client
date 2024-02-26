import 'package:flutter/material.dart';
import 'package:mobile_client/models/resident.dart';

class ResidentPage extends StatelessWidget {
  final Resident resident;
  const ResidentPage({Key? key, required this.resident}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Morador",
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
      body: SingleChildScrollView(
          child: Column(
        children: [
          Text("Nome: ${resident.name}"),
          Text("Roka ID: ${resident.rokaId}"),
          Text("Endereço: ${resident.address}"),
          Text("Ponto de referência: ${resident.referencePoint}"),
          Text("Telefone: ${resident.phone}"),
          Text("Profissão: ${resident.profession}"),
          Text(
              "Está no grupo do WhatsApp?: ${resident.isOnWhatsappGroup.toString()}"),
          Text("Tem plaquinha?: ${resident.hasPlaque.toString()}"),
          Text("Ano de cadastro: ${resident.registrationYear}"),
          Text("Situação: ${resident.situation.toString()}"),
          Text("Observações: ${resident.observations}"),
        ],
      )),
    );
  }
}
