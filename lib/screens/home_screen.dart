import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/section_row.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header + Zoekbalk
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Entdecken',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey.shade500),
                            const SizedBox(width: 8),
                            Text(
                              'Filme, Serien, Personen...',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (provider.state == LoadState.loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.state == LoadState.error)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(provider.errorMessage ?? 'Fehler',
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<HomeProvider>().load(),
                        child: const Text('Erneut versuchen'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: SectionRow(title: '🔥 Trending', items: provider.trending),
              ),
              SliverToBoxAdapter(
                child: SectionRow(title: '🎬 Beliebte Filme', items: provider.popularMovies),
              ),
              SliverToBoxAdapter(
                child: SectionRow(title: '📺 Beliebte Serien', items: provider.popularTv),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ],
        ),
      ),
    );
  }
}
