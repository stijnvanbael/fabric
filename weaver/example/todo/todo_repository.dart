import 'package:box/box.dart';
import 'package:fabric_metadata/fabric_metadata.dart';

import 'todo.dart';

@managed
class TodoRepository {
  final Box _box;

  TodoRepository(this._box);

  Future save(Todo todo) => _box.store(todo);

  Future<Todo?> findById(String id) => _box.find<Todo>(id);
}
