extension Apply<T> on T {
  U applyIf<U>(bool condition, U Function(T it) toApply) {
    if (condition) {
      return toApply(this);
    }
    return this as U;
  }
}
