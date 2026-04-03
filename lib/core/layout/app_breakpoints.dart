enum AppLayout {
  compact,
  medium,
  expanded,
}

class AppBreakpoints {
  static const double compactMaxWidth = 767;
  static const double mediumMaxWidth = 1199;

  static AppLayout layoutForWidth(double width) {
    if (width <= compactMaxWidth) {
      return AppLayout.compact;
    }
    if (width <= mediumMaxWidth) {
      return AppLayout.medium;
    }
    return AppLayout.expanded;
  }
}
