import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cookie_model.dart';

/// Affiche le compteur de cookies avec animation de transition.
///
/// Change de couleur selon le palier atteint.
/// Utilise [AnimatedSwitcher] pour animer la transition.
class CookieCounter extends StatelessWidget {
  const CookieCounter({super.key});

  Color _counterColor(BuildContext context, int cookies) {
    if (cookies >= 10000) return Colors.purple;
    if (cookies >= 5000) return Colors.red;
    if (cookies >= 1000) return Colors.orange;
    if (cookies >= 500) return Colors.blue;
    if (cookies >= 100) return Colors.green;
    return Theme.of(context).colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CookieModel>();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        model.formattedCookies,
        key: ValueKey<int>(model.cookies),
        style: Theme.of(context)
            .textTheme
            .displayLarge
            ?.copyWith(
              color: _counterColor(context, model.cookies),
            ),
      ),
    );
  }
}
