import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mobile_client/components/big_button_tile.dart';
import 'package:mobile_client/components/input_field.dart';
import 'package:mobile_client/pages/home_page.dart';

class CreateResidentPage extends StatefulWidget {
  const CreateResidentPage({Key? key}) : super(key: key);

  @override
  State<CreateResidentPage> createState() => _CreateResidentPageState();
}

class _CreateResidentPageState extends State<CreateResidentPage> {
  DateTime? date;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(" ")[0];
        date = picked;
      });
    }
  }

  Future<void> register(BuildContext context) async {
    const String backendRoute = "http://10.0.2.2:8080/api/v1/auth/register";
    Uri uri = Uri.parse(backendRoute);

    final RegExp emailRegExp =
        RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegExp.hasMatch(_emailController.text)) {
      // TODO: treat invalid email here
      print("Invalid Password");
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      // TODO: treat different passwords here
      print("Passwords do not match");
    }

    Map data = {
      "username": _usernameController.text,
      "email": _emailController.text,
      "firstName": _firstnameController.text,
      "lastName": _lastnameController.text,
      "password": _passwordController.text
    };

    var body = json.encode(data);

    try {
      final Response _ = await http.post(uri,
          headers: {"Content-Type": "application/json"}, body: body);

      navigateToRegistrationConfirmationPage();
    } catch (e) {
      // TODO: treat any problema that may occur with the HTTP request
      print("deu bosta");
    }
  }

  void navigateToRegistrationConfirmationPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    var _dateController;
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "♻️ Cadastrar novo morador",
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
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InputField(controller: _usernameController, hintText: "Nome"),
                InputField(controller: _emailController, hintText: "Endereço"),
                InputField(
                    controller: _firstnameController,
                    hintText: "Ponto de referência"),
                InputField(
                    controller: _lastnameController, hintText: "Mora em JN?"),
                InputField(
                    controller: _passwordController, hintText: "Profissão"),
                TextField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                      labelText: "Data de nascimento",
                      filled: true,
                      prefix: Icon(Icons.calendar_today),
                      enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue))),
                  onTap: _selectDate,
                ),
                InputField(
                    controller: _confirmPasswordController,
                    hintText: "Número de telefone"),
                InputField(
                    controller: _confirmPasswordController,
                    hintText: "Está no grupo do WhatsApp?"),
                InputField(
                    controller: _confirmPasswordController,
                    hintText: "Tem plaquinha?"),
                InputField(
                    controller: _confirmPasswordController,
                    hintText: "Ano de registro"),
                InputField(
                    controller: _confirmPasswordController,
                    hintText: "Quantidade de residentes na casa"),
                InputField(
                    controller: _confirmPasswordController,
                    hintText: "Situação"),
                InputField(
                    controller: _confirmPasswordController,
                    hintText: "Observações"),
                SizedBox(
                    width: double.infinity,
                    child: BigButtonTile(
                      isSolid: true,
                      content: const Text(
                        "Cadastrar morador",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => register(context),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
