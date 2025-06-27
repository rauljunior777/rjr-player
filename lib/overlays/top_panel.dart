import 'package:flutter/material.dart';

Widget buildTopOverlay({
  required bool isVisible,
  required bool isRotated,
  required VoidCallback onRotate,
  required VoidCallback onOpenWindow,
  required double height,
}) {
  return Positioned(
    top: 0,
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
              color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      isRotated
                          ? Icons.screen_lock_rotation
                          : Icons.screen_rotation,
                    ),
                    color: Colors.white,
                    onPressed: onRotate,
                  ),
                  IconButton(
                    icon: Icon(Icons.open_in_new),
                    color: Colors.white,
                    onPressed: onOpenWindow,
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey(false)),
    ),
  );
}
