import 'package:flutter/material.dart';
import '../core/app_colors.dart';
class _Decision { final String says, action, stage, time; const _Decision(this.says,this.action,this.stage,this.time); }
const _decisions=< _Decision >[
  _Decision('"විස්තර / sample එවන්න"','Relevant sample 1-3ක් + short value line යවන්න.','SAMPLE SENT + Due Date','Same day'),
  _Decision('"Price කොහොමද?"','Value recap → applicable price / final quote clear කරන්න.','PRICE SENT','Same day'),
  _Decision('"මිල වැඩියි"','Argue නොකර smaller / Normal / priority option suggest කරන්න.','OPTION SHARED','24h'),
  _Decision('"බලලා කියන්නම්"','"හරි, ඉක්මනක් නෑ" → Follow-up Clock start.','FOLLOW-UP','Day 2'),
  _Decision('"දැනට budget නෑ"','Pressure නොකර PARK. Future need note කරන්න.','PARKED','Stop'),
  _Decision('"Full set එක බලමු"','7-Banner Premium at Normal Base Price offer explain කරන්න.','PACKAGE INTEREST','Same day'),
  _Decision('"හරි, කරමු"','Sales talk stop → Order Gate Checklist complete කරන්න.','ORDER CONFIRMED','Same day'),
  _Decision('"File එක දෙන්න"','Generic office banner source/editable file policy explain කරන්න.','POLICY EXPLAINED','Same day'),
  _Decision('"Urgent"','Urgent availability, surcharge/lead time confirm කරලා proceed කරන්න.','URGENT CHECK','Before payment'),
  _Decision('Complaint / production issue','Argue නොකර evidence collect කර CR8iVE support වෙත handover කරන්න.','ESCALATED','Immediately'),
];
class DecisionCardScreen extends StatefulWidget { const DecisionCardScreen({super.key}); @override State<DecisionCardScreen> createState()=>_DecisionCardScreenState(); }
class _DecisionCardScreenState extends State<DecisionCardScreen> {
  String _q='';
  @override Widget build(BuildContext context){
    final list=_decisions.where((d)=>d.says.toLowerCase().contains(_q.toLowerCase())||d.action.toLowerCase().contains(_q.toLowerCase())).toList();
    return Scaffold(appBar:AppBar(title:const Text('Customer Decision Card')), body:Column(children:[Padding(padding:const EdgeInsets.all(12), child:TextField(onChanged:(v)=>setState(()=>_q=v), decoration:InputDecoration(hintText:'Customer කිව්වේ මොකක්ද?', prefixIcon:const Icon(Icons.search), filled:true, fillColor:Colors.white, border:OutlineInputBorder(borderRadius:BorderRadius.circular(14), borderSide:BorderSide.none)))), Expanded(child:ListView.builder(padding:const EdgeInsets.fromLTRB(12,0,12,20), itemCount:list.length, itemBuilder:(_,i){ final d=list[i]; return Card(margin:const EdgeInsets.only(bottom:10), child:ExpansionTile(leading:const Icon(Icons.chat_bubble_outline, color:AppColors.sky), title:Text(d.says, style:const TextStyle(fontWeight:FontWeight.bold, fontSize:14)), children:[Padding(padding:const EdgeInsets.fromLTRB(16,0,16,16), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[_row(Icons.task_alt,'Partner කරන දේ',d.action,AppColors.navy), _row(Icons.flag,'Next Stage',d.stage,AppColors.green), _row(Icons.schedule,'Time',d.time,AppColors.orange)]))])); }))]));
  }
  Widget _row(IconData i,String label,String v,Color c)=>Padding(padding:const EdgeInsets.only(bottom:8), child:Row(crossAxisAlignment:CrossAxisAlignment.start, children:[Icon(i,size:16,color:c), const SizedBox(width:8), Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text(label, style:TextStyle(fontSize:11, color:Colors.grey[600], fontWeight:FontWeight.bold)), Text(v, style:const TextStyle(fontSize:13))]))]));
}