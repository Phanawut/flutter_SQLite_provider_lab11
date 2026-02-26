import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // เพิ่ม import นี้เพื่อใช้ Sqflite.firstIntValue
import '../../data/db/app_database.dart';
import '../../data/models/event_model.dart';
import '../../data/models/category_model.dart';  // Model for Category objects

class EventProvider extends ChangeNotifier {
  List<Event> _events = [];
  List<Category> _categories = [];
  
  // ตัวแปรสำหรับ Filter
  String _searchQuery = '';
  String _filterStatus = 'All'; 
  int? _filterCategoryId;

  // Getter สำหรับดึงรายการกิจกรรมที่ผ่านการกรองแล้ว
  List<Event> get events {
    List<Event> result = _events;

    // 1. กรองตามหมวดหมู่
    if (_filterCategoryId != null) {
      result = result.where((e) => e.categoryId == _filterCategoryId).toList();
    }

    // 2. กรองตามสถานะ
    if (_filterStatus != 'All') {
      result = result.where((e) => e.status == _filterStatus).toList();
    }

    // 3. ค้นหาตามชื่อ
    if (_searchQuery.isNotEmpty) {
      result = result.where((e) => e.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    
    // 4. เรียงลำดับ (วันที่และเวลาเริ่ม)
    result.sort((a, b) {
      int dateComp = a.eventDate.compareTo(b.eventDate);
      if (dateComp != 0) return dateComp;
      return a.startTime.compareTo(b.startTime);
    });

    return result;
  }

  List<Category> get categories => _categories;

  // --- โหลดข้อมูลทั้งหมด ---
  Future<void> loadData() async {
    final db = await AppDatabase.instance.database;
    
    final catMaps = await db.query('categories');
    _categories = catMaps.map((map) => Category.fromMap(map)).toList();

    final eventMaps = await db.query('events');
    _events = eventMaps.map((map) => Event.fromMap(map)).toList();
    
    notifyListeners();
  }

  // --- จัดการ Event (CRUD) ---
  Future<void> addEvent(Event event) async {
    final db = await AppDatabase.instance.database;
    await db.insert('events', event.toMap());
    await loadData();
  }

  Future<void> updateEvent(Event event) async {
    final db = await AppDatabase.instance.database;
    await db.update('events', event.toMap(), where: 'id = ?', whereArgs: [event.id]);
    await loadData();
  }

  Future<void> deleteEvent(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('events', where: 'id = ?', whereArgs: [id]);
    await loadData();
  }

  // --- จัดการ Category (ส่วนที่เพิ่มใหม่) ---
  Future<void> addCategory(Category category) async {
    final db = await AppDatabase.instance.database;
    await db.insert('categories', category.toMap());
    await loadData();
  }

  Future<void> deleteCategory(int id) async {
    final db = await AppDatabase.instance.database;
    // เช็คก่อนลบ: ห้ามลบหมวดหมู่ที่มีกิจกรรมใช้งานอยู่
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM events WHERE category_id = ?', [id])
    );
    
    if (count != null && count > 0) {
      throw Exception('ไม่สามารถลบได้: มีกิจกรรมที่ใช้หมวดหมู่นี้อยู่');
    }

    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    await loadData();
  }

  // --- ตัวจัดการ Filter ---
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }
}