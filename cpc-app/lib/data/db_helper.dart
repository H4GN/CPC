import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/lead.dart';
import '../models/payment.dart';
import '../models/order_record.dart';

class DBHelper {
  static Database? _db;
  static Future<Database> get db async { _db??=await _init(); return _db!; }
  static Future<Database> _init() async {
    final path=join(await getDatabasesPath(),'cpc.db');
    return openDatabase(path, version:1, onCreate:(d,v) async{
      await d.execute('CREATE TABLE leads(id INTEGER PRIMARY KEY AUTOINCREMENT, customer TEXT, office TEXT, position TEXT, contact TEXT, currentStage TEXT, lastAction TEXT, nextAction TEXT, dueDate TEXT, sampleSentDate TEXT, createdAt TEXT, synced INTEGER DEFAULT 0)');
      await d.execute('CREATE TABLE orders(id INTEGER PRIMARY KEY AUTOINCREMENT, orderId TEXT, customer TEXT, handoverDate TEXT, checklistJson TEXT, basePaid INTEGER DEFAULT 0, synced INTEGER DEFAULT 0)');
      await d.execute('CREATE TABLE payments(id INTEGER PRIMARY KEY AUTOINCREMENT, orderId TEXT, customer TEXT, bannerSize TEXT, cr8iveBase INTEGER, basePaid INTEGER DEFAULT 0, commission INTEGER, bonusCount INTEGER, partnerPaid INTEGER DEFAULT 0, date TEXT, synced INTEGER DEFAULT 0)');
      await d.execute('CREATE TABLE followup_logs(id INTEGER PRIMARY KEY AUTOINCREMENT, leadId INTEGER, date TEXT, note TEXT)');
    });
  }
  static Future<int> insertLead(Lead l) async => (await db).insert('leads', l.toMap()..remove('id'));
  static Future<int> updateLead(Lead l) async => (await db).update('leads', l.toMap(), where:'id=?', whereArgs:[l.id]);
  static Future<int> deleteLead(int id) async => (await db).delete('leads', where:'id=?', whereArgs:[id]);
  static Future<List<Lead>> getLeads() async { final rows=await (await db).query('leads', orderBy:'dueDate ASC'); return rows.map(Lead.fromMap).toList(); }
  static Future<int> insertOrder(OrderRecord o) async => (await db).insert('orders', o.toMap()..remove('id'));
  static Future<int> updateOrder(OrderRecord o) async => (await db).update('orders', o.toMap(), where:'id=?', whereArgs:[o.id]);
  static Future<int> deleteOrder(int id) async => (await db).delete('orders', where:'id=?', whereArgs:[id]);
  static Future<List<OrderRecord>> getOrders() async { final rows=await (await db).query('orders', orderBy:'id DESC'); return rows.map(OrderRecord.fromMap).toList(); }
  static Future<int> insertPayment(Payment p) async => (await db).insert('payments', p.toMap()..remove('id'));
  static Future<int> updatePayment(Payment p) async => (await db).update('payments', p.toMap(), where:'id=?', whereArgs:[p.id]);
  static Future<int> deletePayment(int id) async => (await db).delete('payments', where:'id=?', whereArgs:[id]);
  static Future<List<Payment>> getPayments() async { final rows=await (await db).query('payments', orderBy:'date DESC, id DESC'); return rows.map(Payment.fromMap).toList(); }
  static Future<void> logFollowUp(int leadId, String date, String note) async { await (await db).insert('followup_logs', {'leadId':leadId,'date':date,'note':note}); }
  static Future<int> countFollowUps(String from, String to) async { final r=await (await db).rawQuery('SELECT COUNT(*) c FROM followup_logs WHERE date >= ? AND date <= ?', [from,to]); return (r.first['c'] as int?)??0; }
}