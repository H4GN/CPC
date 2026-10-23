import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../data/db_helper.dart';
import '../models/order_record.dart';

class OrderChecklistScreen extends StatefulWidget { const OrderChecklistScreen({super.key}); @override State<OrderChecklistScreen> createState()=>_OrderChecklistScreenState(); }
class _OrderChecklistScreenState extends State<OrderChecklistScreen> {
  final _orderId=TextEditingController(); final _customer=TextEditingController(); Map<String,bool> _check=OrderRecord.emptyChecklist(); List<OrderRecord> _saved=[]; int? _editingId;
  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async { _saved=await DBHelper.getOrders(); if(mounted) setState((){}); }
  OrderRecord get _current=>OrderRecord(id:_editingId, orderId:_orderId.text.trim(), customer:_customer.text.trim(), handoverDate:DateFormat('yyyy-MM-dd').format(DateTime.now()), checklist:_check);
  @override Widget build(BuildContext context){
    final o=_current; final ok=o.canMoveToProduction;
    return Scaffold(appBar:AppBar(title:const Text('Order Gate Checklist')), body:ListView(padding:const EdgeInsets.all(14), children:[
      Row(children:[Expanded(child:_tf(_orderId,'Order ID')), const SizedBox(width:10), Expanded(flex:2, child:_tf(_customer,'Customer'))]),
      const SizedBox(height:14),
      Container(padding:const EdgeInsets.all(14), decoration:BoxDecoration(color:ok?AppColors.green.withOpacity(0.1):AppColors.orange.withOpacity(0.1), borderRadius:BorderRadius.circular(14), border:Border.all(color:ok?AppColors.green:AppColors.orange)), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[Text('${o.doneCount} / ${o.totalCount} complete', style:const TextStyle(fontWeight:FontWeight.bold)), Text(ok?'✅ PRODUCTION OK':'🔒 LOCKED', style:TextStyle(fontWeight:FontWeight.bold, color:ok?AppColors.green:AppColors.red))]), const SizedBox(height:8), ClipRRect(borderRadius:BorderRadius.circular(8), child:LinearProgressIndicator(value:o.progress, minHeight:10, backgroundColor:Colors.grey.shade300, color:ok?AppColors.green:AppColors.orange)) ])),
      const SizedBox(height:18),
      _group('Customer / Order Details', OrderRecord.customerItems),
      const SizedBox(height:10),
      _group('Production / Delivery / Payment', OrderRecord.productionItems),
      const SizedBox(height:14),
      Container(padding:const EdgeInsets.all(12), decoration:BoxDecoration(color:AppColors.sky.withOpacity(0.08), border:Border.all(color:AppColors.sky), borderRadius:BorderRadius.circular(14)), child:const Text('GATE RULE: "CR8iVE Base Paid = YES" සහ සියලු fields complete වුණාම පමණක් PRODUCTION stage එකට move කරන්න.', style:TextStyle(fontSize:12))),
      const SizedBox(height:16),
      FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:AppColors.navy, padding:const EdgeInsets.all(16)), onPressed:_save, icon:const Icon(Icons.save), label:Text(_editingId==null?'SAVE HANDOVER RECORD':'UPDATE')),
      const SizedBox(height:24),
      const Text('Handover Records', style:TextStyle(fontSize:17, fontWeight:FontWeight.bold, color:AppColors.navy)),
      const SizedBox(height:8),
      if(_saved.isEmpty) const Text('Records නැහැ.', style:TextStyle(color:Colors.grey)),
      ..._saved.map((r)=>Card(margin:const EdgeInsets.only(bottom:8), child:ListTile(leading:Icon(r.canMoveToProduction?Icons.check_circle:Icons.lock, color:r.canMoveToProduction?AppColors.green:AppColors.red), title:Text('${r.orderId} • ${r.customer}', style:const TextStyle(fontWeight:FontWeight.bold)), subtitle:Text('${r.doneCount}/${r.totalCount} • ${r.handoverDate}'), trailing:PopupMenuButton<String>(onSelected:(v) async { if(v=='edit'){ setState((){ _editingId=r.id; _orderId.text=r.orderId; _customer.text=r.customer; _check=Map.of(r.checklist); }); } else { await DBHelper.deleteOrder(r.id!); _load(); } }, itemBuilder:(_)=>const[PopupMenuItem(value:'edit', child:Text('Edit')), PopupMenuItem(value:'del', child:Text('Delete'))])))),
      const SizedBox(height:30),
    ]));
  }
  Widget _tf(TextEditingController c,String l)=>TextField(controller:c, decoration:InputDecoration(labelText:l, isDense:true, border:OutlineInputBorder(borderRadius:BorderRadius.circular(12))));
  Widget _group(String title,List<String> items)=>Card(child:Column(children:[Container(width:double.infinity, padding:const EdgeInsets.all(12), decoration:const BoxDecoration(color:AppColors.navy, borderRadius:BorderRadius.vertical(top:Radius.circular(16))), child:Text(title, style:const TextStyle(color:Colors.white, fontWeight:FontWeight.bold))), ...items.map((i)=>CheckboxListTile(dense:true, activeColor:AppColors.green, controlAffinity:ListTileControlAffinity.leading, title:Text(i, style:TextStyle(fontSize:13, fontWeight:i.contains('Base Paid')?FontWeight.bold:FontWeight.normal, color:i.contains('Base Paid')?AppColors.navy:null)), value:_check[i]??false, onChanged:(v)=>setState(()=>_check[i]=v??false)))]));
  Future<void> _save() async { if(_orderId.text.trim().isEmpty||_customer.text.trim().isEmpty){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor:AppColors.red, content:Text('Order ID සහ Customer අනිවාර්යයි'))); return; } final o=_current; if(_editingId==null) await DBHelper.insertOrder(o); else await DBHelper.updateOrder(o); setState((){ _editingId=null; _orderId.clear(); _customer.clear(); _check=OrderRecord.emptyChecklist(); }); _load(); if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor:AppColors.green, content:Text('Saved ✔'))); }
}