import 'package:flutter/material.dart';

/// Bouton cookie réutilisable avec effet ripple et ombre.
///
/// Reçoit un callback [onTap] déclenché au clic.
/// La taille s'adapte selon l'espace disponible
/// via [LayoutBuilder].
class CookieButton extends StatelessWidget {
  /// Callback déclenché au clic sur le cookie.
  final VoidCallback onTap;

  const CookieButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size =
            constraints.maxWidth < 400 ? 100.0 : 140.0;
        return Tooltip(
          message: 'Clique pour gagner un cookie',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(size),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withAlpha(60),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '🍪',
                    style: TextStyle(fontSize: size * 0.8),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
