import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_colors.dart';
import '../core/app_constants.dart';
import '../data/db_helper.dart';
import '../models/lead.dart';
import '../models/order_record.dart';
import '../models/payment.dart';
import '../services/pdf_export_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  List<Lead> _leads = [];
  List<Payment> _payments = [];
  List<OrderRecord> _orders = [];

  int _completedFollowUps = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final leads = await DBHelper.getLeads();
    final payments = await DBHelper.getPayments();
    final orders = await DBHelper.getOrders();

    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final followUps = await DBHelper.countFollowUps(
      _dateFormat.format(weekStart),
      _dateFormat.format(now),
    );

    if (!mounted) return;

    setState(() {
      _leads = leads;
      _payments = payments;
      _orders = orders;
      _completedFollowUps = followUps;
      _loading = false;
    });
  }

  bool _isInCurrentWeek(String date) {
    final parsed = DateTime.tryParse(date);

    if (parsed == null) return false;

    final now = DateTime.now();

    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));

    return !parsed.isBefore(weekStart) && parsed.isBefore(tomorrow);
  }

  bool _isInCurrentMonth(String date) {
    if (date.isEmpty) return false;

    final month = DateFormat('yyyy-MM').format(DateTime.now());
    return date.startsWith(month);
  }

  int _stageIndex(String stage) {
    return Stages.list.indexOf(stage);
  }

  bool _isQualified(Lead lead) {
    final currentIndex = _stageIndex(lead.currentStage);
    final needIndex = _stageIndex('NEED CONFIRMED');
    final referralIndex = _stageIndex('REFERRAL');

    return currentIndex >= needIndex && currentIndex <= referralIndex;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Weekly metrics
    final weeklyNewConversations = _leads.where((lead) {
      return _isInCurrentWeek(lead.createdAt);
    }).length;

    final weeklyQualifiedNeeds = _leads.where((lead) {
      return _isInCurrentWeek(lead.createdAt) && _isQualified(lead);
    }).length;

    final weeklySamples = _leads.where((lead) {
      return _isInCurrentWeek(lead.sampleSentDate);
    }).length;

    final weeklyPaidOrders = _payments.where((payment) {
      return payment.eligible && _isInCurrentWeek(payment.date);
    }).length;

    final missedFollowUps = _leads.where((lead) {
      return lead.status == 'OVERDUE';
    }).length;

    final ordersWithMissingData = _orders.where((order) {
      return !order.canMoveToProduction;
    }).length;

    // Monthly metrics
    final monthlyNewLeads = _leads.where((lead) {
      return _isInCurrentMonth(lead.createdAt);
    }).length;

    final monthlyQualifiedNeeds = _leads.where((lead) {
      return _isInCurrentMonth(lead.createdAt) && _isQualified(lead);
    }).length;

    final monthlyPaidOrders = _payments.where((payment) {
      return payment.eligible && _isInCurrentMonth(payment.date);
    }).toList();

    final monthlyPaidBanners = monthlyPaidOrders.fold<int>(
      0,
      (sum, payment) => sum + payment.bonusCount,
    );

    final monthlyCommission = monthlyPaidOrders.fold<int>(
      0,
      (sum, payment) => sum + payment.payableCommission,
    );

    final monthlyBonus =
        PriceTable.monthlyBonus(monthlyPaidBanners);

    final totalMonthlyEarnings =
        monthlyCommission + monthlyBonus;

    final conversionRate = monthlyNewLeads == 0
        ? 0.0
        : (monthlyPaidOrders.length / monthlyNewLeads) * 100;

    final pendingFollowUps = _leads.where((lead) {
      return lead.status == 'OVERDUE' ||
          lead.status == 'DUE_SOON';
    }).length;

    final repeatCustomers = _countRepeatCustomers();

    final referrals = _leads.where((lead) {
      return lead.currentStage == 'REFERRAL' &&
          _isInCurrentMonth(lead.createdAt);
    }).length;

    final escalations = _leads.where((lead) {
      return lead.currentStage == 'ESCALATED' &&
          _isInCurrentMonth(lead.createdAt);
    }).length;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: AppColors.navy,
            child: const TabBar(
              indicatorColor: AppColors.sky,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                Tab(
                  icon: Icon(Icons.calendar_view_week_outlined),
                  text: 'WEEKLY',
                ),
                Tab(
                  icon: Icon(Icons.calendar_month_outlined),
                  text: 'MONTHLY',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildWeeklyReport(
                  newConversations: weeklyNewConversations,
                  qualifiedNeeds: weeklyQualifiedNeeds,
                  samplesSent: weeklySamples,
                  paidOrders: weeklyPaidOrders,
                  missedFollowUps: missedFollowUps,
                  missingOrders: ordersWithMissingData,
                ),
                _buildMonthlyReport(
                  newLeads: monthlyNewLeads,
                  qualifiedNeeds: monthlyQualifiedNeeds,
                  paidOrders: monthlyPaidOrders.length,
                  conversionRate: conversionRate,
                  commission: monthlyCommission,
                  bonus: monthlyBonus,
                  totalEarnings: totalMonthlyEarnings,
                  pendingFollowUps: pendingFollowUps,
                  repeatCustomers: repeatCustomers,
                  referrals: referrals,
                  escalations: escalations,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyReport({
    required int newConversations,
    required int qualifiedNeeds,
    required int samplesSent,
    required int paidOrders,
    required int missedFollowUps,
    required int missingOrders,
  }) {
    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _buildTitle(
            'Weekly Control Board',
            'Targets are planning references, not pressure quotas.',
          ),
          _buildMetric(
            metric: 'New Conversations',
            target: '10–15',
            actual: '$newConversations',
          ),
          _buildMetric(
            metric: 'Qualified Needs',
            target: '6–8',
            actual: '$qualifiedNeeds',
          ),
          _buildMetric(
            metric: 'Follow-ups Completed',
            target: '5+',
            actual: '$_completedFollowUps',
          ),
          _buildMetric(
            metric: 'Relevant Samples / Options Sent',
            target: 'As needed',
            actual: '$samplesSent',
          ),
          _buildMetric(
            metric: 'Target Closes / Paid Orders',
            target: '2–4',
            actual: '$paidOrders',
          ),
          _buildMetric(
            metric: 'Missed Follow-ups',
            target: '0',
            actual: '$missedFollowUps',
            warning: missedFollowUps > 0,
          ),
          _buildMetric(
            metric: 'Orders with Missing Data',
            target: '0',
            actual: '$missingOrders',
            warning: missingOrders > 0,
          ),
          const SizedBox(height: 20),
          const Text(
            'Weekly Review Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          _buildQuestionCard(
            '1. Pipeline',
            'කවුරු NEW / INTERESTED / FOLLOW-UP stage එකේද?',
          ),
          _buildQuestionCard(
            '2. Due Work',
            'Next Action + Due Date miss වෙලා තියෙන rows තිබේද?',
          ),
          _buildQuestionCard(
            '3. Conversion',
            'Need තිබුණත් option/price stage එකට නොගිය leads කවුද?',
          ),
          _buildQuestionCard(
            '4. Quality',
            'Repeated pressure, missing data හෝ payment confusion තිබුණාද?',
          ),
          const SizedBox(height: 14),
          _buildPdfButton(
            onPressed: () {
              PdfExportService.exportReport(
                'CHART 08 - WEEKLY CONTROL BOARD',
                [
                  [
                    'New Conversations',
                    '10-15',
                    '$newConversations',
                  ],
                  [
                    'Qualified Needs',
                    '6-8',
                    '$qualifiedNeeds',
                  ],
                  [
                    'Follow-ups Completed',
                    '5+',
                    '$_completedFollowUps',
                  ],
                  [
                    'Samples / Options Sent',
                    'As needed',
                    '$samplesSent',
                  ],
                  [
                    'Paid Orders',
                    '2-4',
                    '$paidOrders',
                  ],
                  [
                    'Missed Follow-ups',
                    '0',
                    '$missedFollowUps',
                  ],
                  [
                    'Orders with Missing Data',
                    '0',
                    '$missingOrders',
                  ],
                ],
                [
                  'Metric',
                  'Reference Target',
                  'Actual',
                ],
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMonthlyReport({
    required int newLeads,
    required int qualifiedNeeds,
    required int paidOrders,
    required double conversionRate,
    required int commission,
    required int bonus,
    required int totalEarnings,
    required int pendingFollowUps,
    required int repeatCustomers,
    required int referrals,
    required int escalations,
  }) {
    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _buildTitle(
            'Monthly Performance Dashboard',
            'Performance = Activity + Trust + Paid Results + Process Quality',
          ),
          _buildMetric(
            metric: 'Total New Leads',
            actual: '$newLeads',
          ),
          _buildMetric(
            metric: 'Qualified Needs',
            actual: '$qualifiedNeeds',
          ),
          _buildMetric(
            metric: 'Paid Orders',
            actual: '$paidOrders',
          ),
          _buildMetric(
            metric: 'Conversion Rate',
            actual: '${conversionRate.toStringAsFixed(1)}%',
          ),
          _buildMetric(
            metric: 'Total Commission',
            actual: 'Rs. $commission',
          ),
          _buildMetric(
            metric: 'Bonus Tier',
            target: '5 / 10 / 15+',
            actual: 'Rs. $bonus',
          ),
          _buildMetric(
            metric: 'Total Earnings',
            actual: 'Rs. $totalEarnings',
          ),
          _buildMetric(
            metric: 'Pending Follow-ups',
            actual: '$pendingFollowUps',
            warning: pendingFollowUps > 0,
          ),
          _buildMetric(
            metric: 'Repeat Customers',
            actual: '$repeatCustomers',
          ),
          _buildMetric(
            metric: 'Referrals',
            actual: '$referrals',
          ),
          _buildMetric(
            metric: 'Complaints / Escalations',
            target: '0',
            actual: '$escalations',
            warning: escalations > 0,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.sky.withOpacity(0.08),
              border: Border.all(color: AppColors.sky),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Month-end Decision\n\n'
              'Total Earnings: Rs. $totalEarnings\n\n'
              'ඊළඟ මාසේ target වැඩි කරනවාද, same rhythm එක තියාගන්නවාද, '
              'නැත්නම් follow-up / need discovery / conversion stage එක '
              'improve කරනවාද කියලා මේ numbers අනුව තීරණය කරන්න.',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 14),
          _buildPdfButton(
            onPressed: () {
              PdfExportService.exportReport(
                'CHART 09 - MONTHLY PERFORMANCE DASHBOARD',
                [
                  ['Total New Leads', '$newLeads'],
                  ['Qualified Needs', '$qualifiedNeeds'],
                  ['Paid Orders', '$paidOrders'],
                  [
                    'Conversion Rate',
                    '${conversionRate.toStringAsFixed(1)}%',
                  ],
                  ['Total Commission', 'Rs. $commission'],
                  ['Bonus Tier', 'Rs. $bonus'],
                  ['Total Earnings', 'Rs. $totalEarnings'],
                  ['Pending Follow-ups', '$pendingFollowUps'],
                  ['Repeat Customers', '$repeatCustomers'],
                  ['Referrals', '$referrals'],
                  ['Complaints / Escalations', '$escalations'],
                ],
                [
                  'Metric',
                  'Result',
                ],
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  int _countRepeatCustomers() {
    final customerOrderCount = <String, int>{};

    for (final payment in _payments) {
      if (!payment.eligible) continue;

      final customerName = payment.customer.trim().toLowerCase();

      if (customerName.isEmpty) continue;

      customerOrderCount[customerName] =
          (customerOrderCount[customerName] ?? 0) + 1;
    }

    return customerOrderCount.values.where((count) {
      return count > 1;
    }).length;
  }

  Widget _buildTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required String metric,
    String target = '',
    required String actual,
    bool warning = false,
  }) {
    final resultColor =
        warning ? AppColors.red : AppColors.navy;

    return Card(
      margin: const EdgeInsets.only(bottom: 7),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                metric,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            if (target.isNotEmpty)
              Expanded(
                child: Text(
                  target,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                actual,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: resultColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(String title, String question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              question,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfButton({
    required VoidCallback onPressed,
  }) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.sky,
        padding: const EdgeInsets.all(14),
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.picture_as_pdf),
      label: const Text('EXPORT PDF'),
    );
  }
}