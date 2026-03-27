import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_service.dart';
import '../../data/models/paath_service.dart';

final paathServicesProvider = FutureProvider<List<PaathService>>((ref) async {
  final data = await ApiService.getPaathServices();
  return data
      .map((e) => PaathService.fromJson(e as Map<String, dynamic>))
      .toList();
});
