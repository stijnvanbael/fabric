import 'package:pluralize/pluralize.dart';

extension Apply<T> on T {
  U apply<U>(U Function(T it) toApply) => toApply(this);

  U applyIf<U>(bool condition, U Function(T it) toApply) {
    if (condition) {
      return toApply(this);
    }
    return this as U;
  }
}

extension PluralString on String {
  static final Pluralize _pluralize = Pluralize();

  String get plural => _pluralize.plural(this);
}
