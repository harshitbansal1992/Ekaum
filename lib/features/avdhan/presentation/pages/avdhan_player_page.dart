import 'dart:async';
import 'dart:ui';

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

  // Animation Controller for rotating artwork
  late AnimationController _rotationController;

  // Lock to prevent concurrent initialization attempts
  bool _isInitAudioLocked = false;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _playbackEventSubscription;

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
        await _audioPlayer.setLoopMode(LoopMode.off);

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

  @override
  void dispose() {
    _isDisposed = true;
    _rotationController.dispose(); // Dispose animation
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
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

    // Background Image Provider
    final ImageProvider? bgImage = widget.audio.thumbnailUrl != null 
        ? NetworkImage(widget.audio.thumbnailUrl!) 
        : null;

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
          // 1. Immersive Background
          if (bgImage != null)
            Image(image: bgImage, fit: BoxFit.cover),
          
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
                        image: DecorationImage(
                          image: bgImage ?? const AssetImage('assets/images/logo.png'), // Fallback
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

                  // Title & Meta
                  Text(
                    widget.audio.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.audio.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textDim,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 48),

                  // Slider Section
                  if (_errorMessage == null) ...[
                    // Preview Badge
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
                          'Free Preview: 5m',
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
                        max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0,
                        onChanged: (value) {
                           if (!_isInitialized) return;
                           _audioPlayer.seek(Duration(seconds: value.toInt()));
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Controls Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Replay 10s
                        IconButton(
                          icon: const Icon(Icons.replay_10_rounded, color: AppTheme.primaryGold),
                          iconSize: 32,
                          onPressed: () => _seekRelative(-10),
                        ),
                        
                        // Play/Pause Main Button
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryGold,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGold.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: _isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: CircularProgressIndicator(color: Colors.black),
                                  )
                                : Icon(
                                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    size: 40,
                                    color: Colors.white, // High contrast on Gold
                                  ),
                          ),
                        ),
                        
                        // Forward 10s
                        IconButton(
                          icon: const Icon(Icons.forward_10_rounded, color: AppTheme.primaryGold),
                          iconSize: 32,
                          onPressed: () => _seekRelative(10),
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
