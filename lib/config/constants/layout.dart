// config/constants/layout.dart

import 'package:flutter/material.dart';

/// Layout constants for responsive UI measurements
class AppLayout {
  // Private constructor to prevent instantiation
  AppLayout._();

  // Named spacing constants for consistency
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;

  // Component dimensions
  static const double sidebarWidth = 55.0;
  static const double compactSidebarWidth = 38.5; // 70% of original
  static const double selectorHeight = 36.0;
  static const double buttonRadius = 8.0;
  static const double tagRadius = 12.0;
  static const double actionBarHeight = 50.0;
  static const double compactActionBarHeight = 42.5; // 85% of original
  static const double circleButtonSize = 45.0;
  static const double compactCircleButtonSize = 38.0; // 85% of original

  // Screen size breakpoints for responsive design
  static const double mobileBreakpoint = 480.0;
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1024.0;

  // Get appropriate dimensions based on screen width
  static double getSidebarWidth(BuildContext context, {bool isCompact = false}) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) {
      return isCompact ? compactSidebarWidth - 5 : compactSidebarWidth;
    }
    return isCompact ? compactSidebarWidth : sidebarWidth;
  }

  static double getSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return spacingXS;
    if (width < tabletBreakpoint) return spacingS;
    return spacingM;
  }
  
  // Get icon size based on screen width
  static double getIconSize(BuildContext context, {double baseSize = 24.0}) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) return baseSize * 0.83; // ~20.0 for base of 24
    return baseSize;
  }

  // Get font size based on screen width
  static double getFontSize(BuildContext context, {double baseSize = 16.0}) {
    final width = MediaQuery.of(context).size.width;
    if (width < tabletBreakpoint) return baseSize * 0.875; // ~14.0 for base of 16
    return baseSize;
  }
}