import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:store/common/bloc_state_event.dart';
import 'package:store/common/constants/model.dart';


@immutable
abstract class ConstantsEvent extends BlocEvent {}

@immutable
abstract class ConstantsState extends BlocState {}

// STATES *******************************

class LoadingConstants extends ConstantsState {
  LoadingConstants();

  @override
  String toString() {
    return "STATE: loading";
  }
}

class LoadedConstants extends ConstantsState {
  final ConstantData constants;

  LoadedConstants(this.constants);

  @override
  String toString() {
    return "STATE: loaded";
  }
}

class FailedLoading extends ConstantsState {
  @override
  String toString() {
    return "STATE: failed";
  }
}

// EVENTS *******************************

class FetchConstants extends ConstantsEvent {
  @override
  String toString() {
    return "fetch";
  }
}
