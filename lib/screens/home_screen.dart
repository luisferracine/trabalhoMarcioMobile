import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/countries_service.dart';
import '../services/favorites_service.dart';
import '../widgets/country_card.dart';
import '../widgets/region_filter_bar.dart';
import 'country_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Country> _countries = [];
  Set<String> _favorites = {};
  String _selectedRegion = 'Todos';
  bool _loading = true;
  bool _hasError = false;
  int _currentIndex = 0;

  final _countriesService = CountriesService();
  final _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final results = await Future.wait([
        _countriesService.fetchAll(),
        _favoritesService.loadFavoriteCodes(),
      ]);
      if (!mounted) return;
      setState(() {
        _countries = results[0] as List<Country>;
        _favorites = results[1] as Set<String>;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  List<String> get _regions {
    final set = <String>{};
    for (final c in _countries) {
      if (c.region.isNotEmpty) set.add(c.region);
    }
    return ['Todos', ...(set.toList()..sort())];
  }

  List<Country> get _filteredCountries {
    if (_selectedRegion == 'Todos') return _countries;
    return _countries.where((c) => c.region == _selectedRegion).toList();
  }

  List<Country> get _favoriteCountries =>
      _countries.where((c) => _favorites.contains(c.code)).toList();

  Future<void> _toggleFavorite(Country country) async {
    final wasFav = _favorites.contains(country.code);
    // Atualização otimista da UI
    setState(() {
      if (wasFav) {
        _favorites.remove(country.code);
      } else {
        _favorites.add(country.code);
      }
    });
    try {
      if (wasFav) {
        await _favoritesService.removeFavorite(country.code);
      } else {
        await _favoritesService.addFavorite(country);
      }
    } catch (_) {
      // Reverte em caso de erro
      if (!mounted) return;
      setState(() {
        if (wasFav) {
          _favorites.add(country.code);
        } else {
          _favorites.remove(country.code);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar favoritos.')),
        );
      }
    }
  }

  void _openDetail(Country country) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CountryDetailScreen(
          country: country,
          initiallyFavorite: _favorites.contains(country.code),
          onFavoriteChanged: (isFav) {
            setState(() {
              if (isFav) {
                _favorites.add(country.code);
              } else {
                _favorites.remove(country.code);
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildError()
              : IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildCountriesTab(),
                    _buildFavoritesTab(),
                  ],
                ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public),
            label: 'Países',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _favorites.isNotEmpty,
              label: Text('${_favorites.length}'),
              child: const Icon(Icons.favorite_outline),
            ),
            selectedIcon: Badge(
              isLabelVisible: _favorites.isNotEmpty,
              label: Text('${_favorites.length}'),
              child: const Icon(Icons.favorite),
            ),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Não foi possível carregar os países.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountriesTab() {
    final countries = _filteredCountries;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Atlas de Países',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
              ),
              Text(
                '${countries.length} país(es) • $_selectedRegion',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: RegionFilterBar(
              regions: _regions,
              selected: _selectedRegion,
              onSelected: (r) => setState(() => _selectedRegion = r),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final country = countries[index];
                return CountryCard(
                  country: country,
                  isFavorite: _favorites.contains(country.code),
                  onFavoriteToggle: () => _toggleFavorite(country),
                  onTap: () => _openDetail(country),
                );
              },
              childCount: countries.length,
            ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisExtent: 290,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    final favorites = _favoriteCountries;
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          snap: true,
          centerTitle: false,
          title: Text(
            'Favoritos',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
        ),
        if (favorites.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 72,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum favorito ainda.',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque no coração de um país para salvar.',
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final country = favorites[index];
                  return CountryCard(
                    country: country,
                    isFavorite: true,
                    onFavoriteToggle: () => _toggleFavorite(country),
                    onTap: () => _openDetail(country),
                  );
                },
                childCount: favorites.length,
              ),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisExtent: 290,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
            ),
          ),
      ],
    );
  }
}
