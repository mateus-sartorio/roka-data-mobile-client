String toDateString(DateTime dateTime) {
  List<String> dayMonthYear = dateTime.toString().split(" ")[0].split("-");
  return "${dayMonthYear[2]}/${dayMonthYear[1]}/${dayMonthYear[0]}";
}
