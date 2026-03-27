import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/payment_handler.dart';
import '../../data/models/paath_service.dart';
import '../../data/models/paath_form_data.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/components/glass_card.dart';

class PaathFormPage extends ConsumerStatefulWidget {
  final PaathService service;

  const PaathFormPage({
    super.key,
    required this.service,
  });

  @override
  ConsumerState<PaathFormPage> createState() => _PaathFormPageState();
}

class _PaathFormPageState extends ConsumerState<PaathFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _installments = widget.service.installments.clamp(1, AppConstants.maxInstallments);
  }
  final _dobController = TextEditingController();
  final _tobController = TextEditingController();
  final _pobController = TextEditingController();
  final _fathersNameController = TextEditingController();
  final _gotraController = TextEditingController();
  final _casteController = TextEditingController();
  final _customPayNowController = TextEditingController();
  
  DateTime? _dateOfBirth;
  late int _installments;
  final List<Map<String, dynamic>> _familyMembers = [];
  bool _isSubmitting = false;
  String? _customPayNowError;
  
  // Family member form state
  bool _showFamilyForm = false;
  final _fmNameController = TextEditingController();
  final _fmTobController = TextEditingController();
  final _fmPobController = TextEditingController();
  final _fmRelationshipController = TextEditingController();
  DateTime? _fmDob;
  String? _fmDobError;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _tobController.dispose();
    _pobController.dispose();
    _fathersNameController.dispose();
    _gotraController.dispose();
    _casteController.dispose();
    _customPayNowController.dispose();
    _fmNameController.dispose();
    _fmTobController.dispose();
    _fmPobController.dispose();
    _fmRelationshipController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    if (widget.service.isFamilyService && _familyMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one family member')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final installmentAmount = widget.service.price / _installments;
      double paymentAmount = installmentAmount;
      final customInput = _customPayNowController.text.trim().replaceAll(',', '');
      if (customInput.isNotEmpty) {
        final parsedAmount = double.tryParse(customInput);
        if (parsedAmount == null || parsedAmount <= 0) {
          setState(() {
            _customPayNowError = 'Enter a valid amount';
          });
          return;
        }
        if (parsedAmount > widget.service.price) {
          setState(() {
            _customPayNowError = 'Amount cannot exceed total amount';
          });
          return;
        }
        paymentAmount = parsedAmount;
      }
      setState(() {
        _customPayNowError = null;
      });

      final formData = PaathFormData(
        serviceId: widget.service.id,
        serviceName: widget.service.name,
        totalAmount: widget.service.price,
        installments: _installments,
        installmentAmount: installmentAmount,
        name: _nameController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        timeOfBirth: _tobController.text.trim(),
        placeOfBirth: _pobController.text.trim(),
        fathersOrHusbandsName: _fathersNameController.text.trim(),
        gotra: _gotraController.text.trim(),
        caste: _casteController.text.trim(),
        familyMembers: widget.service.isFamilyService
            ? _familyMembers.map((m) {
                return FamilyMember(
                  name: m['name'],
                  dateOfBirth: m['dateOfBirth'],
                  timeOfBirth: m['timeOfBirth'],
                  placeOfBirth: m['placeOfBirth'],
                  relationship: m['relationship'],
                );
              }).toList()
            : null,
      );

      final authState = ref.read(authProvider);
      final userId = authState.user?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Save form data to API
      final formId = await ApiService.createPaathForm({
        ...formData.toJson(),
        'userId': userId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form submitted successfully. Proceed to payment.'),
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to payment for first installment
        PaymentHandler.handlePaathPayment(
          context,
          formId,
          paymentAmount,
          1, // First installment
          goToMyPaathOnSuccess: true,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final installmentAmount = widget.service.price / _installments;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.service.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassCard(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryGoldDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Total Amount: ₹${widget.service.price.toInt()}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (widget.service.isOneTime)
                      Text(
                        'One-time payment: ₹${widget.service.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else ...[
                      Text(
                        'Payment in Installments (up to ${widget.service.installments})',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _installments.toDouble(),
                              min: 1,
                              max: widget.service.installments.toDouble(),
                              divisions: widget.service.installments > 1 ? widget.service.installments - 1 : 1,
                              label: _installments == 1 ? 'One-time' : '$_installments installments',
                              onChanged: (value) {
                                setState(() {
                                  _installments = value.toInt();
                                });
                              },
                            ),
                          ),
                          Text(
                            _installments == 1 ? 'One-time' : '$_installments',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        _installments == 1
                            ? 'Full amount: ₹${installmentAmount.toStringAsFixed(2)}'
                            : 'Per Installment: ₹${installmentAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customPayNowController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Amount to pay now (optional)',
                          hintText: 'Suggested ₹${installmentAmount.toStringAsFixed(2)}',
                          prefixText: '₹ ',
                          errorText: _customPayNowError,
                          border: const OutlineInputBorder(),
                          helperText: 'Leave empty to pay suggested amount',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final user = ref.watch(authProvider).user;
                  final hasProfileData = user != null;
                  if (!hasProfileData) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        AppUser? u = ref.read(authProvider).user;
                        try {
                          final latest = await ApiService.getCurrentUser();
                          u = AppUser.fromJson(latest);
                        } catch (_) {
                          // Fall back to locally cached user data if API fetch fails.
                        }
                        if (u == null) return;
                        final resolvedUser = u;
                        setState(() {
                          _nameController.text = resolvedUser.name ?? '';
                          if (resolvedUser.dateOfBirth != null) {
                            _dateOfBirth = resolvedUser.dateOfBirth;
                            _dobController.text =
                                DateFormat('yyyy-MM-dd').format(resolvedUser.dateOfBirth!);
                          }
                          _tobController.text = resolvedUser.timeOfBirth ?? '';
                          _pobController.text = resolvedUser.placeOfBirth ?? '';
                          _fathersNameController.text =
                              resolvedUser.fathersOrHusbandsName ?? '';
                          _gotraController.text = resolvedUser.gotra ?? '';
                          _casteController.text = resolvedUser.caste ?? '';
                        });
                        final loadedFields = <String>[
                          if ((resolvedUser.name ?? '').trim().isNotEmpty) 'name',
                          if (resolvedUser.dateOfBirth != null) 'date of birth',
                          if ((resolvedUser.timeOfBirth ?? '').trim().isNotEmpty) 'time of birth',
                          if ((resolvedUser.placeOfBirth ?? '').trim().isNotEmpty) 'place of birth',
                          if ((resolvedUser.fathersOrHusbandsName ?? '').trim().isNotEmpty) 'father/husband name',
                          if ((resolvedUser.gotra ?? '').trim().isNotEmpty) 'gotra',
                          if ((resolvedUser.caste ?? '').trim().isNotEmpty) 'caste',
                        ];
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              loadedFields.isEmpty
                                  ? 'No profile details found. Please update your profile first.'
                                  : 'Loaded ${loadedFields.length} profile field${loadedFields.length == 1 ? '' : 's'}.',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_search),
                      label: const Text('Use my profile details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryGold,
                        side: const BorderSide(color: AppTheme.primaryGold),
                      ),
                    ),
                  );
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth *',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Date of birth is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tobController,
                decoration: const InputDecoration(
                  labelText: 'Time of Birth (HH:MM) *',
                  hintText: 'e.g., 14:30',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Time of birth is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pobController,
                decoration: const InputDecoration(
                  labelText: 'Place of Birth *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Place of birth is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fathersNameController,
                decoration: const InputDecoration(
                  labelText: 'Father\'s/Husband\'s Name *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gotraController,
                decoration: const InputDecoration(
                  labelText: 'Gotra *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Gotra is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _casteController,
                decoration: const InputDecoration(
                  labelText: 'Caste *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Caste is required';
                  }
                  return null;
                },
              ),
              if (widget.service.isFamilyService) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Family Members',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showFamilyForm = !_showFamilyForm;
                          if (_showFamilyForm) {
                            _fmDob = null;
                            _fmDobError = null;
                            _fmNameController.clear();
                            _fmTobController.clear();
                            _fmPobController.clear();
                            _fmRelationshipController.clear();
                          }
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Member'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_showFamilyForm) ...[
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Add Family Member',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _fmNameController,
                          decoration: const InputDecoration(
                            labelText: 'Name *',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _fmDob = picked;
                                _fmDobError = null;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Date of Birth *',
                              suffixIcon: const Icon(Icons.calendar_today),
                              errorText: _fmDobError,
                              border: const OutlineInputBorder(),
                            ),
                            child: Text(
                              _fmDob == null
                                  ? 'Select Date'
                                  : DateFormat('yyyy-MM-dd').format(_fmDob!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _fmTobController,
                          decoration: const InputDecoration(
                            labelText: 'Time of Birth (HH:MM) *',
                            hintText: 'e.g., 14:30',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _fmPobController,
                          decoration: const InputDecoration(
                            labelText: 'Place of Birth *',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _fmRelationshipController,
                          decoration: const InputDecoration(
                            labelText: 'Relationship *',
                            hintText: 'e.g., Wife, Son, Daughter',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _showFamilyForm = false;
                                  });
                                },
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_fmNameController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Name is required')),
                                    );
                                    return;
                                  }
                                  if (_fmDob == null) {
                                    setState(() {
                                      _fmDobError = 'Date of birth is required';
                                    });
                                    return;
                                  }
                                  if (_fmTobController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Time of birth is required')),
                                    );
                                    return;
                                  }
                                  if (_fmPobController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Place of birth is required')),
                                    );
                                    return;
                                  }
                                  if (_fmRelationshipController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Relationship is required')),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    _familyMembers.add({
                                      'name': _fmNameController.text.trim(),
                                      'dateOfBirth': _fmDob!,
                                      'timeOfBirth': _fmTobController.text.trim(),
                                      'placeOfBirth': _fmPobController.text.trim(),
                                      'relationship': _fmRelationshipController.text.trim(),
                                    });
                                    _showFamilyForm = false;
                                  });
                                },
                                child: const Text('Add Member'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                ..._familyMembers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final member = entry.value;
                  return GlassCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${member['relationship']} - ${DateFormat('yyyy-MM-dd').format(member['dateOfBirth'])}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                        onPressed: () {
                          setState(() {
                            _familyMembers.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit & Proceed to Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



