import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cookie_model.dart';
import '../models/score.dart';
import '../services/score_repository.dart';

/// État de chargement du classement.
enum LoadingState { initial, loading, loaded, error }

/// Écran de classement complet.
///
/// Gère le chargement, le cache local, le pull-to-refresh,
/// l'auto-refresh via [Stream.periodic], le retry avec
/// backoff exponentiel et le mode offline.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() =>
      _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  LoadingState _state = LoadingState.initial;
  List<Score> _scores = [];
  String _errorMessage = '';
  DateTime? _lastFetched;
  StreamSubscription<void>? _autoRefreshSub;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadCache().then((_) => _fetchScores());
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshSub?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _autoRefreshSub = Stream.periodic(
      const Duration(seconds: 60),
    ).listen((_) {
      if (mounted) _fetchScores(silent: true);
    });
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('leaderboard_cache');
    final cachedAt = prefs.getString('leaderboard_cached_at');
    if (cached != null) {
      final list = (jsonDecode(cached) as List<dynamic>)
          .map((e) => Score.fromJson(e as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(() {
          _scores = list;
          _state = LoadingState.loaded;
          if (cachedAt != null) {
            _lastFetched = DateTime.tryParse(cachedAt);
          }
        });
      }
    }
  }

  Future<void> _saveCache(List<Score> scores) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'leaderboard_cache',
      jsonEncode(scores.map((s) => s.toJson()).toList()),
    );
    await prefs.setString(
      'leaderboard_cached_at',
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> _fetchScores({bool silent = false}) async {
    if (!silent) {
      setState(() => _state = LoadingState.loading);
    }
    try {
      final repo = context.read<ScoreRepository>();
      final scores = await repo.fetchLeaderboard();
      if (mounted) {
        setState(() {
          _scores = scores;
          _state = LoadingState.loaded;
          _isOffline = false;
          _lastFetched = DateTime.now();
        });
        _saveCache(scores);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOffline = true;
          if (_scores.isEmpty) {
            _state = LoadingState.error;
            _errorMessage = e.toString();
          }
        });
      }
    }
  }

  Future<void> _submitScore() async {
    if (_isOffline) return;

    final model = context.read<CookieModel>();
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: model.playerName,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Envoyer ton score'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Pseudo',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.length < 3) {
                return 'Min. 3 caractères';
              }
              if (v.length > 20) return 'Max. 20 caractères';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final score = Score(
      name: nameController.text,
      cookies: model.cookies,
    );

    await _submitWithRetry(score);
  }

  Future<void> _submitWithRetry(Score score) async {
    final repo = context.read<ScoreRepository>();
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        await repo.submitScore(score);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Score envoyé !'),
            ),
          );
          _fetchScores();
        }
        return;
      } catch (_) {
        if (attempt < 3) {
          final delay = Duration(seconds: 1 << (attempt - 1));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Tentative $attempt/3 échouée, '
                  'réessai dans ${delay.inSeconds}s...',
                ),
              ),
            );
          }
          await Future<void>.delayed(delay);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Envoi échoué après 3 tentatives'),
              ),
            );
          }
        }
      }
    }
  }

  Widget _buildMedal(int rank) {
    switch (rank) {
      case 0:
        return const CircleAvatar(
          backgroundColor: Colors.amber,
          child: Text('🥇'),
        );
      case 1:
        return const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Text('🥈'),
        );
      case 2:
        return CircleAvatar(
          backgroundColor: Colors.brown.shade300,
          child: const Text('🥉'),
        );
      default:
        return CircleAvatar(child: Text('${rank + 1}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classement'),
        centerTitle: true,
        actions: [
          if (!_isOffline)
            IconButton(
              icon: const Icon(Icons.send),
              tooltip: 'Envoyer le score',
              onPressed: _submitScore,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isOffline)
            Container(
              width: double.infinity,
              color: Colors.orange.shade100,
              padding: const EdgeInsets.all(8),
              child: const Text(
                '📡 Mode hors ligne — données en cache',
                textAlign: TextAlign.center,
              ),
            ),
          if (_lastFetched != null && _isOffline)
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Dernière mise à jour : ${_timeAgo(_lastFetched!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case LoadingState.initial:
      case LoadingState.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadingState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(_errorMessage),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _fetchScores,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        );
      case LoadingState.loaded:
        return RefreshIndicator(
          onRefresh: _fetchScores,
          child: ListView.builder(
            itemCount: _scores.length,
            itemBuilder: (context, index) {
              final score = _scores[index];
              return ListTile(
                leading: _buildMedal(index),
                title: Text(score.name),
                trailing: Text(
                  '${score.cookies} 🍪',
                  style:
                      Theme.of(context).textTheme.titleMedium,
                ),
              );
            },
          ),
        );
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) {
      return 'il y a ${diff.inMinutes} min';
    }
    return 'il y a ${diff.inHours}h';
  }
}
