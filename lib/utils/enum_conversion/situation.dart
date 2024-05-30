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
