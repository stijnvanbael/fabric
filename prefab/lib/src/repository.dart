import 'package:fabric_prefab/fabric_prefab.dart';

extension QueryStepExtension<T> on QueryStep<T> {
  QueryStep<T> filterWith(List<Enum> fields, List<dynamic> values) {
    final filterFields = fields
        .map((field) {
          final value = values[fields.indexOf(field)];
          return (field, value);
        })
        .where((e) => e.$2 != null)
        .toList();
    if (filterFields.isEmpty) {
      return this;
    }
    final queryStep =
        where(filterFields.first.$1.name).equals(filterFields.first.$2);
    return filterFields
        .skip(1)
        .fold(queryStep, (q, e) => q.and(e.$1.name).equals(e.$2));
  }

  ExpectationStep<T> orderByWith(Enum? field, SortDirection sortDirection) {
    if (field != null) {
      final orderByStep = orderBy(field.name);
      return sortDirection == SortDirection.ascending
          ? orderByStep.ascending()
          : orderByStep.descending();
    }
    return this;
  }
}
