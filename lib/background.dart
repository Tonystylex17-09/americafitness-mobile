import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF330000), // rojo oscuro
            Color(0xFF550000), // rojo medio
            Color(0xFF770000), // rojo más claro
          ],
        ),
      ),
      child: child,
    );
  }
}
