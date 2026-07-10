import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const SettingsScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _apiKeyCtrl.text = prefs.getString('tmdb_api_key') ?? '');
  }

  Future<void> _saveApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tmdb_api_key', _apiKeyCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API-Key gespeichert')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Dark mode
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Dunkles Design'),
            value: widget.isDark,
            onChanged: (_) => widget.onToggleTheme(),
          ),
          const Divider(),

          // API Key
          const ListTile(
            title: Text('TMDb API Key'),
            subtitle: Text(
              'Kostenlos registrieren auf themoviedb.org → Einstellungen → API',
              style: TextStyle(fontSize: 12),
            ),
          ),
          TextField(
            controller: _apiKeyCtrl,
            decoration: InputDecoration(
              hintText: 'API Key eingeben',
              filled: true,
              fillColor: Colors.grey.shade900,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveApiKey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ohne API Key funktioniert die App nicht. Der Key ist gratis.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const Divider(height: 32),

          // Info
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Über die App'),
            subtitle: const Text('Lightweight IMDb Alternative · TMDb API'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    super.dispose();
  }
}
