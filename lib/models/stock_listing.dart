class StockListing {
  final String code;
  final String isin;
  final String name;
  final String securityType;
  final String capSize;
  final String indLarge;
  final String indMedium;
  final String indSmall;
  final double marketCap; // Market cap in hundred million KRW

  StockListing({
    required this.code,
    required this.isin,
    required this.name,
    required this.securityType,
    required this.capSize,
    required this.indLarge,
    required this.indMedium,
    required this.indSmall,
    required this.marketCap,
  });

  // Helper getter for market cap score (higher is better)
  int get marketCapScore {
    switch (capSize) {
      case '1': // 대형
        return 3;
      case '2': // 중형
        return 2;
      case '3': // 소형
        return 1;
      default:
        return 0;
    }
  }

  // Helper getter for security type score (higher is better)
  int get securityTypeScore {
    switch (securityType) {
      case 'ST': // 주권
      case 'EW': // ELW
      case 'EF': // ETF
        return 3;
      case 'DR': // 주식예탁증서
        return 2;
      default:
        return 1;
    }
  }

  // Helper getter for total relevance score
  int get relevanceScore => marketCapScore + securityTypeScore;

  factory StockListing.fromCsv(List<String> row) {
    // Parse market cap with fallback to 0.0
    double parseMarketCap(String? value) {
      if (value == null || value.isEmpty) return 0.0;
      return double.tryParse(value) ?? 0.0;
    }

    return StockListing(
      code: row[0], // Keep as string to preserve leading zeros
      isin: row[1],
      name: row[2],
      securityType: row[3],
      capSize: row[4],
      indLarge: row[5],
      indMedium: row[6],
      indSmall: row[7],
      marketCap: parseMarketCap(row[8]),
    );
  }

  @override
  String toString() => '$name ($code)';
}
