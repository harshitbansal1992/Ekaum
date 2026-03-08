import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/components/glass_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/services/rahu_kaal_service.dart';

class RahuKaalPage extends StatefulWidget {
  const RahuKaalPage({super.key});

  @override
  State<RahuKaalPage> createState() => _RahuKaalPageState();
}

class _RahuKaalPageState extends State<RahuKaalPage> {
  dynamic _currentPosition;
  Map<String, String>? _timings;
  bool _isLoading = false;
  String? _error;
  String? _locationName;
  DateTime _selectedDate = DateTime.now();
  bool _showCopyButton = false;
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('en', null);
      setState(() {
        _localeInitialized = true;
      });
      _getCurrentLocation();
    } catch (e) {
      // If locale initialization fails, still try to get location
      // DateFormat will use default formatting
      setState(() {
        _localeInitialized = true;
      });
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _showCopyButton = false;
    });

    try {
      if (kIsWeb) {
        // Web version - use default location
        final defaultLat = 22.7196;
        final defaultLon = 75.8577;
        
        final timings = RahuKaalService.calculateTimings(
          latitude: defaultLat,
          longitude: defaultLon,
          date: _selectedDate,
          cityName: 'Indore',
        );

        setState(() {
          _timings = timings;
          _locationName = 'Indore, India';
          _isLoading = false;
          _showCopyButton = true;
        });
        return;
      }

      // Mobile/Desktop - use Geolocator
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled. Please enable them.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permissions are denied.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permissions are permanently denied. Please enable in settings.';
          _isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      // Get location name (simplified - in production use reverse geocoding)
      final timings = RahuKaalService.calculateTimings(
        latitude: position.latitude,
        longitude: position.longitude,
        date: _selectedDate,
      );

      setState(() {
        _timings = timings;
        _locationName = '${timings['cityName']}${timings['stateName']?.isNotEmpty == true ? ', ${timings['stateName']}' : ''}';
        _isLoading = false;
        _showCopyButton = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Error getting location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkToday() async {
    setState(() {
      _selectedDate = DateTime.now();
    });
    await _getCurrentLocation();
  }

  Future<void> _checkTomorrow() async {
    setState(() {
      _selectedDate = DateTime.now().add(const Duration(days: 1));
    });
    await _getCurrentLocation();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      await _getCurrentLocation();
    }
  }

  Future<void> _copyResults() async {
    if (_timings == null) return;
    
    final resultText = RahuKaalService.formatResultForCopy(_timings!);
    
    await Clipboard.setData(ClipboardData(text: resultText));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Results copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Global gradient shows through
      appBar: AppBar(
        title: const Text('RahuKaal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
          : _error != null
              ? _buildErrorView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Main Rahukaal Display
                      if (_timings != null) _buildRahukaalCard(),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons (Today/Tomorrow)
                      _buildActionButtons(),
                      
                      const SizedBox(height: 24),

                      // Date Picker
                      _buildDatePickerSection(),
                      
                      const SizedBox(height: 24),

                      // Sandhya Note
                      if (_timings != null) _buildSandhyaNote(),
                      
                      const SizedBox(height: 24),

                      // Time Periods List
                      if (_timings != null) _buildTimePeriodsCards(),
                      
                      // Copy Button
                      if (_showCopyButton && _timings != null) _buildCopyButton(),
                      
                      // Video Link
                      _buildVideoLink(),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  Widget _buildRahukaalCard() {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
           Text(
            'RAHU KAAL',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryGold,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Time Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _timings!['rahuKaalStart'] ?? '',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '-',
                  style: TextStyle(
                    fontSize: 32,
                    color: AppTheme.textDark.withOpacity(0.3),
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
              Text(
                _timings!['rahuKaalEnd'] ?? '',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Location & Date
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withOpacity(0.05),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined, color: AppTheme.primaryGold, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _locationName ?? 'Unknown Location',
                    style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
          ),
          const SizedBox(height: 12),
          Text(
            _timings!['formattedDate'] ?? '',
            style: const TextStyle(color: AppTheme.textDim, fontSize: 14),
          ),
          
          const SizedBox(height: 24),
          
          // Warning Note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red.shade200, size: 20),
                const SizedBox(width: 10),
                Text(
                  'DO NOT perform auspicious tasks',
                  style: TextStyle(color: Colors.red.shade100, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildGlassButton(
            label: 'Today',
            onTap: _checkToday,
            isActive: DateUtils.isSameDay(_selectedDate, DateTime.now()),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGlassButton(
            label: 'Tomorrow',
            onTap: _checkTomorrow,
            isActive: DateUtils.isSameDay(_selectedDate, DateTime.now().add(const Duration(days: 1))),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassButton({required String label, required VoidCallback onTap, required bool isActive}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryGold : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppTheme.primaryGold : AppTheme.primaryGold.withOpacity(0.2),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.textDark,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerSection() {
    return GlassCard(
      padding: const EdgeInsets.all(4),
      child: ListTile(
        onTap: _selectDate,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGold.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.calendar_month_outlined, color: AppTheme.primaryGold),
        ),
        title: Text(
          DateFormat('EEEE, d MMMM y').format(_selectedDate),
          style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w500),
        ),
        subtitle: const Text(
          'Tap to change date',
          style: TextStyle(color: AppTheme.textDim, fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textDim),
      ),
    );
  }

  Widget _buildSandhyaNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, color: AppTheme.primaryGold, size: 16),
          const SizedBox(width: 12),
          const Text(
            'Recommended times for prayer (Sandhya)',
            style: TextStyle(
              color: AppTheme.primaryGoldDark,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodsCards() {
    return Column(
      children: [
        _buildTimeRow('Brahma Muhurat', _timings!['brahmaMuhuratStart']!, _timings!['brahmaMuhuratEnd']!, isHighlight: true),
        const SizedBox(height: 12),
        _buildTimeRow('Pratah Sandhya', _timings!['pratahSandhyaStart']!, _timings!['pratahSandhyaEnd']!),
        const SizedBox(height: 12),
        _buildTimeRow('Madhya Sandhya', _timings!['madhyaSandhyaStart']!, _timings!['madhyaSandhyaEnd']!),
        const SizedBox(height: 12),
        _buildTimeRow('Sayahna Sandhya', _timings!['sayahnaSandhyaStart']!, _timings!['sayahnaSandhyaEnd']!),
      ],
    );
  }

  Widget _buildTimeRow(String title, String start, String end, {bool isHighlight = false}) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      frostColor: isHighlight ? AppTheme.primaryGold : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isHighlight ? AppTheme.primaryGoldDark : AppTheme.textDark,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              fontSize: 15,
            ),
          ),
          Row(
            children: [
              Text(
                start,
                style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('-', style: TextStyle(color: AppTheme.textDim)),
              ),
              Text(
                end,
                style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCopyButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: TextButton.icon(
        onPressed: _copyResults,
        icon: const Icon(Icons.copy_rounded, size: 18),
        label: const Text('Copy All Timings'),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.textDim,
        ),
      ),
    );
  }

  Widget _buildVideoLink() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextButton.icon(
        onPressed: () async {
          final url = Uri.parse('https://youtube.com/shorts/Y5413M_klB8?feature=share');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        icon: const Icon(Icons.play_circle_fill, color: Colors.red),
        label: const Text('Watch Explainer Video', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textDark),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

