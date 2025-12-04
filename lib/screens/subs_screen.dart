import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../provider/subs_provider.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  // Helper untuk membuka URL
  Future<void> _launchURL(String urlString, BuildContext context) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch payment URL')),
        );
      }
    }
  }

  // Helper untuk menampilkan Dialog Input Donasi
  void _showDonationDialog(BuildContext context, SubscriptionProvider provider) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Enter Donation Amount"),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "e.g. 15000",
            prefixText: "Rp ",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = amountController.text.trim();
              if (amount.isNotEmpty) {
                Navigator.pop(ctx); // Tutup dialog dulu
                try {
                  // Panggil Provider
                  final url = await provider.processDonation(amount);
                  if (url != null && context.mounted) {
                    _launchURL(url, context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            child: const Text("Pay Now"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subProvider, child) {
        final theme = Theme.of(context);
        
        // Cek jika sedang loading transaksi
        if (subProvider.isProcessing) {
           return Scaffold(
             body: Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: const [
                   CircularProgressIndicator(),
                   SizedBox(height: 16),
                   Text("Processing Transaction..."),
                 ],
               ),
             ),
           );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Support & Upgrade')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                if (subProvider.isPro)
                  Card(
                    color: Colors.green.withOpacity(0.2),
                    child: const ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('You are a Pro User!'),
                      subtitle: Text('Thank you for your support.'),
                    ),
                  ),
                const SizedBox(height: 20),
                
                // --- CARD UPGRADE PRO ---
                _buildProCard(context, theme, subProvider),
                
                const SizedBox(height: 20),
                
                // --- CARD DONATION ---
                _buildDonationCard(context, theme, subProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProCard(BuildContext context, ThemeData theme, SubscriptionProvider subProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.primaryColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('TitikKondisi PRO',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('IDR 15,000 / month',
                style: TextStyle(fontSize: 18, color: theme.primaryColor)),
            const SizedBox(height: 24),
            // ... feature items ...
            ElevatedButton(
              onPressed: subProvider.isPro 
                ? null // Kalau sudah pro, disable tombol (atau ganti jadi Manage Subs)
                : () async {
                    try {
                      final url = await subProvider.processSubscription();
                      if (url != null && context.mounted) {
                        _launchURL(url, context);
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
              child: Text(subProvider.isPro ? 'Active' : 'Upgrade Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCard(BuildContext context, ThemeData theme, SubscriptionProvider subProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Donate', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Support the developer with a donation.', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              // Trigger Dialog Input Amount
              onPressed: () => _showDonationDialog(context, subProvider),
              child: const Text('Donate Now'),
            )
          ],
        ),
      ),
    );
  }
}