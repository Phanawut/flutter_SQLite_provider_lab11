import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'state/event_provider.dart';
import '../../data/models/event_model.dart';
import 'category_page.dart';

class EventFormPage extends StatefulWidget {
  final Event? event;
  const EventFormPage({super.key, this.event});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _dateCtrl; // วันที่
  late TextEditingController _startCtrl;
  late TextEditingController _endCtrl;
  late TextEditingController _remindMinutesCtrl; // นาทีแจ้งเตือน

  int? _selectedCategoryId;
  String _status = 'pending';
  int _priority = 2; // Default Normal
  bool _remindEnabled = false;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _dateCtrl = TextEditingController(text: e?.eventDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now()));
    _startCtrl = TextEditingController(text: e?.startTime ?? '09:00');
    _endCtrl = TextEditingController(text: e?.endTime ?? '10:00');
    _remindMinutesCtrl = TextEditingController(text: e?.remindMinutes.toString() ?? '15');
    
    _selectedCategoryId = e?.categoryId;
    _status = e?.status ?? 'pending';
    _priority = e?.priority ?? 2;
    _remindEnabled = e?.remindEnabled ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _remindMinutesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) {
       ctrl.text = '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณาเลือกหมวดหมู่')));
        return;
      }
      
      // Validation: เวลาสิ้นสุด ต้องมากกว่า เวลาเริ่ม
      if (_endCtrl.text.compareTo(_startCtrl.text) <= 0) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เวลาสิ้นสุดต้องมากกว่าเวลาเริ่ม')));
         return;
      }

      final nowIso = DateTime.now().toIso8601String();
      final newEvent = Event(
        id: widget.event?.id,
        title: _titleCtrl.text,
        description: _descCtrl.text,
        categoryId: _selectedCategoryId!,
        eventDate: _dateCtrl.text,
        startTime: _startCtrl.text,
        endTime: _endCtrl.text,
        status: _status,
        priority: _priority,
        remindEnabled: _remindEnabled,
        remindMinutes: int.tryParse(_remindMinutesCtrl.text) ?? 15,
        updatedAt: nowIso,
      );

      final provider = context.read<EventProvider>();
      try {
        if (widget.event == null) {
          await provider.addEvent(newEvent);
        } else {
          await provider.updateEvent(newEvent);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<EventProvider>().categories;

    // ถ้ายังไม่มีหมวดหมู่ ให้แจ้งเตือนและนำทางไปหน้าจัดการหมวดหมู่
    if (categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.event == null ? 'เพิ่มกิจกรรม' : 'แก้ไขกิจกรรม')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ยังไม่มีหมวดหมู่ กรุณาเพิ่มก่อน'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoryPage()),
                ).then((_) => setState(() {})), // refresh เมื่อกลับ
                child: const Text('ไปหน้าจัดการหมวดหมู่'),
              ),
            ],
          ),
        ),
      );
    }

    // ตั้งค่า default เลือกหมวดหมู่เมื่อเพิ่งโหลด
    if (_selectedCategoryId == null) {
      // ถ้ามีการแก้ไข ให้ใช้ค่าเดิม
      _selectedCategoryId = widget.event?.categoryId ?? categories.first.id;
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.event == null ? 'เพิ่มกิจกรรม' : 'แก้ไขกิจกรรม')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. ชื่อกิจกรรม
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'ชื่อกิจกรรม *', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'จำเป็นต้องระบุ' : null,
            ),
            const SizedBox(height: 16),
            
            // 2. หมวดหมู่ & ระดับความสำคัญ
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'หมวดหมู่', border: OutlineInputBorder()),
                    items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<int>(
                    value: _priority,
                    decoration: const InputDecoration(labelText: 'ความสำคัญ', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('ต่ำ')),
                      DropdownMenuItem(value: 2, child: Text('ปกติ')),
                      DropdownMenuItem(value: 3, child: Text('สูง')),
                    ],
                    onChanged: (v) => setState(() => _priority = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. วันที่และเวลา
            TextFormField(
              controller: _dateCtrl,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'วันที่', prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()),
              onTap: _pickDate,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'เริ่ม', prefixIcon: Icon(Icons.access_time), border: OutlineInputBorder()),
                    onTap: () => _pickTime(_startCtrl),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _endCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'สิ้นสุด', prefixIcon: Icon(Icons.access_time_filled), border: OutlineInputBorder()),
                    onTap: () => _pickTime(_endCtrl),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. รายละเอียด
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'รายละเอียด', border: OutlineInputBorder()),
            ),
            
            // 5. สถานะ (แสดงเฉพาะตอนแก้ไข)
            if (widget.event != null) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'สถานะ', border: OutlineInputBorder()),
                items: ['pending', 'in_progress', 'completed', 'cancelled']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
            ],

            const Divider(height: 30),

            // 6. การแจ้งเตือน
            SwitchListTile(
              title: const Text('เปิดการแจ้งเตือน'),
              value: _remindEnabled,
              onChanged: (v) => setState(() => _remindEnabled = v),
            ),
            if (_remindEnabled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _remindMinutesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'เตือนก่อนกี่นาที?',
                    suffixText: 'นาที',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }
}