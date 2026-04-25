import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../services/supabase_config.dart';
import 'home_screen.dart';
import '../utils/validators.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _firstNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _instagramController = TextEditingController();
  final _addressController = TextEditingController();

  // Shipping selections
  String? _selectedWilaya;
  String? _selectedDaira;
  String _deliveryMethod = 'home';
  Map<String, dynamic>? _selectedDeskData;

  // Packaging
  String _packagingType = 'none';
  int _packagingPrice = 0;

  bool _isSubmitting = false;

  // ========== ALL 58 WILAYAS ==========
  final List<String> _wilayas = [
    'Adrar', 'Chlef', 'Laghouat', 'Oum El Bouaghi', 'Batna', 'Béjaïa', 'Biskra',
    'Béchar', 'Blida', 'Bouira', 'Tamanrasset', 'Tébessa', 'Tlemcen', 'Tiaret',
    'Tizi Ouzou', 'Alger', 'Djelfa', 'Jijel', 'Sétif', 'Saïda', 'Skikda',
    'Sidi Bel Abbès', 'Annaba', 'Guelma', 'Constantine', 'Médéa', 'Mostaganem',
    'M\'Sila', 'Mascara', 'Ouargla', 'Oran', 'El Bayadh', 'Illizi',
    'Bordj Bou Arreridj', 'Boumerdès', 'El Tarf', 'Tindouf', 'Tissemsilt',
    'El Oued', 'Khenchela', 'Souk Ahras', 'Tipaza', 'Mila', 'Aïn Defla',
    'Naâma', 'Aïn Témouchent', 'Ghardaïa', 'Relizane', 'Timimoun',
    'Bordj Badji Mokhtar', 'Ouled Djellal', 'Béni Abbès', 'In Salah',
    'Touggourt', 'Djanet', 'El M\'Ghair', 'El Menia'
  ];

  // ========== DAIRAS DATA (ALL 58 WILAYAS) ==========
  final Map<String, List<String>> _dairas = {
    'Adrar': ['Adrar', 'Reggane', 'Fenoughil', 'Tinerkouk', 'Aoulef', 'Zaouiet Kounta'],
    'Chlef': ['Chlef', 'Ténès', 'Oued Fodda', 'Abou El Hassan', 'Boukadir', 'Zeboudja'],
    'Laghouat': ['Aflou', 'Laghouat', 'Kheneg', 'Gueltet Sidi Saâd', 'Sidi Makhlouf'],
    'Oum El Bouaghi': ['Aïn M\'lila', 'Oum El Bouaghi', 'Aïn Beïda', 'Fkirina', 'Dhalaa'],
    'Batna': ['Barika', 'Batna', 'Menaa', 'N\'Gaous', 'T\'Kout', 'Aïn Touta', 'Ouled Si Slimane'],
    'Béjaïa': ['Akbou', 'Béjaïa', 'El Kseur', 'Souk El Tenine', 'Tichy', 'Seddouk', 'Amizour'],
    'Biskra': ['Biskra', 'El Kantara', 'Tolga', 'Sidi Okba', 'Zeribet El Oued', 'Ourlal', 'Djemorah'],
    'Béchar': ['Béchar', 'Abadla', 'Beni Abbes', 'Kenadsa', 'Lahmar'],
    'Blida': ['Blida', 'Boufarik', 'Larbaa', 'Mouzaia', 'Ouled Yaïch', 'Chiffa', 'El Affroun'],
    'Bouira': ['Aïn Bessem', 'Bouira', 'Lakhdaria', 'Sour El Ghouzlane', 'Bir Ghbalou', 'M\'Chedallah', 'Kadiria'],
    'Tamanrasset': ['Tamanrasset', 'In Ghar', 'Abalessa', 'Tazrouk', 'Idlès'],
    'Tébessa': ['Cheria', 'Tébessa', 'El Aouinet', 'Bir El Ater', 'Morsott', 'Ouenza'],
    'Tlemcen': ['Chetouane', 'Maghnia', 'Remchi', 'Tlemcen', 'Sebdou', 'Hennaya', 'Nedroma', 'Fellaoucene'],
    'Tiaret': ['Tiaret', 'Médroussa', 'Mechraâ Sfa', 'Sougueur', 'Rahouia', 'Aïn Deheb'],
    'Tizi Ouzou': ['Azazga', 'Beni Douala', 'Draâ Ben Khedda', 'Tizi Gheniff', 'Tizi Ouzou', 'Boghni', 'Ouacif', 'Iferhounène'],
    'Alger': ['Alger Centre', 'Bab El Oued', 'Bab Ezzouar', 'Bachdjerrah', 'Baraki', 'Bir Mourad Raïs', 'Birkhadem', 'Birtouta', 'Bordj El Bahri', 'Bordj El Kiffan', 'Cheraga', 'Dar El Beïda', 'Djasr Kasentina', 'Draria', 'Hussein Dey', 'Kouba', 'Les Eucalyptus', 'Mohammadia', 'Oued Smar', 'Ouled Fayet', 'Reghaïa', 'Rouïba', 'Zeralda'],
    'Djelfa': ['Aïn Oussara', 'Djelfa', 'Messaad', 'Faidh El Botma', 'Birine', 'Hassi Bahbah', 'Sidi Ladjel'],
    'Jijel': ['El Milia', 'Jijel', 'Kaous', 'Taher', 'Chekfa', 'Sidi Maarouf', 'Djemaa Beni Habibi'],
    'Sétif': ['Aïn Arnat', 'Aïn Oulmene', 'Bougaa', 'El Eulma', 'Sétif', 'Bir El Arch', 'Hammam Guergour', 'Maoklane', 'Ouled Si Ahmed'],
    'Saïda': ['Saïda', 'Aïn El Hadjar', 'Ouled Brahim', 'Sidi Boubekeur', 'Youb'],
    'Skikda': ['Azzaba', 'Collo', 'El Harrouch', 'Skikda', 'Ben Azzouz', 'Ramdane Djamel', 'Tamalous', 'Zitouna'],
    'Sidi Bel Abbès': ['Sidi Bel Abbes', 'Aïn El Berd', 'Ben Badis', 'Marhoum', 'Merine', 'Mostefa Ben Brahim', 'Moulay Slissen', 'Telagh', 'Tessala'],
    'Annaba': ['Annaba', 'El Bouni', 'Aïn El Berda', 'Berrahal', 'Chetaïbi'],
    'Guelma': ['Guelma', 'Oued Zenati', 'Aïn Makhlouf', 'Bouchegouf', 'Hammam Debagh', 'Khezaras'],
    'Constantine': ['Constantine', 'Didouche Mourad', 'El Khroub', 'Aïn Smara', 'Beni Hamiden', 'Ibn Ziad', 'Ouled Rahmoune'],
    'Médéa': ['Beni Slimane', 'Médéa', 'Tablat', 'Aïn Boucif', 'Aziz', 'Berrouaghia', 'Chellalet El Adhaoura', 'Ouzera', 'Sidi Naamane'],
    'Mostaganem': ['Mostaganem', 'Aïn Nouïssy', 'Aïn Tedles', 'Bouguirat', 'Sidi Ali', 'Hassi Mamèche'],
    'M\'Sila': ['Berhoum', 'Bou Saâda', 'M\'Sila', 'Sidi Aïssa', 'Aïn El Hadjel', 'Chellal', 'Hammam Dhalaa', 'Ouled Derradj'],
    'Mascara': ['Mascara', 'Aïn Fares', 'Bouhanifia', 'El Bordj', 'Ghriss', 'Mohammadia', 'Oued El Abtal', 'Sig', 'Tizi'],
    'Ouargla': ['Hassi Messaoud', 'Ouargla', 'N\'Goussa', 'Sidi Khouiled', 'Touggourt', 'Taibet', 'Megarine', 'Temacine'],
    'Oran': ['Arzew', 'Bir El Djir', 'Oran', 'Aïn El Turk', 'Boutlélis', 'Es Senia', 'Gdyel', 'Oued Tlélat', 'Sidi Chahmi'],
    'El Bayadh': ['El Bayadh', 'Brézina', 'Rogassa', 'Bougtob', 'Sidi Ameur', 'Chellala'],
    'Illizi': ['Illizi', 'In Amenas', 'Djanet', 'Bordj Omar Driss'],
    'Bordj Bou Arreridj': ['Bordj Bou Arreridj', 'Ras El Oued', 'Bordj Ghedir', 'Bir Kasd Ali', 'El Hamadia', 'Mansoura', 'Médjana'],
    'Boumerdès': ['Bordj Menaiel', 'Boudouaou', 'Boumerdes', 'Hammedi', 'Baghlia', 'Dellys', 'Isser', 'Khemis El Khechna', 'Ouled Moussa', 'Thenia'],
    'El Tarf': ['Dréan', 'El Tarf', 'Bouhadjar', 'Ben M\'hidi', 'Bessera'],
    'Tindouf': ['Tindouf', 'Oum El Assel'],
    'Tissemsilt': ['Tissemsilt', 'Lardjem', 'Boucaid', 'Bordj Bounaama', 'Theniet El Had'],
    'El Oued': ['El Oued', 'Guemar', 'Reguiba', 'Debila', 'Robbah', 'Bayadha', 'Sidi Aoun'],
    'Khenchela': ['Khenchela', 'Aïn Touila', 'Babar', 'Chelia', 'Bouhmama', 'El Mahmel', 'Ouled Rechache'],
    'Souk Ahras': ['Souk Ahras', 'Sedrata', 'M\'daourouch', 'Oum El Adhaim', 'Heddada', 'Bir Bouhouche'],
    'Tipaza': ['Cherchell', 'Hadjout', 'Koléa', 'Tipaza', 'Ahmar El Aïn', 'Bou Ismaïl', 'Fouka', 'Sidi Amar', 'Sidi Rached'],
    'Mila': ['Chelghoum Laid', 'Ferdjioua', 'Mila', 'Aïn Beida', 'Tadjenanet', 'Bouhatem', 'Grarem Gouga', 'Terrai Bainen', 'Oued Endja'],
    'Aïn Defla': ['Aïn Defla', 'Khemis Miliana', 'El Abadia', 'Aïn Lechiakh', 'Bathia', 'Bordj El Amir Khaled', 'Djelida', 'Hammam Righa'],
    'Naâma': ['Mecheria', 'Naâma', 'Aïn Sefra', 'Assela', 'Moghrar'],
    'Aïn Témouchent': ['Aïn Témouchent', 'Beni Saf', 'El Amria', 'El Malah', 'Hammam Bou Hadjar', 'Oulhaça El Gheraba', 'Sidi Ben Adda'],
    'Ghardaïa': ['Bounoura', 'Ghardaïa', 'El Menia', 'Dhayet Bendhahoua', 'El Guerrara', 'Berriane', 'Zelfana', 'Métlili'],
    'Relizane': ['Relizane', 'Aïn Tarek', 'El Matmar', 'Mazouna', 'Mendes', 'Oued Rhiou', 'Yellel', 'Zemmoura', 'Sidi M\'Hamed Ben Ali'],
    'Timimoun': ['Timimoun', 'Aougrout', 'Ouled Said', 'Charouine', 'Tinerkouk', 'Deldoul'],
    'Bordj Badji Mokhtar': ['Bordj Badji Mokhtar'],
    'Ouled Djellal': ['Ouled Djellal', 'Bouzina', 'Doucen', 'El Haouita', 'Ech Chaïba'],
    'Béni Abbès': ['Béni Abbès', 'El Ouata', 'Kerzaz', 'Ouled Khoudir', 'Tabelbala', 'Igli', 'Tamtert'],
    'In Salah': ['In Salah', 'Foggaret Ezzoua', 'In Ghar'],
    'Touggourt': ['Touggourt', 'N\'Goussa', 'Megarine', 'Taibet', 'Temacine', 'Blidet Amor'],
    'Djanet': ['Djanet'],
    'El M\'Ghair': ['Djamaa', 'El M\'Ghair', 'Oum Touyour', 'Sidi Amrane', 'Tendla'],
    'El Menia': ['El Menia', 'Hassi Gara', 'Hassi Fehal'],
  };

  // ========== SHIPPING PRICES ==========
  final Map<String, int> _homePrices = {
    'Alger': 700, 'Batna': 700, 'Béjaïa': 700, 'Jijel': 700, "M'Sila": 700,
    'Bordj Bou Arreridj': 700, 'Mila': 700, 'Sétif': 590,
    'Chlef': 900, 'Oum El Bouaghi': 900, 'Blida': 900, 'Bouira': 900,
    'Tébessa': 900, 'Tlemcen': 900, 'Tiaret': 900, 'Tizi Ouzou': 900,
    'Saida': 900, 'Skikda': 900, 'Sidi Bel Abbès': 900, 'Annaba': 900,
    'Guelma': 900, 'Constantine': 900, 'Médéa': 900, 'Mostaganem': 900,
    'Mascara': 900, 'Oran': 900, 'Boumerdès': 900, 'El Tarf': 900,
    'Tissemsilt': 900, 'Khenchela': 900, 'Souk Ahras': 900, 'Tipaza': 900,
    'Aïn Defla': 900, 'Aïn Témouchent': 900, 'Relizane': 900,
    'Laghouat': 950, 'Biskra': 950, 'Djelfa': 950, 'Ouargla': 950,
    'El Oued': 950, 'Ghardaïa': 950, 'Ouled Djellal': 950, 'Touggourt': 950,
    'El M\'Ghair': 950, 'El Menia': 950,
    'Adrar': 1050, 'Béchar': 1050, 'El Bayadh': 1050, 'Naama': 1050,
    'Timimoun': 1050, 'Bordj Badji Mokhtar': 1050,
    'Béni Abbès': 1600, 'Tamanrasset': 1600, 'Illizi': 1600, 'Tindouf': 1600,
    'In Salah': 1600, 'Djanet': 1600, 'In Guezzam': 1600,
  };

  final Map<String, int> _deskPrices = {
    'Alger': 550, 'Batna': 550, 'Béjaïa': 550, 'Jijel': 550, "M'Sila": 550,
    'Bordj Bou Arreridj': 550, 'Mila': 550, 'Sétif': 450,
    'Chlef': 650, 'Oum El Bouaghi': 650, 'Blida': 650, 'Bouira': 650,
    'Tébessa': 650, 'Tlemcen': 650, 'Tiaret': 650, 'Tizi Ouzou': 650,
    'Saida': 650, 'Skikda': 650, 'Sidi Bel Abbès': 650, 'Annaba': 650,
    'Guelma': 650, 'Constantine': 650, 'Médéa': 650, 'Mostaganem': 650,
    'Mascara': 650, 'Oran': 650, 'Boumerdès': 650, 'El Tarf': 650,
    'Tissemsilt': 650, 'Khenchela': 650, 'Souk Ahras': 650, 'Tipaza': 650,
    'Aïn Defla': 650, 'Aïn Témouchent': 650, 'Relizane': 650,
    'Laghouat': 750, 'Biskra': 750, 'Djelfa': 750, 'Ouargla': 750,
    'El Oued': 750, 'Ghardaïa': 750, 'Ouled Djellal': 750, 'Touggourt': 750,
    'El M\'Ghair': 750, 'El Menia': 750,
    'Adrar': 850, 'Béchar': 850, 'El Bayadh': 850, 'Naama': 850,
    'Timimoun': 850, 'Bordj Badji Mokhtar': 850,
    'Béni Abbès': 1400, 'Tamanrasset': 1400, 'Illizi': 1400, 'Tindouf': 1400,
    'In Salah': 1400, 'Djanet': 1400, 'In Guezzam': 1400,
  };

  int getShippingPrice(String wilaya, String deliveryMethod) {
    if (deliveryMethod == 'home') return _homePrices[wilaya] ?? 0;
    return _deskPrices[wilaya] ?? 0;
  }

  int get _shippingCost {
    if (_selectedWilaya == null) return 0;
    return getShippingPrice(_selectedWilaya!, _deliveryMethod);
  }

  List<String> get _availableDairas {
    if (_selectedWilaya == null) return [];
    return _dairas[_selectedWilaya] ?? [];
  }

  List<Map<String, dynamic>> get _availableDesks {
    if (_selectedWilaya == null || _selectedDaira == null) return [];
    return _desks[_selectedWilaya]?[_selectedDaira] ?? [];
  }

  // ========== DESKS DATA (COMPLETE) ==========
  final Map<String, Map<String, List<Map<String, dynamic>>>> _desks = {
    'Alger': {
      'Alger Centre': [{'name': 'Sacré-Cœur [Guepex]', 'address': '116 Didouche Mourad, Sacre Cœur', 'code': '160101'}],
      'Bab El Oued': [{'name': 'Agence de Bab El Oued [Guepex]', 'address': '107 Rue Colonel Lotfi', 'code': '160501'}],
      'Bab Ezzouar': [{'name': 'Agence Bab Ezzouar [Yalitec]', 'address': 'EPLF - Bab Ezzouar', 'code': '162102'}],
      'Bachdjerrah': [{'name': 'Agence Bachdjerrah [WeCanServices]', 'address': 'Bachdjerrah 3 derrière l\'ancien APC', 'code': '161601'}],
      'Baraki': [{'name': 'Agence de Baraki [Guepex]', 'address': 'Route de Larbâa', 'code': '161401'}],
      'Bir Mourad Raïs': [{'name': 'Agence Bir Mourad Rais [EasyAndSpeed]', 'address': '14 rue des trois, Bir Mourad Raïs', 'code': '160902'}],
      'Birkhadem': [{'name': 'Agence de Birkhadem [Yalidine]', 'address': 'Cite Vergers Villa N°1', 'code': '161201'}],
      'Birtouta': [{'name': 'Agence de Birtouta [Guepex]', 'address': '06 rue El Moudjahid Hamida Mouhamed', 'code': '163401'}],
      'Bordj El Bahri': [{'name': 'Agence Bordj El Bahri [Yalidine]', 'address': 'Bordj El Bahri', 'code': '163901'}],
      'Bordj El Kiffan': [{'name': 'Agence de Bordj El Kiffan [Yalidine]', 'address': 'Rue 1Er Novembre', 'code': '163001'}],
      'Cheraga': [{'name': 'Dar Diaf [Yalidine]', 'address': 'Dar Diaf', 'code': '165001'}],
      'Dar El Beïda': [{'name': 'Agence d\'El Hamiz [EasyAndSpeed]', 'address': 'Cité les orangers', 'code': '162003'}],
      'Djasr Kasentina': [{'name': 'Agence Gué de Constantine [SpeedMail]', 'address': 'Cite Sonelgaz', 'code': '162602'}],
      'Draria': [{'name': 'Agence de Draria [Guepex]', 'address': 'Cite Darbush', 'code': '165301'}],
      'Hussein Dey': [{'name': 'Hussein Dey [Yalidine]', 'address': 'Route Tripoli N°152', 'code': '161701'}],
      'Kouba': [{'name': 'Agence Kouba [Yalidine]', 'address': 'Lotissement 26 Tranche 56', 'code': '161801'}],
      'Les Eucalyptus': [{'name': 'Agence Les Eucalyptus [Zimou-Express]', 'address': 'Rue Les Eucalyptus', 'code': '163302'}],
      'Mohammadia': [{'name': 'Agence les Pins Maritime [Yalitec]', 'address': 'Rue Les Pins Maritime', 'code': '162902'}],
      'Oued Smar': [{'name': 'Agence El Harrach [WeCanServices]', 'address': '128 RUE BOUBAGHLA', 'code': '161503'}],
      'Ouled Fayet': [{'name': 'Agence de Ouled Fayet [Guepex]', 'address': '19 route du stade communal', 'code': '165101'}],
      'Reghaïa': [{'name': 'Agence de DNC [Yalidine]', 'address': 'Cité El Ouancharis', 'code': '164301'}],
      'Rouïba': [{'name': 'Agence de Rouiba [Zimou-Express]', 'address': 'Rue Hassiba Ben Bouali', 'code': '164201'}],
      'Zeralda': [{'name': 'Agence de Zeralda [Guepex]', 'address': 'Cite Yesswel Kouider', 'code': '164601'}],
    },
    'Sétif': {
      'Sétif': [{'name': 'Agence Maabouda [Yalidine]', 'address': 'Cite D\'Al-Ma\'Bouda, Sétif', 'code': '195501'}],
      'El Eulma': [{'name': 'Desk El Eulma [Yalidine]', 'address': 'Rue Abdelaziz Khaled, El Eulma', 'code': '193202'}],
      'Aïn Arnat': [{'name': 'Agence Ain Arnat [EasyAndSpeed]', 'address': 'Quartier 400 logements, Aïn Arnat', 'code': '190202'}],
    },
    'Constantine': {
      'Constantine': [{'name': 'Agence Belle Vue [Yalidine]', 'address': '70 Rue Belle Vue', 'code': '250401'}],
      'El Khroub': [{'name': 'Agence Nouvelle ville Ali Mendjeli [Yalidine]', 'address': 'Ali MENDJLI', 'code': '250602'}],
    },
    'Oran': {
      'Oran': [{'name': 'Cité Djamel [Guepex]', 'address': 'Rond-point cité Djamel', 'code': '310102'}],
      'Bir El Djir': [{'name': 'El Morchid [Yalidine]', 'address': 'Cooperative Immobiliere Dar El Amel', 'code': '310301'}],
    },
    'Saïda': {
      'Saïda': [{'name': 'Agence de Saïda [Yalidine]', 'address': 'cité Riadh (à coté de la mosquée Riadh)', 'code': '201101'}],
    },
    'Blida': {
      'Blida': [{'name': 'Agence de Blida [Yalidine]', 'address': 'Zone industrielle Ben Boulaid', 'code': '90101'}],
      'Boufarik': [{'name': 'Agence de Boufarik [Guepex]', 'address': '64 Rue Si Ben Youcef', 'code': '92001'}],
    },
    'Béjaïa': {
      'Béjaïa': [{'name': 'Agence de Béjaïa [Yalidine]', 'address': 'Zone Industrielle, Edimco', 'code': '60102'}],
    },
    'Tizi Ouzou': {
      'Tizi Ouzou': [{'name': 'Agence de Nouvelle Ville [Yalidine]', 'address': 'Nouvelle ville', 'code': '150102'}],
    },
    'Annaba': {
      'Annaba': [{'name': 'Agence de Valmascort [Yalidine]', 'address': 'Avenue Seddik Benyahia', 'code': '230101'}],
    },
    'Biskra': {
      'Biskra': [{'name': 'Agence de Biskra [EasyAndSpeed]', 'address': 'Coopératif du verger N°22', 'code': '70402'}],
    },
    'Djelfa': {
      'Djelfa': [{'name': 'Agence de Djelfa [Yalidine]', 'address': 'Cité Boutrifis', 'code': '171401'}],
    },
    'Ouargla': {
      'Ouargla': [{'name': 'Agence de Ouargla [Yalidine]', 'address': 'Ave 1er novembre', 'code': '301302'}],
    },
    'Adrar': {
      'Adrar': [{'name': 'Agence de Adrar [Yalidine]', 'address': 'Rue Benhachem Maamar', 'code': '10102'}],
    },
    'Tamanrasset': {
      'Tamanrasset': [{'name': 'Agence Tamanrasset [Yalidine]', 'address': 'Tahaggart', 'code': '110102'}],
    },
    'Batna': {
      'Batna': [{'name': 'Agence des 500 Logements [Yalidine]', 'address': 'Lotissement Meddour', 'code': '50101'}],
    },
  };

  final List<Map<String, dynamic>> _packagingOptions = [
    {'type': 'none', 'name': 'No packaging / بدون تغليف', 'price': 0, 'image': null},
    {'type': 'papier_craft', 'name': 'Papier Craft / ورق كرافت', 'price': 500, 'image': 'assets/images/papier-craft.PNG'},
    {'type': 'surprise', 'name': 'Surprise / مفاجأة', 'price': 500, 'image': 'assets/images/surprise.png'},
  ];

  final List<Map<String, dynamic>> _deliveryMethods = [
    {'value': 'home', 'label': 'Home Delivery / توصيل للمنزل'},
    {'value': 'desk', 'label': 'Desk Pickup / استلام من المكتب'},
  ];

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final cart = CartProvider.of(context);
    final user = SupabaseConfig.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please login first')));
      setState(() => _isSubmitting = false);
      return;
    }

    final itemsList = cart.items.map((item) => ({
      'title': item.book.title,
      'price': item.book.price.toInt(),
      'quantity': item.quantity,
    })).toList();

    final orderData = {
      'user_id': user.id,
      'firstName': _firstNameController.text.trim(),
      'familyName': _familyNameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'instagramUsername': _instagramController.text.trim(),
      'deliveryMethod': _deliveryMethod,
      'total_price': (cart.totalPrice + _packagingPrice + _shippingCost).toInt(),
      'shipping_price': _shippingCost.toInt(),
      'packaging_type': _packagingType,
      'packaging_price': _packagingPrice.toInt(),
      'wilaya': _selectedWilaya,
      'daira': _selectedDaira,
      'address': _addressController.text.trim(),
      'desk': (_deliveryMethod == 'desk' && _selectedDeskData != null) ? _selectedDeskData!['name'] : null,
      'items': itemsList,
    };

    try {
      await SupabaseConfig.client.from('orders').insert(orderData);
      cart.clearCart();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order placed successfully!'), backgroundColor: Color(0xFF5e2217)));
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.of(context);

    return Scaffold(
      backgroundColor: Color(0xFFf5f5dc),
      appBar: AppBar(title: Text('Checkout'), backgroundColor: Color(0xFFf5f5dc), foregroundColor: Color(0xFF5e2217), elevation: 0),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Information
              Text('Customer Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5e2217))),
              SizedBox(height: 12),
              TextFormField(controller: _firstNameController, decoration: InputDecoration(labelText: 'First Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (value) => value == null || value.isEmpty ? 'First name required' : null),
              SizedBox(height: 10),
              TextFormField(controller: _familyNameController, decoration: InputDecoration(labelText: 'Family Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (value) => value == null || value.isEmpty ? 'Family name required' : null),
              SizedBox(height: 10),
              TextFormField(controller: _phoneController, keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: PhoneValidator.validate),
              SizedBox(height: 10),
              TextFormField(controller: _instagramController, decoration: InputDecoration(labelText: 'Instagram Username (optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              SizedBox(height: 20),
              
              // Order Summary (Books)
              Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5e2217))),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(children: cart.items.map((item) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(6),
                        child: Image.network(item.book.image, width: 50, height: 70, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 50, height: 70, color: Colors.grey[200], child: Icon(Icons.book, size: 30, color: Colors.grey)))),
                      SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.book.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 4),
                          Text('${item.book.price} DA x ${item.quantity}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      )),
                      Text('${item.book.price * item.quantity} DA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF5e2217))),
                    ],
                  ),
                )).toList()),
              ),
              SizedBox(height: 20),

              // Delivery Information
              Text('Delivery Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5e2217))),
              SizedBox(height: 12),
              Text('Delivery Method', style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 6),
              Row(children: _deliveryMethods.map((m) => Expanded(
                child: RadioListTile(title: Text(m['label'], style: TextStyle(fontSize: 12)), value: m['value'], groupValue: _deliveryMethod,
                  onChanged: (v) => setState(() => _deliveryMethod = v.toString()), activeColor: Color(0xFF5e2217), contentPadding: EdgeInsets.zero),
              )).toList()),
              SizedBox(height: 12),

              // Wilaya dropdown
              Container(padding: EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                  isExpanded: true, hint: Text('Select wilaya / الولاية'), value: _selectedWilaya,
                  items: _wilayas.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                  onChanged: (v) => setState(() { _selectedWilaya = v; _selectedDaira = null; _selectedDeskData = null; }),
                )),
              ),
              SizedBox(height: 10),

              // Daira dropdown
              Container(padding: EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                  isExpanded: true, hint: Text('Select daira / الدائرة'), value: _selectedDaira,
                  items: _availableDairas.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => setState(() { _selectedDaira = v; _selectedDeskData = null; }),
                )),
              ),
              SizedBox(height: 10),

              // Desk dropdown (only for pickup)
              if (_deliveryMethod == 'desk')
                Container(padding: EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(child: _availableDesks.isNotEmpty
                    ? DropdownButton<Map<String, dynamic>>(
                        isExpanded: true, hint: Text('Select a desk / agency'), value: _selectedDeskData,
                        items: _availableDesks.map((d) => DropdownMenuItem(value: d,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                            children: [Text(d['name'], style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                              Text(d['address'], style: TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedDeskData = v),
                      )
                    : DropdownButton<String>(isExpanded: true, hint: Text('No desks available for this location yet'), value: null, items: [], onChanged: null)
                  ),
                ),

              // Address
              TextFormField(controller: _addressController, maxLines: 2,
                decoration: InputDecoration(labelText: 'Address / العنوان', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (value) => value == null || value.isEmpty ? 'Address required' : null),
              SizedBox(height: 20),

              // Packaging Options
              Text('Packaging / التغليف',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5e2217))),
              SizedBox(height: 12),
              ..._packagingOptions.map((opt) => RadioListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 2),
                title: Row(
                  children: [
                    if (opt['image'] != null)
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFF5e2217).withOpacity(0.3)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            opt['image'],
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, size: 35, color: Colors.grey),
                          ),
                        ),
                      ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(opt['name'], style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                          Text('${opt['price']} DA', style: TextStyle(color: Color(0xFF5e2217), fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
                value: opt['type'],
                groupValue: _packagingType,
                onChanged: (v) => setState(() {
                  _packagingType = v.toString();
                  _packagingPrice = opt['price'];
                }),
                activeColor: Color(0xFF5e2217),
              )).toList(),
              SizedBox(height: 16),

              // Order Summary (Prices)
              Container(padding: EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Subtotal'), Text('${cart.totalPrice.toInt()} DA')]),
                  SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Shipping'), Text('$_shippingCost DA')]),
                  SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Packaging'), Text('$_packagingPrice DA')]),
                  Divider(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${(cart.totalPrice + _packagingPrice + _shippingCost).toInt()} DA', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5e2217))),
                  ]),
                ]),
              ),
              SizedBox(height: 20),

              // Place Order Button
              SizedBox(width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF5e2217), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}