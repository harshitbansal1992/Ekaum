import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_service.dart';
import '../../data/models/mantra_note.dart';

final mantraNotesProvider = FutureProvider<List<MantraNote>>((ref) async {
  final data = await ApiService.getMantraNotes();
  return data
      .map((item) => MantraNote.fromJson(item as Map<String, dynamic>))
      .toList();
});
