import 'package:store/common/constants.dart';

import '../netclient.dart';

class ErrorReportRepository {
  final Net _net;

  ErrorReportRepository(this._net);

  Future<void> reportError(dynamic error, dynamic stackTrace) async {
    if (Helpers.isInDebugMode) {
    } else {
    }
  }

  _report(dynamic error, dynamic stackTrace) async {
//    final res = await _net.post(EndPoint.BUG_REPORT,body: )
  }

}