class Stages {
  static const list = [
    'NEW', 'CONTACTED', 'INTERESTED', 'SAMPLE SENT',
    'NEED CONFIRMED', 'OPTION SHARED', 'PRICE SENT',
    'FOLLOW-UP', 'ORDER CONFIRMED', 'PAYMENT PENDING',
    'PAID', 'PRODUCTION', 'DELIVERED', 'REFERRAL',
    'PARKED', 'ESCALATED',
  ];

  static const Map<String, Map<String, String>> stageMap = {
    'NEW': {
      'action_si': 'Friendly first contact. Office/display need ගැන සාමාන්‍ය conversation එකක් start කරන්න.',
      'action_en': 'Friendly first contact. Start casual conversation.',
      'timeLimit': '24h',
      'moveTo': 'CONTACTED',
      'rule_si': 'Price first message එකක් නොයවන්න.',
      'rule_en': 'Do not send price in first message.',
    },
    'CONTACTED': {
      'action_si': 'දැනට තියෙන display situation සහ priority එක අහන්න.',
      'action_en': 'Ask current display situation and priority.',
      'timeLimit': 'Same day / 24h',
      'moveTo': 'INTERESTED',
      'rule_si': 'Reply නැත්නම් Follow-up Clock start.',
      'rule_en': 'No reply -> start Follow-up Clock.',
    },
    'INTERESTED': {
      'action_si': 'Relevant sample + short value line යවන්න.',
      'action_en': 'Send relevant sample + value line.',
      'timeLimit': 'Same day',
      'moveTo': 'SAMPLE SENT',
      'rule_si': 'Unrelated samples ගොඩක් නොයවන්න.',
      'rule_en': 'Do not send many unrelated samples.',
    },
    'SAMPLE SENT': {
      'action_si': 'Actual need අහන්න. office photo ඉල්ලන්න.',
      'action_en': 'Ask actual need. Request photo if needed.',
      'timeLimit': '24h',
      'moveTo': 'NEED CONFIRMED',
      'rule_si': 'Setup criticize නොකරන්න.',
      'rule_en': 'Do not criticize setup.',
    },
    'NEED CONFIRMED': {
      'action_si': 'Single / small set / full set option recommend කරන්න.',
      'action_en': 'Recommend fitting option.',
      'timeLimit': '24h',
      'moveTo': 'OPTION SHARED',
      'rule_si': 'Need නැති items push නොකරන්න.',
      'rule_en': 'Do not push unneeded items.',
    },
    'OPTION SHARED': {
      'action_si': 'Value recap + final quote clear කරන්න.',
      'action_en': 'Value recap + clear final quote.',
      'timeLimit': 'Same day',
      'moveTo': 'PRICE SENT',
      'rule_si': 'Fake discount නොකරන්න.',
      'rule_en': 'No fake discount.',
    },
    'PRICE SENT': {
      'action_si': 'Day 2 / 5 / 10 follow-up sequence.',
      'action_en': 'Day 2 / 5 / 10 follow-up.',
      'timeLimit': 'Follow-up Clock',
      'moveTo': 'FOLLOW-UP / PARK',
      'rule_si': 'Day 10 පසු no response නම් PARK.',
      'rule_en': 'No response after Day 10 -> PARK.',
    },
    'ORDER CONFIRMED': {
      'action_si': 'Sales talk stop. Order Gate Checklist 100% complete.',
      'action_en': 'Stop sales talk. Complete checklist.',
      'timeLimit': 'Same day',
      'moveTo': 'PAYMENT PENDING',
      'rule_si': 'Missing fields නම් handover නොකරන්න.',
      'rule_en': 'Do not handover with missing fields.',
    },
    'PAID': {
      'action_si': 'Design/production handover.',
      'action_en': 'Handover to production.',
      'timeLimit': 'Same day',
      'moveTo': 'PRODUCTION',
      'rule_si': 'Base unpaid නම් production lock.',
      'rule_en': 'Base unpaid -> locked.',
    },
    'DELIVERED': {
      'action_si': 'Feedback check + referral ask.',
      'action_en': 'Feedback + ask referral.',
      'timeLimit': '1-3 days',
      'moveTo': 'FEEDBACK / REFERRAL',
      'rule_si': 'One respectful referral only.',
      'rule_en': 'One respectful referral only.',
    },
  };
}

class PriceItem {
  final String size;
  final int normalBase, premiumBase, singleCommission, packCommission;
  const PriceItem(this.size, this.normalBase, this.premiumBase, this.singleCommission, this.packCommission);
}

class PriceTable {
  static const items = [
    PriceItem('3 x 2 ft', 1700, 2200, 150, 175),
    PriceItem('4 x 2 ft', 2000, 2500, 200, 225),
    PriceItem('4 x 3 ft', 2700, 3100, 250, 275),
    PriceItem('5 x 3 ft', 3200, 3500, 300, 325),
    PriceItem('5 x 4 ft', 3800, 4000, 350, 375),
    PriceItem('6 x 4 ft', 4400, 4500, 400, 425),
  ];
  static int monthlyBonus(int paidBanners) {
    if (paidBanners >= 15) return 3000;
    if (paidBanners >= 10) return 1500;
    if (paidBanners >= 5) return 500;
    return 0;
  }
}