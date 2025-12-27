import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/app_background.dart';
import '../widgets/section_header.dart';
import '../widgets/staggered_fade_in.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.auto_graph)),
        ],
      ),
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                StaggeredFadeIn(
                  child: SectionHeader(
                    title: 'Advanced marketplace signals',
                    subtitle: 'AI, automation, and optimization across the lifecycle.',
                  ),
                ),
                const SizedBox(height: 16),
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 120),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Smart fraud detection',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(
                                'Real-time risk scoring with payout holds and manual review queues.',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 160),
                  child: SectionHeader(
                    title: 'Predictive demand forecasting',
                    subtitle: 'Forecast by category and metro for smarter pricing.',
                  ),
                ),
                const SizedBox(height: 12),
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 190),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      children: demandForecast.map((item) {
                        final color = item.delta >= 0 ? theme.colorScheme.secondary : theme.colorScheme.tertiary;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.label,
                                        style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: item.score / 100,
                                        minHeight: 8,
                                        backgroundColor: color.withValues(alpha: 0.12),
                                        valueColor: AlwaysStoppedAnimation<Color>(color),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${item.delta >= 0 ? '+' : ''}${item.delta}%',
                                  style: theme.textTheme.labelSmall?.copyWith(color: color),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...advancedSignals.asMap().entries.map(
                  (entry) {
                    final index = entry.key;
                    final signal = entry.value;
                    return StaggeredFadeIn(
                      delay: Duration(milliseconds: 180 + index * 70),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.bolt, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(signal, style: theme.textTheme.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 400),
                  child: SectionHeader(
                    title: 'Logistics optimization',
                    subtitle: 'Carrier routing and savings by corridor.',
                  ),
                ),
                const SizedBox(height: 12),
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 430),
                  child: Column(
                    children: logisticsLanes
                        .map(
                          (lane) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.14)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.route),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(lane.route,
                                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 6),
                                      Text('ETA ${lane.eta} · Savings ${lane.savings}',
                                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text('Carbon ${lane.carbonScore}',
                                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 480),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.public),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cross-border trade readiness',
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(
                                'Currency conversion, duties, and restricted item checks ready to enable.',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        TextButton(onPressed: () {}, child: const Text('Configure')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 520),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.tertiary.withValues(alpha: 0.18)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.eco),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sustainability scoring',
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(
                                'Average marketplace score is 74 with resale impact tracking.',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        TextButton(onPressed: () {}, child: const Text('Report')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 560),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.credit_score, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Buyer credit line adoption',
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(
                                '28% of buyers qualify, with a 14% lift in conversion.',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
