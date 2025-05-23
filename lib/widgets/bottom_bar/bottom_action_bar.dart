// widgets/bottom_bar/bottom_action_bar.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';

/// Bottom action bar with Settings, Explore, and Profile buttons
class BottomActionBar extends StatelessWidget {
  final VoidCallback onSettingsPressed;
  final VoidCallback onExplorePressed;
  final VoidCallback onProfilePressed;
  final bool isCompact;

  const BottomActionBar({
    super.key,
    required this.onSettingsPressed,
    required this.onExplorePressed,
    required this.onProfilePressed,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate sizes based on compact mode
    final buttonSize = isCompact 
        ? AppLayout.compactCircleButtonSize 
        : AppLayout.circleButtonSize;
    final sidebarWidth = AppLayout.getSidebarWidth(context, isCompact: isCompact);
    final sidePadding = isCompact 
        ? AppLayout.spacingS * 0.5 
        : AppLayout.spacingS;
    final actionBarHeight = isCompact 
        ? AppLayout.compactActionBarHeight 
        : AppLayout.actionBarHeight;
    final iconSize = AppLayout.getIconSize(context, baseSize: 26.0);
    final borderWidth = isCompact ? 1.5 : 2.0;
    final fontSize = AppLayout.getFontSize(context, 
        baseSize: isCompact ? 15.0 : 16.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.all(isCompact ? AppLayout.spacingS * 0.7 : AppLayout.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Settings button
          _buildCircleButton(
            context: context,
            icon: Icons.settings,
            onTap: onSettingsPressed,
            tooltip: 'Settings',
            buttonSize: buttonSize,
            sidebarWidth: sidebarWidth,
            sidePadding: sidePadding,
            iconSize: iconSize,
            borderWidth: borderWidth,
          ),

          // Explore button
          Expanded(
            child: Semantics(
              label: 'Explore notes',
              button: true,
              child: Container(
                height: actionBarHeight,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
                  child: InkWell(
                    onTap: onExplorePressed,
                    borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
                    splashColor: Colors.white.withOpacity(0.4),
                    highlightColor: Colors.white.withOpacity(0.2),
                    child: Center(
                      child: Text(
                        'Explore',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Profile button
          _buildCircleButton(
            context: context,
            icon: Icons.person,
            onTap: onProfilePressed,
            tooltip: 'Profile',
            buttonSize: buttonSize,
            sidebarWidth: sidebarWidth,
            sidePadding: sidePadding,
            iconSize: iconSize,
            borderWidth: borderWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    required double buttonSize,
    required double sidebarWidth,
    required double sidePadding,
    required double iconSize,
    required double borderWidth,
  }) {
    final theme = Theme.of(context);
    final backgroundColor = theme.brightness == Brightness.light 
        ? Colors.white 
        : const Color(0xFF2A2A2A);
    
    return Semantics(
      label: tooltip,
      button: true,
      child: Container(
        width: sidebarWidth,
        margin: EdgeInsets.symmetric(horizontal: sidePadding),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.primary,
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: backgroundColor,
          shape: const CircleBorder(),
          elevation: 0,
          child: Tooltip(
            message: tooltip,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              splashColor: theme.colorScheme.primary.withOpacity(0.2),
              highlightColor: theme.colorScheme.primary.withOpacity(0.1),
              child: SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: Center(
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: iconSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}