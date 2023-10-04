import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:fabric_prefab_example/todo/todo_controller.dart';
import 'package:recase/recase.dart';

part 'todo.g.dart';
part 'todo.prefab.g.dart';

@Prefab(useCases: {
  create,
  getByKey,
  search
}, controllerMixins: {
  TodoController,
}) // Move create to the constructor, also allow create on factory methods
class Todo {
  @key
  final String id;
  final String description;
  final bool done;
  final DateTime created;

  Todo({
    String? id,
    required this.description,
    this.done = false,
    DateTime? created,
  })  : this.id = id ?? description.replaceAll(RegExp(r'\W+'), '-').paramCase,
        this.created = created ?? DateTime.now();

  @Update(Post('/done'))
  Todo markAsDone() => copy(done: true);

  @Update(Put('/description'))
  Todo updateDescription(String description) => copy(description: description);

  // Bad example: does not have Todo as return type, assumed it mutates the entity
  @Update(Post('/clueless'))
  void noClue() {}

  static Todo fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}
