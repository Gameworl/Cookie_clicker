import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cookie_cubit.dart';
import '../cubit/cookie_state.dart';

/// Écran des paramètres (Bloc version).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CookieCubit, CookieState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Paramètres'),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _PlayerNameField(
                        initialName: state.playerName,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import / Export',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _exportSave(context),
                              icon: const Icon(Icons.upload),
                              label: const Text('Exporter'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _importSave(context),
                              icon: const Icon(
                                Icons.download,
                              ),
                              label: const Text('Importer'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _resetGame(context),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Nouvelle partie'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _exportSave(BuildContext context) {
    final json = context.read<CookieCubit>().exportSave();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Exporter la sauvegarde'),
        content: SelectableText(
          json,
          style: const TextStyle(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: json));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copié dans le presse-papier'),
                ),
              );
            },
            child: const Text('Copier'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _importSave(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Importer une sauvegarde'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Colle le JSON ici...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              try {
                context
                    .read<CookieCubit>()
                    .importSave(controller.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sauvegarde importée !'),
                  ),
                );
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ JSON invalide'),
                  ),
                );
              }
            },
            child: const Text('Importer'),
          ),
        ],
      ),
    );
  }

  void _resetGame(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle partie ?'),
        content: const Text('Es-tu sûr ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              showDialog<void>(
                context: context,
                builder: (ctx2) => AlertDialog(
                  title: const Text('Dernière chance'),
                  content: const Text(
                    'Cette action est irréversible.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx2),
                      child: const Text('Annuler'),
                    ),
                    FilledButton(
                      onPressed: () {
                        context.read<CookieCubit>().reset();
                        Navigator.pop(ctx2);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }
}

class _PlayerNameField extends StatefulWidget {
  final String initialName;
  const _PlayerNameField({required this.initialName});

  @override
  State<_PlayerNameField> createState() =>
      _PlayerNameFieldState();
}

class _PlayerNameFieldState extends State<_PlayerNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialName,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        labelText: 'Pseudo',
        hintText: 'Min. 3 caractères',
        border: OutlineInputBorder(),
      ),
      onSubmitted: (value) {
        if (value.length >= 3) {
          context.read<CookieCubit>().setPlayerName(value);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pseudo : $value')),
          );
        }
      },
    );
  }
}
