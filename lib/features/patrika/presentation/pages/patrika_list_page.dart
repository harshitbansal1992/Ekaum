import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/data/models/favourite_item.dart';
import '../../../home/presentation/providers/favourites_provider.dart';
import '../../data/models/patrika_issue.dart';

class PatrikaListPage extends ConsumerStatefulWidget {
  const PatrikaListPage({super.key});

  @override
  ConsumerState<PatrikaListPage> createState() => _PatrikaListPageState();
}

class _PatrikaListPageState extends ConsumerState<PatrikaListPage> {
  List<PatrikaIssue> _issues = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  Future<void> _loadIssues() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService.getPatrikaList();
      final issues = data.map((item) {
        final json = item as Map<String, dynamic>;
        return PatrikaIssue.fromJson(json);
      }).toList();

      setState(() {
        _issues = issues;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prabhu Kripa Patrika'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadIssues,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _issues.isEmpty
                  ? const Center(child: Text('No issues available'))
                  : ListView.builder(
                      itemCount: _issues.length,
                      itemBuilder: (context, index) {
                        final issue = _issues[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.menu_book, size: 40),
                            title: Text(issue.title),
                            subtitle: Text('${issue.month} ${issue.year}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Consumer(
                                  builder: (_, ref, __) {
                                    final isFav = ref.watch(favouritesProvider).any((f) => f.type == 'patrika' && f.id == issue.id);
                                    return IconButton(
                                      icon: Icon(
                                        isFav ? Icons.favorite : Icons.favorite_border,
                                        color: isFav ? Colors.red : AppTheme.textDim,
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        final item = FavouriteItem(
                                          type: 'patrika',
                                          id: issue.id,
                                          title: issue.title,
                                          subtitle: '${issue.month} ${issue.year}',
                                          extra: issue.toJson(),
                                        );
                                        ref.read(favouritesProvider.notifier).toggle(item);
                                      },
                                    );
                                  },
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${issue.price.toInt()}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const Text('Read', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () {
                              context.push(
                                '/patrika/${issue.id}',
                                extra: issue,
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}

