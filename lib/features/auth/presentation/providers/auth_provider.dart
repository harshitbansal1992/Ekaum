import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/models/user_model.dart';

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    // Check for existing token and load user
    Future.microtask(() => _init());
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      // Check if we have a stored token
      final token = await ApiService.getToken();
      if (token != null) {
        // Try to get current user
        try {
          final userData = await ApiService.getCurrentUser();
          state = state.copyWith(
            user: AppUser.fromJson(userData),
            isLoading: false,
          );
          debugPrint('User auto-logged in: ${userData['email']}');
        } catch (e) {
          // Token might be invalid, clear it
          debugPrint('Token invalid, clearing: $e');
          await ApiService.logout();
          state = state.copyWith(user: null, isLoading: false);
        }
      } else {
        state = state.copyWith(user: null, isLoading: false);
      }
    } catch (e) {
      debugPrint('Auth init error: $e');
      state = state.copyWith(user: null, isLoading: false);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiService.login(email: email, password: password);
      final userData = response['user'] as Map<String, dynamic>;
      state = state.copyWith(
        user: AppUser.fromJson(userData),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      final userData = response['user'] as Map<String, dynamic>;
      state = state.copyWith(
        user: AppUser.fromJson(userData),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    await ApiService.logout();
    state = AuthState();
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    DateTime? dateOfBirth,
    String? timeOfBirth,
    String? placeOfBirth,
    String? fathersOrHusbandsName,
    String? gotra,
    String? caste,
  }) async {
    try {
      final userData = await ApiService.updateProfile(
        name: name,
        phone: phone,
        dateOfBirth: dateOfBirth,
        timeOfBirth: timeOfBirth,
        placeOfBirth: placeOfBirth,
        fathersOrHusbandsName: fathersOrHusbandsName,
        gotra: gotra,
        caste: caste,
      );
      state = state.copyWith(user: AppUser.fromJson(userData));
    } catch (e) {
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
