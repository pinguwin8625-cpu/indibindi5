import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/scroll_indicator.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedColor;
  final String _plateExample = '34ABC123';
  bool _isSaved = false;
  
  final Map<String, List<String>> _carData = {
    'Acura': ['ILX', 'TLX', 'RLX', 'MDX', 'RDX', 'NSX', 'Integra'],
    'Aixam': ['City', 'Crossline', 'Coupe'],
    'Alfa Romeo': ['Giulia', 'Stelvio', 'Tonale', '4C', 'Giulietta', 'MiTo', '159', '156', '147', 'Brera', 'Spider'],
    'Aston Martin': ['DB11', 'DBS', 'Vantage', 'DBX', 'DB9', 'Rapide', 'Vanquish'],
    'Audi': ['A1', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'Q2', 'Q3', 'Q5', 'Q7', 'Q8', 'e-tron', 'R8', 'TT', 'TTS', 'RS3', 'RS4', 'RS5', 'RS6', 'RS7', 'RSQ8'],
    'Bentley': ['Continental GT', 'Flying Spur', 'Bentayga', 'Mulsanne'],
    'BMW': ['1 Series', '2 Series', '3 Series', '4 Series', '5 Series', '6 Series', '7 Series', '8 Series', 'X1', 'X2', 'X3', 'X4', 'X5', 'X6', 'X7', 'Z3', 'Z4', 'i3', 'i4', 'i7', 'i8', 'iX', 'iX3', 'M2', 'M3', 'M4', 'M5', 'M6', 'M8', 'X3 M', 'X4 M', 'X5 M', 'X6 M'],
    'Bugatti': ['Chiron', 'Veyron'],
    'Buick': ['Enclave', 'Encore', 'Envision', 'Regal', 'LaCrosse'],
    'BYD': ['Atto 3', 'Han', 'Tang', 'Seal', 'Dolphin'],
    'Cadillac': ['CT4', 'CT5', 'CT6', 'XT4', 'XT5', 'XT6', 'Escalade', 'Lyriq', 'CTS', 'SRX', 'ATS'],
    'Chery': ['Tiggo', 'Arrizo', 'QQ', 'Eastar'],
    'Chevrolet': ['Spark', 'Aveo', 'Cruze', 'Malibu', 'Impala', 'Camaro', 'Corvette', 'Trax', 'Trailblazer', 'Equinox', 'Blazer', 'Traverse', 'Tahoe', 'Suburban', 'Silverado', 'Colorado', 'Bolt', 'Captiva', 'Lacetti', 'Epica'],
    'Chrysler': ['300', 'Pacifica', 'Voyager', 'Sebring', 'PT Cruiser'],
    'Citroën': ['C1', 'C3', 'C3 Aircross', 'C4', 'C4 Cactus', 'C5', 'C5 Aircross', 'Berlingo', 'Jumpy', 'Spacetourer', 'DS3', 'DS4', 'DS5'],
    'Cupra': ['Formentor', 'Leon', 'Ateca', 'Born'],
    'Dacia': ['Sandero', 'Logan', 'Duster', 'Lodgy', 'Dokker', 'Spring', 'Jogger'],
    'Daewoo': ['Matiz', 'Kalos', 'Lacetti', 'Nubira', 'Leganza', 'Lanos'],
    'Daihatsu': ['Terios', 'Sirion', 'Materia', 'Cuore', 'Charade'],
    'Dodge': ['Charger', 'Challenger', 'Durango', 'Journey', 'Nitro', 'Ram', 'Viper'],
    'DS Automobiles': ['DS3', 'DS4', 'DS5', 'DS7', 'DS9'],
    'Ferrari': ['296 GTB', 'F8 Tributo', 'Roma', 'Portofino', 'SF90', '812', 'Purosangue', '488', '458', 'California', 'F12', 'FF', 'GTC4Lusso'],
    'Fiat': ['500', '500X', '500L', 'Panda', 'Tipo', 'Egea', 'Doblo', 'Fiorino', 'Ducato', 'Punto', 'Linea', 'Bravo', 'Albea', 'Palio', 'Uno', 'Tempra', 'Marea'],
    'Ford': ['Fiesta', 'Focus', 'Mondeo', 'Fusion', 'Mustang', 'EcoSport', 'Puma', 'Kuga', 'Escape', 'Edge', 'Explorer', 'Expedition', 'F-150', 'Ranger', 'Bronco', 'Maverick', 'Mustang Mach-E', 'Transit', 'Transit Custom', 'Transit Connect', 'Courier', 'Galaxy', 'S-Max', 'C-Max', 'Ka'],
    'Geely': ['Coolray', 'Emgrand', 'Atlas', 'Geometry C'],
    'Genesis': ['G70', 'G80', 'G90', 'GV60', 'GV70', 'GV80'],
    'GMC': ['Terrain', 'Acadia', 'Yukon', 'Sierra', 'Canyon', 'Hummer EV', 'Savana'],
    'Great Wall': ['Wingle', 'Hover', 'Voleex', 'Steed'],
    'Honda': ['Civic', 'Accord', 'City', 'Insight', 'CR-Z', 'Jazz', 'HR-V', 'CR-V', 'Passport', 'Pilot', 'Ridgeline', 'e'],
    'Hummer': ['H1', 'H2', 'H3', 'EV'],
    'Hyundai': ['i10', 'i20', 'i30', 'i40', 'Accent', 'Elantra', 'Sonata', 'Veloster', 'Bayon', 'Venue', 'Kona', 'Tucson', 'Santa Fe', 'Palisade', 'Ioniq', 'Ioniq 5', 'Ioniq 6', 'ix35', 'Getz', 'Matrix', 'Atos', 'Coupe'],
    'Infiniti': ['Q30', 'Q50', 'Q60', 'Q70', 'QX30', 'QX50', 'QX55', 'QX60', 'QX70', 'QX80'],
    'Isuzu': ['D-Max', 'MU-X', 'Trooper'],
    'Iveco': ['Daily', 'Massif'],
    'Jaguar': ['XE', 'XF', 'XJ', 'F-Type', 'E-Pace', 'F-Pace', 'I-Pace', 'X-Type', 'S-Type'],
    'Jeep': ['Avenger', 'Renegade', 'Compass', 'Cherokee', 'Grand Cherokee', 'Wrangler', 'Gladiator', 'Wagoneer', 'Grand Wagoneer', 'Commander', 'Patriot', 'Liberty'],
    'Kia': ['Picanto', 'Rio', 'Cerato', 'Forte', 'K5', 'Stinger', 'K8', 'Soul', 'Stonic', 'Seltos', 'Sportage', 'Sorento', 'Telluride', 'Carnival', 'EV6', 'EV9', 'Niro', 'e-Niro', 'Ceed', 'ProCeed', 'Optima', 'Venga'],
    'Lada': ['Niva', 'Granta', 'Vesta', 'Largus', '2107', '2110', 'Priora', 'Kalina'],
    'Lamborghini': ['Huracán', 'Urus', 'Aventador', 'Revuelto', 'Gallardo', 'Murciélago'],
    'Lancia': ['Ypsilon', 'Delta', 'Musa', 'Thema'],
    'Land Rover': ['Defender', 'Discovery', 'Discovery Sport', 'Range Rover', 'Range Rover Sport', 'Range Rover Velar', 'Range Rover Evoque', 'Freelander'],
    'Lexus': ['CT', 'IS', 'ES', 'GS', 'LS', 'RC', 'LC', 'UX', 'NX', 'RX', 'GX', 'LX'],
    'Lincoln': ['Corsair', 'Nautilus', 'Aviator', 'Navigator', 'MKZ', 'MKC', 'MKX', 'Town Car'],
    'Lotus': ['Emira', 'Evora', 'Eletre', 'Elise', 'Exige'],
    'Maserati': ['Ghibli', 'Quattroporte', 'Levante', 'GranTurismo', 'GranCabrio', 'MC20', 'Grecale'],
    'Mazda': ['2', '3', '6', 'CX-3', 'CX-30', 'CX-5', 'CX-50', 'CX-60', 'CX-9', 'CX-90', 'MX-5', 'MX-30', 'RX-8', '626'],
    'McLaren': ['GT', 'Artura', '720S', '765LT', '570S', '600LT', 'P1'],
    'Mercedes-Benz': ['A-Class', 'B-Class', 'C-Class', 'E-Class', 'S-Class', 'CLA', 'CLS', 'GLA', 'GLB', 'GLC', 'GLE', 'GLS', 'G-Class', 'EQA', 'EQB', 'EQC', 'EQE', 'EQS', 'AMG GT', 'SL', 'SLC', 'SLK', 'CLK', 'V-Class', 'Vito', 'Sprinter', 'Citan', 'X-Class', 'ML', 'GL', 'GLK', 'R-Class'],
    'MG': ['ZS', 'HS', 'Marvel R', '3', '5', '6', 'TF'],
    'Mini': ['Cooper', 'Clubman', 'Countryman', 'Paceman', 'Roadster', 'Coupe'],
    'Mitsubishi': ['Mirage', 'Space Star', 'Attrage', 'Lancer', 'Eclipse Cross', 'Outlander', 'ASX', 'Pajero', 'L200'],
    'Nissan': ['Micra', 'Note', 'Versa', 'Sentra', 'Almera', 'Altima', 'Maxima', 'GT-R', 'Z', '370Z', '350Z', 'Juke', 'Kicks', 'Qashqai', 'X-Trail', 'Rogue', 'Murano', 'Pathfinder', 'Armada', 'Patrol', 'Navara', 'Frontier', 'Titan', 'Ariya', 'Leaf', 'Primera', 'Terrano', 'Pulsar'],
    'Opel': ['Corsa', 'Astra', 'Insignia', 'Mokka', 'Crossland', 'Grandland', 'Combo', 'Vivaro', 'Zafira', 'Vectra', 'Meriva', 'Antara', 'Agila', 'Adam'],
    'Peugeot': ['108', '208', '2008', '301', '308', '3008', '408', '508', '5008', 'Rifter', 'Partner', 'Expert', 'Traveller', 'e-208', 'e-2008', 'RCZ', '207', '307', '407', '607', '206', '306', '406'],
    'Polestar': ['1', '2', '3', '4'],
    'Porsche': ['718 Cayman', '718 Boxster', '911', 'Panamera', 'Macan', 'Cayenne', 'Taycan', 'Carrera GT', 'Cayman', 'Boxster'],
    'Proton': ['Saga', 'Persona', 'Wira', 'Satria', 'Gen-2'],
    'Ram': ['1500', '2500', '3500', 'ProMaster', 'ProMaster City'],
    'Renault': ['Clio', 'Megane', 'Talisman', 'Captur', 'Kadjar', 'Koleos', 'Arkana', 'Austral', 'Kangoo', 'Trafic', 'Master', 'Zoe', 'Twingo', 'Fluence', 'Latitude', 'Laguna', 'Scenic', 'Espace', 'Modus', 'Symbol', 'Taliant'],
    'Rivian': ['R1T', 'R1S'],
    'Rolls-Royce': ['Ghost', 'Wraith', 'Dawn', 'Phantom', 'Cullinan', 'Spectre'],
    'Rover': ['25', '45', '75', '200', '400', '600', '800'],
    'Saab': ['9-3', '9-5', '900', '9000'],
    'Seat': ['Ibiza', 'Leon', 'Arona', 'Ateca', 'Tarraco', 'Alhambra', 'Toledo', 'Altea', 'Cordoba', 'Exeo'],
    'Skoda': ['Fabia', 'Scala', 'Octavia', 'Superb', 'Kamiq', 'Karoq', 'Kodiaq', 'Enyaq', 'Roomster', 'Rapid', 'Yeti', 'Citigo'],
    'Smart': ['ForTwo', 'ForFour', 'Roadster'],
    'SsangYong': ['Tivoli', 'Korando', 'Rexton', 'Musso', 'Actyon', 'Kyron'],
    'Subaru': ['Impreza', 'Legacy', 'WRX', 'BRZ', 'XV', 'Crosstrek', 'Forester', 'Outback', 'Ascent', 'Solterra', 'Tribeca'],
    'Suzuki': ['Swift', 'Baleno', 'Dzire', 'Ciaz', 'Ignis', 'Vitara', 'S-Cross', 'Jimny', 'Grand Vitara', 'SX4', 'Alto', 'Celerio', 'Wagon R', 'Ertiga', 'Splash', 'Liana'],
    'Tata': ['Indica', 'Indigo', 'Nano', 'Sumo', 'Safari'],
    'Tesla': ['Model 3', 'Model S', 'Model X', 'Model Y', 'Cybertruck', 'Roadster'],
    'Tofaş': ['Şahin', 'Kartal', 'Doğan', 'Serçe'],
    'Toyota': ['Aygo', 'Yaris', 'Corolla', 'Camry', 'Avalon', 'Prius', 'Mirai', 'GT86', 'GR86', 'GR Supra', 'C-HR', 'RAV4', 'Venza', 'Highlander', 'Sequoia', 'Land Cruiser', '4Runner', 'Tacoma', 'Tundra', 'Hilux', 'bZ4X', 'Verso', 'Avensis', 'Auris', 'Urban Cruiser', 'Fortuner', 'Proace', 'Proace City'],
    'Volkswagen': ['Up', 'Polo', 'Golf', 'Jetta', 'Passat', 'Arteon', 'CC', 'Beetle', 'Eos', 'Scirocco', 'T-Cross', 'T-Roc', 'Taos', 'Tiguan', 'Touareg', 'Atlas', 'Touran', 'Sharan', 'Caddy', 'Transporter', 'Crafter', 'Amarok', 'ID.3', 'ID.4', 'ID.5', 'ID. Buzz', 'Bora', 'Phaeton'],
    'Volvo': ['S40', 'S60', 'S80', 'S90', 'V40', 'V50', 'V60', 'V70', 'V90', 'XC40', 'XC60', 'XC70', 'XC90', 'C30', 'C40', 'C70', 'EX30', 'EX90'],
  };
  
  List<String> get _availableModels {
    if (_selectedBrand == null) return [];
    return _carData[_selectedBrand!] ?? [];
  }
  
  @override
  void initState() {
    super.initState();
    _loadUserVehicleData();
  }
  
  void _loadUserVehicleData() {
    final user = AuthService.currentUser;
    if (user != null) {
      setState(() {
        _selectedBrand = user.vehicleBrand;
        _selectedModel = user.vehicleModel;
        _selectedColor = user.vehicleColor;
        _plateController.text = user.licensePlate ?? '';
      });
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Localized colors list
    final localizedColors = [
      l10n.white,
      l10n.black,
      l10n.silver,
      l10n.gray,
      l10n.red,
      l10n.blue,
      l10n.green,
      l10n.yellow,
      l10n.orange,
      l10n.brown,
      l10n.beige,
      l10n.gold,
      l10n.purple,
      l10n.pink,
      l10n.turquoise,
      l10n.bronze,
      l10n.maroon,
      l10n.navyBlue,
      l10n.other,
    ];
    
    // Ensure selected color exists in localized list
    if (_selectedColor != null && !localizedColors.contains(_selectedColor)) {
      _selectedColor = null;
    }
    
    // Ensure selected brand exists in the car data
    if (_selectedBrand != null && !_carData.containsKey(_selectedBrand)) {
      _selectedBrand = null;
      _selectedModel = null;
    }
    
    // Ensure selected model exists for the selected brand
    if (_selectedBrand != null && _selectedModel != null) {
      final availableModels = _carData[_selectedBrand!] ?? [];
      if (!availableModels.contains(_selectedModel)) {
        _selectedModel = null;
      }
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.vehicleInformation,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ScrollIndicator(
        scrollController: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                
                // Brand dropdown
                Text(
                  l10n.brand,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedBrand,
                  decoration: InputDecoration(
                    hintText: l10n.selectBrand,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFDD2C00), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: _carData.keys.map((brand) {
                    return DropdownMenuItem<String>(
                      value: brand,
                      child: Text(brand),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBrand = value;
                      _selectedModel = null; // Reset model when brand changes
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseSelectBrand;
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 20),
                
                // Model dropdown
                Text(
                  l10n.model,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedModel,
                  decoration: InputDecoration(
                    hintText: _selectedBrand == null 
                        ? l10n.selectBrandFirst
                        : l10n.selectModel,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFDD2C00), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: _availableModels.map((model) {
                    return DropdownMenuItem<String>(
                      value: model,
                      child: Text(model),
                    );
                  }).toList(),
                  onChanged: _selectedBrand == null ? null : (value) {
                    setState(() {
                      _selectedModel = value;
                    });
                  },
                ),
                
                SizedBox(height: 20),
                
                // Color dropdown
                Text(
                  l10n.color,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedColor,
                  decoration: InputDecoration(
                    hintText: l10n.selectColor,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFDD2C00), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: localizedColors.map((color) {
                    return DropdownMenuItem<String>(
                      value: color,
                      child: Text(color),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedColor = value;
                    });
                  },
                ),
                
                SizedBox(height: 20),
                
                // License plate field
                Text(
                  l10n.licensePlate,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (value) {
                    // Remove spaces and capitalize
                    final cleanedValue = value.replaceAll(' ', '').toUpperCase();
                    if (cleanedValue != value) {
                      _plateController.value = TextEditingValue(
                        text: cleanedValue,
                        selection: TextSelection.collapsed(offset: cleanedValue.length),
                      );
                    }
                  },
                  decoration: InputDecoration(
                    hintText: _plateExample,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFFDD2C00), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterPlate;
                          }
                          return null;
                        },
                      ),
                
                SizedBox(height: 32),
                
                // Save button
                GestureDetector(
                  onTap: _isSaved ? null : () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isSaved = true;
                      });
                      
                      // Navigate back after a short delay
                      Future.delayed(Duration(milliseconds: 800), () {
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isSaved ? Color(0xFF00C853) : Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SizedBox(
                      height: 42.0,
                      child: Center(
                        child: Text(
                          _isSaved ? l10n.saved : l10n.save,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
