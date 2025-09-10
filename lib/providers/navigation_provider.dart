import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  PageController? _pageController;

  PageController? get pageController => _pageController;

  void setPageController(PageController controller) {
    _pageController = controller;
  }

  void navigateToPage(int page) {
    _pageController?.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
