import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../data/db_helper.dart';
import '../../models/lead.dart';
import '../../services/pdf_export_service.dart';
import 'lead_form_screen.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  List<Lead> _allLeads = [];

  String _searchQuery = '';
  String _statusFilter = 'ALL';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    final data = await DBHelper.getLeads();

    if (!mounted) return;

    setState(() {
      _allLeads = data;
      _loading = false;
    });
  }

  List<Lead> get _visibleLeads {
    final query = _searchQuery.trim().toLowerCase();

    return _allLeads.where((lead) {
      final matchesSearch = query.isEmpty ||
          lead.customer.toLowerCase().contains(query) ||
          lead.office.toLowerCase().contains(query) ||
          lead.position.toLowerCase().contains(query) ||
          lead.contact.toLowerCase().contains(query) ||
          lead.currentStage.toLowerCase().contains(query);

      final matchesFilter = _statusFilter == 'ALL' ||
          lead.status == _statusFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int _statusCount(String status) {
    if (status == 'ALL') return _allLeads.length;

    return _allLeads.where((lead) {
      return lead.status == status;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final leads = _visibleLeads;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search customer / office / phone',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 58,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              children: [
                _buildFilterChip(
                  status: 'ALL',
                  label: 'All',
                  color: Colors.blueGrey,
                ),
                _buildFilterChip(
                  status: 'OVERDUE',
                  label: 'Overdue',
                  color: AppColors.red,
                ),
                _buildFilterChip(
                  status: 'DUE_SOON',
                  label: 'Due Soon',
                  color: AppColors.orange,
                ),
                _buildFilterChip(
                  status: 'ACTIVE',
                  label: 'Active',
                  color: AppColors.sky,
                ),
                _buildFilterChip(
                  status: 'COMPLETED',
                  label: 'Completed',
                  color: AppColors.green,
                ),
                _buildFilterChip(
                  status: 'PARKED',
                  label: 'Parked',
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          Expanded(
            child: leads.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadLeads,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        12,
                        4,
                        12,
                        95,
                      ),
                      itemCount: leads.length,
                      itemBuilder: (context, index) {
                        return _buildLeadCard(leads[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'leadPdfButton',
            backgroundColor: AppColors.sky,
            onPressed: () {
              PdfExportService.exportLeadPipeline(_allLeads);
            },
            child: const Icon(
              Icons.picture_as_pdf,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'newLeadButton',
            backgroundColor: AppColors.navy,
            onPressed: _addLead,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            label: const Text(
              'New Lead',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String status,
    required String label,
    required Color color,
  }) {
    final selected = _statusFilter == status;
    final count = _statusCount(status);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        label: Text('$label ($count)'),
        selectedColor: color.withOpacity(0.20),
        side: BorderSide(
          color: selected ? color : Colors.grey.shade300,
        ),
        onSelected: (_) {
          setState(() {
            _statusFilter = status;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadLeads,
      child: ListView(
        children: const [
          SizedBox(height: 100),
          Icon(
            Icons.people_outline,
            size: 65,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'Leads නැහැ.\nNew Lead බටන් එකෙන් customer කෙනෙක් add කරන්න.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard(Lead lead) {
    final statusColor = AppColors.statusColor(lead.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _editLead(lead),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 42,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lead.customer,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (lead.office.isNotEmpty)
                          Text(
                            lead.office,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editLead(lead);
                      } else if (value == 'delete') {
                        _confirmDelete(lead);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: AppColors.red,
                            ),
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
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _buildBadge(
                    text: lead.currentStage,
                    color: AppColors.navy,
                  ),
                  _buildBadge(
                    text: lead.status,
                    color: statusColor,
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.arrow_forward,
                    size: 15,
                    color: AppColors.navy,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      lead.nextAction,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 15,
                    color: statusColor,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    lead.dueDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (lead.contact.isNotEmpty)
                    Text(
                      lead.contact,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.35),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Future<void> _addLead() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const LeadFormScreen(),
      ),
    );

    if (result == true) {
      await _loadLeads();
    }
  }

  Future<void> _editLead(Lead lead) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => LeadFormScreen(lead: lead),
      ),
    );

    if (result == true) {
      await _loadLeads();
    }
  }

  Future<void> _confirmDelete(Lead lead) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Lead?'),
          content: Text(
            '${lead.customer} lead record එක මකන්නද?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && lead.id != null) {
      await DBHelper.deleteLead(lead.id!);
      await _loadLeads();
    }
  }
}