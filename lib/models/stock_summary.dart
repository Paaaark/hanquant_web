class StockSummary {
  final String logoUrl; // optional for now
  final String stockName;
  final String stockCode;
  final String changePercentage;
  final String currentPrice;
  final String volume;
  final String marketCap;

  StockSummary({
    required this.logoUrl,
    required this.stockName,
    required this.stockCode,
    required this.changePercentage,
    required this.currentPrice,
    required this.volume,
    required this.marketCap,
  });
}
