@JS()
library pwa_interop;

import 'package:js/js.dart';

@JS('installPWA')
external dynamic installPWA();

@JS('isPWAInstalled')
external bool isPWAInstalled();

@JS('isPWAPromptReady')
external bool isPWAPromptReady();
