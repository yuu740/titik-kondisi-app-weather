import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/subs_provider.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subProvider, child) {
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(title: const Text('Support & Upgrade')), // EN
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                if (subProvider.isPro)
                  Card(
                    color: Colors.green.withOpacity(0.2),
                    child: const ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('You are a Pro User!'), // EN
                      subtitle: Text('Thank you for your support.'), // EN
                    ),
                  ),
                const SizedBox(height: 20),
                _buildProCard(context, theme, subProvider),
                const SizedBox(height: 20),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('TitikKondisi PRO',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text('IDR 15,000 / month', // EN
              style: TextStyle(fontSize: 18, color: theme.primaryColor, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildFeatureItem(Icons.block, 'Ad-Free', 'Enjoy the app without interruptions.'), // EN
            _buildFeatureItem(Icons.widgets_outlined, 'Exclusive Widgets', 'Access advanced weather widgets on home screen.'), // EN
            _buildFeatureItem(Icons.notification_add, 'Smart Notifications', 'More accurate rain & astronomy alerts.'), // EN
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: subProvider.isPro ? Colors.grey : theme.primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
                disabledBackgroundColor: Colors.grey.withOpacity(0.5),
              ),
              onPressed: subProvider.isSubProcessing
                  ? null 
                  : () async {
                      if (subProvider.isPro) {
                        await subProvider.downgradeToFree();
                      } else {
                        await subProvider.upgradeToPro();
                      }
                    },
              child: subProvider.isSubProcessing
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Text(subProvider.isPro
                      ? 'Deactivate Pro (Simulation)' // EN
                      : 'Upgrade to Pro'), // EN
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Donate', // EN
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text('Love this app? Support the developer with a donation.', // EN
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey.withOpacity(0.5),
              ),
              onPressed: subProvider.isDonationProcessing
                  ? null 
                  : () async {
                      await subProvider.simulateDonation();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thank you for your donation! (Simulation)'), // EN
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
              child: subProvider.isDonationProcessing
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    )
                  : const Text('Donate Now'), // EN
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}