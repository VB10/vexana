/// Manage your network layer with dio.
///
/// ## dio yeniden export'u hakkında
///
/// vexana'nın public API'si dio tiplerini doğrudan alıp döndürür
/// (`Response`, `Options`, `DioException`, `FormData`, `CancelToken`,
/// `Interceptor`, `Transformer`, `Headers` …). Bu yüzden dio'nun **kendi
/// küratörlüğünü yaptığı** `package:dio/dio.dart` yüzeyi olduğu gibi
/// yeniden export edilir.
///
/// `package:dio/src/...` altındaki private yollar **bilerek export edilmez**:
/// hepsi zaten `package:dio/dio.dart` içinde mevcut ve private yola bağlanmak
/// dio'nun minor sürümlerinde kırılmaya açıktır. Ayrıca dio, `dio_mixin.dart`'ı
/// `hide InterceptorState, InterceptorResultType` ile export eder; private
/// yoldan export etmek dio'nun kasten gizlediği iç tipleri sızdırıyordu.
library vexana;

export 'package:dio/dio.dart';

// CACHE
export 'src/cache/file/local_file.dart';
export 'src/cache/shared/local_preferences.dart';
export 'src/feature/no_network/index.dart';
export 'src/interface/index.dart';
// MODEL
export 'src/model/empty_model.dart';
export 'src/model/enum/request_type.dart';
export 'src/model/error_model.dart';
export 'src/model/network_result.dart';
export 'src/model/response_model.dart';
// NETWORK
export 'src/network_manager.dart';
