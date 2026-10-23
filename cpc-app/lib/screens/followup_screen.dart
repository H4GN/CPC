import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../data/db_helper.dart';
import '../models/lead.dart';

class FollowUpScreen extends StatefulWidget { const FollowUpScreen({super.key}); @override State<FollowUpScreen> createState()=>_FollowUpScreenState(); }
class _FollowUpScreenState extends State<FollowUpScreen> {
  List<Lead> _leads=[];
  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async { _leads=await DBHelper.getLeads(); if(mounted) setState((){}); }
  @override Widget build(BuildContext context){
    final due=_leads.where((l)=>l.status=='OVERDUE'||l.status=='DUE_SOON').toList();
    final clock=_leads.where((l)=>l.clockDay>=0 && l.status!='COMPLETED' && l.currentStage!='PARKED').toList();
    return RefreshIndicator(onRefresh:_load, child:ListView(padding:const EdgeInsets.all(14), children:[
      const Text('Follow-up Clock', style:TextStyle(fontSize:20, fontWeight:FontWeight.bold, color:AppColors.navy)),
      const Text('Customer pressure නොකර fixed follow-up rhythm එකක්.', style:TextStyle(fontSize:12, color:Colors.grey)),
      const SizedBox(height:12),
      _clockCard('DAY 0','Need + Sample',AppColors.sky,'Relevant sample එක යවන්න. Requirement note කරන්න.','Record: Sample Sent date + Next Due Date.'),
      _clockCard('DAY 2','Helpful Follow-up',AppColors.navy,'"Sample එක බලන්න ලැබුණාද? Size / need එක ගැන උදව් ඕනද?"','Limit: One short message.'),
      _clockCard('DAY 5','Option / Package',AppColors.orange,'Multiple needs තිබේ නම් package/value option එක explain කරන්න.','Limit: New value එකක් තිබුණොත් පමණක්.'),
      _clockCard('DAY 10','Close / Park',AppColors.red,'Final respectful check. Decision නැත්නම් PARK.','Stop: Repeated follow-up නොකරන්න.'),
      const SizedBox(height:8),
      Container(padding:const EdgeInsets.all(12), decoration:BoxDecoration(color:AppColors.sky.withOpacity(0.08), border:Border.all(color:AppColors.sky), borderRadius:BorderRadius.circular(14)), child:const Text('Follow-up Rule: "Reply නැහැ" කියන එක "තව message යවන්න" කියන signal එකක් නෙමෙයි. Day 10 පසු PARK කරලා future need එකක් එනතෙක් නවත්වන්න.', style:TextStyle(fontSize:12))),
      const SizedBox(height:22),
      _section('Due / Overdue Follow-ups', due.length),
      if(due.isEmpty) _empty('අද due follow-ups නැහැ 🎉'),
      ...due.map(_dueTile),
      const SizedBox(height:22),
      _section('Clock Running (Sample Sent)', clock.length),
      if(clock.isEmpty) _empty('Clock running leads නැහැ.'),
      ...clock.map(_clockTile),
      const SizedBox(height:60),
    ]));
  }
  Widget _section(String t,int n)=>Padding(padding:const EdgeInsets.only(bottom:8), child:Text('$t  ($n)', style:const TextStyle(fontSize:17, fontWeight:FontWeight.bold, color:AppColors.navy)));
  Widget _empty(String t)=>Padding(padding:const EdgeInsets.symmetric(vertical:10), child:Text(t, style:const TextStyle(color:Colors.grey)));
  Widget _clockCard(String day,String title,Color c,String body,String foot)=>Card(margin:const EdgeInsets.only(bottom:10), child:Padding(padding:const EdgeInsets.all(14), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Row(children:[Container(padding:const EdgeInsets.symmetric(horizontal:10, vertical:4), decoration:BoxDecoration(color:c, borderRadius:BorderRadius.circular(20)), child:Text(day, style:const TextStyle(color:Colors.white, fontSize:11, fontWeight:FontWeight.bold))), const SizedBox(width:8), Text(title, style:const TextStyle(fontWeight:FontWeight.bold))]), const SizedBox(height:8), Text(body, style:const TextStyle(fontSize:13)), const SizedBox(height:6), Text(foot, style:TextStyle(fontSize:11, color:Colors.grey[700], fontStyle:FontStyle.italic)) ])));
  Widget _dueTile(Lead l){ final c=AppColors.statusColor(l.status); return Card(margin:const EdgeInsets.only(bottom:8), child:ListTile(leading:CircleAvatar(backgroundColor:c.withOpacity(0.18), child:Icon(Icons.alarm, color:c, size:20)), title:Text(l.customer, style:const TextStyle(fontWeight:FontWeight.bold)), subtitle:Text('${l.nextAction}\nDue: ${l.dueDate}', style:const TextStyle(fontSize:12)), isThreeLine:true, trailing:FilledButton(style:FilledButton.styleFrom(backgroundColor:AppColors.green), onPressed:()=>_doneSheet(l), child:const Text('Done')))); }
  Widget _clockTile(Lead l){ final d=l.clockDay; final next=d<=0?2:(d<=2?5:(d<=5?10:-1)); final park=d>10; return Card(margin:const EdgeInsets.only(bottom:8), color:park?AppColors.red.withOpacity(0.05):null, child:ListTile(leading:CircleAvatar(backgroundColor:AppColors.navy, child:Text('D$d', style:const TextStyle(color:Colors.white, fontSize:12))), title:Text(l.customer, style:const TextStyle(fontWeight:FontWeight.bold)), subtitle:Text(park?'Day 10 ඉක්මවා ඇත → PARK කරන්න':'Next milestone: Day $next'), trailing:park?TextButton(onPressed:() async { l.currentStage='PARKED'; l.nextAction='Future need එකක් එනතෙක් නවතා ඇත'; await DBHelper.updateLead(l); _load(); }, child:const Text('PARK', style:TextStyle(color:AppColors.red))):null)); }
  void _doneSheet(Lead l){ showModalBottomSheet(context:context, shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(20))), builder:(_)=>Padding(padding:const EdgeInsets.all(20), child:Column(mainAxisSize:MainAxisSize.min, crossAxisAlignment:CrossAxisAlignment.start, children:[Text('Follow-up complete: ${l.customer}', style:const TextStyle(fontWeight:FontWeight.bold, fontSize:16)), const SizedBox(height:6), const Text('ඊළඟ Due Date එක තෝරන්න:', style:TextStyle(fontSize:12, color:Colors.grey)), const SizedBox(height:14), Wrap(spacing:8, children:[_dayBtn(l,2), _dayBtn(l,3), _dayBtn(l,5), _dayBtn(l,10)])]))); }
  Widget _dayBtn(Lead l,int days)=>FilledButton(style:FilledButton.styleFrom(backgroundColor:AppColors.navy), onPressed:() async { final today=DateTime.now(); final f=DateFormat('yyyy-MM-dd'); await DBHelper.logFollowUp(l.id!, f.format(today), l.nextAction); l.lastAction=l.nextAction; l.dueDate=f.format(today.add(Duration(days:days))); await DBHelper.updateLead(l); if(mounted) Navigator.pop(context); _load(); }, child:Text('+$days days'));
}