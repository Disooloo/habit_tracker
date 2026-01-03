import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}

class OnboardingSkipped extends OnboardingEvent {
  const OnboardingSkipped();
}


