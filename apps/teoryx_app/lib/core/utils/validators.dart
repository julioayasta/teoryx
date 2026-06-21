class Validators {
  const Validators._();

  static bool isNotBlank(String value) => value.trim().isNotEmpty;
}
