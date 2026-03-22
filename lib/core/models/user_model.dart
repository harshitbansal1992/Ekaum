class AppUser {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? timeOfBirth;
  final String? placeOfBirth;
  final String? fathersOrHusbandsName;
  final String? gotra;
  final String? caste;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.dateOfBirth,
    this.timeOfBirth,
    this.placeOfBirth,
    this.fathersOrHusbandsName,
    this.gotra,
    this.caste,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      timeOfBirth: json['time_of_birth'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      fathersOrHusbandsName: json['fathers_or_husbands_name'] as String?,
      gotra: json['gotra'] as String?,
      caste: json['caste'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Whether the user has enough profile data to prepopulate a paath form.
  bool get canPrepopulatePaathForm =>
      (name != null && name!.isNotEmpty) &&
      dateOfBirth != null &&
      (timeOfBirth != null && timeOfBirth!.isNotEmpty) &&
      (placeOfBirth != null && placeOfBirth!.isNotEmpty) &&
      (fathersOrHusbandsName != null && fathersOrHusbandsName!.isNotEmpty) &&
      (gotra != null && gotra!.isNotEmpty) &&
      (caste != null && caste!.isNotEmpty);
}


