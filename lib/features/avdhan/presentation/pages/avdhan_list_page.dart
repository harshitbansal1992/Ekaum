import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/payment_handler.dart';
import '../../data/models/avdhan_audio.dart';
import '../pages/avdhan_player_page.dart';
import '../providers/subscription_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/components/glass_card.dart';

class AvdhanListPage extends ConsumerStatefulWidget {
  const AvdhanListPage({super.key});

  @override
  ConsumerState<AvdhanListPage> createState() => _AvdhanListPageState();
}

class _AvdhanListPageState extends ConsumerState<AvdhanListPage> {
  List<AvdhanAudio> _audios = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAudios();
  }

  Future<void> _loadAudios() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService.getAvdhanList();
      final audios = data.map((item) {
        final json = item as Map<String, dynamic>;
        return AvdhanAudio.fromJson(json);
      }).toList();

      setState(() {
        _audios = audios;
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
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Avdhan'),
        actions: [
          subscriptionAsync.when(
            data: (hasSubscription) => hasSubscription
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () => _showSubscriptionDialog(context),
                    child: const Text(
                      'Subscribe',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
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
                        onPressed: _loadAudios,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _audios.isEmpty
                  ? const Center(child: Text('No audio files available', style: TextStyle(color: AppTheme.textDim)))
                  : RefreshIndicator(
                      onRefresh: _loadAudios,
                      child: ListView.builder(
                        itemCount: _audios.length,
                        itemBuilder: (context, index) {
                          final audio = _audios[index];
                          return GlassCard(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGold.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.headphones, color: AppTheme.primaryGold, size: 28),
                              ),
                              title: Text(
                                audio.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              ),
                              subtitle: Text(
                                audio.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppTheme.textDim),
                              ),
                              trailing: const Icon(Icons.play_circle_fill, color: AppTheme.primaryGold, size: 32),
                              onTap: () {
                                context.push(
                                  '/avdhan/${audio.id}',
                                  extra: audio,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscribe to Avdhan'),
        content: Text(
          'Subscribe for ₹${AppConstants.subscriptionPrice.toInt()} per month to access all Avdhan content.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              PaymentHandler.handleSubscriptionPayment(context, ref);
            },
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }
}
