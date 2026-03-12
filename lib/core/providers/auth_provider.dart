import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthState {
  final bool isAuthenticated;
  final String? error;

  AuthState({
    required this.isAuthenticated,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  static const String _boxName = 'auth_box';
  static const String _authKey = 'is_authenticated';
  static const String _passwordKey = 'app_password';
  static const String _defaultPassword = '123456';

  late Box _box;
  bool _initialized = false;

  AuthNotifier() : super(AuthState(isAuthenticated: false)) {
    _initBox();
  }

  Future<void> _initBox() async {
    if (_initialized) return;
    try {
      _box = await Hive.openBox(_boxName);
      final isAuth = _box.get(_authKey, defaultValue: false) as bool;
      state = state.copyWith(isAuthenticated: isAuth);
      _initialized = true;
    } catch (e) {
      state = state.copyWith(error: '初始化失败: $e');
    }
  }

  Future<bool> authenticate(String password) async {
    try {
      await _initBox();
      final storedPassword = _box.get(_passwordKey, defaultValue: _defaultPassword) as String;

      if (password == storedPassword) {
        await _box.put(_authKey, true);
        state = state.copyWith(isAuthenticated: true, error: null);
        return true;
      } else {
        state = state.copyWith(error: '密码错误');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '认证失败: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _initBox();
      await _box.put(_authKey, false);
      state = state.copyWith(isAuthenticated: false, error: null);
    } catch (e) {
      state = state.copyWith(error: '登出失败: $e');
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      await _initBox();
      final storedPassword = _box.get(_passwordKey, defaultValue: _defaultPassword) as String;

      if (oldPassword != storedPassword) {
        state = state.copyWith(error: '旧密码错误');
        return false;
      }

      await _box.put(_passwordKey, newPassword);
      state = state.copyWith(error: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: '修改密码失败: $e');
      return false;
    }
  }

  Future<void> resetPassword() async {
    try {
      await _initBox();
      await _box.put(_passwordKey, _defaultPassword);
    } catch (e) {
      state = state.copyWith(error: '重置密码失败: $e');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
