// ไฟล์: lib/data/models/event_model.dart

class Event {
  final int? id;
  final String title;
  final String description;
  final int categoryId;
  final String eventDate;
  final String startTime;
  final String endTime;
  final String status;
  final int priority;
  final bool remindEnabled;
  final int remindMinutes;
  final String updatedAt; // 1. ต้องมีตัวแปรนี้

  Event({
    this.id,
    required this.title,
    this.description = '',
    required this.categoryId,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    this.status = 'pending',
    this.priority = 2,
    this.remindEnabled = false,
    this.remindMinutes = 15,
    required this.updatedAt, // 2. ต้อง Require ตรงนี้
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'event_date': eventDate,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'priority': priority,
      'remind_enabled': remindEnabled ? 1 : 0,
      'remind_minutes': remindMinutes,
      'updated_at': updatedAt, // 3. สำคัญมาก! ต้องส่งค่านี้ลง DB ด้วย
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      categoryId: map['category_id'],
      eventDate: map['event_date'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      status: map['status'],
      priority: map['priority'],
      remindEnabled: map['remind_enabled'] == 1,
      remindMinutes: map['remind_minutes'] ?? 0,
      updatedAt: map['updated_at'] ?? DateTime.now().toIso8601String(),
    );
  }
}