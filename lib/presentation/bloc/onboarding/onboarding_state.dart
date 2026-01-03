import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingInProgress extends OnboardingState {
  final int currentPage;

  const OnboardingInProgress(this.currentPage);

  @override
  List<Object?> get props => [currentPage];
}

class OnboardingCompletedState extends OnboardingState {
  const OnboardingCompletedState();
}

