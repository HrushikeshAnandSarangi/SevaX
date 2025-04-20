import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/timezone/widgets/timezone_card.dart';
import '../../ui/screens/timezone/timezone_search_delegate.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

import '../core.dart';

//import 'package:timezone/timezone.dart';
class TimezoneListData {
  final timezonelist = [
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: -11,
//        timezoneAbb: 'ST',
//        timezoneName: 'SAMOA STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -10,
        timezoneAbb: 'HAT',
        timezoneName: 'HAWAII-ALEUTIAN STANDARD TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: -9,
//        timezoneAbb: 'AKT',
//        timezoneName: 'ALASKA TIME ZONE'),
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: -9,
//        timezoneAbb: 'AKDT',
//        timezoneName: 'ALASKA DAY LIGHT TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -7,
        timezoneAbb: 'MST',
        timezoneName: 'MOUNTAIN STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -6,
        timezoneAbb: 'MDT',
        timezoneName: 'MOUNTAIN DAY LIGHT TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -8,
        timezoneAbb: 'PT',
        timezoneName: 'PACIFIC TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -7,
        timezoneAbb: 'PDT',
        timezoneName: 'PACIFIC DAY LIGHT TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -7,
        timezoneAbb: 'MT',
        timezoneName: 'MOUNTAIN TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -6,
        timezoneAbb: 'CT',
        timezoneName: 'CENTRAL STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -5,
        timezoneAbb: 'EDT',
        timezoneName: 'EASTERN DAY LIGHT TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -10,
        timezoneAbb: 'HST',
        timezoneName: 'HAWAII-ALEUTIAN TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -9,
        timezoneAbb: 'HDT',
        timezoneName: 'HAWAII-ALEUTIAN DAY LIGHT TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -5,
        timezoneAbb: 'ET',
        timezoneName: 'EASTERN TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -4,
        timezoneAbb: 'AST',
        timezoneName: 'ATLANTIC STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 10,
        timezoneAbb: 'ChT',
        timezoneName: 'CHAMORRO STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 12,
        timezoneAbb: 'WIT',
        timezoneName: 'WAKE ISLAND TIME ZONE'),

    //europian timezones

    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 0,
        timezoneAbb: 'WET',
        timezoneName: 'WESTERN EUROPEAN TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 1,
        timezoneAbb: 'CET',
        timezoneName: 'CENTRAL EUROPEAN TIME'),

    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 3,
        timezoneAbb: 'MSK',
        timezoneName: 'MOSCOW TIME'),

    //Australia

//    TimeZoneModel(
//      offsetFromUtcMin: 0,
//      offsetFromUtc: 11,
//      timezoneAbb: 'ACTT',
//      timezoneName: 'AUSTRALIAN CAPITAL TERRITORY TIME',
//    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 11,
      timezoneAbb: 'VT',
      timezoneName: 'VICTORIA TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 11,
      timezoneAbb: 'NSWT',
      timezoneName: 'NEW SOUTH WALES TIME',
    ),

    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 10,
        timezoneAbb: 'QT',
        timezoneName: 'QUEENSLAND TIME'),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 9,
      timezoneAbb: 'NTT',
      timezoneName: 'NORTHERN TERRITORY TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'TT',
      timezoneName: 'TASMANIA TIME',
    ),

//    TimeZoneModel(
//      offsetFromUtcMin: 0,
//      offsetFromUtc: 8,
//      timezoneAbb: 'WA',
//      timezoneName: 'WESTERN AUSTRALIA (MOST)',
//    ),
    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'WA',
      timezoneName: 'WESTERN AUSTRALIA (EUCLA)',
    ),
    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 10,
      timezoneAbb: 'SAT',
      timezoneName: 'SOUTH AUSTRALIA TIME',
    ),

    //Asian

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'AMST',
      timezoneName: 'ARMENIA SUMMER TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'AQTT',
      timezoneName: 'AQTOBE TIME',
    ),

//    TimeZoneModel(
//      offsetFromUtcMin: 0,
//      offsetFromUtc: 3,
//      timezoneAbb: 'ADT',
//      timezoneName: 'ARABIA DAYLIGHT TIME',
//    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 3,
      timezoneAbb: 'AST',
      timezoneName: 'ARAB STANDARD TIME',
    ),

//    TimeZoneModel(
//      offsetFromUtcMin: 0,
//      offsetFromUtc: 3,
//      timezoneAbb: 'AST',
//      timezoneName: 'ARABIA STANDARD TIME',
//    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 4,
      timezoneAbb: 'AT',
      timezoneName: 'ATLANTIC TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'AZST',
      timezoneName: 'AZERBAIJAN SUMMER TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'BT',
      timezoneName: 'BRUNEI TIME',
    ),

//    TimeZoneModel(
//      offsetFromUtcMin: 0,
//      offsetFromUtc: 6,
//      timezoneAbb: 'BT',
//      timezoneName: 'BANGLADESH TIME',
//    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 6,
      timezoneAbb: 'BST',
      timezoneName: 'BANGLADESH STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 6,
      timezoneAbb: 'BTT',
      timezoneName: 'BHUTAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'CHOT',
      timezoneName: 'CHOIBALSAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 9,
      timezoneAbb: 'CHOST',
      timezoneName: 'CHOIBALSAN SUMMER TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'CST',
      timezoneName: 'CHINA STANDARD TIME',
    ),

//    TimeZoneModel(
//      offsetFromUtcMin: 0,
//      offsetFromUtc: 8,
//      timezoneAbb: 'CT',
//      timezoneName: 'CHINA TIME',
//    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 3,
      timezoneAbb: 'EEST',
      timezoneName: 'EASTERN EUROPE SUMMER TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 2,
      timezoneAbb: 'EET',
      timezoneName: 'EASTERN EUROPE TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 4,
      timezoneAbb: 'GET',
      timezoneName: 'GEORGIA STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 0,
      timezoneAbb: 'GMT',
      timezoneName: 'GREENWICH MEAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 4,
      timezoneAbb: 'GST',
      timezoneName: 'GULF STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'HKT',
      timezoneName: 'HONG KONG TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 7,
      timezoneAbb: 'HOVT',
      timezoneName: 'HOVD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 7,
      timezoneAbb: 'ICT',
      timezoneName: 'INDOCHINA TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 3,
      timezoneAbb: 'IDT',
      timezoneName: 'ISRAEL DAYLIGHT TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 4,
      timezoneAbb: 'IRDT',
      timezoneName: 'IRAN DAYLIGHT TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'IRKT',
      timezoneName: 'IRKUTSK TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 9,
      timezoneAbb: 'IRKST',
      timezoneName: 'IRKUTSK SUMMER TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 3,
      timezoneAbb: 'IRST',
      timezoneName: 'IRAN STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 30,
      offsetFromUtc: 5,
      timezoneAbb: 'IST',
      timezoneName: 'INDIA STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 2,
      timezoneAbb: 'IST',
      timezoneName: 'ISRAEL STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 9,
      timezoneAbb: 'JST',
      timezoneName: 'JAPAN STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 6,
      timezoneAbb: 'KGT',
      timezoneName: 'KYRGYZSTAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 7,
      timezoneAbb: 'KRAT',
      timezoneName: 'KRASNOYARSK TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'KST',
      timezoneName: 'KOREA STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 11,
      timezoneAbb: 'MAGT',
      timezoneName: 'MAGADAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 6,
      timezoneAbb: 'MMT',
      timezoneName: 'MYANMAR TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 3,
      timezoneAbb: 'MSK',
      timezoneName: 'MOSCOW STANDARD TIME',
    ),
    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'MVT',
      timezoneName: 'MALDIVES TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'MYT',
      timezoneName: 'MALAYSIA TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 6,
      timezoneAbb: 'NOVT',
      timezoneName: 'NOVOSIBIRSK TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'NPT',
      timezoneName: 'NEPAL TIME',
    ),
    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 6,
      timezoneAbb: 'OMST',
      timezoneName: 'OMSK STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'ORAT',
      timezoneName: 'ORAL TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 12,
      timezoneAbb: 'PETT',
      timezoneName: 'KAMCHATKA TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'PHT',
      timezoneName: 'PHILIPPINE TIME',
    ),
    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'PKT',
      timezoneName: 'PAKISTAN STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'PST',
      timezoneName: 'PYONGYANG TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 11,
      timezoneAbb: 'SAKT',
      timezoneName: 'SAKHALIN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 6,
      timezoneAbb: 'QYZT',
      timezoneName: 'QYZYLORDA TIME',
    ),
    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 4,
      timezoneAbb: 'SAMT',
      timezoneName: 'SAMARA TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'SGT',
      timezoneName: 'SINGAPORE TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 11,
      timezoneAbb: 'SRAT',
      timezoneName: 'SREDNEKOLYMSK TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'TJT',
      timezoneName: 'TAJIKISTAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 3,
      timezoneAbb: 'TLT',
      timezoneName: 'TURKEY TIME OR TURKISH TIME',
    ),

//    TimeZoneModel(
//      offsetFromUtcMin: 0,
//      offsetFromUtc: 3,
//      timezoneAbb: 'TRT',
//      timezoneName: 'TURKMENISTAN TIME',
//    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 10,
      timezoneAbb: 'TRUT',
      timezoneName: 'TRUK TIME ',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'ULAT',
      timezoneName: 'ULAANBAATAR TIME',
    ),

//    TimeZoneModel(
//      offsetFromUtcMin: 0,
//      offsetFromUtc: 5,
//      timezoneAbb: 'UZAT',
//      timezoneName: 'UZBEKISTAN TIME',
//    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 10,
      timezoneAbb: 'VLAT',
      timezoneName: 'VLADIVOSTOK TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 4,
      timezoneAbb: 'VOLT',
      timezoneName: 'VOLGOGRAD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 7,
      timezoneAbb: 'WIB',
      timezoneName: 'WESTERN INDONESIAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 9,
      timezoneAbb: 'WIT',
      timezoneName: 'EASTERN INDONESIAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'WITA',
      timezoneName: 'CENTRAL INDONESIAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 9,
      timezoneAbb: 'YAKT',
      timezoneName: 'YAKUTSK TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'YEKT',
      timezoneName: 'YEKATERINBURG TIME',
    ),

    //ladditional timezones
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 1,
        timezoneAbb: 'A',
        timezoneName: 'ALPHA TIME ZONE'),
//    TimeZoneModel(
//        offsetFromUtcMin: 30,
//        offsetFromUtc: 10,
//        timezoneAbb: 'ACDT',
//        timezoneName: 'AUSTRALIAN CENTRAL DAYLIGHT TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 30,
        offsetFromUtc: 9,
        timezoneAbb: 'ACST',
        timezoneName: 'AUSTRALIAN CENTRAL STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 5,
        timezoneAbb: 'ACT',
        timezoneName: 'ACRE TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 30,
//        offsetFromUtc: 9,
//        timezoneAbb: 'ACT',
//        timezoneName: 'AUSTRALIAN CENTRAL TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 45,
//        offsetFromUtc: 8,
//        timezoneAbb: 'ACWST',
//        timezoneName: 'AUSTRALIAN CENTRAL WESTERN STANDARD TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: 11,
//        timezoneAbb: 'AEDT',
//        timezoneName: 'AUSTRALIAN EASTERN DAYLIGHT TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 10,
        timezoneAbb: 'AEST',
        timezoneName: 'AUSTRALIAN EASTERN STANDARD TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: 10,
//        timezoneAbb: 'AET',
//        timezoneName: 'AUSTRALIAN EASTERN TIM'),
    TimeZoneModel(
        offsetFromUtcMin: 30,
        offsetFromUtc: 4,
        timezoneAbb: 'AFT',
        timezoneName: 'AFGHANISTAN TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -9,
        timezoneAbb: 'AKST',
        timezoneName: 'ALASKA STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 6,
        timezoneAbb: 'ALMT',
        timezoneName: 'ALMA-ATA TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -3,
        timezoneAbb: 'AMST',
        timezoneName: 'AMAZON SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -4,
        timezoneAbb: 'AMT',
        timezoneName: 'AMAZON TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 4,
        timezoneAbb: 'AMT',
        timezoneName: 'ARMENIA TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: 12,
//        timezoneAbb: 'ANAST',
//        timezoneName: 'ANADYR SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 12,
        timezoneAbb: 'ANAT',
        timezoneName: 'ANADYR TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: -12,
//        timezoneAbb: 'AoE',
//        timezoneName: 'ANYWHERE ON EARTH'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -3,
        timezoneAbb: 'ART',
        timezoneName: 'ARGENTINA TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: 9,
//        timezoneAbb: 'AWDT',
//        timezoneName: 'AUSTRALIAN WESTERN DAYLIGHT TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 8,
        timezoneAbb: 'AWST',
        timezoneName: 'AUSTRALIAN WESTERN STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 0,
        timezoneAbb: 'AZOST',
        timezoneName: 'AZORES SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -1,
        timezoneAbb: 'AZOT',
        timezoneName: 'AZORES TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 4,
        timezoneAbb: 'AZT',
        timezoneName: 'AZERBAIJAN TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 2,
        timezoneAbb: 'B',
        timezoneName: 'BRAVO TIME ZONE'),
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: 8,
//        timezoneAbb: 'BNT',
//        timezoneName: 'BRUNEI DARUSSALAM TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -4,
        timezoneAbb: 'BOT',
        timezoneName: 'BOLIVIA TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -2,
        timezoneAbb: 'BRST',
        timezoneName: 'BRASÍLIA SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -3,
        timezoneAbb: 'BRT',
        timezoneName: 'BRASÍLIA TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 3,
        timezoneAbb: 'C',
        timezoneName: 'CHARLIE TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 8,
        timezoneAbb: 'CAST',
        timezoneName: 'CASEY TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 2,
        timezoneAbb: 'CAT',
        timezoneName: 'CENTRAL AFRICA TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 30,
        offsetFromUtc: 6,
        timezoneAbb: 'CCT',
        timezoneName: 'COCOS ISLANDS TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -5,
        timezoneAbb: 'CDT',
        timezoneName: 'CENTRAL DAYLIGHT TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 2,
        timezoneAbb: 'CEST',
        timezoneName: 'CENTRAL EUROPEAN SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 45,
        offsetFromUtc: 13,
        timezoneAbb: 'CHADT',
        timezoneName: 'CHATHAM ISLAND DAYLIGHT TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 45,
        offsetFromUtc: 12,
        timezoneAbb: 'CHAST',
        timezoneName: 'CHATHAM ISLAND STANDARD TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: 10,
//        timezoneAbb: 'ChST',
//        timezoneName: 'CHAMORRO STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 10,
        timezoneAbb: 'CHUT',
        timezoneName: 'CHUUK TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -4,
        timezoneAbb: 'CIDST',
        timezoneName: 'CAYMAN ISLANDS DAYLIGHT SAVING TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -5,
        timezoneAbb: 'CIST',
        timezoneName: 'CAYMAN ISLANDS STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -10,
        timezoneAbb: 'CKT',
        timezoneName: 'COOK ISLAND TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -3,
        timezoneAbb: 'CLST',
        timezoneName: 'CHILE SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -4,
        timezoneAbb: 'CLT',
        timezoneName: 'CHILE STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -5,
        timezoneAbb: 'COT',
        timezoneName: 'COLOMBIA TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -1,
        timezoneAbb: 'CVT',
        timezoneName: 'CAPE VERDE TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 7,
        timezoneAbb: 'CXT',
        timezoneName: 'CHRISTMAS ISLAND TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 4,
        timezoneAbb: 'D',
        timezoneName: 'DELTA TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 7,
        timezoneAbb: 'DAVT',
        timezoneName: 'DAVIS TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 10,
        timezoneAbb: 'DDUT',
        timezoneName: 'DUMONT-D\'URVILLE TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 5,
        timezoneAbb: 'E',
        timezoneName: 'ECHO TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -5,
        timezoneAbb: 'EASST',
        timezoneName: 'EASTER ISLAND SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -6,
        timezoneAbb: 'EAST',
        timezoneName: 'EASTER ISLAND STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 3,
        timezoneAbb: 'EAT',
        timezoneName: 'EASTERN AFRICA TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -5,
        timezoneAbb: 'ECT',
        timezoneName: 'ECUADOR TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 0,
        timezoneAbb: 'EGST',
        timezoneName: 'EASTERN GREENLAND SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -1,
        timezoneAbb: 'EGT',
        timezoneName: 'EAST GREENLAND TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -5,
        timezoneAbb: 'EST',
        timezoneName: 'EASTERN STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 6,
        timezoneAbb: 'F',
        timezoneName: 'FOXTROT TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 3,
        timezoneAbb: 'FET',
        timezoneName: 'FURTHER-EASTERN EUROPEAN TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 13,
        timezoneAbb: 'FJST',
        timezoneName: 'FIJI SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 12,
        timezoneAbb: 'FJT',
        timezoneName: 'FIJI TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -3,
        timezoneAbb: 'FKST',
        timezoneName: 'FALKLAND ISLANDS SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -4,
        timezoneAbb: 'FKT',
        timezoneName: 'FALKLAND ISLAND TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -2,
        timezoneAbb: 'FNT',
        timezoneName: 'FERNANDO DE NORONHA TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 7,
        timezoneAbb: 'G',
        timezoneName: 'GOLF TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -6,
        timezoneAbb: 'GALT',
        timezoneName: 'GALAPAGOS TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -9,
        timezoneAbb: 'GAMT',
        timezoneName: 'GAMBIER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -3,
        timezoneAbb: 'GFT',
        timezoneName: 'FRENCH GUIANA TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 12,
        timezoneAbb: 'GILT',
        timezoneName: 'GILBERT ISLAND TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -4,
        timezoneAbb: 'GYT',
        timezoneName: 'GUYANA TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: 8,
//        timezoneAbb: 'H',
//        timezoneName: 'HOTEL TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 8,
        timezoneAbb: 'HOVST',
        timezoneName: 'HOVD SUMMER TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: 9,
//        timezoneAbb: 'I',
//        timezoneName: 'INDIA TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 6,
        timezoneAbb: 'IOT',
        timezoneName: 'INDIAN CHAGOS TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 10,
        timezoneAbb: 'K',
        timezoneName: 'KILO TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 11,
        timezoneAbb: 'KOST',
        timezoneName: 'KOSRAE TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 8,
        timezoneAbb: 'KRAST',
        timezoneName: 'KRASNOYARSK SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 4,
        timezoneAbb: 'KUYT',
        timezoneName: 'KUYBYSHEV TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 11,
        timezoneAbb: 'L',
        timezoneName: 'LIMA TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 11,
        timezoneAbb: 'LHDT',
        timezoneName: 'LORD HOWE DAYLIGHT TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 30,
        offsetFromUtc: 10,
        timezoneAbb: 'LHST',
        timezoneName: 'LORD HOWE STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 14,
        timezoneAbb: 'LINT',
        timezoneName: 'LINE ISLANDS TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 12,
        timezoneAbb: 'M',
        timezoneName: 'MIKE TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 12,
        timezoneAbb: 'MAGST',
        timezoneName: 'MAGADAN SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 30,
        offsetFromUtc: -9,
        timezoneAbb: 'MART',
        timezoneName: 'MARQUESAS TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 5,
        timezoneAbb: 'MAWT',
        timezoneName: 'MAWSON TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 12,
        timezoneAbb: 'MHT',
        timezoneName: 'MARSHALL ISLANDS TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 4,
        timezoneAbb: 'MSD',
        timezoneName: 'MOSCOW DAYLIGHT TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 4,
        timezoneAbb: 'MUT',
        timezoneName: 'MAURITIUS TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -1,
        timezoneAbb: 'N',
        timezoneName: 'NOVEMBER TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 11,
        timezoneAbb: 'NCT',
        timezoneName: 'NEW CALEDONIA TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 30,
        offsetFromUtc: -2,
        timezoneAbb: 'NDT',
        timezoneName: 'NEWFOUNDLAND DAYLIGHT TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 12,
        timezoneAbb: 'NFDT',
        timezoneName: 'NORFOLK DAYLIGHT TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 11,
        timezoneAbb: 'NFT',
        timezoneName: 'NORFOLK TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 7,
        timezoneAbb: 'NOVST',
        timezoneName: 'NOVOSIBIRSK SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 12,
        timezoneAbb: 'NRT',
        timezoneName: 'NAURU TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 30,
        offsetFromUtc: -3,
        timezoneAbb: 'NST',
        timezoneName: 'NEWFOUNDLAND STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -11,
        timezoneAbb: 'NUT',
        timezoneName: 'NIUE TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 13,
        timezoneAbb: 'NZDT',
        timezoneName: 'NEW ZEALAND DAYLIGHT TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 12,
        timezoneAbb: 'NZST',
        timezoneName: 'NEW ZEALAND STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -2,
        timezoneAbb: 'O',
        timezoneName: 'OSCAR TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 7,
        timezoneAbb: 'OMSST',
        timezoneName: 'OMSK SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -3,
        timezoneAbb: 'P',
        timezoneName: 'PAPA TIME ZONe'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -5,
        timezoneAbb: 'PET',
        timezoneName: 'PERU TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: 12,
//        timezoneAbb: 'PETST',
//        timezoneName: 'KAMCHATKA SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 10,
        timezoneAbb: 'PGT',
        timezoneName: 'PAPUA NEW GUINEA TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 13,
        timezoneAbb: 'PHOT',
        timezoneName: 'PHOENIX ISLAND TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -2,
        timezoneAbb: 'PMDT',
        timezoneName: 'PIERRE & MIQUELON DAYLIGHT TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -3,
        timezoneAbb: 'PMST',
        timezoneName: 'PIERRE & MIQUELON STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 11,
        timezoneAbb: 'PONT',
        timezoneName: 'POHNPEI STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 9,
        timezoneAbb: 'PWT',
        timezoneName: 'PALAU TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -3,
        timezoneAbb: 'PYST',
        timezoneName: 'PARAGUAY SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -4,
        timezoneAbb: 'PYT',
        timezoneName: 'PARAGUAY TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 30,
//        offsetFromUtc: 8,
//        timezoneAbb: 'PYT',
//        timezoneName: 'PYONGYANG TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -4,
        timezoneAbb: 'Q',
        timezoneName: 'QUEBEC TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -5,
        timezoneAbb: 'R',
        timezoneName: 'ROMEO TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 4,
        timezoneAbb: 'RET',
        timezoneName: 'REUNION TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -3,
        timezoneAbb: 'ROTT',
        timezoneName: 'ROTHERA TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -6,
        timezoneAbb: 'S',
        timezoneName: 'SIERRA TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 2,
        timezoneAbb: 'SAST',
        timezoneName: 'SOUTH AFRICA STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 11,
        timezoneAbb: 'SBT',
        timezoneName: 'SOLOMON ISLANDS TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 4,
        timezoneAbb: 'SCT',
        timezoneName: 'SEYCHELLES TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: 11,
//        timezoneAbb: 'SRET',
//        timezoneName: 'SREDNEKOLYMSK TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -3,
        timezoneAbb: 'SRT',
        timezoneName: 'SURINAME TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -11,
        timezoneAbb: 'SST',
        timezoneName: 'SAMOA STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 3,
        timezoneAbb: 'SYOT',
        timezoneName: 'SYOWA TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -7,
        timezoneAbb: 'T',
        timezoneName: 'TANGO TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -10,
        timezoneAbb: 'TAHT',
        timezoneName: 'TAHITI TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 5,
        timezoneAbb: 'TFT',
        timezoneName: 'FRENCH SOUTHERN AND ANTARCTIC TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 13,
        timezoneAbb: 'TKT',
        timezoneName: 'TOKELAU TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 5,
        timezoneAbb: 'TMT',
        timezoneName: 'TURKMENISTAN TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 14,
        timezoneAbb: 'TOST',
        timezoneName: 'TONGA SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 13,
        timezoneAbb: 'TOT',
        timezoneName: 'TONGA TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 12,
        timezoneAbb: 'TVT',
        timezoneName: 'TUVALU TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -8,
        timezoneAbb: 'U',
        timezoneName: 'UNIFORM TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 9,
        timezoneAbb: 'ULAST',
        timezoneName: 'ULAANBAATAR SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 0,
        timezoneAbb: 'UTC',
        timezoneName: 'COORDINATED UNIVERSAL TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 0,
        timezoneAbb: 'UYST',
        timezoneName: 'URUGUAY SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -3,
        timezoneAbb: 'UYT',
        timezoneName: 'URUGUAY TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 5,
        timezoneAbb: 'UZT',
        timezoneName: 'UZBEKISTAN TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -9,
        timezoneAbb: 'V',
        timezoneName: 'VICTOR TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -4,
        timezoneAbb: 'VET',
        timezoneName: 'VENEZUELAN STANDARD TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: 11,
//        timezoneAbb: 'VLAST',
//        timezoneName: 'VLADIVOSTOK SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 6,
        timezoneAbb: 'VOST',
        timezoneName: 'VOSTOK TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 11,
        timezoneAbb: 'VUT',
        timezoneName: 'VANUATU TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -10,
        timezoneAbb: 'W',
        timezoneName: 'WHISKEY TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 12,
        timezoneAbb: 'WAKT',
        timezoneName: 'WAKE TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -3,
        timezoneAbb: 'WARST',
        timezoneName: 'WESTERN ARGENTINE SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 2,
        timezoneAbb: 'WAST',
        timezoneName: 'WEST AFRICA SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 1,
        timezoneAbb: 'WAT',
        timezoneName: 'WEST AFRICA TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: 1,
//        timezoneAbb: 'WEST',
//        timezoneName: 'WESTERN EUROPEAN SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 12,
        timezoneAbb: 'WFT',
        timezoneName: 'WALLIS AND FUTUNA TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -2,
        timezoneAbb: 'WGST',
        timezoneName: 'WESTERN GREENLAND SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -3,
        timezoneAbb: 'WGT',
        timezoneName: 'WEST GREENLAND TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 13,
        timezoneAbb: 'WST',
        timezoneName: 'WEST SAMOA TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: 1,
//        timezoneAbb: 'WST',
//        timezoneName: 'WESTERN SAHARA SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 0,
        timezoneAbb: 'WT',
        timezoneName: 'WESTERN SAHARA STANDARD TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -11,
        timezoneAbb: 'X',
        timezoneName: 'X-RAY TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -12,
        timezoneAbb: 'Y',
        timezoneName: 'YANKEE TIME ZONE'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 10,
        timezoneAbb: 'YAPT',
        timezoneName: 'YAP TIME'),
//    TimeZoneModel(
//        offsetFromUtcMin: 0,
//        offsetFromUtc: 6,
//        timezoneAbb: 'YEKST',
//        timezoneName: 'YEKATERINBURG SUMMER TIME'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 0,
        timezoneAbb: 'Z',
        timezoneName: 'ZULU TIME ZONE'),
  ];

  TimezoneListData();

  List<int> getTimezoneData(timezoneName) {
    for (var i = 0; i < timezonelist.length; i++) {
      if (timezonelist[i].timezoneName == timezoneName) {
        return [
          timezonelist[i].offsetFromUtc!,
          timezonelist[i].offsetFromUtcMin!
        ];
      }
    }
    return [-5, 0];
  }

  String getTimeZoneByCodeData(timezoneCode) {
    for (var i = 0; i < timezonelist.length; i++) {
      if (timezonelist[i].timezoneAbb == timezoneCode) {
        return timezonelist[i].timezoneName!;
      }
    }
    return "Pacific STANDARD TIME";
  }

  List<TimeZoneModel> getData() {
    return timezonelist;
  }

  printData() {
    List<String> x = [];
    List<String> y = [];
    timezonelist.forEach((element) {
      x.add(element.timezoneName!);
      y.add(element.timezoneAbb!);
    });
  }

  List<TimeZoneModel> searchTimebank(
    String query,
    List<TimeZoneModel> timezoneList,
  ) {
    List<TimeZoneModel> data = List<TimeZoneModel>.from(timezoneList);
    data.retainWhere(
      (element) =>
          element.timezoneName!.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
          element.timezoneAbb!.toLowerCase().contains(query.toLowerCase()),
    );
    return data;
  }
}

class TimezoneView extends StatefulWidget {
  @override
  _TimezoneViewState createState() => _TimezoneViewState();
}

class _TimezoneViewState extends State<TimezoneView> {
  List<TimeZoneModel> timezonelist = [];

  @override
  void initState() {
    timezonelist = TimezoneListData().getData();
    timezonelist.sort((a, b) {
      return a.timezoneName!
          .toLowerCase()
          .compareTo(b.timezoneName!.toLowerCase());
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TimezoneListData().printData();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          S.of(context).my_timezone,
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              TimeZoneModel? timezone = await showSearch(
                context: context,
                delegate: TimezoneSearchDelegate(
                  timezoneList: timezonelist,
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                  selectedTimezone: SevaCore.of(context).loggedInUser.timezone!,
                ),
              );
              if (timezone != null) {
                if (SevaCore.of(context).loggedInUser.timezone !=
                    timezone.timezoneName) {
                  SevaCore.of(context).loggedInUser.timezone =
                      timezone.timezoneName;
                  await updateUser(user: SevaCore.of(context).loggedInUser);
                }
              }
            },
          ),
        ],
      ),
      body: TimezoneList(
        timezoneList: timezonelist,
      ),
    );
  }
}

class TimezoneList extends StatefulWidget {
  final List<TimeZoneModel>? timezoneList;

  TimezoneList({this.timezoneList});

  @override
  TimezoneListState createState() => TimezoneListState();
}

class TimezoneListState extends State<TimezoneList> {
  List<TimeZoneModel> timezonelist = [];
  String? isSelected;
//  ScrollController _scrollController =   ScrollController();
  final TextEditingController searchTextController = TextEditingController();

  @override
  void initState() {
    timezonelist = widget.timezoneList!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: FirestoreManager.getUserForIdStream(
            sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          UserModel userModel = snapshot.data as UserModel;
          isSelected = userModel.timezone;
          return ListView.builder(
            itemCount: timezonelist.length,
//            controller: _scrollController,
            itemBuilder: (context, index) {
              TimeZoneModel model = timezonelist.elementAt(index);
              DateFormat format = DateFormat(
                  'dd/MMM/yyyy HH:mm', Locale(getLangTag()).toLanguageTag());
              DateTime timeInUtc = DateTime.now().toUtc();

              DateTime localtime = timeInUtc.add(Duration(
                  hours: model.offsetFromUtc!,
                  minutes: model.offsetFromUtcMin!));

              return TimezoneCard(
                isSelected: isSelected == model.timezoneName,
                title: model.timezoneName!,
                subTitle: format.format(localtime),
                code: model.timezoneAbb!,
                onTap: () async {
                  if (userModel.timezone != model.timezoneName) {
                    userModel.timezone = model.timezoneName;
                    SevaCore.of(context).loggedInUser.timezone =
                        model.timezoneName;
                    await updateUser(user: userModel);
                  }
                },
              );
            },
          );
        });
  }
}

class TimeZoneModel {
  String? timezoneName;
  int? offsetFromUtc;
  int? offsetFromUtcMin;
  String? timezoneAbb;

  TimeZoneModel(
      {this.timezoneName,
      this.offsetFromUtc,
      this.timezoneAbb,
      this.offsetFromUtcMin});
}
