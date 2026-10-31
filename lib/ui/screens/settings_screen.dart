import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../../domain/settings/settings.dart';
import '../../platform/versioning/version.dart';
import '../widgets/widgets.dart';

/// S9. An empty box keeps the current value — it never means zero
/// (docs/01-platform/storage/lld.md §4).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _headsUp = TextEditingController();
  final _buffer = TextEditingController();
  final _pause = TextEditingController();
  final _cooldown = TextEditingController();
  final _phrase = TextEditingController();
  AppSettings? _current;
  Map<String, String> _errors = const {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_current != null) return;
    AppScope.of(context).settings.get().then((s) {
      if (!mounted) return;
      setState(() {
        _current = s;
        _headsUp.text = '${s.headsUpMinutes}';
        _buffer.text = '${s.hardBufferMinutes}';
        _pause.text = '${s.pauseMinutes}';
        _cooldown.text = '${s.pauseCooldownSeconds}';
        _phrase.text = s.pausePhrase;
      });
    });
  }

  @override
  void dispose() {
    for (final c in [_headsUp, _buffer, _pause, _cooldown, _phrase]) {
      c.dispose();
    }
    super.dispose();
  }

  int? _int(TextEditingController c) => int.tryParse(c.text.trim());

  Future<void> _save() async {
    final cur = _current;
    if (cur == null) return;
    final next = cur.copyWith(
      headsUpMinutes: _int(_headsUp),
      hardBufferMinutes: _int(_buffer),
      pauseMinutes: _int(_pause),
      pauseCooldownSeconds: _int(_cooldown),
      pausePhrase: _phrase.text.trim().isEmpty ? null : _phrase.text.trim(),
    );
    final errors = validateSettings(next);
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;
    await AppScope.of(context).settings.update(next);
    if (mounted) say(context, 'Saved');
  }

  Widget _number(TextEditingController c, String label, String suffix, String key, {String? helper}) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            suffixText: suffix,
            helperText: helper,
            errorText: _errors[key],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(onPressed: _current == null ? null : _save, child: const Text('Save')),
          ),
        ),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          _number(_headsUp, 'Heads-up before a habit', 'min', 'headsUp', helper: '0 turns it off'),
          _number(_buffer, 'Buffer before hard habits', 'min', 'buffer',
              helper: 'Soft habits may not run into this time'),
          _number(_pause, 'Pause length', 'min', 'pauseMinutes'),
          _number(_cooldown, 'Wait before pausing', 's', 'cooldown', helper: 'Doubled for hard habits'),
          TextField(
            controller: _phrase,
            maxLength: 80,
            decoration: InputDecoration(labelText: 'Pause sentence', errorText: _errors['phrase']),
          ),
          const SizedBox(height: 8),
          ListTile(contentPadding: EdgeInsets.zero, title: Text('Habit Force $kAppVersion ($kAppBuild)')),
        ]),
      );
}
