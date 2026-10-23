import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/db_helper.dart';
import '../models/lead.dart';
import 'leads/leads_screen.dart';
import 'followup_screen.dart';
import 'order_checklist_screen.dart';
import 'finance_screen.dart';
import 'reports_screen.dart';
import 'reference_screen.dart';
import 'price_calculator_screen.dart';
import 'decision_card_screen.dart';

class HomeDashboard extends StatefulWidget { const HomeDashboard({super.key}); @override State<HomeDashboard> createState()=>_HomeDashboardState(); }
class _HomeDashboardState extends State<HomeDashboard> {
  int _tab=0; List<Lead> leads=[];
  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async { leads=await DBHelper.getLeads(); if(mounted) setState((){}); }
  int _count(String s)=>leads.where((l)=>l.status==s).length;
  @override Widget build(BuildContext context){
    final pages=[_dashboardBody(), const LeadsScreen(), const FollowUpScreen(), const FinanceScreen(), const ReportsScreen()];
    return Scaffold(appBar:AppBar(title:const Text('CPC Dashboard')), body:pages[_tab], bottomNavigationBar:NavigationBar(selectedIndex:_tab, onDestinationSelected:(i)=>setState(()=>_tab=i), destinations:const[NavigationDestination(icon:Icon(Icons.home), label:'Home'), NavigationDestination(icon:Icon(Icons.people), label:'Leads'), NavigationDestination(icon:Icon(Icons.alarm), label:'Follow-up'), NavigationDestination(icon:Icon(Icons.payments), label:'Finance'), NavigationDestination(icon:Icon(Icons.bar_chart), label:'Reports')]));
  }
  Widget _dashboardBody(){
    return RefreshIndicator(onRefresh:_load, child:ListView(padding:const EdgeInsets.all(16), children:[
      Row(children:[_statCard('Overdue','ප්‍රමාදයි',_count('OVERDUE'),AppColors.red), const SizedBox(width:12), _statCard('Due Soon','ළඟදී',_count('DUE_SOON'),AppColors.orange)]),
      const SizedBox(height:12),
      Row(children:[_statCard('Active','ක්‍රියාත්මක',_count('ACTIVE'),AppColors.sky), const SizedBox(width:12), _statCard('Completed','සම්පූර්ණයි',_count('COMPLETED'),AppColors.green)]),
      const SizedBox(height:24),
      Text('Quick Actions', style:Theme.of(context).textTheme.titleLarge?.copyWith(color:AppColors.navy, fontWeight:FontWeight.bold)),
      const SizedBox(height:12),
      _quickTile(Icons.calculate,'Price Calculator','මිල / කොමිස් ගණනය',const PriceCalculatorScreen()),
      _quickTile(Icons.question_answer,'Decision Card','Customer reply → Action',const DecisionCardScreen()),
      _quickTile(Icons.checklist,'Order Gate Checklist','Order handover check',const OrderChecklistScreen()),
      _quickTile(Icons.help_center,'Ask CR8iVE Matrix','Ask / Escalate / Stop',const ReferenceScreen()),
    ]));
  }
  Widget _statCard(String en,String si,int count,Color color)=>Expanded(child:Container(padding:const EdgeInsets.all(16), decoration:BoxDecoration(color:color.withOpacity(0.1), borderRadius:BorderRadius.circular(16), border:Border.all(color:color, width:1.5)), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text('$count', style:TextStyle(fontSize:32, fontWeight:FontWeight.bold, color:color)), Text(en, style:const TextStyle(fontWeight:FontWeight.bold)), Text(si, style:TextStyle(fontSize:12, color:Colors.grey[600]))])));
  Widget _quickTile(IconData icon,String title,String sub,Widget page)=>Card(child:ListTile(leading:CircleAvatar(backgroundColor:AppColors.navy, child:Icon(icon,color:Colors.white,size:20)), title:Text(title, style:const TextStyle(fontWeight:FontWeight.bold)), subtitle:Text(sub), trailing:const Icon(Icons.chevron_right), onTap:()=>Navigator.push(context, MaterialPageRoute(builder:(_)=>page))));
}