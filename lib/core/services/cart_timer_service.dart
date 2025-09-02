import 'dart:async';
 
import 'package:shared_preferences/shared_preferences.dart';
 
class CartTimerService {
  static const String _timerStartKey = 'cart_timer_start';
  static const String _timerDurationKey = 'cart_timer_duration';
  static const String _isTimerActiveKey = 'cart_timer_active';
  static const int _timerDurationMinutes = 10;
  static const int _timerDurationSeconds = _timerDurationMinutes * 60;
 
  static final CartTimerService _instance = CartTimerService._internal();
  factory CartTimerService() => _instance;
  CartTimerService._internal();
 
  Timer? _timer;
  DateTime? _startTime;
  int _remainingSeconds = _timerDurationSeconds;
  bool _isActive = false;
  final StreamController<int> _timerController =
      StreamController<int>.broadcast();
  final StreamController<bool> _timerStatusController =
      StreamController<bool>.broadcast();
  final StreamController<void> _timerExpiredController =
      StreamController<void>.broadcast();
 
  Stream<int> get timerStream => _timerController.stream;
  Stream<bool> get timerStatusStream => _timerStatusController.stream;
  Stream<void> get timerExpiredStream => _timerExpiredController.stream;
  bool get isActive => _isActive;
  int get remainingSeconds => _remainingSeconds;
  DateTime? get startTime => _startTime;
 
  Future<void> initialize() async {
    await _loadTimerState();
    if (_isActive && _startTime != null) {
      _calculateRemainingTime();
      if (_remainingSeconds > 0) {
        _startTimer();
        _timerStatusController.add(true);
      } else {
        await _clearTimer();
        _timerExpiredController.add(null);
      }
    }
  }
 
  Future<void> startTimer() async {
    if (_isActive) {
      print('CartTimerService: Timer already active, skipping start');
      return;
    }
 
    _startTime = DateTime.now().toUtc(); // Use UTC to avoid timezone issues
    _remainingSeconds = _timerDurationSeconds;
    _isActive = true;
 
    await _saveTimerState();
    _startTimer();
    _timerStatusController.add(true);
 
    print('CartTimerService: Timer started at ${_startTime}');
  }
 
  Future<void> startTestTimer() async {
    if (_isActive) {
      print('CartTimerService: Timer already active, skipping test start');
      return;
    }
 
    _startTime = DateTime.now().toUtc();
    _remainingSeconds = 30; // 30 seconds for testing
    _isActive = true;
 
    await _saveTimerState();
    _startTimer();
    _timerStatusController.add(true);
 
    print(
        'CartTimerService: Test timer started at ${_startTime} with 30 seconds');
  }
 
  Future<void> stopTimer() async {
    if (!_isActive) return;
    _timer?.cancel();
    await _clearTimer();
    _timerStatusController.add(false);
 
    print('CartTimerService: Timer stopped and cleared');
  }
 
  Future<void> clearTimer() async {
    await _clearTimer();
    print('CartTimerService: Timer state cleared');
  }
 
  Future<void> forceReset() async {
    _timer?.cancel();
    _isActive = false;
    _startTime = null;
    _remainingSeconds = _timerDurationSeconds;
    await _clearTimer();
    _timerStatusController.add(false);
    print('CartTimerService: Timer force reset');
  }
 
  String getFormattedTime() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
 
  bool get isExpired => _remainingSeconds <= 0;
 
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _timerController.add(_remainingSeconds);
 
        if (_remainingSeconds <= 0) {
          timer.cancel();
          _handleTimerExpired();
        }
      }
    });
  }
 
  void _handleTimerExpired() {
    print('CartTimerService: Timer expired - triggering cart clear');
    _isActive = false;
    _timerStatusController.add(false);
    _timerController.add(0);
    _timerExpiredController.add(null);
    _clearTimer();
  }
 
  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timerStartKey, _startTime?.toIso8601String() ?? '');
    await prefs.setInt(_timerDurationKey, _timerDurationSeconds);
    await prefs.setBool(_isTimerActiveKey, _isActive);
  }
 
  Future<void> _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeString = prefs.getString(_timerStartKey);
    _isActive = prefs.getBool(_isTimerActiveKey) ?? false;
 
    if (startTimeString != null && startTimeString.isNotEmpty) {
      try {
        _startTime = DateTime.parse(startTimeString).toUtc();
      } catch (e) {
        print('CartTimerService: Error parsing start time: $e');
        _startTime = null;
        _isActive = false;
        await _clearTimer();
      }
    }
  }
 
  void _calculateRemainingTime() {
    if (_startTime == null) {
      _remainingSeconds = 0;
      _isActive = false;
      return;
    }
 
    final elapsed = DateTime.now().toUtc().difference(_startTime!).inSeconds;
    _remainingSeconds = _timerDurationSeconds - elapsed;
 
    if (_remainingSeconds < 0) {
      _remainingSeconds = 0;
      _isActive = false;
    }
  }
 
  Future<void> _clearTimer() async {
    _timer?.cancel();
    _isActive = false;
    _startTime = null;
    _remainingSeconds = _timerDurationSeconds;
 
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_timerStartKey);
    await prefs.remove(_timerDurationKey);
    await prefs.remove(_isTimerActiveKey);
  }
 
  void dispose() {
    _timer?.cancel();
    _timerController.close();
    _timerStatusController.close();
    _timerExpiredController.close();
  }
}
 
 