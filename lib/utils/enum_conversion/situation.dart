import 'package:mobile_client/enums/situation.dart';

int situationToInteger(Situation situation) {
  int situationIntegerValue = 0;
  if (situation == Situation.active) {
    situationIntegerValue = 0;
  } else if (situation == Situation.inactive) {
    situationIntegerValue = 1;
  } else if (situation == Situation.noContact) {
    situationIntegerValue = 2;
  }

  return situationIntegerValue;
}

String situationToString(Situation situation) {
  switch (situation) {
    case Situation.active:
      return "Ativo";
    case Situation.inactive:
      return "Inativo";
    case Situation.noContact:
      return "Sem contato";
  }
}

Situation stringToSituation(String situation) {
  switch (situation) {
    case "Ativo":
      return Situation.active;
    case "Inativo":
      return Situation.inactive;
    case "Sem contato":
      return Situation.noContact;
    default:
      return Situation.active;
  }
}

Situation integerToSituation(int situationIntegerValue) {
  Situation situation = Situation.active;
  if (situationIntegerValue == 0) {
    situation = Situation.active;
  } else if (situationIntegerValue == 1) {
    situation = Situation.inactive;
  } else if (situationIntegerValue == 2) {
    situation = Situation.noContact;
  }

  return situation;
}
