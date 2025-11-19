// lib/features/dev_tools/dev_tools_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ekaplus_ekatunggal/constant.dart';

class DevToolsPage extends StatefulWidget {
  const DevToolsPage({Key? key}) : super(key: key);

  @override
  State<DevToolsPage> createState() => _DevToolsPageState();
}

class _DevToolsPageState extends State<DevToolsPage> {
  String _jsonContent = '';
  String _filePath = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/users_data.json');
      
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          _jsonContent = content;
          _filePath = file.path;
          _isLoading = false;
        });
      } else {
        setState(() {
          _jsonContent = 'File not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _jsonContent = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _shareFile() async {
    try {
      final file = File(_filePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(_filePath)],
          subject: 'Users Data Export',
          text: 'Export users data untuk development',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _jsonContent));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ JSON copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Dev Tools - Export Users',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Instructions
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '📱 How to Export',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('1. Click "Share File"'),
                      Text('2. Share via Gmail/WhatsApp/Drive'),
                      Text('3. Copy JSON di PC/Laptop'),
                      Text('4. Paste ke: assets/data/users.json'),
                    ],
                  ),
                ),

                // Buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _shareFile,
                          icon: const Icon(Icons.share),
                          label: const Text('Share File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _copyToClipboard,
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy JSON'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // JSON Preview
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _jsonContent,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}