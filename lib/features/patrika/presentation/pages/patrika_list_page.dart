import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
  Set<String> _purchasedIssueIds = <String>{};
  bool _isLoading = true;
  String? _error;

  static const Map<String, int> _monthToNumber = {
    'jan': 1,
    'january': 1,
    'feb': 2,
    'february': 2,
    'mar': 3,
    'march': 3,
    'apr': 4,
    'april': 4,
    'may': 5,
    'jun': 6,
    'june': 6,
    'jul': 7,
    'july': 7,
    'aug': 8,
    'august': 8,
    'sep': 9,
    'sept': 9,
    'september': 9,
    'oct': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'dec': 12,
    'december': 12,
  };

  int _monthNumber(PatrikaIssue issue) {
    final normalized = issue.month.trim().toLowerCase();
    final fromMap = _monthToNumber[normalized];
    if (fromMap != null) {
      return fromMap;
    }

    final asInt = int.tryParse(normalized);
    if (asInt != null && asInt >= 1 && asInt <= 12) {
      return asInt;
    }

    return issue.publishedDate.month;
  }

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

      issues.sort((a, b) {
        final yearCompare = b.year.compareTo(a.year);
        if (yearCompare != 0) {
          return yearCompare;
        }

        final monthCompare = _monthNumber(b).compareTo(_monthNumber(a));
        if (monthCompare != 0) {
          return monthCompare;
        }

        return b.publishedDate.compareTo(a.publishedDate);
      });

      final userId = ref.read(authProvider).user?.id;
      Set<String> purchasedIds = <String>{};
      if (userId != null) {
        final purchases = await ApiService.getPatrikaPurchases(userId);
        purchasedIds = purchases.map((e) => e.toString()).toSet();
      }

      setState(() {
        _issues = issues;
        _purchasedIssueIds = purchasedIds;
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
                        final isPurchased = _purchasedIssueIds.contains(issue.id);
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: isPurchased ? const Color(0xFFEAFBF1) : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isPurchased
                                  ? const Color(0xFF8ED8A8)
                                  : Colors.transparent,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.menu_book,
                              size: 40,
                              color: isPurchased ? const Color(0xFF1E8E3E) : null,
                            ),
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
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isPurchased
                                            ? const Color(0xFFD5F5E3)
                                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isPurchased ? 'Purchased' : 'Not purchased',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isPurchased ? const Color(0xFF1E8E3E) : AppTheme.textDim,
                                        ),
                                      ),
                                    ),
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

