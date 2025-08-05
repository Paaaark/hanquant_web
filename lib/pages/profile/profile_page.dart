import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login/login_page.dart';
import '../../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, dynamic>> _accounts = [];
  bool _loadingAccounts = false;
  String? _accountsError;
  String _serverStatus = 'unknown';
  bool _loadingServerStatus = false;
  bool _startingServer = false;
  bool _stoppingServer = false;

  @override
  void initState() {
    super.initState();
    _checkServerStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchAccounts();
  }

  Future<void> _checkServerStatus() async {
    setState(() {
      _loadingServerStatus = true;
    });
    try {
      final status = await ApiService.getServerStatus();
      setState(() {
        _serverStatus = status;
      });
    } catch (e) {
      setState(() {
        _serverStatus = 'error';
      });
    } finally {
      setState(() {
        _loadingServerStatus = false;
      });
    }
  }

  Future<void> _startServer() async {
    setState(() {
      _startingServer = true;
    });
    try {
      await ApiService.startServer();
      // Wait 30 seconds then check status
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted) {
          _checkServerStatus();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start server: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _startingServer = false;
      });
    }
  }

  Future<void> _stopServer() async {
    setState(() {
      _stoppingServer = true;
    });
    try {
      await ApiService.stopServer();
      // Wait 30 seconds then check status
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted) {
          _checkServerStatus();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop server: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _stoppingServer = false;
      });
    }
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

  Widget _buildServerManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        const Text('Server Management',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Server Status: '),
            _loadingServerStatus
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_serverStatus),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _serverStatus,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
            const Spacer(),
            IconButton(
              onPressed: _loadingServerStatus ? null : _checkServerStatus,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _startingServer || _serverStatus == 'running'
                    ? null
                    : _startServer,
                icon: _startingServer
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.play_arrow),
                label: Text(_startingServer ? 'Starting...' : 'Start Server'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _stoppingServer || _serverStatus == 'stopped'
                    ? null
                    : _stopServer,
                icon: _stoppingServer
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.stop),
                label: Text(_stoppingServer ? 'Stopping...' : 'Stop Server'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return Colors.green;
      case 'stopped':
        return Colors.red;
      case 'starting':
      case 'stopping':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                    auth.checkLoginStatus();
                  },
                  child: const Text('Login to access Profile'),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              _buildServerManagement(),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Hello! ${auth.username ?? ''}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      await auth.logout();
                      setState(() {});
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Linked Bank Accounts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_loadingAccounts)
                const Center(child: CircularProgressIndicator()),
              if (_accountsError != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_accountsError!,
                      style: const TextStyle(color: Colors.red)),
                ),
              if (!_loadingAccounts &&
                  _accounts.isEmpty &&
                  _accountsError == null)
                const Text('No accounts linked.'),
              if (!_loadingAccounts && _accounts.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _accounts.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final acc = _accounts[index];
                    return ListTile(
                      title: Text(acc['account_id'] ?? ''),
                      subtitle: Text(
                          'CANO: ${acc['enc_cano'] ?? ''}${acc['is_mock'] == true ? ' (Mock)' : ''}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteAccount(acc['id'] as int),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadingAccounts ? null : _showLinkAccountDialog,
                icon: const Icon(Icons.add),
                label: const Text('Link New Bank Account'),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const Text('Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const ListTile(
                leading: Icon(Icons.settings),
                title: Text('Notification Preferences'),
                subtitle: Text('Manage your notifications'),
              ),
              const ListTile(
                leading: Icon(Icons.lock),
                title: Text('Change Password'),
                subtitle: Text('Update your password'),
              ),
              _buildServerManagement(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLinkAccountDialog() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final accountIdController = TextEditingController();
    final appKeyController = TextEditingController();
    final appSecretController = TextEditingController();
    final canoController = TextEditingController();
    bool isMock = false;
    bool loading = false;
    String? error;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Link Bank Account'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: accountIdController,
                      decoration:
                          const InputDecoration(labelText: 'Account ID'),
                    ),
                    TextField(
                      controller: appKeyController,
                      decoration: const InputDecoration(labelText: 'App Key'),
                    ),
                    TextField(
                      controller: appSecretController,
                      decoration:
                          const InputDecoration(labelText: 'App Secret'),
                    ),
                    TextField(
                      controller: canoController,
                      decoration: const InputDecoration(labelText: 'CANO'),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: isMock,
                          onChanged: (v) => setState(() => isMock = v ?? false),
                        ),
                        const Text('Mock Account'),
                      ],
                    ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(error!,
                            style: const TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: loading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          setState(() => loading = true);
                          try {
                            await ApiService.linkBankAccount(
                              token: auth.token!,
                              accountId: accountIdController.text,
                              appKey: appKeyController.text,
                              appSecret: appSecretController.text,
                              cano: canoController.text,
                              isMock: isMock,
                            );
                            if (mounted) Navigator.pop(context);
                            _fetchAccounts();
                          } catch (e) {
                            setState(() {
                              error = e.toString();
                              loading = false;
                            });
                          }
                        },
                  child: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Link'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAccount(int id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _loadingAccounts = true);
    try {
      await ApiService.deleteBankAccount(token: auth.token!, id: id);
      _fetchAccounts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
      setState(() => _loadingAccounts = false);
    }
  }
}
