import 'package:flutter/material.dart';

Future<T?> showDynamicIslandDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: builder(context),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Dynamic Island style transition
      // Scales down slightly from the very top center
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );

      return FractionalTranslation(
        translation: Offset(0.0, -1.0 + curve.value),
        child: Transform.scale(
          scale: 0.8 + (0.2 * curve.value),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        ),
      );
    },
  );
}
