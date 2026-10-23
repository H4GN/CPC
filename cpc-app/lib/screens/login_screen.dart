import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_colors.dart';
import 'home_dashboard.dart';

class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override State<LoginScreen> createState()=>_LoginScreenState(); }
class _LoginScreenState extends State<LoginScreen> {
  final _name=TextEditingController(); final _pin=TextEditingController(); bool _loading=true, _register=false; String _savedName='';
  @override void initState(){ super.initState(); _check(); }
  Future<void> _check() async { final p=await SharedPreferences.getInstance(); final pin=p.getString('pin'); _savedName=p.getString('name')??''; setState((){_register=pin==null; _loading=false;}); }
  Future<void> _submit() async { final p=await SharedPreferences.getInstance(); if(_register){ if(_name.text.trim().isEmpty||_pin.text.length<4){ _msg('Name එක සහ අංක 4ක PIN එකක් දාන්න'); return; } await p.setString('name',_name.text.trim()); await p.setString('pin',_pin.text); _go(); } else { if(_pin.text==p.getString('pin')) _go(); else _msg('PIN එක වැරදියි'); } }
  void _msg(String m)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor:AppColors.red, content:Text(m)));
  void _go()=>Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>const HomeDashboard()));
  @override Widget build(BuildContext context){
    if(_loading) return const Scaffold(body:Center(child:CircularProgressIndicator()));
    return Scaffold(body:Container(decoration:const BoxDecoration(gradient:LinearGradient(begin:Alignment.topLeft, end:Alignment.bottomRight, colors:[AppColors.navy, Color(0xFF14557F), AppColors.sky])), child:SafeArea(child:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24), child:Column(mainAxisSize:MainAxisSize.min, children:[Container(padding:const EdgeInsets.all(20), decoration:const BoxDecoration(color:Colors.white, shape:BoxShape.circle), child:const Icon(Icons.lightbulb, size:56, color:AppColors.navy)), const SizedBox(height:16), const Text('CPC', style:TextStyle(fontSize:44, letterSpacing:6, fontWeight:FontWeight.bold, color:Colors.white)), const Text('CR8iVE Partner Control', style:TextStyle(color:Colors.white70)), const SizedBox(height:32), Card(child:Padding(padding:const EdgeInsets.all(20), child:Column(children:[Text(_register?'ගිණුම හදන්න / Create Account':'ආයුබෝවන් $_savedName', style:const TextStyle(fontSize:18, fontWeight:FontWeight.bold, color:AppColors.navy)), const SizedBox(height:16), if(_register) TextField(controller:_name, decoration:InputDecoration(labelText:'Partner Name', prefixIcon:const Icon(Icons.person), border:OutlineInputBorder(borderRadius:BorderRadius.circular(12)))), if(_register) const SizedBox(height:12), TextField(controller:_pin, keyboardType:TextInputType.number, obscureText:true, maxLength:6, decoration:InputDecoration(labelText:'PIN (4-6 digits)', counterText:'', prefixIcon:const Icon(Icons.lock), border:OutlineInputBorder(borderRadius:BorderRadius.circular(12)))), const SizedBox(height:18), SizedBox(width:double.infinity, child:FilledButton(style:FilledButton.styleFrom(backgroundColor:AppColors.navy, padding:const EdgeInsets.all(16)), onPressed:_submit, child:Text(_register?'CREATE':'LOGIN', style:const TextStyle(fontSize:16))))])))]))))));
  }
}