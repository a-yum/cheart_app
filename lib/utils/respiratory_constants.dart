class RespiratoryConstants {
  static const int highBpmThreshold = 40;

  static String highBpmWarningMessage(String petName) {
    return '$petName\'s breathing rate is above the normal range. '
           'Please monitor closely and consult your vet if it continues.';
  }
}
