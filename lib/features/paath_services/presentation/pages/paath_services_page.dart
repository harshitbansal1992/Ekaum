import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/paath_service.dart';
import '../pages/paath_form_page.dart';

class PaathServicesPage extends StatelessWidget {
  const PaathServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final services = PaathService.getAvailableServices();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paath Services'),
      ),
      body: ListView.builder(
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
                  if (service.isFamilyService)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Family Service',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
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
    );
  }
}

