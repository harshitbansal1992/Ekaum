import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/services/rahu_kaal_location_service.dart';
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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _showCopyButton = false;
    });

    try {
      final locationResult = await RahuKaalLocationService.getCurrentLocation(
        webTimeout: const Duration(seconds: 10),
      );

      final timings = RahuKaalService.calculateTimings(
        latitude: locationResult.latitude,
        longitude: locationResult.longitude,
        date: _selectedDate,
        cityName: locationResult.cityName,
        stateName: locationResult.stateName,
        countryCode: locationResult.countryCode,
      );

      if (!mounted) return;
      setState(() {
        _currentPosition = locationResult.position;
        _timings = timings;
        _locationName = locationResult.displayName;
        _isLoading = false;
        _showCopyButton = true;
      });
    } on RahuKaalLocationException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
      backgroundColor: const Color(0xFFFAFAF5),
      appBar: AppBar(
        title: const Text('RahuKaal'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Logo and Title Section
                      _buildHeader(),
                      
                      // Main Rahukaal Card
                      if (_timings != null) _buildRahukaalCard(),
                      
                      // Action Buttons
                      _buildActionButtons(),
                      
                      // Date Picker Section
                      _buildDatePickerSection(),
                      
                      // Sandhya Note
                      if (_timings != null) _buildSandhyaNote(),
                      
                      // Time Periods Cards
                      if (_timings != null) _buildTimePeriodsCards(),
                      
                      // Copy Button
                      if (_showCopyButton && _timings != null) _buildCopyButton(),
                      
                      // Video Link
                      _buildVideoLink(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo (if available)
        const SizedBox(height: 16),
        // Title
        const Text(
          'RahuKaal',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFB8860B),
            fontFamily: 'Georgia',
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRahukaalCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Rahukaal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Time Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _timings!['rahuKaalStart'] ?? '',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '-',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  _timings!['rahuKaalEnd'] ?? '',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Location and Date
            if (_locationName != null)
              Text(
                _locationName!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            if (_timings!['formattedDate'] != null)
              Text(
                _timings!['formattedDate']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 12),
            // Note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '(नोट : इस समय पाठ नहीं करना)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _checkToday,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: const Text(
              'Today',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _checkTomorrow,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: const Text(
              'Tomorrow',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Text(
            '----- OR -----',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Select Specific date to check Rahu Kaal',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20, color: Color(0xFF6B7280)),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF716D66),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _getCurrentLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF06445),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Check',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSandhyaNote() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFBBF24).withOpacity(0.06),
            const Color(0xFFF59E0B).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFBBF24).withOpacity(0.15),
        ),
      ),
      child: const Text(
        '(नोट : निचे दिए गए समय में पाठ करना है)',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C2C2C),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimePeriodsCards() {
    return Column(
      children: [
        // Brahma Muhurat
        _buildTimeCard(
          title: 'ब्रह्म मुहूर्त',
          startTime: _timings!['brahmaMuhuratStart'] ?? '',
          endTime: _timings!['brahmaMuhuratEnd'] ?? '',
          isBrahma: true,
        ),
        const SizedBox(height: 16),
        // Pratah Sandhya
        _buildTimeCard(
          title: 'Pratah Sandhya',
          startTime: _timings!['pratahSandhyaStart'] ?? '',
          endTime: _timings!['pratahSandhyaEnd'] ?? '',
        ),
        const SizedBox(height: 16),
        // Madhya Sandhya
        _buildTimeCard(
          title: 'Madhya Sandhya',
          startTime: _timings!['madhyaSandhyaStart'] ?? '',
          endTime: _timings!['madhyaSandhyaEnd'] ?? '',
        ),
        const SizedBox(height: 16),
        // Sayahna Sandhya
        _buildTimeCard(
          title: 'Sayahna Sandhya',
          startTime: _timings!['sayahnaSandhyaStart'] ?? '',
          endTime: _timings!['sayahnaSandhyaEnd'] ?? '',
        ),
      ],
    );
  }

  Widget _buildTimeCard({
    required String title,
    required String startTime,
    required String endTime,
    bool isBrahma = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isBrahma
            ? const LinearGradient(
                colors: [Color(0xFFFEFCE8), Color(0xFFFEF3C7)],
              )
            : const LinearGradient(
                colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
              ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBrahma
              ? const Color(0xFFFBBF24).withOpacity(0.2)
              : const Color(0xFFFBBF24).withOpacity(0.15),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isBrahma ? const Color(0xFFD97706) : const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFBBF24).withOpacity(0.2),
                  ),
                ),
                child: Text(
                  startTime,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '-',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF555555),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFBBF24).withOpacity(0.2),
                  ),
                ),
                child: Text(
                  endTime,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCopyButton() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: ElevatedButton.icon(
        onPressed: _copyResults,
        icon: const Icon(Icons.copy, size: 20),
        label: const Text('Copy Results'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildVideoLink() {
    return Container(
      margin: const EdgeInsets.only(top: 32, bottom: 16),
      child: InkWell(
        onTap: () async {
          final url = Uri.parse('https://youtube.com/shorts/Y5413M_klB8?feature=share');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        child: const Text(
          'Watch Video',
          style: TextStyle(
            color: Color(0xFFF59E0B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFF06445),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
