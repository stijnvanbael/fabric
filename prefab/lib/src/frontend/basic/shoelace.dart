@JS("shoelace")
library shoelace;

import 'dart:js_interop';

@JS()
@staticInterop
class SlDialog {}

extension SlDialogMethods on SlDialog {
  external void show();

  external void hide();
}
