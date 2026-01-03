import 'package:equatable/equatable.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadStatistics extends StatisticsEvent {
  final int habitId;

  const LoadStatistics(this.habitId);

  @override
  List<Object?> get props => [habitId];
}


