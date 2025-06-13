class IndexSummary {
  final String indexName;
  final String changeRate;
  final bool isChangePositive;
  final String currentPrice;
  final String high;
  final String low;

  IndexSummary({
    required this.indexName,
    required this.changeRate,
    required this.isChangePositive,
    required this.currentPrice,
    required this.high,
    required this.low,
  });
}
