import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../data/db_helper.dart';
import '../../models/lead.dart';

class LeadFormScreen extends StatefulWidget {
  final Lead? lead;

  const LeadFormScreen({
    super.key,
    this.lead,
  });

  @override
  State<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends State<LeadFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _customerController =
      TextEditingController();

  final TextEditingController _officeController =
      TextEditingController();

  final TextEditingController _positionController =
      TextEditingController();

  final TextEditingController _contactController =
      TextEditingController();

  final TextEditingController _nextActionController =
      TextEditingController();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  String _currentStage = 'NEW';
  DateTime? _dueDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final lead = widget.lead;

    if (lead != null) {
      _customerController.text = lead.customer;
      _officeController.text = lead.office;
      _positionController.text = lead.position;
      _contactController.text = lead.contact;
      _nextActionController.text = lead.nextAction;

      _currentStage = Stages.list.contains(lead.currentStage)
          ? lead.currentStage
          : 'NEW';

      _dueDate = DateTime.tryParse(lead.dueDate);
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _officeController.dispose();
    _positionController.dispose();
    _contactController.dispose();
    _nextActionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stageInformation = Stages.stageMap[_currentStage];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lead == null ? 'New Lead' : 'Edit Lead',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              controller: _customerController,
              label: 'Customer Name *',
              icon: Icons.person_outline,
              requiredField: true,
            ),
            _buildTextField(
              controller: _officeController,
              label: 'Office / Institution',
              icon: Icons.business_outlined,
            ),
            _buildTextField(
              controller: _positionController,
              label: 'Position',
              icon: Icons.badge_outlined,
            ),
            _buildTextField(
              controller: _contactController,
              label: 'Contact Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            DropdownButtonFormField<String>(
              value: _currentStage,
              decoration: _inputDecoration(
                label: 'Current Stage',
                icon: Icons.flag_outlined,
              ),
              items: Stages.list.map((stage) {
                return DropdownMenuItem<String>(
                  value: stage,
                  child: Text(stage),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currentStage = value;
                  });
                }
              },
            ),
            if (stageInformation != null) ...[
              const SizedBox(height: 14),
              _buildStageGuide(stageInformation),
            ],
            const SizedBox(height: 14),
            _buildTextField(
              controller: _nextActionController,
              label: 'Next Action *',
              icon: Icons.next_plan_outlined,
              requiredField: true,
              maxLines: 3,
            ),
            const SizedBox(height: 2),
            _buildDueDatePicker(),
            const SizedBox(height: 18),
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
                'NON-NEGOTIABLE: Active lead එකකට Next Action + Due Date '
                'දෙකම අනිවාර්යයි.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.navy,
                padding: const EdgeInsets.all(16),
              ),
              onPressed: _saving ? null : _saveLead,
              icon: _saving
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _saving ? 'SAVING...' : 'SAVE LEAD',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStageGuide(Map<String, String> stageInformation) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sky.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sky),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.assistant_outlined,
                color: AppColors.navy,
              ),
              SizedBox(width: 7),
              Text(
                'Stage Guide',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '✅ ${stageInformation['action_si'] ?? ''}',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 5),
          Text(
            '🇬🇧 ${stageInformation['action_en'] ?? ''}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const Divider(height: 18),
          _buildGuideRow(
            Icons.schedule,
            'Time Limit',
            stageInformation['timeLimit'] ?? '-',
          ),
          _buildGuideRow(
            Icons.arrow_forward,
            'Move To',
            stageInformation['moveTo'] ?? '-',
          ),
          const SizedBox(height: 6),
          Text(
            '🚫 ${stageInformation['rule_si'] ?? ''}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.navy,
          ),
          const SizedBox(width: 7),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueDatePicker() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _selectDueDate,
      child: InputDecorator(
        decoration: _inputDecoration(
          label: 'Due Date *',
          icon: Icons.calendar_month_outlined,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _dueDate == null
                    ? 'Select Due Date / දිනය තෝරන්න'
                    : _dateFormat.format(_dueDate!),
                style: TextStyle(
                  color: _dueDate == null
                      ? AppColors.red
                      : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: AppColors.navy,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 30),
      ),
      lastDate: DateTime.now().add(
        const Duration(days: 730),
      ),
    );

    if (selectedDate != null) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  Future<void> _saveLead() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.red,
          content: Text(
            'Due Date අනිවාර්යයි / Due Date is required.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      String sampleSentDate =
          widget.lead?.sampleSentDate ?? '';

      if (_currentStage == 'SAMPLE SENT' &&
          sampleSentDate.isEmpty) {
        sampleSentDate =
            _dateFormat.format(DateTime.now());
      }

      final newNextAction =
          _nextActionController.text.trim();

      String lastAction = widget.lead?.lastAction ?? '';

      if (widget.lead != null &&
          widget.lead!.nextAction.trim().isNotEmpty &&
          widget.lead!.nextAction.trim() != newNextAction) {
        lastAction = widget.lead!.nextAction.trim();
      }

      final lead = Lead(
        id: widget.lead?.id,
        customer: _customerController.text.trim(),
        office: _officeController.text.trim(),
        position: _positionController.text.trim(),
        contact: _contactController.text.trim(),
        currentStage: _currentStage,
        lastAction: lastAction,
        nextAction: newNextAction,
        dueDate: _dateFormat.format(_dueDate!),
        sampleSentDate: sampleSentDate,
        createdAt: widget.lead?.createdAt,
        synced: 0,
      );

      if (lead.id == null) {
        await DBHelper.insertLead(lead);
      } else {
        await DBHelper.updateLead(lead);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.red,
            content: Text('Save failed: $error'),
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool requiredField = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _inputDecoration(
          label: label,
          icon: icon,
        ),
        validator: requiredField
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'අනිවාර්යයි / Required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}