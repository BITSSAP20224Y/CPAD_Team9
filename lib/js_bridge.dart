@JS()
library js_bridge;

import 'package:js/js.dart';

@JS('runDetectionWithBase64')
external void runDetectionWithBase64(String base64Image);

@JS('flutter_inject_predictions')
external set flutterInjectPredictions(Function callback);
