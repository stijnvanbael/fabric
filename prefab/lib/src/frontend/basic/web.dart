import 'dart:html';

import 'package:fabric_prefab/src/frontend/basic/shoelace.dart';

void initPrefab() {
  final addButton = querySelector('.add-button');
  final addDialog = querySelector('.add-dialog') as SlDialog;
  final addDialogCancelButton = querySelector('.add-dialog .cancel');
  final addDialogAddButton = querySelector('.add-dialog .add');
  final addForm = querySelector('.add-dialog form') as FormElement;
  addButton?.onClick.listen((event) => addDialog.show());
  addDialogCancelButton?.onClick.listen((event) => addDialog.hide());
  addDialogAddButton?.onClick.listen((event) {
    _addEntity(addForm);
    addDialog.hide();
  });
}

void _addEntity(FormElement form) {
  final formData = FormData(form);
  // TODO: we need a client-side registry to look up values with their respective types and validate.
}
