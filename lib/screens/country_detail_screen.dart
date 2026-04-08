import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/country.dart';
import '../models/country_detail.dart';
import '../services/countries_service.dart';
import '../services/favorites_service.dart';
import '../widgets/detail_info_row.dart';

class CountryDetailScreen extends StatefulWidget {
  final Country country;
  final bool initiallyFavorite;
  final ValueChanged<bool> onFavoriteChanged;

  const CountryDetailScreen({
    super.key,
    required this.country,
    required this.initiallyFavorite,
    required this.onFavoriteChanged,
  });

  @override
  State<CountryDetailScreen> createState() => _CountryDetailScreenState();
}

class _CountryDetailScreenState extends State<CountryDetailScreen> {
  CountryDetail? _detail;
  bool _loading = true;
  late bool _isFavorite;

  final _countriesService = CountriesService();
  final _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initiallyFavorite;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final detail = await _countriesService.fetchByCode(widget.country.code);
    if (!mounted) return;
    setState(() {
      _detail = detail;
      _loading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final newValue = !_isFavorite;
    setState(() => _isFavorite = newValue);
    widget.onFavoriteChanged(newValue);
    try {
      if (newValue) {
        await _favoritesService.addFavorite(widget.country);
      } else {
        await _favoritesService.removeFavorite(widget.country.code);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isFavorite = !newValue);
      widget.onFavoriteChanged(!newValue);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar favoritos.')),
      );
    }
  }

  Future<void> _launchMap(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          // AppBar com imagem da bandeira expandida
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: colorScheme.surface,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.country.flagUrl.isNotEmpty)
                    Image.network(
                      widget.country.flagUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.flag_outlined,
                            size: 64, color: Colors.grey),
                      ),
                    )
                  else
                    Container(color: Colors.grey.shade200),
                  // Gradiente para legibilidade dos ícones
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black38, Colors.transparent],
                        stops: [0.0, 0.5],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                tooltip: _isFavorite ? 'Remover dos favoritos' : 'Favoritar',
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.redAccent : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),

          // Conteúdo
          SliverToBoxAdapter(
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(64),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _detail == null
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'Não foi possível carregar os detalhes.',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _buildContent(_detail!),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(CountryDetail d) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Text(
            d.common,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            d.official,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          // Chips de código e região
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: [
              _Chip(label: d.code, color: colorScheme.primary),
              _Chip(label: d.region, color: colorScheme.secondary),
            ],
          ),
          const SizedBox(height: 16),

          // Seção: Informações Básicas
          _SectionCard(
            title: 'Informações Básicas',
            icon: Icons.info_outline,
            children: [
              DetailInfoRow(
                  label: 'Sub-região',
                  value: d.subregion ?? 'Não informada'),
              DetailInfoRow(label: 'Capital', value: d.capital),
              DetailInfoRow(
                label: 'População',
                value: d.population != null
                    ? _formatNumber(d.population!)
                    : 'Não informada',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Seção: Geografia
          _SectionCard(
            title: 'Geografia',
            icon: Icons.public_outlined,
            children: [
              DetailInfoRow(
                label: 'Área',
                value: d.area != null
                    ? '${_formatNumber(d.area!.toInt())} km²'
                    : 'Não informada',
              ),
              DetailInfoRow(
                label: 'Continentes',
                value: d.continents.isNotEmpty
                    ? d.continents.join(', ')
                    : 'Não informado',
              ),
              DetailInfoRow(
                label: 'Fusos horários',
                value: d.timezones.isNotEmpty
                    ? d.timezones.join(', ')
                    : 'Não informado',
              ),
              DetailInfoRow(
                label: 'TLD',
                value: d.tld.isNotEmpty ? d.tld.join(', ') : 'Não informado',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Seção: Cultura
          _SectionCard(
            title: 'Cultura',
            icon: Icons.language_outlined,
            children: [
              DetailInfoRow(
                label: 'Idiomas',
                value: d.languages.isNotEmpty
                    ? d.languages.join(', ')
                    : 'Não informado',
              ),
              DetailInfoRow(
                label: 'Moedas',
                value: d.currencies.isNotEmpty
                    ? d.currencies.join(', ')
                    : 'Não informado',
              ),
              DetailInfoRow(label: 'FIFA', value: d.fifa ?? 'Não informado'),
              DetailInfoRow(
                  label: 'Lado do volante',
                  value: d.carSide ?? 'Não informado'),
              DetailInfoRow(
                  label: 'Início da semana',
                  value: d.startOfWeek ?? 'Não informado'),
            ],
          ),
          const SizedBox(height: 12),

          // Seção: Status Internacional
          _SectionCard(
            title: 'Status Internacional',
            icon: Icons.flag_outlined,
            children: [
              DetailInfoRow(
                label: 'Independente',
                value: d.independent == null
                    ? 'Não informado'
                    : (d.independent! ? 'Sim' : 'Não'),
              ),
              DetailInfoRow(
                label: 'Membro da ONU',
                value: d.unMember == null
                    ? 'Não informado'
                    : (d.unMember! ? 'Sim' : 'Não'),
              ),
            ],
          ),

          // Botão Google Maps
          if (d.mapUrl != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _launchMap(d.mapUrl!),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Ver no Google Maps'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ──────────────────────────────────────────────
// Widgets locais
// ──────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Icon(icon, size: 16, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
