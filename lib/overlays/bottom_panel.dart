import 'package:flutter/material.dart';

Widget buildBottomOverlay({
  required bool isVisible,
  required Widget progressBar,
  required Widget controls,
  required double height,
}) {
  return Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: AnimatedSwitcher(
      duration: Duration(milliseconds: 400),
      transitionBuilder: (child, anim) =>
          SizeTransition(sizeFactor: anim, axis: Axis.vertical, child: child),
      child: isVisible
          ? Container(
              key: ValueKey(true),
              height: height,
              color: Colors.black.withAlpha(128),
              padding: const EdgeInsets.only(top: 4.0, bottom: 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: progressBar,
                  ),
                  const SizedBox(height: 12),
                  controls,
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey(false)),
    ),
  );
}
