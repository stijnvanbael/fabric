import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:recase/recase.dart';

part 'todo.g.dart';
part 'todo.prefab.g.dart';

@Prefab(useCases: {create, getByKey})
class Todo {
  @key
  final String id;
  final String description;
  final bool done;

  Todo({
    String? id,
    required this.description,
    this.done = false,
  }) : this.id = id ?? description.paramCase;

  @UseCase(Post('/done'))
  Todo markAsDone() => copy(done: true);

  static Todo fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}
