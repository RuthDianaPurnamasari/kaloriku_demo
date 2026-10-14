import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kaloriku/model/food_model.dart';
import 'package:kaloriku/services/api_services.dart';
import 'package:kaloriku/services/auth_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtl = TextEditingController();
  final TextEditingController _caloriesCtl = TextEditingController();
  final TextEditingController _ingredientsCtl = TextEditingController();
  final TextEditingController _descriptionCtl = TextEditingController();

  final ApiServices _dataService = ApiServices();

  static const String _demoMenuKey = 'kaloriku_food_list';

  final List<String> _categories = [
    'Vegan',
    'High Protein',
    'Dessert',
    'Drink',
  ];

  List<FoodsModel> _foodList = [];

  bool _isDemoMode = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;

  String? _selectedCategory;
  String? _editingFoodId;
  String _username = 'Pengguna';

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    try {
      final bool demo = await AuthManager.isDemoMode();
      final String? savedUsername = await AuthManager.getUsername();

      if (!mounted) return;

      setState(() {
        _isDemoMode = demo;
        _username = savedUsername ?? 'Pengguna';
      });

      debugPrint('STATUS MODE DEMO: $demo');
      debugPrint('USERNAME: $_username');

      await refreshFoodList();
    } catch (e, stackTrace) {
      debugPrint('ERROR INISIALISASI MENU: $e');
      debugPrint('$stackTrace');

      if (mounted) {
        _showMessage('Gagal membuka halaman menu.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> refreshFoodList() async {
    try {
      final bool demoMode = await AuthManager.isDemoMode();

      if (!mounted) return;

      setState(() {
        _isDemoMode = demoMode;
      });

      if (demoMode) {
        await _loadDemoFood();
        return;
      }

      debugPrint('Mengambil daftar makanan dari server...');

      final Iterable<FoodsModel>? response =
          await _dataService.getAllMenuItem();

      if (!mounted) return;

      setState(() {
        _foodList = response?.toList() ?? [];
      });
    } catch (e, stackTrace) {
      debugPrint('ERROR MENGAMBIL MENU: $e');
      debugPrint('$stackTrace');

      if (mounted) {
        _showMessage(
          'Gagal mengambil menu dari server. '
          'Silakan gunakan Mode Demo.',
        );
      }
    }
  }

  Future<void> _loadDemoFood() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String? savedData = prefs.getString(_demoMenuKey);
      List<FoodsModel> loadedFoods = [];

      if (savedData != null && savedData.isNotEmpty) {
        final dynamic decoded = jsonDecode(savedData);

        if (decoded is List) {
          loadedFoods = decoded.map<FoodsModel>((item) {
            return FoodsModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            );
          }).toList();
        }
      }

      if (!mounted) return;

      setState(() {
        _foodList = loadedFoods;
      });

      debugPrint('JUMLAH MENU DEMO: ${_foodList.length}');
    } catch (e, stackTrace) {
      debugPrint('ERROR MEMUAT MENU DEMO: $e');
      debugPrint('$stackTrace');

      if (mounted) {
        _showMessage('Gagal membaca data menu demo.');
      }
    }
  }

  Future<void> _persistDemoFood() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String encodedData = jsonEncode(
      _foodList.map((food) => food.toJson()).toList(),
    );

    final bool saved = await prefs.setString(
      _demoMenuKey,
      encodedData,
    );

    if (!saved) {
      throw Exception('Data menu demo gagal disimpan.');
    }

    debugPrint('DATA MENU DEMO TERSIMPAN');
    debugPrint('JUMLAH MENU: ${_foodList.length}');
  }

  Future<void> _saveFood() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    final double? calories = double.tryParse(_caloriesCtl.text.trim());

    if (calories == null || !calories.isFinite || calories < 0) {
      _showMessage('Masukkan jumlah kalori yang valid.');
      return;
    }

    if (_selectedCategory == null) {
      _showMessage('Silakan pilih kategori makanan.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final bool demoMode = await AuthManager.isDemoMode();

      debugPrint('MODE DEMO SAAT MENYIMPAN: $demoMode');

      if (demoMode) {
        await _saveDemoFood(calories);
      } else {
        await _saveServerFood(calories);
      }
    } catch (e, stackTrace) {
      debugPrint('ERROR SIMPAN MENU: $e');
      debugPrint('$stackTrace');

      if (mounted) {
        _showMessage('Gagal menyimpan menu: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _saveDemoFood(double calories) async {
    final String id = _isEditing && _editingFoodId != null
        ? _editingFoodId!
        : DateTime.now().microsecondsSinceEpoch.toString();

    final FoodsModel newFood = FoodsModel(
      id: id,
      name: _nameCtl.text.trim(),
      ingredients: _ingredientsCtl.text.trim(),
      description: _descriptionCtl.text.trim(),
      calories: calories.round(),
      category: _selectedCategory!,
    );

    final int index = _foodList.indexWhere((food) => food.id == id);

    setState(() {
      if (_isEditing && index != -1) {
        _foodList[index] = newFood;
      } else {
        _foodList.insert(0, newFood);
      }
    });

    await _persistDemoFood();

    if (!mounted) return;

    final bool wasEditing = _isEditing;

    Navigator.of(context).pop();
    _clearFields();

    _showMessage(
      wasEditing ? 'Menu berhasil diperbarui.' : 'Menu berhasil ditambahkan.',
    );
  }

  Future<void> _saveServerFood(double calories) async {
    final FoodInput foodInput = FoodInput(
      name: _nameCtl.text.trim(),
      ingredients: _ingredientsCtl.text.trim(),
      description: _descriptionCtl.text.trim(),
      calories: calories,
      category: _selectedCategory!,
    );

    final FoodResponse? response;

    if (_isEditing && _editingFoodId != null) {
      response = await _dataService.putMenu(
        _editingFoodId!,
        foodInput,
        calories,
        '',
        _selectedCategory!,
      );
    } else {
      response = await _dataService.postMenu(
        foodInput,
        calories,
        '',
        _selectedCategory!,
      );
    }

    if (response == null || response.status < 200 || response.status >= 300) {
      throw Exception(
        'Server gagal menyimpan menu. '
        'Periksa koneksi dan status backend.',
      );
    }

    final bool wasEditing = _isEditing;

    await refreshFoodList();

    if (!mounted) return;

    Navigator.of(context).pop();
    _clearFields();

    _showMessage(
      wasEditing ? 'Menu berhasil diperbarui.' : 'Menu berhasil ditambahkan.',
    );
  }

  Future<void> _deleteFood(FoodsModel food) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Makanan'),
        content: Text('Yakin ingin menghapus "${food.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final bool demoMode = await AuthManager.isDemoMode();

      if (demoMode) {
        setState(() {
          _foodList.removeWhere((item) => item.id == food.id);
        });

        await _persistDemoFood();
      } else {
        await _dataService.deleteMenu(food.id);
        await refreshFoodList();
      }

      if (mounted) {
        _showMessage('Menu berhasil dihapus.');
      }
    } catch (e, stackTrace) {
      debugPrint('ERROR MENGHAPUS MENU: $e');
      debugPrint('$stackTrace');

      if (mounted) {
        _showMessage('Gagal menghapus menu: $e');
      }
    }
  }

  void _startEdit(FoodsModel food) {
    _nameCtl.text = food.name;
    _ingredientsCtl.text = food.ingredients;
    _caloriesCtl.text = food.calories.toString();
    _descriptionCtl.text = food.description;

    setState(() {
      _isEditing = true;
      _editingFoodId = food.id;
      _selectedCategory =
          _categories.contains(food.category) ? food.category : null;
    });

    _showFoodForm();
  }

  void _clearFields() {
    _nameCtl.clear();
    _ingredientsCtl.clear();
    _caloriesCtl.clear();
    _descriptionCtl.clear();

    if (!mounted) return;

    setState(() {
      _selectedCategory = null;
      _isEditing = false;
      _editingFoodId = null;
    });
  }

  void _showFoodForm() {
    if (!_isEditing) {
      _nameCtl.clear();
      _ingredientsCtl.clear();
      _caloriesCtl.clear();
      _descriptionCtl.clear();
      _selectedCategory = null;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditing ? 'Edit Makanan' : 'Tambah Makanan',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameCtl,
                        decoration: const InputDecoration(
                          labelText: 'Nama makanan',
                          hintText: 'Contoh: Nasi Goreng',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.restaurant),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama makanan wajib diisi.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _ingredientsCtl,
                        decoration: const InputDecoration(
                          labelText: 'Bahan makanan',
                          hintText: 'Contoh: nasi, telur, sayur',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.eco),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _caloriesCtl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Kalori (kkal)',
                          hintText: 'Contoh: 250',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_fire_department),
                        ),
                        validator: (value) {
                          final double? number = double.tryParse(
                            (value ?? '').trim(),
                          );

                          if (number == null ||
                              !number.isFinite ||
                              number < 0) {
                            return 'Masukkan angka kalori yang valid.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setSheetState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Pilih kategori makanan.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descriptionCtl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          hintText: 'Deskripsi makanan (opsional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving
                              ? null
                              : () async {
                                  FocusScope.of(context).unfocus();
                                  await _saveFood();
                                },
                          icon: _isSaving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            _isSaving
                                ? 'Menyimpan...'
                                : (_isEditing ? 'SIMPAN PERUBAHAN' : 'TAMBAH'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _ingredientsCtl.dispose();
    _caloriesCtl.dispose();
    _descriptionCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu Makanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _isLoading ? null : refreshFoodList,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refreshFoodList,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            child: Icon(Icons.person),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Selamat datang,',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  _username,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _isDemoMode
                                      ? 'Mode • Data tersimpan di perangkat'
                                      : 'Mode Server',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isDemoMode
                                        ? Colors.green
                                        : Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.restaurant_menu,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'List Makanan',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _editingFoodId = null;
                          });
                          _showFoodForm();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('TAMBAH'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_foodList.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 32,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.no_food_outlined,
                              size: 54,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Belum ada makanan',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tekan tombol TAMBAH untuk memasukkan '
                              'makanan pertama kamu.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._foodList.map((food) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: const Icon(Icons.restaurant),
                          ),
                          title: Text(
                            food.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${food.calories} kkal'),
                                Text(
                                  'Kategori: ${food.category}',
                                ),
                                if (food.ingredients.trim().isNotEmpty)
                                  Text(
                                    'Bahan: ${food.ingredients}',
                                  ),
                                if (food.description.trim().isNotEmpty)
                                  Text(food.description),
                              ],
                            ),
                          ),
                          isThreeLine: food.ingredients.trim().isNotEmpty ||
                              food.description.trim().isNotEmpty,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _startEdit(food);
                              } else if (value == 'delete') {
                                _deleteFood(food);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Hapus'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
