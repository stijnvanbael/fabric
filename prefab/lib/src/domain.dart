class PagedResults<T> {
  final List<T> results;

  PagedResults(this.results);

  Map<String, dynamic> toJson() => {'results': results};
}
