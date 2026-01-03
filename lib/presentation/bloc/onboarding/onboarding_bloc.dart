import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingInitial()) {
    on<OnboardingStarted>(_onOnboardingStarted);
    on<OnboardingCompleted>(_onOnboardingCompleted);
    on<OnboardingSkipped>(_onOnboardingSkipped);
  }

  Future<void> _onOnboardingStarted(
    OnboardingStarted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingInProgress(0));
  }

  Future<void> _onOnboardingCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingCompleted, true);
    emit(const OnboardingCompletedState());
  }

  Future<void> _onOnboardingSkipped(
    OnboardingSkipped event,
    Emitter<OnboardingState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingCompleted, true);
    emit(const OnboardingCompletedState());
  }

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;
  }
}

