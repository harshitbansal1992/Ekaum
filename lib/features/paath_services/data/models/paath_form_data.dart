class PaathFormData {
  final String serviceId;
  final String serviceName;
  final double totalAmount;
  final int installments;
  final double installmentAmount;
  
  // Personal details
  final String name;
  final DateTime dateOfBirth;
  final String timeOfBirth;
  final String placeOfBirth;
  final String fathersOrHusbandsName;
  final String gotra;
  final String caste;
  
  // Family members (for family services)
  final List<FamilyMember>? familyMembers;

  PaathFormData({
    required this.serviceId,
    required this.serviceName,
    required this.totalAmount,
    required this.installments,
    required this.installmentAmount,
    required this.name,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.placeOfBirth,
    required this.fathersOrHusbandsName,
    required this.gotra,
    required this.caste,
    this.familyMembers,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'totalAmount': totalAmount,
      'installments': installments,
      'installmentAmount': installmentAmount,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'timeOfBirth': timeOfBirth,
      'placeOfBirth': placeOfBirth,
      'fathersOrHusbandsName': fathersOrHusbandsName,
      'gotra': gotra,
      'caste': caste,
      'familyMembers': familyMembers?.map((m) => m.toJson()).toList(),
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}

class FamilyMember {
  final String name;
  final DateTime dateOfBirth;
  final String timeOfBirth;
  final String placeOfBirth;
  final String relationship;

  FamilyMember({
    required this.name,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.placeOfBirth,
    required this.relationship,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'timeOfBirth': timeOfBirth,
      'placeOfBirth': placeOfBirth,
      'relationship': relationship,
    };
  }
}

