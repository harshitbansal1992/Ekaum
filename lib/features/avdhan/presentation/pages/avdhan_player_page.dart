import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/payment_handler.dart';
import '../../data/models/avdhan_audio.dart';
import '../providers/subscription_provider.dart';
import '../../../../core/theme/app_theme.dart';

class AvdhanPlayerPage extends ConsumerStatefulWidget {
  final AvdhanAudio audio;

  const AvdhanPlayerPage({
    super.key,
    required this.audio,
  });

  @override
  ConsumerState<AvdhanPlayerPage> createState() => _AvdhanPlayerPageState();
}

class _AvdhanPlayerPageState extends ConsumerState<AvdhanPlayerPage>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _hasReachedPreviewLimit = false;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isInitialized = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  bool _listenersSetUp = false;
  bool _isDisposed = false;

  // Playback options
  double _playbackSpeed = 1.0;
  static const List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  LoopMode _loopMode = LoopMode.off;
  bool _showDescription = false;
  Timer? _sleepTimer;
  int? _sleepSecondsRemaining; // null = sleep timer off

  // Animation Controller for rotating artwork
  late AnimationController _rotationController;

  // Lock to prevent concurrent initialization attempts
  bool _isInitAudioLocked = false;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _playbackEventSubscription;
  StreamSubscription? _durationSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    
    // Initialize animation controller (slow rotation: 10 seconds per circle)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _setupErrorListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAudio();
    });
  }

  void _setupErrorListeners() {
    if (_listenersSetUp) return;
    _listenersSetUp = true;

    // Listen to position stream
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (_isDisposed || !mounted) return;

      setState(() {
        _position = position;

        // Check if preview limit reached
        final subscriptionAsync = ref.read(subscriptionProvider);
        final hasSubscription = subscriptionAsync.value ?? false;
        if (!hasSubscription &&
            position.inSeconds >= AppConstants.audioPreviewSeconds) {
          if (!_hasReachedPreviewLimit) {
            _hasReachedPreviewLimit = true;
            _audioPlayer.pause();
            _rotationController.stop();
            _showSubscriptionPrompt();
          }
        }
      });
    });

    // Listen to player state changes
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (_isDisposed || !mounted) return;

      setState(() {
        _isPlaying = state.playing;
        
        // Sync animation with playing state
        if (_isPlaying && !_rotationController.isAnimating) {
          _rotationController.repeat();
        } else if (!_isPlaying && _rotationController.isAnimating) {
          _rotationController.stop();
        }

        if (state.processingState == ProcessingState.ready) {
          _isLoading = false;
          _isInitialized = true;
        } else if (state.processingState == ProcessingState.loading) {
          _isLoading = true;
        } else if (state.processingState == ProcessingState.idle) {
           // Idle handling
        } else if (state.processingState == ProcessingState.buffering) {
           // Buffering
        }
      });
    });

    // Listen to duration (for files without pre-set duration)
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (_isDisposed || !mounted || duration == null) return;
      setState(() => _duration = duration);
    });

    // Listen to playback events for errors
    _playbackEventSubscription = _audioPlayer.playbackEventStream.listen(
      (event) {},
      onError: (error) {
        if (_isDisposed || !mounted) return;

        setState(() {
          _errorMessage = 'Playback error: ${error.toString()}';
          _isLoading = false;
          _isPlaying = false;
          _rotationController.stop();
        });
        if (_retryCount < _maxRetries) {
          Future.delayed(const Duration(seconds: 2), () {
            if (!_isDisposed && mounted) {
              _initAudio(isRetry: true);
            }
          });
        }
      },
    );
  }

  Future<void> _initAudio({bool isRetry = false}) async {
    if (_isDisposed || !mounted) return;
    if (_isInitAudioLocked) return;
    _isInitAudioLocked = true;

    try {
        if (isRetry) {
          _retryCount++;
          if (_retryCount > _maxRetries) {
            if (!_isDisposed && mounted) {
              setState(() {
                _errorMessage = 'Failed to load audio. Please retry.';
                _isLoading = false;
              });
            }
            return;
          }
        } else {
          _retryCount = 0;
        }

        if (!_isDisposed && mounted) {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
            _isInitialized = false;
          });
        }

        try {
          if (!_isDisposed && _audioPlayer.processingState != ProcessingState.idle) {
            await _audioPlayer.stop();
          }
        } catch (e) { /* Ignore stop error */ }

        if (_isDisposed) return;

        await _audioPlayer.setUrl(
          widget.audio.audioUrl,
          headers: {'User-Agent': 'BSLND-App'},
        );
        
        if (_isDisposed) return;
        await _audioPlayer.setLoopMode(_loopMode);
        await _audioPlayer.setSpeed(_playbackSpeed);

        // Wait for ready (simplified from previous version for brevity)
        if (widget.audio.duration > 0) {
           _duration = Duration(seconds: widget.audio.duration);
        }

        if (!_isDisposed && mounted) {
           setState(() {
             _isLoading = false; // Optimistic
           });
        }

    } catch (e) {
      if (_isDisposed) return;
      if (mounted) {
         setState(() {
          _errorMessage = 'Error loading audio';
          _isLoading = false;
         });
      }
    } finally {
        _isInitAudioLocked = false;
    }
  }

  void _showSubscriptionPrompt() {
    if (_isDisposed || !mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Preview Limit Reached'),
        content: const Text('Subscribe to listen to the full audio.'),
        actions: [
          TextButton(
            onPressed: () {Navigator.pop(context); Navigator.pop(context);},
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              PaymentHandler.handleSubscriptionPayment(context, ref);
            },
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePlayPause() async {
    if (_isDisposed || !mounted) return;

    if (!_isInitialized) {
      await _initAudio();
      return;
    }

    final subscriptionAsync = ref.read(subscriptionProvider);
    final hasSubscription = subscriptionAsync.value ?? false;
    if (!hasSubscription &&
        _position.inSeconds >= AppConstants.audioPreviewSeconds) {
      _showSubscriptionPrompt();
      return;
    }

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }
  
  void _seekRelative(int seconds) {
    if (!_isInitialized) return;
    final newPos = _position + Duration(seconds: seconds);
    final clampedPos = newPos < Duration.zero 
        ? Duration.zero 
        : (newPos > _duration ? _duration : newPos);
    _audioPlayer.seek(clampedPos);
  }

  void _startSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    setState(() => _sleepSecondsRemaining = minutes * 60);
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isDisposed || !mounted) return;
      setState(() {
        _sleepSecondsRemaining = _sleepSecondsRemaining! - 1;
        if (_sleepSecondsRemaining! <= 0) {
          _sleepSecondsRemaining = null;
          _sleepTimer?.cancel();
          _audioPlayer.pause();
          _rotationController.stop();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sleep timer ended')),
            );
          }
        }
      });
    });
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    setState(() => _sleepSecondsRemaining = null);
  }

  String _formatSleepRemaining() {
    if (_sleepSecondsRemaining == null) return '';
    final m = _sleepSecondsRemaining! ~/ 60;
    final s = _sleepSecondsRemaining! % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _showSleepTimerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.bgLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Sleep timer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [5, 10, 15, 30, 45, 60].map((m) {
                return ActionChip(
                  label: Text('$m min'),
                  backgroundColor: AppTheme.primaryGold.withOpacity(0.1),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _startSleepTimer(m * 60); // Convert to seconds for countdown
                  },
                );
              }).toList(),
            ),
            if (_sleepSecondsRemaining != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _cancelSleepTimer();
                },
                child: const Text('Cancel timer'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _sleepTimer?.cancel();
    _rotationController.dispose();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _playbackEventSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscriptionAsync = ref.watch(subscriptionProvider);
    final isSubscribed = subscriptionAsync.value ?? false;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(''), // Clean look
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32, color: AppTheme.primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Immersive Background (cached for performance, fallback when no thumbnail)
          widget.audio.thumbnailUrl != null
              ? CachedNetworkImage(
                  imageUrl: widget.audio.thumbnailUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppTheme.bgCream),
                  errorWidget: (_, __, ___) => Container(color: AppTheme.bgCream),
                )
              : Container(color: AppTheme.bgCream),
          
          // 2. Global Gradient (Fallback or Overlay)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33FFFFFF),
                  AppTheme.bgCream,
                  AppTheme.bgLight,
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),
          
          // 3. Blur Effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.transparent),
          ),

          // 4. Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  
                  // Rotating Artwork (The "Sattva" Chakra look)
                  RotationTransition(
                    turns: _rotationController,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                          // Optional: Golden Glow
                          BoxShadow(
                            color: const Color(0xFFFBBF24).withOpacity(0.2), // Gold glow
                            blurRadius: 40,
                            spreadRadius: 0,
                          ),
                        ],
                        image: widget.audio.thumbnailUrl != null
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(widget.audio.thumbnailUrl!),
                                fit: BoxFit.cover,
                              )
                            : const DecorationImage(
                                image: AssetImage('assets/images/logo.png'),
                                fit: BoxFit.cover,
                              ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(flex: 2),

                  // Title
                  Text(
                    widget.audio.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Description (expandable)
                  if (widget.audio.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() => _showDescription = !_showDescription),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showDescription ? Icons.expand_less : Icons.expand_more,
                            color: AppTheme.primaryGold,
                            size: 24,
                          ),
                          Text(
                            _showDescription ? 'Hide' : 'Show description',
                            style: const TextStyle(color: AppTheme.primaryGold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                        child: Text(
                          widget.audio.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textDim,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      crossFadeState: _showDescription
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Slider Section
                  if (_errorMessage == null) ...[
                    // Preview Badge - dynamic from AppConstants
                    if (!isSubscribed)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryGold.withOpacity(0.2)),
                        ),
                        child: const Text(
                          'Free Preview: ${AppConstants.audioPreviewSeconds ~/ 60}m',
                          style: TextStyle(color: AppTheme.primaryGoldDark, fontSize: 12),
                        ),
                      ),
                      
                    // Time Labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(_position), style: const TextStyle(color: AppTheme.textDim)),
                        Text(_formatDuration(_duration), style: const TextStyle(color: AppTheme.textDim)),
                      ],
                    ),
                    
                    // Custom Slider
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        activeTrackColor: AppTheme.primaryGold,
                        inactiveTrackColor: AppTheme.primaryGold.withOpacity(0.1),
                        thumbColor: AppTheme.primaryGold,
                        overlayColor: AppTheme.primaryGold.withOpacity(0.1),
                      ),
                      child: Slider(
                        value: _duration.inSeconds > 0 
                            ? _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()) 
                            : 0.0,
                        max: _duration.inSeconds > 0 
                            ? (!isSubscribed ? AppConstants.audioPreviewSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()) : _duration.inSeconds.toDouble())
                            : 1.0,
                        onChanged: (value) {
                           if (!_isInitialized) return;
                           // Clamp free users to preview limit
                           final maxSec = !isSubscribed 
                               ? AppConstants.audioPreviewSeconds.clamp(0, _duration.inSeconds)
                               : _duration.inSeconds;
                           _audioPlayer.seek(Duration(seconds: (value.toInt().clamp(0, maxSec))));
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Controls Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Replay 15s
                        IconButton(
                          icon: const Icon(Icons.replay_10_rounded, color: AppTheme.primaryGold),
                          iconSize: 36,
                          tooltip: 'Replay 15s',
                          onPressed: () => _seekRelative(-15),
                        ),
                        
                        // Play/Pause Main Button
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primaryGoldLight,
                                  AppTheme.primaryGold,
                                  AppTheme.primaryGoldDark,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGold.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: _isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(22.0),
                                    child: CircularProgressIndicator(color: Colors.black),
                                  )
                                : Icon(
                                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    size: 44,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                        
                        // Forward 15s
                        IconButton(
                          icon: const Icon(Icons.forward_10_rounded, color: AppTheme.primaryGold),
                          iconSize: 36,
                          tooltip: 'Forward 15s',
                          onPressed: () => _seekRelative(15),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Secondary controls: Speed + Loop + Sleep
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        // Playback speed
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGold.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppTheme.primaryGold.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.speed_rounded, color: AppTheme.primaryGold, size: 20),
                              const SizedBox(width: 8),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<double>(
                                  value: _playbackSpeed,
                                  isDense: true,
                                  dropdownColor: AppTheme.bgLight,
                                  icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryGold),
                                  items: _speedOptions.map((s) {
                                    return DropdownMenuItem(
                                      value: s,
                                      child: Text(
                                        s == 1.0 ? '1x' : '${s}x',
                                        style: const TextStyle(
                                          color: AppTheme.textDark,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) async {
                                    if (value == null || !_isInitialized) return;
                                    setState(() => _playbackSpeed = value);
                                    await _audioPlayer.setSpeed(value);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Loop mode
                        InkWell(
                          onTap: () async {
                            final next = _loopMode == LoopMode.one ? LoopMode.off : LoopMode.one;
                            setState(() => _loopMode = next);
                            await _audioPlayer.setLoopMode(next);
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: _loopMode == LoopMode.one
                                  ? AppTheme.primaryGold.withOpacity(0.2)
                                  : AppTheme.primaryGold.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: _loopMode == LoopMode.one
                                    ? AppTheme.primaryGold
                                    : AppTheme.primaryGold.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.repeat_rounded,
                                  color: _loopMode == LoopMode.one
                                      ? AppTheme.primaryGold
                                      : AppTheme.textDim,
                                  size: 22,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _loopMode == LoopMode.one ? 'Repeat On' : 'Repeat Off',
                                  style: TextStyle(
                                    color: _loopMode == LoopMode.one
                                        ? AppTheme.primaryGold
                                        : AppTheme.textDim,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Sleep timer
                        InkWell(
                          onTap: _showSleepTimerSheet,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: _sleepSecondsRemaining != null
                                  ? AppTheme.primaryGold.withOpacity(0.2)
                                  : AppTheme.primaryGold.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: _sleepSecondsRemaining != null
                                    ? AppTheme.primaryGold
                                    : AppTheme.primaryGold.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bedtime_rounded,
                                  color: _sleepSecondsRemaining != null
                                      ? AppTheme.primaryGold
                                      : AppTheme.textDim,
                                  size: 22,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _sleepSecondsRemaining != null
                                      ? _formatSleepRemaining()
                                      : 'Sleep',
                                  style: TextStyle(
                                    color: _sleepSecondsRemaining != null
                                        ? AppTheme.primaryGold
                                        : AppTheme.textDim,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                     // Error View inside Player
                     Padding(
                       padding: const EdgeInsets.all(16.0),
                       child: Column(
                         children: [
                           const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                           const SizedBox(height: 16),
                           Text(_errorMessage!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                           const SizedBox(height: 16),
                           ElevatedButton(
                             onPressed: () => _initAudio(isRetry: true),
                             style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
                             child: const Text('Retry'),
                           ),
                         ],
                       ),
                     )
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
