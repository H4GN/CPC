class Payment {
  int? id; String orderId, customer, bannerSize, date; int cr8iveBase, basePaid, commission, bonusCount, partnerPaid, synced;
  Payment({this.id, required this.orderId, required this.customer, required this.bannerSize, required this.cr8iveBase, this.basePaid=0, required this.commission, this.bonusCount=1, this.partnerPaid=0, required this.date, this.synced=0});
  bool get eligible=>basePaid==1;
  String get commissionStatus=>eligible?'ELIGIBLE':'LOCKED';
  int get payableCommission=>eligible?commission:0;
  Map<String,dynamic> toMap()=>{'id':id,'orderId':orderId,'customer':customer,'bannerSize':bannerSize,'cr8iveBase':cr8iveBase,'basePaid':basePaid,'commission':commission,'bonusCount':bonusCount,'partnerPaid':partnerPaid,'date':date,'synced':synced};
  factory Payment.fromMap(Map<String,dynamic> m)=>Payment(id:m['id'] as int?, orderId:(m['orderId']??'') as String, customer:(m['customer']??'') as String, bannerSize:(m['bannerSize']??'') as String, cr8iveBase:(m['cr8iveBase']??0) as int, basePaid:(m['basePaid']??0) as int, commission:(m['commission']??0) as int, bonusCount:(m['bonusCount']??1) as int, partnerPaid:(m['partnerPaid']??0) as int, date:(m['date']??'') as String, synced:(m['synced']??0) as int);
}