import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';

class PriceCalculatorScreen extends StatefulWidget { const PriceCalculatorScreen({super.key}); @override State<PriceCalculatorScreen> createState()=>_PriceCalculatorScreenState(); }
class _PriceCalculatorScreenState extends State<PriceCalculatorScreen> {
  PriceItem _item=PriceTable.items.first; bool _premium=false, _sevenPack=false; int _qty=1;
  @override Widget build(BuildContext context){
    final base=(_premium?_item.premiumBase:_item.normalBase)*_qty;
    final comm=(_sevenPack?_item.packCommission:_item.singleCommission)*_qty;
    final totalBase=base; final totalComm=comm;
    return Scaffold(appBar:AppBar(title:const Text('Price & Commission')), body:ListView(padding:const EdgeInsets.all(16), children:[
      DropdownButtonFormField<PriceItem>(value:_item, decoration:InputDecoration(labelText:'Banner Size', border:OutlineInputBorder(borderRadius:BorderRadius.circular(12))), items:PriceTable.items.map((p)=>DropdownMenuItem(value:p, child:Text(p.size))).toList(), onChanged:(v)=>setState(()=>_item=v!)),
      const SizedBox(height:12),
      SwitchListTile(title:const Text('Premium Base'), value:_premium, activeColor:AppColors.sky, onChanged:(v)=>setState(()=>_premium=v)),
      SwitchListTile(title:const Text('7-Pack Commission Rate'), value:_sevenPack, activeColor:AppColors.sky, onChanged:(v)=>setState(()=>_sevenPack=v)),
      Row(children:[const Text('Quantity:', style:TextStyle(fontSize:16)), IconButton(onPressed:()=>setState(()=>_qty=_qty>1?_qty-1:1), icon:const Icon(Icons.remove_circle, color:AppColors.navy)), Text('$_qty', style:const TextStyle(fontSize:20, fontWeight:FontWeight.bold)), IconButton(onPressed:()=>setState(()=>_qty++), icon:const Icon(Icons.add_circle, color:AppColors.navy))]),
      const SizedBox(height:16),
      Container(padding:const EdgeInsets.all(20), decoration:BoxDecoration(gradient:const LinearGradient(colors:[AppColors.navy, Color(0xFF14557F)]), borderRadius:BorderRadius.circular(20)), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[_row('Base (each)','Rs. ${_premium?_item.premiumBase:_item.normalBase}'), _row('Commission (each)','Rs. ${_sevenPack?_item.packCommission:_item.singleCommission}'), const Divider(color:Colors.white38), _row('Total Base','Rs. $totalBase', big:true), _row('Total Commission','Rs. $totalComm', big:true, color:AppColors.orange)])),
      const SizedBox(height:16),
      Card(child:Padding(padding:const EdgeInsets.all(16), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:const[Text('Monthly Bonus Tiers', style:TextStyle(fontWeight:FontWeight.bold, color:AppColors.navy)), SizedBox(height:8), Text('🔵 5 Paid Banners → + Rs. 500'), Text('🟣 10 Paid Banners → + Rs. 1,500'), Text('🟠 15+ Paid Banners → + Rs. 3,000'), SizedBox(height:8), Text('⚠️ Commission Lock: Paid orders සඳහා පමණි.', style:TextStyle(fontSize:12, color:AppColors.red))]))),
    ]));
  }
  Widget _row(String l,String v,{bool big=false, Color color=Colors.white})=>Padding(padding:const EdgeInsets.symmetric(vertical:4), child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[Text(l, style:const TextStyle(color:Colors.white70)), Text(v, style:TextStyle(color:color, fontSize:big?20:15, fontWeight:big?FontWeight.bold:FontWeight.normal))]));
}