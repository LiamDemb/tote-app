import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tote_app/services/api_service.dart';
import 'package:tote_app/services/user_service.dart';
import 'package:tote_app/theme/index.dart';
import 'package:http/http.dart' as http;
import 'package:tote_app/config/api_config.dart';

/// A screen for diagnosing API connectivity issues
class ApiDiagnosticScreen extends ConsumerStatefulWidget {
  const ApiDiagnosticScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ApiDiagnosticScreen> createState() => _ApiDiagnosticScreenState();
}

class _ApiDiagnosticScreenState extends ConsumerState<ApiDiagnosticScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _diagnosticResults;
  
  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }
  
  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final results = await ApiService.checkApiStatus();
      setState(() {
        _diagnosticResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _diagnosticResults = {
          'error': e.toString(),
          'success': false,
        };
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showConnectionSettings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildDiagnosticResults(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _runDiagnostics,
        child: const Icon(Icons.refresh),
      ),
    );
  }
  
  void _showConnectionSettings() {
    final TextEditingController controller = TextEditingController(
      text: ApiConfig.baseUrl,
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Connection Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current API URL:',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              ApiConfig.baseUrl,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Set Custom API URL',
                hintText: 'http://localhost:5000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final url = controller.text.trim();
                    if (url.isNotEmpty) {
                      await ApiConfig.setManualOverrideUrl(url);
                      Navigator.pop(context);
                      _runDiagnostics();
                    }
                  },
                  child: const Text('Set URL'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await ApiConfig.setManualOverrideUrl(null);
                    Navigator.pop(context);
                    _runDiagnostics();
                  },
                  child: const Text('Reset to Default'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _testDirectConnection();
              },
              child: const Text('Test Direct Connection'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _testDirectConnection() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Try a direct HTTP request to the server
      final client = http.Client();
      final url = '${ApiConfig.baseUrl}/health';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Testing direct connection to $url')),
      );
      
      try {
        final response = await client.get(Uri.parse(url))
            .timeout(const Duration(seconds: 5));
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Response: ${response.statusCode} - ${response.body}',
            ),
            duration: const Duration(seconds: 10),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
          ),
        );
      } finally {
        client.close();
      }
    } finally {
      // Run normal diagnostics
      _runDiagnostics();
    }
  }
  
  Widget _buildDiagnosticResults() {
    if (_diagnosticResults == null) {
      return const Center(
        child: Text('No diagnostic results available'),
      );
    }
    
    final success = _diagnosticResults!['success'] == true;
    final dbConnected = _diagnosticResults!['dbConnected'] == true;
    final platform = _diagnosticResults!['platform'] ?? 'unknown';
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Platform info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  platform == 'web' ? Icons.web : Icons.phone_android,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Platform: ${platform.toUpperCase()}',
                        style: AppTypography.titleMedium,
                      ),
                      Text(
                        'Running on ${platform == 'web' ? 'browser' : 'native device'}',
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Overall status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: success ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        success ? 'API Connection Successful' : 'API Connection Failed',
                        style: AppTypography.titleMedium,
                      ),
                      if (!success && _diagnosticResults!.containsKey('error'))
                        Text(
                          _diagnosticResults!['error'].toString(),
                          style: AppTypography.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Database status
          if (_diagnosticResults!.containsKey('dbConnected'))
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dbConnected ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    dbConnected ? Icons.check_circle : Icons.error,
                    color: dbConnected ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dbConnected ? 'Database Connected' : 'Database Connection Failed',
                          style: AppTypography.titleMedium,
                        ),
                        if (_diagnosticResults!.containsKey('userCount'))
                          Text(
                            'Users in database: ${_diagnosticResults!['userCount']}',
                            style: AppTypography.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Base URL
          Text('Base URL', style: AppTypography.titleSmall),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            width: double.infinity,
            child: Text(_diagnosticResults!['baseUrl'] ?? 'Not available'),
          ),
          
          const SizedBox(height: 24),
          
          // Health endpoint
          if (_diagnosticResults!.containsKey('healthEndpoint'))
            _buildEndpointResult('Health Endpoint', _diagnosticResults!['healthEndpoint']),
          
          const SizedBox(height: 16),
          
          // DB Test endpoint
          if (_diagnosticResults!.containsKey('dbTestEndpoint'))
            _buildEndpointResult('Database Test Endpoint', _diagnosticResults!['dbTestEndpoint']),
          
          const SizedBox(height: 16),
          
          // Users endpoint
          if (_diagnosticResults!.containsKey('usersEndpoint'))
            _buildEndpointResult('Users Endpoint', _diagnosticResults!['usersEndpoint']),
          
          const SizedBox(height: 24),
          
          // Timestamp
          Text('Timestamp', style: AppTypography.bodySmall),
          Text(_diagnosticResults!['timestamp'] ?? 'Not available'),
        ],
      ),
    );
  }
  
  Widget _buildEndpointResult(String title, Map<String, dynamic> result) {
    final success = result['success'] == true;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(title, style: AppTypography.titleSmall),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (result.containsKey('statusCode'))
                Text('Status Code: ${result['statusCode']}'),
              if (result.containsKey('body'))
                Text('Response: ${result['body']}'),
              if (result.containsKey('error'))
                Text('Error: ${result['error']}'),
            ],
          ),
        ),
      ],
    );
  }
} 