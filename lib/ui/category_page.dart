import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/event_provider.dart';
import '../../data/models/category_model.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('จัดการหมวดหมู่')),
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          if (provider.categories.isEmpty) {
            return const Center(child: Text('ไม่มีข้อมูลหมวดหมู่'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: provider.categories.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (context, index) {
              final cat = provider.categories[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _parseColor(cat.colorHex),
                  child: Icon(_getIconData(cat.iconKey), color: Colors.white),
                ),
                title: Text(cat.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context, cat),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // แปลง String เป็น IconData
  IconData _getIconData(String key) {
    switch (key) {
      case 'work': return Icons.work;
      case 'person': return Icons.person;
      case 'school': return Icons.school;
      case 'home': return Icons.home;
      case 'star': return Icons.star;
      default: return Icons.label;
    }
  }

  // แปลง Hex String เป็น Color
  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }

  // Dialog ยืนยันลบ
  void _confirmDelete(BuildContext context, Category cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('ต้องการลบหมวดหมู่ "${cat.name}" ใช่ไหม?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () async {
              try {
                await ctx.read<EventProvider>().deleteCategory(cat.id!);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) Navigator.pop(ctx);
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Dialog เพิ่มหมวดหมู่
  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    String selectedColor = '#2196F3'; // Default Blue
    String selectedIcon = 'label';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('เพิ่มหมวดหมู่ใหม่'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl, 
                  decoration: const InputDecoration(labelText: 'ชื่อหมวดหมู่'),
                ),
                const SizedBox(height: 15),
                const Text('เลือกสี:'),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 10,
                  children: ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0', '#607D8B'].map((color) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: CircleAvatar(
                        backgroundColor: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                        radius: 14,
                        child: selectedColor == color ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 15),
                const Text('เลือกไอคอน:'),
                DropdownButton<String>(
                  value: selectedIcon,
                  isExpanded: true,
                  items: ['label', 'work', 'person', 'school', 'home', 'star'].map((k) {
                    return DropdownMenuItem(value: k, child: Row(children: [Icon(_getIconData(k)), const SizedBox(width: 8), Text(k)]));
                  }).toList(),
                  onChanged: (v) => setState(() => selectedIcon = v!),
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  ctx.read<EventProvider>().addCategory(Category(
                    name: nameCtrl.text,
                    colorHex: selectedColor,
                    iconKey: selectedIcon,
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }
}