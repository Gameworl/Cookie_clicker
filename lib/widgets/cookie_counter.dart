import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubit/cookie_cubit.dart';
import '../cubit/cookie_state.dart';

/// Affiche le compteur avec animation et couleur par palier.
class CookieCounter extends StatelessWidget {
  const CookieCounter({super.key});

  static final _numberFormat = NumberFormat('#,###', 'fr_FR');

  Color _counterColor(BuildContext context, int cookies) {
    if (cookies >= 10000) return Colors.purple;
    if (cookies >= 5000) return Colors.red;
    if (cookies >= 1000) return Colors.orange;
    if (cookies >= 500) return Colors.blue;
    if (cookies >= 100) return Colors.green;
    return Theme.of(context).colorScheme.onSurface;
  }

  String _format(int cookies) {
    final formatted =
        cookies == 0 ? '0' : _numberFormat.format(cookies);
    return cookies == 1
        ? '$formatted cookie'
        : '$formatted cookies';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CookieCubit, CookieState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _format(state.cookies),
            key: ValueKey<int>(state.cookies),
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(
                  color: _counterColor(
                    context,
                    state.cookies,
                  ),
                ),
          ),
        );
      },
    );
  }
}
