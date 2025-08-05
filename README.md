# HanQuant Frontend - Quantitative Trading Mobile App

[![Backend Repository](https://img.shields.io/badge/Backend_HanQuant-Open%20Repo-blue?style=for-the-badge&logo=github)](https://github.com/Paaaark/HanQuant)

[![Flutter](https://img.shields.io/badge/Flutter-3.2+-blue?style=flat-square&logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.2+-blue?style=flat-square&logo=dart)](https://dart.dev/)
[![Provider](https://img.shields.io/badge/Provider-State%20Management-orange?style=flat-square)](https://pub.dev/packages/provider)
[![WebSocket](https://img.shields.io/badge/WebSocket-Real--time%20Data-green?style=flat-square)](https://pub.dev/packages/web_socket_channel)
[![JWT](https://img.shields.io/badge/JWT-Authentication-red?style=flat-square)](https://pub.dev/packages/jwt_decoder)
[![AWS Lambda](https://img.shields.io/badge/AWS%20Lambda-Serverless-orange?style=flat-square&logo=amazon-aws)](https://aws.amazon.com/lambda/)
[![KIS API](https://img.shields.io/badge/KIS%20API-Trading%20Integration-purple?style=flat-square)](https://securities.koreainvestment.com/)
[![Material Design](https://img.shields.io/badge/Material%20Design-3-757575?style=flat-square&logo=material-design)](https://material.io/)

A sophisticated Flutter-based mobile application for quantitative trading and portfolio management, featuring real-time market data, automated trading strategies, and comprehensive portfolio analytics.

## Overview

HanQuant Frontend is a full-featured quantitative trading platform that provides institutional-grade tools for stock market analysis, portfolio management, and automated trading. Built with Flutter for cross-platform compatibility, the app integrates with Korean Investment & Securities (KIS) APIs for real-time market data and trading execution.

## Key Features

### Real-Time Market Data

- **Live Stock Tickers**: Real-time price updates via WebSocket connections
- **Market Indices**: KOSPI, KOSDAQ, and other major Korean market indices
- **Trending Stocks**: Top stocks by volume, fluctuation, and market cap
- **Stock Search**: Comprehensive search with company logos and real-time data

### Portfolio Management

- **Multi-Account Support**: Link multiple KIS trading accounts (real & mock)
- **Portfolio Analytics**: Real-time P&L tracking, total returns, and daily fluctuations
- **Holdings Overview**: Detailed position analysis with unrealized gains/losses
- **Account Switching**: Seamless toggle between real and paper trading accounts

### Authentication & Security

- **JWT Authentication**: Secure login with token-based session management
- **Account Linking**: Secure integration with KIS trading accounts
- **Session Management**: 10-minute auto-logout for security
- **Mock Trading**: Risk-free paper trading environment

### Trading Features

- **Watchlist Management**: Customizable stock watchlists with real-time updates
- **Strategy Framework**: Infrastructure for implementing trading strategies
- **Order Management**: Direct integration with KIS trading APIs
- **Risk Management**: Position sizing and portfolio diversification tools

### Server Management

- **Cloud Infrastructure**: AWS Lambda-powered server management
- **Auto-Scaling**: Intelligent server wake/sleep based on usage
- **Status Monitoring**: Real-time server status with 30-second health checks
- **Cost Optimization**: Automated server lifecycle management

## Architecture

### Frontend Architecture

```
lib/
├── app/                 # App configuration & navigation
├── pages/              # Main application screens
│   ├── home/           # Market overview & trending stocks
│   ├── market/         # Real-time market data & watchlists
│   ├── portfolio/      # Portfolio management & analytics
│   ├── strategy/       # Trading strategy framework
│   └── profile/        # User settings & account management
├── services/           # API & WebSocket services
├── providers/          # State management (Provider pattern)
├── models/             # Data models & serialization
├── widgets/            # Reusable UI components
└── utils/              # Utility functions & helpers
```

### Backend Integration

- **RESTful APIs**: Comprehensive API layer for all trading operations
- **WebSocket Streaming**: Real-time market data via persistent connections
- **JWT Authentication**: Secure token-based authentication
- **Error Handling**: Robust error management with user-friendly messages

## Tech Stack

### Frontend

- **Flutter 3.2+**: Cross-platform mobile development
- **Dart**: Modern programming language with strong typing
- **Provider**: State management solution
- **Riverpod**: Advanced dependency injection
- **Material Design 3**: Modern UI/UX components

### Backend Services

- **KIS Trading APIs**: Korean Investment & Securities integration
- **WebSocket**: Real-time data streaming
- **JWT**: Secure authentication
- **AWS Lambda**: Serverless infrastructure management

### Data & Storage

- **Hive**: Local data persistence
- **SharedPreferences**: User settings storage
- **JSON Serialization**: Efficient data parsing
- **CSV Integration**: Market data import/export

### Development Tools

- **Flutter Lints**: Code quality enforcement
- **Build Runner**: Code generation for models
- **JSON Annotation**: Type-safe JSON handling
- **Hive Generator**: Database code generation

## Getting Started

### Prerequisites

- Flutter SDK 3.2.3 or higher
- Dart SDK 3.2.3 or higher
- Android Studio / VS Code
- KIS Trading Account (for live trading)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/hanquant_frontend.git
   cd hanquant_frontend
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run code generation**

   ```bash
   flutter packages pub run build_runner build
   ```

4. **Launch the app**
   ```bash
   flutter run
   ```

### Configuration

1. **KIS Account Setup**: Link your KIS trading account in the Profile section
2. **API Keys**: Configure your KIS API credentials
3. **Server Management**: Use the built-in server controls to manage the backend

## Screenshots

_Screenshots coming soon - showcasing the modern UI and comprehensive trading features_

## Development

### Project Structure

The app follows a clean architecture pattern with clear separation of concerns:

- **Presentation Layer**: Pages and widgets for UI
- **Business Logic**: Providers and services for state management
- **Data Layer**: Models and API services for data handling

### Key Components

#### Real-Time Data Streaming

```dart
// WebSocket service for live market data
WebSocketService().subscribe(['005930', '000660']); // Samsung, SK Hynix
```

#### Portfolio Management

```dart
// Multi-account portfolio tracking
final portfolio = await ApiService.getPortfolio(
  token: authToken,
  accountId: 'account123'
);
```

#### Server Management

```dart
// Intelligent server lifecycle management
await ApiService.startServer();  // Wake up server
await ApiService.stopServer();   // Sleep server for cost optimization
```

## Use Cases

### For Individual Traders

- Real-time market monitoring
- Portfolio tracking and analytics
- Paper trading for strategy testing
- Multi-account management

### For Quantitative Analysts

- Strategy backtesting framework
- Real-time data feeds
- Automated trading execution
- Risk management tools

### For Financial Institutions

- Multi-user account management
- Institutional-grade security
- Scalable infrastructure
- Comprehensive audit trails

## Security Features

- **JWT Token Management**: Secure session handling
- **API Key Encryption**: Secure storage of trading credentials
- **Session Timeout**: Automatic logout for security
- **Error Handling**: Secure error messages without data leakage

## Performance Optimizations

- **Caching**: Intelligent data caching for better performance
- **Lazy Loading**: Efficient resource management
- **WebSocket Optimization**: Minimal data transfer for real-time updates
- **Memory Management**: Efficient state management and cleanup

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Links

- **Backend Repository**: [HanQuant](https://github.com/Paaaark/HanQuant)
- **API Documentation**: [Coming Soon]
- **Trading Strategy Examples**: [Coming Soon]

---

**Built with Flutter and modern web technologies**
