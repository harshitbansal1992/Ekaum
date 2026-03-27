import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/rahu_sandhya_notification_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _tobController;
  late TextEditingController _pobController;
  late TextEditingController _fathersNameController;
  late TextEditingController _gotraController;
  late TextEditingController _casteController;

  DateTime? _dateOfBirth;
  bool _isLoading = false;
  bool _notifyRahuKaal = false;
  bool _notifySandhyaKaal = false;
  bool _notificationPrefsLoading = true;
  List<dynamic> _recurringDonations = [];
  bool _recurringDonationsLoading = true;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _dobController = TextEditingController(
      text: user?.dateOfBirth != null
          ? DateFormat('yyyy-MM-dd').format(user!.dateOfBirth!)
          : '',
    );
    _tobController = TextEditingController(text: user?.timeOfBirth ?? '');
    _pobController = TextEditingController(text: user?.placeOfBirth ?? '');
    _fathersNameController =
        TextEditingController(text: user?.fathersOrHusbandsName ?? '');
    _gotraController = TextEditingController(text: user?.gotra ?? '');
    _casteController = TextEditingController(text: user?.caste ?? '');
    _dateOfBirth = user?.dateOfBirth;
    _loadNotificationPrefs();
    _loadRecurringDonations();
  }

  Future<void> _loadRecurringDonations() async {
    try {
      final subs = await ApiService.getDonationSubscriptions();
      if (mounted) {
        setState(() {
          _recurringDonations = subs;
          _recurringDonationsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _recurringDonationsLoading = false);
      }
    }
  }

  Future<void> _cancelSubscription(String id) async {
    try {
      await ApiService.cancelDonationSubscription(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.recurringDonationCancelled)),
        );
        _loadRecurringDonations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.failedToUpdate} ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _loadNotificationPrefs() async {
    final rahu = await RahuSandhyaNotificationService.getNotifyRahuKaal();
    final sandhya = await RahuSandhyaNotificationService.getNotifySandhyaKaal();
    if (mounted) {
      setState(() {
        _notifyRahuKaal = rahu;
        _notifySandhyaKaal = sandhya;
        _notificationPrefsLoading = false;
      });
    }
  }

  Future<void> _setNotifyRahuKaal(bool value) async {
    setState(() => _notifyRahuKaal = value);
    await RahuSandhyaNotificationService.instance.setNotifyRahuKaal(value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? AppLocalizations.of(context)!.rahuKaalNotificationsEnabled
                : AppLocalizations.of(context)!.rahuKaalNotificationsDisabled,
          ),
        ),
      );
    }
  }

  Future<void> _setNotifySandhyaKaal(bool value) async {
    setState(() => _notifySandhyaKaal = value);
    await RahuSandhyaNotificationService.instance.setNotifySandhyaKaal(value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? AppLocalizations.of(context)!.sandhyaKaalNotificationsEnabled
                : AppLocalizations.of(context)!.sandhyaKaalNotificationsDisabled,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _tobController.dispose();
    _pobController.dispose();
    _fathersNameController.dispose();
    _gotraController.dispose();
    _casteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            dateOfBirth: _dateOfBirth,
            timeOfBirth: _tobController.text.trim().isEmpty
                ? null
                : _tobController.text.trim(),
            placeOfBirth: _pobController.text.trim().isEmpty
                ? null
                : _pobController.text.trim(),
            fathersOrHusbandsName: _fathersNameController.text.trim().isEmpty
                ? null
                : _fathersNameController.text.trim(),
            gotra: _gotraController.text.trim().isEmpty
                ? null
                : _gotraController.text.trim(),
            caste: _casteController.text.trim().isEmpty
                ? null
                : _casteController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdatedSuccess)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.failedToUpdate}: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.nameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: user?.email ?? '',
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.email),
                  ),
                  enabled: false,
                  readOnly: true,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.emailCannotChange,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textDim,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumber,
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        value.length != 10) {
                      return l10n.validPhoneNumber;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.detailsForPaathForms,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.saveToPrepopulate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textDim,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: l10n.dateOfBirth,
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  onTap: _selectDate,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tobController,
                  decoration: InputDecoration(
                    labelText: l10n.timeOfBirth,
                    prefixIcon: const Icon(Icons.access_time),
                    hintText: l10n.timeOfBirthHint,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pobController,
                  decoration: InputDecoration(
                    labelText: l10n.placeOfBirth,
                    prefixIcon: const Icon(Icons.place),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fathersNameController,
                  decoration: InputDecoration(
                    labelText: l10n.fathersHusbandsName,
                    prefixIcon: const Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gotraController,
                  decoration: InputDecoration(
                    labelText: l10n.gotra,
                    prefixIcon: const Icon(Icons.family_restroom),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _casteController,
                  decoration: InputDecoration(
                    labelText: l10n.caste,
                    prefixIcon: const Icon(Icons.groups),
                  ),
                ),
                if (!kIsWeb) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.getNotifications,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.getNotificationsDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textDim,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_notificationPrefsLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: Text(l10n.notifyRahuKaal),
                              subtitle: Text(
                                l10n.notifyRahuKaalDesc,
                                style: theme.textTheme.bodySmall,
                              ),
                              value: _notifyRahuKaal,
                              onChanged: _setNotifyRahuKaal,
                              activeThumbColor: AppTheme.primaryGold,
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              title: Text(l10n.notifySandhyaKaal),
                              subtitle: Text(
                                l10n.notifySandhyaKaalDesc,
                                style: theme.textTheme.bodySmall,
                              ),
                              value: _notifySandhyaKaal,
                              onChanged: _setNotifySandhyaKaal,
                              activeThumbColor: AppTheme.primaryGold,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 24),
                Text(
                  l10n.myRecurringDonations,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (_recurringDonationsLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else if (_recurringDonations.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      l10n.noRecurringDonations,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textDim,
                      ),
                    ),
                  )
                else
                  ..._recurringDonations.map<Widget>((s) {
                    final id = s['id'];
                    final amount = s['amount'] ?? 0;
                    final frequency = s['frequency'] ?? 'monthly';
                    final nextDate = s['nextBillingDate'] as String?;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('₹${amount.toStringAsFixed(0)} / $frequency'),
                        subtitle: nextDate != null
                            ? Text('Next billing: $nextDate')
                            : null,
                        trailing: TextButton(
                          onPressed: () => _cancelSubscription(id.toString()),
                          child: Text(l10n.cancelSubscription),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.saveChanges),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
