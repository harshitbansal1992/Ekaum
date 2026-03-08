class PaathService {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool isFamilyService;

  PaathService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.isFamilyService = false,
  });

  static List<PaathService> getAvailableServices() {
    return [
      PaathService(
        id: 'durga_saptashti_paath',
        name: 'Durga Saptashti Paath',
        description: 'Durga Saptashti Paath service',
        price: 21000.0,
      ),
      PaathService(
        id: 'durga_saptashti_parihar_paath',
        name: 'Durga Saptashti Parihar Paath',
        description: 'Durga Saptashti Parihar Paath service',
        price: 21000.0,
      ),
      PaathService(
        id: 'durga_saptashti_paath_family',
        name: 'Durga Saptashti Paath Family',
        description: 'Durga Saptashti Paath for family',
        price: 51000.0,
        isFamilyService: true,
      ),
      PaathService(
        id: 'durga_saptashti_parihar_paath_family',
        name: 'Durga Saptashti Parihar Paath Family',
        description: 'Durga Saptashti Parihar Paath for family',
        price: 51000.0,
        isFamilyService: true,
      ),
      PaathService(
        id: 'mahamritunjaya_paath',
        name: 'Mahamritunjaya Paath',
        description: 'Mahamritunjaya Paath service',
        price: 125000.0,
      ),
      PaathService(
        id: 'vishesh_kripa_samadhan',
        name: 'Vishesh Kripa Samadhan',
        description: 'Vishesh Kripa Samadhan service',
        price: 1100.0,
      ),
      PaathService(
        id: 'janam_kundli_samadhar',
        name: 'Janam Kundli Samadhar',
        description: 'Janam Kundli Samadhar service',
        price: 1100.0,
      ),
    ];
  }
}

