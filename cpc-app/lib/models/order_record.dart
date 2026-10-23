import 'dart:convert';
class OrderRecord {
  int? id; String orderId, customer, handoverDate; Map<String,bool> checklist; int synced;
  OrderRecord({this.id, required this.orderId, required this.customer, required this.handoverDate, required this.checklist, this.synced=0});
  static const customerItems=['Customer Name','Position / Institution','Contact Number','Banner Name(s)','Exact Size(s)','Quantity','Normal / Premium','Office / Institution Name to Print'];
  static const productionItems=['Text / Data Received','Logo / Emblem / Photos Received','Theme / Colour Confirmed','Urgent? If yes, terms confirmed','Delivery Name / Address / Phone','Customer Final Amount Confirmed','Customer Payment Status Recorded','CR8iVE Base Paid = YES'];
  static List<String> get allItems=>[...customerItems,...productionItems];
  static Map<String,bool> emptyChecklist()=>{for (final i in allItems) i:false};
  int get doneCount=>checklist.values.where((v)=>v).length;
  int get totalCount=>allItems.length;
  double get progress=>totalCount==0?0:doneCount/totalCount;
  bool get basePaid=>checklist['CR8iVE Base Paid = YES']??false;
  bool get canMoveToProduction=>doneCount==totalCount && basePaid;
  Map<String,dynamic> toMap()=>{'id':id,'orderId':orderId,'customer':customer,'handoverDate':handoverDate,'checklistJson':jsonEncode(checklist),'basePaid':basePaid?1:0,'synced':synced};
  factory OrderRecord.fromMap(Map<String,dynamic> m){ final raw=(m['checklistJson']??'{}') as String; final decoded=jsonDecode(raw) as Map<String,dynamic>; final map=emptyChecklist(); decoded.forEach((k,v){ if(map.containsKey(k)) map[k]=v==true; }); return OrderRecord(id:m['id'] as int?, orderId:(m['orderId']??'') as String, customer:(m['customer']??'') as String, handoverDate:(m['handoverDate']??'') as String, checklist:map, synced:(m['synced']??0) as int); }
}