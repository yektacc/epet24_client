import 'package:bloc/bloc.dart';
import 'package:store/common/constants/constants_repository.dart';
import 'package:store/common/constants/constants_event_state.dart';
import 'package:store/common/constants/model.dart';
import 'package:store/common/log/log.dart';

class ConstantsBloc extends Bloc<ConstantsEvent, ConstantsState> {
  final ConstantsRepository _repository;

  @override
  void onEvent(ConstantsEvent event) {
    print("CONSTANTS_BLOC: new event: $event");
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    print(error);
    print(stacktrace);
  }

  ConstantsBloc(this._repository);

  @override
  ConstantsState get initialState {
    return LoadingConstants();
  }

  @override
  Stream<ConstantsState> mapEventToState(ConstantsEvent event) async* {
    if (event is FetchConstants) {
      try {
        yield LoadingConstants();
        var snapshot = await _repository.fetch();
        if (snapshot is ConstantData ) {
          yield LoadedConstants(snapshot);
        } else {
          yield FailedLoading();
          Nik.e("failed: constants response from repository is empty");
        }
      } catch (e, stacktrace) {
        print("CONSTANTS_BLOC: failure: " + e.toString());
        print(stacktrace);
        yield FailedLoading();
      }
    }
  }
}
