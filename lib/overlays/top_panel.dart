import 'package:flutter/material.dart';

Widget buildTopOverlay({
  required bool isVisible,
  required bool isRotated,
  required VoidCallback onRotate,
  required VoidCallback onOpenWindow,
  required VoidCallback onPrevious,
  required VoidCallback onNext,
  required double height,
  required String title,
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
              color: Colors.black.withAlpha(128),
              padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous),
                    tooltip: 'Anterior',
                    onPressed: onPrevious,
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: Icon(
                      isRotated
                          ? Icons.screen_lock_rotation
                          : Icons.screen_rotation,
                    ),
                    color: Colors.white,
                    onPressed: onRotate,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.open_in_new),
                    color: Colors.white,
                    onPressed: onOpenWindow,
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next),
                    tooltip: 'Siguiente',
                    onPressed: onNext,
                    color: Colors.white,
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey(false)),
    ),
  );
}
