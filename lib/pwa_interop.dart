import 'dart:js_interop';

@JS('installPWA')
external JSPromise installPWA();

@JS('isPWAInstalled')
external bool isPWAInstalled();

@JS('isPWAPromptReady')
external bool isPWAPromptReady();
