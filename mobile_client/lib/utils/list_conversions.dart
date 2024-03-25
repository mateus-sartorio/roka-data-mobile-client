List<T> dynamicListToTList<T>(List<dynamic> list) {
  List<T> returnList = [];
  for (dynamic element in list) {
    returnList.add(element as T);
  }

  return returnList;
}
