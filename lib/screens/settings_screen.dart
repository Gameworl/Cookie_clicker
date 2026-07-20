import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/cookie_model.dart';
import '../models/game_save.dart';

/// Écran des paramètres du jeu.
///
/// Permet de gérer le profil, les slots de sauvegarde,
/// l'import/export et la réinitialisation.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CookieModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profil joueur
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profil',
                    style:
                        Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _PlayerNameField(
                    initialName: model.playerName,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Slots de sauvegarde
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sauvegardes',
                    style:
                        Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < 3; i++)
                    _SlotTile(slot: i),
                  if (model.lastSavedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Dernière sauvegarde : '
                        '${_timeAgo(model.lastSavedAt!)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Import / Export
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Import / Export',
                    style:
                        Theme.of(context).textTheme.titleMedium,
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
                          icon: const Icon(Icons.download),
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
          // Nouvelle partie
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
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) {
      return 'il y a ${diff.inMinutes} min';
    }
    return 'il y a ${diff.inHours}h';
  }

  void _exportSave(BuildContext context) {
    final json = context.read<CookieModel>().exportSave();
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
                    .read<CookieModel>()
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
              // Double confirmation
              showDialog<void>(
                context: context,
                builder: (ctx2) => AlertDialog(
                  title: const Text('Dernière chance'),
                  content: const Text(
                    'Cette action est irréversible. '
                    'Tous tes cookies seront perdus.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx2),
                      child: const Text('Annuler'),
                    ),
                    FilledButton(
                      onPressed: () {
                        context.read<CookieModel>().reset();
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
          context.read<CookieModel>().setPlayerName(value);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pseudo : $value')),
          );
        }
      },
    );
  }
}

class _SlotTile extends StatelessWidget {
  final int slot;

  const _SlotTile({required this.slot});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CookieModel>();
    final isActive = model.currentSlot == slot;

    return FutureBuilder<GameSave?>(
      future: model.getSlotInfo(slot),
      builder: (context, snapshot) {
        final save = snapshot.data;
        final label = save != null
            ? '${save.playerName} - ${save.cookies} 🍪'
            : 'Vide';

        return ListTile(
          leading: Icon(
            isActive ? Icons.radio_button_on : Icons.radio_button_off,
          ),
          title: Text('Slot ${slot + 1}'),
          subtitle: Text(label),
          trailing: save != null
              ? IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => model.deleteSlot(slot),
                )
              : null,
          onTap: () => model.switchSlot(slot),
        );
      },
    );
  }
}
