import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/services/nadi_dosh_service.dart';
import '../../data/models/nadi_dosh_result.dart';
import '../../data/services/geocoding_service.dart';

class NadiDoshPage extends StatefulWidget {
  const NadiDoshPage({super.key});

  @override
  State<NadiDoshPage> createState() => _NadiDoshPageState();
}

class _NadiDoshPageState extends State<NadiDoshPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _maleBirthDate;
  TimeOfDay? _maleBirthTime;
  String _maleBirthPlace = '';
  DateTime? _femaleBirthDate;
  TimeOfDay? _femaleBirthTime;
  String _femaleBirthPlace = '';
  NadiDoshResult? _result;
  bool _isCalculating = false;
  
  // Place autocomplete controllers
  final TextEditingController _malePlaceController = TextEditingController();
  final TextEditingController _femalePlaceController = TextEditingController();

  Future<void> _selectDate(BuildContext context, bool isMale) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isMale) {
          _maleBirthDate = picked;
        } else {
          _femaleBirthDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isMale) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isMale) {
          _maleBirthTime = picked;
        } else {
          _femaleBirthTime = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _malePlaceController.dispose();
    _femalePlaceController.dispose();
    super.dispose();
  }

  Future<void> _calculateNadiDosh() async {
    if (!_formKey.currentState!.validate()) return;

    if (_maleBirthDate == null || _femaleBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select birth dates')),
      );
      return;
    }

    if (_maleBirthTime == null || _femaleBirthTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select birth times')),
      );
      return;
    }

    setState(() {
      _isCalculating = true;
      _result = null;
    });

    try {
      // Format time as HH:MM string
      final maleTimeString = _maleBirthTime != null
          ? '${_maleBirthTime!.hour.toString().padLeft(2, '0')}:${_maleBirthTime!.minute.toString().padLeft(2, '0')}'
          : '';
      
      final femaleTimeString = _femaleBirthTime != null
          ? '${_femaleBirthTime!.hour.toString().padLeft(2, '0')}:${_femaleBirthTime!.minute.toString().padLeft(2, '0')}'
          : '';

      final maleDetails = NadiDoshService.calculateNadiDosh(
        birthDate: _maleBirthDate!,
        birthTime: maleTimeString,
        birthPlace: _maleBirthPlace,
      );

      final femaleDetails = NadiDoshService.calculateNadiDosh(
        birthDate: _femaleBirthDate!,
        birthTime: femaleTimeString,
        birthPlace: _femaleBirthPlace,
      );

      final result = NadiDoshService.checkNadiDoshForCouple(
        maleDetails: maleDetails,
        femaleDetails: femaleDetails,
      );

      setState(() {
        _result = result;
        _isCalculating = false;
      });
    } catch (e) {
      setState(() => _isCalculating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nadi Dosh Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Male Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text(_maleBirthDate == null
                            ? 'Select Birth Date'
                            : DateFormat('yyyy-MM-dd').format(_maleBirthDate!)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, true),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        title: Text(_maleBirthTime == null
                            ? 'Select Birth Time'
                            : _maleBirthTime!.format(context)),
                        trailing: const Icon(Icons.access_time),
                        onTap: () => _selectTime(context, true),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(
                            color: _maleBirthTime == null
                                ? Colors.grey.shade300
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Autocomplete<PlaceSuggestion>(
                        optionsBuilder: (textEditingValue) async {
                          if (textEditingValue.text.isEmpty || textEditingValue.text.length < 2) {
                            return const Iterable<PlaceSuggestion>.empty();
                          }
                          return await GeocodingService.searchPlaces(textEditingValue.text);
                        },
                        displayStringForOption: (option) => option.displayName,
                        fieldViewBuilder: (
                          context,
                          textEditingController,
                          focusNode,
                          onFieldSubmitted,
                        ) {
                          // Sync controller with state
                          if (textEditingController.text != _malePlaceController.text) {
                            textEditingController.text = _malePlaceController.text;
                          }
                          _malePlaceController.addListener(() {
                            if (textEditingController.text != _malePlaceController.text) {
                              textEditingController.text = _malePlaceController.text;
                            }
                          });
                          
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Birth Place',
                              hintText: 'Start typing place name...',
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            onChanged: (value) {
                              _malePlaceController.text = value;
                            },
                            onFieldSubmitted: (value) {
                              onFieldSubmitted();
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Birth place is required';
                              }
                              return null;
                            },
                          );
                        },
                        onSelected: (option) {
                          setState(() {
                            _maleBirthPlace = option.displayName;
                            _malePlaceController.text = option.displayName;
                          });
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                color: Theme.of(context).cardColor, // Use theme/glass color
                                borderRadius: BorderRadius.circular(8),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        leading: const Icon(Icons.place, size: 20),
                                        title: Text(
                                          option.displayName,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                        onTap: () {
                                          onSelected(option);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Female Details',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: Text(_femaleBirthDate == null
                              ? 'Select Birth Date'
                              : DateFormat('yyyy-MM-dd').format(_femaleBirthDate!)),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () => _selectDate(context, false),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          title: Text(_femaleBirthTime == null
                              ? 'Select Birth Time'
                              : _femaleBirthTime!.format(context)),
                          trailing: const Icon(Icons.access_time),
                          onTap: () => _selectTime(context, false),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: BorderSide(
                              color: _femaleBirthTime == null
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Autocomplete<PlaceSuggestion>(
                          optionsBuilder: (textEditingValue) async {
                            if (textEditingValue.text.isEmpty || textEditingValue.text.length < 2) {
                              return const Iterable<PlaceSuggestion>.empty();
                            }
                            return await GeocodingService.searchPlaces(textEditingValue.text);
                          },
                          displayStringForOption: (option) => option.displayName,
                          fieldViewBuilder: (
                            context,
                            textEditingController,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            // Sync controller with state
                            if (textEditingController.text != _femalePlaceController.text) {
                              textEditingController.text = _femalePlaceController.text;
                            }
                            _femalePlaceController.addListener(() {
                              if (textEditingController.text != _femalePlaceController.text) {
                                textEditingController.text = _femalePlaceController.text;
                              }
                            });
                            
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Birth Place',
                                hintText: 'Start typing place name...',
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              onChanged: (value) {
                                _femalePlaceController.text = value;
                              },
                              onFieldSubmitted: (value) {
                                onFieldSubmitted();
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Birth place is required';
                                }
                                return null;
                              },
                            );
                          },
                          onSelected: (option) {
                            setState(() {
                              _femaleBirthPlace = option.displayName;
                              _femalePlaceController.text = option.displayName;
                            });
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(8),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        leading: const Icon(Icons.place, size: 20),
                                        title: Text(
                                          option.displayName,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                        onTap: () {
                                          onSelected(option);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isCalculating ? null : _calculateNadiDosh,
                  child: _isCalculating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Calculate Nadi Dosh'),
                ),
                if (_result != null) ...[
                  const SizedBox(height: 24),
                  Card(
                    color: _result!.hasNadiDosh
                        ? Colors.red.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _result!.hasNadiDosh
                                    ? Icons.warning
                                    : Icons.check_circle,
                                color: _result!.hasNadiDosh
                                    ? Colors.redAccent
                                    : Colors.greenAccent,
                                size: 32,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _result!.hasNadiDosh
                                      ? 'Nadi Dosh Present'
                                      : 'No Nadi Dosh',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                    color: _result!.hasNadiDosh
                                        ? Colors.redAccent
                                        : Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nadi Type: ${_result!.nadiType}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _result!.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

