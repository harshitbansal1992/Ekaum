// Nadi Dosh calculation service
// Logic adapted from https://github.com/dhaneshcodes/nadi-dosha-calculator

import '../models/nadi_dosh_result.dart';

class NadiDoshService {
  // Calculate Nadi Dosh based on birth details
  static Map<String, dynamic> calculateNadiDosh({
    required DateTime birthDate,
    required String birthTime,
    required String birthPlace,
  }) {
    // Extract birth time components
    final timeParts = birthTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

    // Calculate Nadi based on birth time
    // Nadi is divided into 3 types: Adi, Madhya, Antya
    // Each Nadi spans 2 hours 40 minutes (160 minutes)
    
    final totalMinutes = (hour * 60) + minute;
    final nadiNumber = (totalMinutes ~/ 160) % 3;
    
    String nadiType;
    switch (nadiNumber) {
      case 0:
        nadiType = 'Adi Nadi';
        break;
      case 1:
        nadiType = 'Madhya Nadi';
        break;
      case 2:
        nadiType = 'Antya Nadi';
        break;
      default:
        nadiType = 'Unknown';
    }

    // For couple matching, Nadi Dosh occurs when both have same Nadi
    // This is a simplified version - actual calculation involves more complex astrology
    
    return {
      'nadiType': nadiType,
      'nadiNumber': nadiNumber,
      'birthTime': birthTime,
      'birthDate': birthDate.toIso8601String(),
    };
  }

  // Check Nadi Dosh for couple matching
  static NadiDoshResult checkNadiDoshForCouple({
    required Map<String, dynamic> maleDetails,
    required Map<String, dynamic> femaleDetails,
  }) {
    final maleNadi = maleDetails['nadiNumber'] as int;
    final femaleNadi = femaleDetails['nadiNumber'] as int;

    final hasNadiDosh = maleNadi == femaleNadi;

    String description;
    if (hasNadiDosh) {
      description =
          'Nadi Dosh is present. Both partners have the same Nadi type. '
          'This may require remedies or consultation with an astrologer.';
    } else {
      description =
          'No Nadi Dosh. The Nadi types are compatible for marriage.';
    }

    return NadiDoshResult(
      hasNadiDosh: hasNadiDosh,
      nadiType: hasNadiDosh
          ? '${maleDetails['nadiType']} (Both)'
          : '${maleDetails['nadiType']} & ${femaleDetails['nadiType']}',
      description: description,
      details: {
        'maleNadi': maleDetails['nadiType'],
        'femaleNadi': femaleDetails['nadiType'],
        'maleNadiNumber': maleNadi,
        'femaleNadiNumber': femaleNadi,
      },
    );
  }
}

