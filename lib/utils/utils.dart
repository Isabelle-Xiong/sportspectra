import 'package:flutter/material.dart';

// The SnackBar widget: message briefly appears at the bottom of the screen to provide users with feedback on action
void showSnackBar(BuildContext context, String content) {
  // locates the nearest Scaffold widget in the widget tree and shows the SnackBar within it.
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(content)),
  );
}
