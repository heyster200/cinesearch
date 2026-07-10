import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lists_provider.dart';
import '../widgets/media_card.dart';
import 'detail_screen.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListsProvider>().load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lists = context.watch<ListsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Listen'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.bookmark), text: 'Watchlist'),
            Tab(icon: Icon(Icons.favorite), text: 'Favoriten'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGrid(lists.watchlist, lists),
          _buildGrid(lists.favorites, lists),
        ],
      ),
    );
  }

  Widget _buildGrid(list, ListsProvider lists) {
    if (list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_filter, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('Noch nichts hier', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      itemCount: list.length,
      itemBuilder: (context, i) => MediaCard(
        item: list[i],
        width: double.infinity,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(item: list[i])),
        ),
      ),
    );
  }
}
