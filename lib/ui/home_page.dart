import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/event_provider.dart';
import '../../data/models/category_model.dart';
import 'event_form_page.dart';
import 'category_page.dart'; // import ไฟล์ Category Page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<EventProvider>().loadData());
  }

  Color _parseColor(String hexString) {
    try {
      return Color(int.parse(hexString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Reminder'),
        actions: [
          // ปุ่มไปหน้าจัดการหมวดหมู่ (Settings)
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'จัดการหมวดหมู่',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoryPage()),
              );
            },
          ),
          // ปุ่ม Filter
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'กรองสถานะ',
            onSelected: (val) => context.read<EventProvider>().setFilterStatus(val),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('ทั้งหมด')),
              const PopupMenuItem(value: 'pending', child: Text('ยังไม่เริ่ม')),
              const PopupMenuItem(value: 'in_progress', child: Text('กำลังทำ')),
              const PopupMenuItem(value: 'completed', child: Text('เสร็จสิ้น')),
              const PopupMenuItem(value: 'cancelled', child: Text('ยกเลิก')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ค้นหากิจกรรม...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (val) => context.read<EventProvider>().setSearchQuery(val),
            ),
          ),
        ),
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          final events = provider.events;
          if (events.isEmpty) {
            return const Center(child: Text('ไม่มีรายการกิจกรรม', style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final category = provider.categories.firstWhere(
                (c) => c.id == event.categoryId, 
                orElse: () => Category(name: '?', colorHex: '#000000', iconKey: ''),
              );
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _parseColor(category.colorHex),
                    child: const Icon(Icons.event_note, color: Colors.white),
                  ),
                  title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // แสดงวันที่และเวลาให้ครบ
                      Text('${event.eventDate} | ${event.startTime} - ${event.endTime}'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(event.status, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
                          ),
                          if (event.priority == 3) ...[
                             const SizedBox(width: 5),
                             const Text('🔥 สูง', style: TextStyle(fontSize: 12, color: Colors.red)),
                          ],
                          if (event.remindEnabled) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.alarm, size: 16, color: Colors.redAccent),
                          ]
                        ],
                      )
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EventFormPage(event: event)),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () {
                       context.read<EventProvider>().deleteEvent(event.id!);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}