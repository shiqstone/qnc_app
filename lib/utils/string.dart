class StringUtil {
  static bool isEmail(String input) {
    String regex = "^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}\$";
    if (input.isEmpty) return false;
    return new RegExp(regex).hasMatch(input);
  }

  static bool isChinese(String input) {
    String regex = "[\u4e00-\u9fa5]";
    if (input.isEmpty) return false;
    return new RegExp(regex).hasMatch(input);
  }
}
