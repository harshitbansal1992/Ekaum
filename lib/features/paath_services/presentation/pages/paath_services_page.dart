import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/paath_services_provider.dart';

class PaathServicesPage extends ConsumerWidget {
  const PaathServicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(paathServicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paath Services'),
      ),
      body: servicesAsync.when(
        data: (services) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                service.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(service.description),
                  const SizedBox(height: 8),
                  Text(
                    'Price: ₹${service.price.toInt()}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Row(
                    children: [
                      if (service.isFamilyService)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Family Service',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: service.isOneTime ? Colors.green.shade50 : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          service.isOneTime ? 'One-time payment' : '${service.installments} installments',
                          style: TextStyle(
                            fontSize: 12,
                            color: service.isOneTime ? Colors.green.shade700 : Colors.amber.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                context.push(
                  '/paath-form',
                  extra: service,
                );
              },
            ),
          );
        },
      ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load paath services',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

