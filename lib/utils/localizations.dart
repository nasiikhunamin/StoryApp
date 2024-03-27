class Localization {
  static String getFlag(String code) {
    switch (code) {
      case 'en':
        return "US";
      case 'ja':
        return "JPN";
      case 'id':
      default:
        return "ID";
    }
  }
}
