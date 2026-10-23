import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class ReferenceItem {
  final String situation;
  final String action;
  final String rule;

  const ReferenceItem({
    required this.situation,
    required this.action,
    required this.rule,
  });
}

const List<ReferenceItem> referenceItems = [
  ReferenceItem(
    situation: 'Existing size / base price',
    action: 'CHART',
    rule:
        'Price Reference එකේ තියෙනවා නම් නැවත අහන්න අවශ්‍ය නෑ.',
  ),
  ReferenceItem(
    situation: 'Routine first message / follow-up',
    action: 'CHART',
    rule: 'Standard flow සහ Follow-up Clock භාවිතා කරන්න.',
  ),
  ReferenceItem(
    situation: 'Commission amount',
    action: 'CHART',
    rule: 'Paid order status අනුව commission calculate කරන්න.',
  ),
  ReferenceItem(
    situation: 'New / unusual banner size',
    action: 'ASK CR8iVE',
    rule: 'Order confirm කිරීමට පෙර base quote ලබාගන්න.',
  ),
  ReferenceItem(
    situation: 'Custom commercial design / unusual request',
    action: 'ASK CR8iVE',
    rule: 'Design-only / custom quote policy verify කරන්න.',
  ),
  ReferenceItem(
    situation: 'Customer complaint / production error',
    action: 'ESCALATE',
    rule: 'Evidence + Order ID එක්ක support channel එකට යවන්න.',
  ),
  ReferenceItem(
    situation: 'Special bulk quote / institutional requirement',
    action: 'ASK CR8iVE',
    rule: 'Partner විසින් guarantee හෝ commitment නොදෙන්න.',
  ),
  ReferenceItem(
    situation: 'Unauthorized government endorsement request',
    action: 'STOP',
    rule:
        'CR8iVE approve නොකළ official claims භාවිතා නොකරන්න.',
  ),
];

const List<String> professionalBoundaries = [
  'No Pressure',
  'No Fake Urgency',
  'No Citizen Data Misuse',
  'No Unapproved Official Claims',
  'Clear Records',
];

class ReferenceScreen extends StatefulWidget {
  const ReferenceScreen({super.key});

  @override
  State<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends State<ReferenceScreen> {
  String _search = '';

  List<ReferenceItem> get _filteredItems {
    final query = _search.trim().toLowerCase();

    if (query.isEmpty) return referenceItems;

    return referenceItems.where((item) {
      return item.situation.toLowerCase().contains(query) ||
          item.action.toLowerCase().contains(query) ||
          item.rule.toLowerCase().contains(query);
    }).toList();
  }

  Color _actionColor(String action) {
    switch (action) {
      case 'ASK CR8iVE':
        return AppColors.orange;
      case 'ESCALATE':
        return AppColors.red;
      case 'STOP':
        return Colors.black87;
      default:
        return AppColors.green;
    }
  }

  IconData _actionIcon(String action) {
    switch (action) {
      case 'ASK CR8iVE':
        return Icons.help_outline;
      case 'ESCALATE':
        return Icons.report_problem_outlined;
      case 'STOP':
        return Icons.stop_circle_outlined;
      default:
        return Icons.menu_book_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask CR8iVE / Do Not Ask'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const Text(
            'Routine decisions chart එකෙන් manage කරන්න. '
            'Exceptional cases පමණක් support channel එකට යවන්න.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: (value) {
              setState(() {
                _search = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search situation / action',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 35),
              child: Center(
                child: Text(
                  'Matching reference එකක් නැහැ.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ...items.map(_buildReferenceCard),
          const SizedBox(height: 18),
          const Text(
            'Professional Boundaries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: professionalBoundaries.map((boundary) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: AppColors.sky.withOpacity(0.06),
                  border: Border.all(color: AppColors.sky),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  boundary,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                left: BorderSide(
                  color: AppColors.orange,
                  width: 4,
                ),
              ),
            ),
            child: const Text(
              'Core Principle: System එකෙන් resolve කරන්න පුළුවන් '
              'routine issue chart එකෙන් manage කරන්න. Brand, legal/official, '
              'production, complaint, custom quote වගේ exceptional issue '
              'පමණක් escalate කරන්න.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildReferenceCard(ReferenceItem item) {
    final color = _actionColor(item.action);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(
                    _actionIcon(item.action),
                    color: color,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.situation,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.action,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.rule,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}