import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart'; // 👈 importar AppColors
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_admin_screen.dart';
import 'building_pdf_service.dart'; // Cambia la ruta por la correcta
class AssessedBuildingsPage extends StatefulWidget {
  const AssessedBuildingsPage({super.key});

  @override
  State<AssessedBuildingsPage> createState() => _AssessedBuildingsPageState();
}

class _AssessedBuildingsPageState extends State<AssessedBuildingsPage> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _futureEdificios;
  List<Map<String, dynamic>> _edificios = [];
  List<Map<String, dynamic>> _filteredEdificios = [];
  int _selectedIndex = 0;
  String? _userId;
  String? _token;
  final TextEditingController _searchController = TextEditingController();

  Future<List<Map<String, dynamic>>> _getEdificios() async {
    final response = await supabase
        .from('edificios')
        .select('*')
        .order('id_edificio', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  void initState() {
    super.initState();
    _loadSessionData();
    _futureEdificios = _getEdificios();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredEdificios = List.from(_edificios);
      } else {
        _filteredEdificios = _edificios.where((edificio) {
          final nombre = (edificio['nombre_edificio'] ?? "").toLowerCase();
          return nombre.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadSessionData() async {
    final prefs = await await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
      _token = prefs.getString('accessToken');
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushNamed(context, '/home');
    } else if (index == 1) {
      // Si tenemos los datos, vamos al perfil real
      if (_userId != null && _token != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileAdminScreen(
              userId: _userId,
              token: _token,
            ),
          ),
        );
      } else {
        // Si no hay datos, enviamos al login o mostramos error
        Navigator.pushNamed(context, '/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // 👈 Usando AppColors
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 28,
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: const Text(
                "SismosApp",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              width: double.infinity,
              child: const Text(
                "Edificios",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureEdificios,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: AppColors.error),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No hay edificios registrados",
                        style: TextStyle(color: AppColors.gray500),
                      ),
                    );
                  }

                  if (_edificios.isEmpty) {
                    _edificios = snapshot.data!;
                    _filteredEdificios = List.from(_edificios);
                  }

                  return Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Edificios Evaluados",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Buscar edificio por nombre...",
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 220,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: _filteredEdificios.length,
                          itemBuilder: (context, index) { // 👈 Asegúrate de incluir (context, index) aquí
                            final edificio = _filteredEdificios[index];

                            // Extraemos el ID asegurándonos de que sea un int
                            final int idEdificio = edificio['id_edificio'] ?? 0;

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Imagen del edificio
                                    if (edificio['foto_edificio_url'] != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          edificio['foto_edificio_url'],
                                          height: 80,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),

                                    const SizedBox(height: 8),

                                    // Nombre del edificio
                                    Text(
                                      edificio['nombre_edificio'] ?? "Sin nombre",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.text,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 8),

                                    // BOTÓN PDF
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Generando reporte PDF...")),
                                        );
                                        // Llamada al servicio
                                        await BuildingPdfService.generateFullReport(idEdificio);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade700,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                                      label: const Text("PDF", style: TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray500,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
