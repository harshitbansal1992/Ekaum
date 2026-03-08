import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/patrika_issue.dart';
import '../pages/patrika_viewer_page.dart';

class PatrikaListPage extends StatefulWidget {
  const PatrikaListPage({super.key});

  @override
  State<PatrikaListPage> createState() => _PatrikaListPageState();
}

class _PatrikaListPageState extends State<PatrikaListPage> {
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
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${issue.price.toInt()}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const Text(
                                  'Read',
                                  style: TextStyle(fontSize: 12),
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

