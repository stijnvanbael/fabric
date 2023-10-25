import 'dart:html';

import 'package:fabric_prefab/src/frontend/basic/shoelace.dart';

void initPrefab() {
  final addButton = querySelector('.add-button');
  final addDialog = querySelector('.add-dialog') as SlDialog;
  final addDialogCloseButton = querySelector('.add-dialog .cancel');
  addButton?.onClick.listen((event) => addDialog.show());
  addDialogCloseButton?.onClick.listen((event) => addDialog.hide());
}
