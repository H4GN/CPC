class Lead {
  int? id;
  String customer, office, position, contact, currentStage, lastAction, nextAction, dueDate, sampleSentDate, createdAt;
  int synced;
  Lead({this.id, required this.customer, this.office='', this.position='', this.contact='', this.currentStage='NEW', this.lastAction='', required this.nextAction, required this.dueDate, this.sampleSentDate='', String? createdAt, this.synced=0}) : createdAt = createdAt ?? _today();
  static String _today(){ final n=DateTime.now(); return '${n.year.toString().padLeft(4,'0')}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}'; }
  String get status {
    if (currentStage=='DELIVERED'||currentStage=='REFERRAL'||currentStage=='PAID'||currentStage=='PRODUCTION') return 'COMPLETED';
    if (currentStage=='PARKED') return 'PARKED';
    if (dueDate.isEmpty) return 'ACTIVE';
    final due=DateTime.tryParse(dueDate); if (due==null) return 'ACTIVE';
    final t=DateTime.now(); final today=DateTime(t.year,t.month,t.day);
    if (due.isBefore(today)) return 'OVERDUE';
    if (due.difference(today).inDays<=1) return 'DUE_SOON';
    return 'ACTIVE';
  }
  int get clockDay {
    if (sampleSentDate.isEmpty) return -1;
    final s=DateTime.tryParse(sampleSentDate); if (s==null) return -1;
    final t=DateTime.now(); return DateTime(t.year,t.month,t.day).difference(s).inDays;
  }
  Map<String,dynamic> toMap()=>{'id':id,'customer':customer,'office':office,'position':position,'contact':contact,'currentStage':currentStage,'lastAction':lastAction,'nextAction':nextAction,'dueDate':dueDate,'sampleSentDate':sampleSentDate,'createdAt':createdAt,'synced':synced};
  factory Lead.fromMap(Map<String,dynamic> m)=>Lead(id:m['id'] as int?, customer:(m['customer']??'') as String, office:(m['office']??'') as String, position:(m['position']??'') as String, contact:(m['contact']??'') as String, currentStage:(m['currentStage']??'NEW') as String, lastAction:(m['lastAction']??'') as String, nextAction:(m['nextAction']??'') as String, dueDate:(m['dueDate']??'') as String, sampleSentDate:(m['sampleSentDate']??'') as String, createdAt:(m['createdAt']??'') as String, synced:(m['synced']??0) as int);
}