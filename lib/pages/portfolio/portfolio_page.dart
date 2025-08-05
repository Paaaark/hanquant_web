import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login/login_page.dart';
import '../../services/api_service.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../home/home_page.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});
  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  List<Map<String, dynamic>> _accounts = [];
  bool _loadingAccounts = false;
  String? _accountsError;
  bool _showMock = false;
  String? _selectedAccountId;
  Map<String, dynamic>? _portfolio;
  bool _loadingPortfolio = false;
  String? _portfolioError;
  String? _lastViewedAccountId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn || auth.token == null) return;
    setState(() {
      _loadingAccounts = true;
      _accountsError = null;
    });
    try {
      final accounts = await ApiService.getLinkedAccounts(auth.token!);
      setState(() {
        _accounts = accounts;
      });
      _setDefaultAccount();
    } catch (e) {
      setState(() {
        _accountsError = e.toString();
      });
    } finally {
      setState(() {
        _loadingAccounts = false;
      });
    }
  }

  void _setDefaultAccount() {
    final filtered =
        _accounts.where((a) => (a['is_mock'] ?? false) == _showMock).toList();
    if (filtered.isEmpty) {
      setState(() {
        _selectedAccountId = null;
        _portfolio = null;
      });
      return;
    }
    final lastViewed =
        filtered.any((a) => a['account_id'] == _lastViewedAccountId)
            ? _lastViewedAccountId
            : filtered.first['account_id'];
    setState(() {
      _selectedAccountId = lastViewed;
    });
    _fetchPortfolio(lastViewed!);
  }

  Future<void> _fetchPortfolio(String accountId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _loadingPortfolio = true;
      _portfolioError = null;
      _portfolio = null;
    });
    try {
      final data = await ApiService.getPortfolio(
          token: auth.token!, accountId: accountId);
      setState(() {
        _portfolio = data;
        _lastViewedAccountId = accountId;
      });
    } catch (e) {
      setState(() {
        _portfolioError = e.toString();
      });
    } finally {
      setState(() {
        _loadingPortfolio = false;
      });
    }
  }

  Color _returnColor(String? value) {
    if (value == null) return Colors.grey;
    final v = double.tryParse(value.replaceAll('%', '')) ?? 0.0;
    if (v > 0) return Colors.green;
    if (v < 0) return Colors.red;
    return Colors.grey;
  }

  Widget _toggleButton() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleOption('Real', !_showMock, () {
            if (_showMock)
              setState(() {
                _showMock = false;
                _setDefaultAccount();
              });
          }),
          _toggleOption('Mock', _showMock, () {
            if (!_showMock)
              setState(() {
                _showMock = true;
                _setDefaultAccount();
              });
          }),
        ],
      ),
    );
  }

  Widget _toggleOption(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isLoggedIn) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
              auth.checkLoginStatus();
            },
            child: const Text('Login to access Portfolio'),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loadingAccounts
            ? const Center(child: CircularProgressIndicator())
            : _accountsError != null
                ? Center(
                    child: Text(_accountsError!,
                        style: const TextStyle(color: Colors.red)))
                : _buildPortfolioContent(),
      ),
    );
  }

  Widget _buildPortfolioContent() {
    final filteredAccounts =
        _accounts.where((a) => (a['is_mock'] ?? false) == _showMock).toList();
    if (filteredAccounts.isEmpty) {
      return const Center(child: Text('No accounts found for this type.'));
    }
    final summary = _portfolio?['Summary'] as Map<String, dynamic>?;
    final totalReturn = (summary?['TotalUnrealizedPnl'] != null &&
            summary?['TotalPurchaseAmount'] != null)
        ? (double.parse(summary!['TotalUnrealizedPnl']) /
                double.parse(summary['TotalPurchaseAmount']))
            .toStringAsFixed(2)
        : '-';
    final dailyReturn =
        summary?['AssetChangeRate'] ?? summary?['AssetChangeAmount'] ?? '-';
    final netAsset = summary?['NetAsset'] ?? '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Balance: ${_formatKRW(netAsset)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Return (Total/Daily): '),
                      Text(
                        '$totalReturn%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _returnColor(totalReturn),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($dailyReturn%)',
                        style: TextStyle(
                          color: _returnColor(dailyReturn).withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _toggleButton(),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Select Account: '),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _selectedAccountId,
              items: filteredAccounts
                  .map((acc) => DropdownMenuItem<String>(
                        value: acc['account_id'],
                        child: Text(acc['account_id'] ?? ''),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedAccountId = val;
                  });
                  _fetchPortfolio(val);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _loadingPortfolio
              ? const Center(child: CircularProgressIndicator())
              : _portfolioError != null
                  ? Text(_portfolioError!,
                      style: const TextStyle(color: Colors.red))
                  : _buildHoldingsList(),
        ),
      ],
    );
  }

  Widget _buildHoldingsList() {
    final positions = _portfolio?['Positions'] as List<dynamic>?;
    if (positions == null || positions.isEmpty) {
      return const Center(child: Text('No holdings found.'));
    }
    return ListView.separated(
      itemCount: positions.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final pos = positions[index] as Map<String, dynamic>;
        final symbol = pos['Symbol'] ?? '';
        final name = pos['Name'] ?? '';
        final qty = pos['HoldingQty'] ?? '-';
        final price = pos['CurrentPrice'] ?? '-';
        final totalReturn = pos['UnrealizedPnlRate'] ??
            pos['UnrealizedPnl'] / pos['TotalPurchaseAmount'] ??
            '-';
        final dailyReturn = double.parse(
          pos['FluctuationRate']?.toString() ??
              (Random().nextDouble() * 2 - 1).toString(),
        ).toStringAsFixed(2);
        return ListTile(
          dense: true,
          leading:
              SizedBox(width: 40, height: 40, child: buildAvatar(symbol, name)),
          title: Text('$name', maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('Qty: $qty  Price:  ${_formatKRW(price)}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$totalReturn%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _returnColor(totalReturn),
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '($dailyReturn%)',
                style: TextStyle(
                  color: _returnColor(dailyReturn).withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _formatKRW(String value) {
  try {
    final number = double.parse(value);
    return '${NumberFormat('#,###').format(number)} ₩';
  } catch (e) {
    return '$value ₩';
  }
}
