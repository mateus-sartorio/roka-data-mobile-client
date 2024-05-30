enum StatusCodes {
  update(302),
  create(302),
  delete(302);

  final int value;

  const StatusCodes(this.value);
}
