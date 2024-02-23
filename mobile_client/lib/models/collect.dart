class Collect {
  int id;
  int ammount;
  DateTime collectedOn;
  DateTime createdAt;
  int residentId;
  DateTime updatedAt;
  bool isNew;

  Collect(
      {required this.ammount,
      required this.collectedOn,
      required this.createdAt,
      required this.id,
      required this.residentId,
      required this.updatedAt,
      required this.isNew});
}
