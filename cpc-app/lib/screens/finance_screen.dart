import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_colors.dart';
import '../core/app_constants.dart';
import '../data/db_helper.dart';
import '../models/payment.dart';
import '../services/pdf_export_service.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  List<Payment> _payments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final data = await DBHelper.getPayments();

    if (!mounted) return;

    setState(() {
      _payments = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());

    final eligibleThisMonth = _payments.where((payment) {
      return payment.date.startsWith(currentMonth) && payment.eligible;
    }).toList();

    final paidBanners = eligibleThisMonth.fold<int>(
      0,
      (sum, payment) => sum + payment.bonusCount,
    );

    final totalCommission = eligibleThisMonth.fold<int>(
      0,
      (sum, payment) => sum + payment.payableCommission,
    );

    final monthlyBonus = PriceTable.monthlyBonus(paidBanners);
    final totalEarnings = totalCommission + monthlyBonus;

    final lockedOrders =
        _payments.where((payment) => !payment.eligible).length;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: RefreshIndicator(
        onRefresh: _loadPayments,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
          children: [
            _buildSummaryCard(
              currentMonth: currentMonth,
              paidBanners: paidBanners,
              commission: totalCommission,
              bonus: monthlyBonus,
              earnings: totalEarnings,
              lockedOrders: lockedOrders,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Payment & Commission Register',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    PdfExportService.exportPayments(_payments);
                  },
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('PDF'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (_payments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 55,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Payment records නැහැ.\nAdd බටන් එකෙන් record එකක් ඇතුළත් කරන්න.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ..._payments.map(_buildPaymentCard),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.navy,
        onPressed: () => _openPaymentForm(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Payment',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String currentMonth,
    required int paidBanners,
    required int commission,
    required int bonus,
    required int earnings,
    required int lockedOrders,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.navy,
            Color(0xFF14557F),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.20),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Month • $currentMonth',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow('Paid Banners', '$paidBanners'),
          _summaryRow('Commission', 'Rs. $commission'),
          _summaryRow('Bonus Tier', 'Rs. $bonus'),
          const Divider(color: Colors.white38),
          _summaryRow(
            'TOTAL EARNINGS',
            'Rs. $earnings',
            large: true,
            valueColor: AppColors.orange,
          ),
          if (lockedOrders > 0) ...[
            const SizedBox(height: 10),
            Text(
              '🔒 $lockedOrders order(s) LOCKED — CR8iVE base unpaid',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool large = false,
    Color valueColor = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: large ? 22 : 15,
              fontWeight: large ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    final statusColor =
        payment.eligible ? AppColors.green : AppColors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        onTap: () => _openPaymentForm(payment),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.14),
          child: Icon(
            payment.eligible ? Icons.lock_open : Icons.lock,
            size: 19,
            color: statusColor,
          ),
        ),
        title: Text(
          '${payment.orderId} • ${payment.customer}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${payment.bannerSize}\n'
          'Base: Rs. ${payment.cr8iveBase} • ${payment.date}',
          style: const TextStyle(fontSize: 12),
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _openPaymentForm(payment);
            } else if (value == 'delete') {
              _confirmDelete(payment);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rs. ${payment.commission}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    payment.commissionStatus,
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: AppColors.red),
                  SizedBox(width: 8),
                  Text(
                    'Delete',
                    style: TextStyle(color: AppColors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Payment payment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Payment Record?'),
          content: Text(
            '${payment.orderId} • ${payment.customer}\n'
            'මෙම record එක මකන්නද?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && payment.id != null) {
      await DBHelper.deletePayment(payment.id!);
      await _loadPayments();
    }
  }

  Future<void> _openPaymentForm([Payment? edit]) async {
    final orderIdController = TextEditingController(
      text: edit?.orderId ?? '',
    );

    final customerController = TextEditingController(
      text: edit?.customer ?? '',
    );

    PriceItem selectedItem = PriceTable.items.firstWhere(
      (item) => item.size == edit?.bannerSize,
      orElse: () => PriceTable.items.first,
    );

    int quantity = edit?.bonusCount ?? 1;
    if (quantity < 1) quantity = 1;

    final originalBaseEach =
        edit == null ? selectedItem.normalBase : edit.cr8iveBase ~/ quantity;

    final originalCommissionEach = edit == null
        ? selectedItem.singleCommission
        : edit.commission ~/ quantity;

    bool premium = originalBaseEach == selectedItem.premiumBase;
    bool sevenPack =
        originalCommissionEach == selectedItem.packCommission;
    bool basePaid = edit?.basePaid == 1;
    bool partnerPaid = edit?.partnerPaid == 1;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final baseEach = premium
                ? selectedItem.premiumBase
                : selectedItem.normalBase;

            final commissionEach = sevenPack
                ? selectedItem.packCommission
                : selectedItem.singleCommission;

            final totalBase = baseEach * quantity;
            final totalCommission = commissionEach * quantity;

            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom:
                    MediaQuery.of(sheetContext).viewInsets.bottom + 18,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      edit == null
                          ? 'New Payment Record'
                          : 'Edit Payment Record',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: orderIdController,
                      decoration: InputDecoration(
                        labelText: 'Order ID *',
                        prefixIcon:
                            const Icon(Icons.receipt_long_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: customerController,
                      decoration: InputDecoration(
                        labelText: 'Customer *',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<PriceItem>(
                      value: selectedItem,
                      decoration: InputDecoration(
                        labelText: 'Banner Size',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: PriceTable.items.map((item) {
                        return DropdownMenuItem<PriceItem>(
                          value: item,
                          child: Text(item.size),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() {
                            selectedItem = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Quantity:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          onPressed: () {
                            setSheetState(() {
                              if (quantity > 1) quantity--;
                            });
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text(
                          '$quantity',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setSheetState(() {
                              quantity++;
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Premium Base'),
                      value: premium,
                      onChanged: (value) {
                        setSheetState(() {
                          premium = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('7-Pack Commission Rate'),
                      value: sevenPack,
                      onChanged: (value) {
                        setSheetState(() {
                          sevenPack = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.green,
                      title: const Text(
                        'CR8iVE Base Paid?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        basePaid
                            ? 'Commission ELIGIBLE'
                            : 'Commission LOCKED',
                        style: TextStyle(
                          color: basePaid
                              ? AppColors.green
                              : AppColors.red,
                        ),
                      ),
                      value: basePaid,
                      onChanged: (value) {
                        setSheetState(() {
                          basePaid = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Partner Paid?'),
                      value: partnerPaid,
                      onChanged: (value) {
                        setSheetState(() {
                          partnerPaid = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.navy.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.navy.withOpacity(0.20),
                        ),
                      ),
                      child: Column(
                        children: [
                          _formResultRow(
                            'Total Base',
                            'Rs. $totalBase',
                          ),
                          const SizedBox(height: 6),
                          _formResultRow(
                            'Total Commission',
                            'Rs. $totalCommission',
                            valueColor: basePaid
                                ? AppColors.green
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          padding: const EdgeInsets.all(15),
                        ),
                        onPressed: () async {
                          if (orderIdController.text.trim().isEmpty ||
                              customerController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppColors.red,
                                content: Text(
                                  'Order ID සහ Customer අනිවාර්යයි.',
                                ),
                              ),
                            );
                            return;
                          }

                          final payment = Payment(
                            id: edit?.id,
                            orderId: orderIdController.text.trim(),
                            customer: customerController.text.trim(),
                            bannerSize: selectedItem.size,
                            cr8iveBase: totalBase,
                            basePaid: basePaid ? 1 : 0,
                            commission: totalCommission,
                            bonusCount: quantity,
                            partnerPaid: partnerPaid ? 1 : 0,
                            date: edit?.date ??
                                DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now()),
                          );

                          if (edit == null) {
                            await DBHelper.insertPayment(payment);
                          } else {
                            await DBHelper.updatePayment(payment);
                          }

                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }

                          await _loadPayments();
                        },
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('SAVE PAYMENT'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    orderIdController.dispose();
    customerController.dispose();
  }

  Widget _formResultRow(
    String label,
    String value, {
    Color valueColor = AppColors.navy,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}