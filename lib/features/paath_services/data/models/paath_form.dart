/// User's submitted paath form (list or detail view)
class PaathForm {
  final String id;
  final String serviceName;
  final double totalAmount;
  final int installments;
  final double installmentAmount;
  final String name;
  final String paymentStatus; // pending, partial, completed
  final String paathStatus; // pending, done
  final String? paathDoneDate;
  final String? createdAt;
  final List<PaathInstallment>? installmentDetails;
  final List<PaathPaymentRecord>? paymentHistory;
  final List<PaathFamilyMember>? familyMembers;

  PaathForm({
    required this.id,
    required this.serviceName,
    required this.totalAmount,
    required this.installments,
    required this.installmentAmount,
    required this.name,
    required this.paymentStatus,
    required this.paathStatus,
    this.paathDoneDate,
    this.createdAt,
    this.installmentDetails,
    this.paymentHistory,
    this.familyMembers,
  });

  factory PaathForm.fromJson(Map<String, dynamic> json) {
    final instList = json['installmentDetails'] as List<dynamic>?;
    final paymentList = json['paymentHistory'] as List<dynamic>?;
    final fmList = json['familyMembers'] as List<dynamic>?;
    return PaathForm(
      id: json['id'] as String,
      serviceName: json['serviceName'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      installments: (json['installments'] as num?)?.toInt() ?? 1,
      installmentAmount: (json['installmentAmount'] as num?)?.toDouble() ?? 0,
      name: json['name'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      paathStatus: json['paathStatus'] as String? ?? 'pending',
      paathDoneDate: json['paathDoneDate'] as String?,
      createdAt: json['createdAt'] as String?,
      installmentDetails: instList
          ?.map((e) => PaathInstallment.fromJson(e as Map<String, dynamic>))
          .toList(),
        paymentHistory: paymentList
          ?.map((e) => PaathPaymentRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      familyMembers: fmList
          ?.map((e) => PaathFamilyMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String get paymentStatusLabel {
    switch (paymentStatus) {
      case 'completed':
        return 'Completed';
      case 'partial':
        return 'Partial';
      default:
        return 'Pending';
    }
  }

  String get paathStatusLabel {
    return paathStatus == 'done' ? 'Done' : 'Pending';
  }
}

class PaathInstallment {
  final int installmentNumber;
  final double? amount;
  final String status;
  final String? paymentId;
  final String? paymentDate;

  PaathInstallment({
    required this.installmentNumber,
    this.amount,
    required this.status,
    this.paymentId,
    this.paymentDate,
  });

  factory PaathInstallment.fromJson(Map<String, dynamic> json) {
    return PaathInstallment(
      installmentNumber: (json['installmentNumber'] as num).toInt(),
      amount: (json['amount'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'pending',
      paymentId: json['paymentId'] as String?,
      paymentDate: json['paymentDate'] as String?,
    );
  }

  bool get isPaid => status == 'completed';
}

class PaathPaymentRecord {
  final String paymentId;
  final double amount;
  final String status;
  final int? installmentNumber;
  final bool payRemainingInFull;
  final String? completedAt;
  final String? createdAt;

  PaathPaymentRecord({
    required this.paymentId,
    required this.amount,
    required this.status,
    this.installmentNumber,
    required this.payRemainingInFull,
    this.completedAt,
    this.createdAt,
  });

  factory PaathPaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaathPaymentRecord(
      paymentId: json['paymentId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'completed',
      installmentNumber: (json['installmentNumber'] as num?)?.toInt(),
      payRemainingInFull: json['payRemainingInFull'] as bool? ?? false,
      completedAt: json['completedAt'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  bool get isCompleted => status == 'completed';
}

class PaathFamilyMember {
  final String? id;
  final String name;
  final String? dateOfBirth;
  final String? timeOfBirth;
  final String? placeOfBirth;
  final String? relationship;

  PaathFamilyMember({
    this.id,
    required this.name,
    this.dateOfBirth,
    this.timeOfBirth,
    this.placeOfBirth,
    this.relationship,
  });

  factory PaathFamilyMember.fromJson(Map<String, dynamic> json) {
    return PaathFamilyMember(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String?,
      timeOfBirth: json['timeOfBirth'] as String?,
      placeOfBirth: json['placeOfBirth'] as String?,
      relationship: json['relationship'] as String?,
    );
  }
}
