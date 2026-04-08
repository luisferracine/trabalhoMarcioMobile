import 'package:flutter/material.dart';
import '../models/country.dart';

/// Card de país exibido na grade da tela inicial.
class CountryCard extends StatelessWidget {
  final Country country;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const CountryCard({
    super.key,
    required this.country,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Faixa superior gradiente
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
              ),
            ),
            // Imagem da bandeira
            SizedBox(
              height: 110,
              width: double.infinity,
              child: country.flagUrl.isNotEmpty
                  ? Image.network(
                      country.flagUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (_, _, _) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(
                          Icons.flag_outlined,
                          size: 36,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade100,
                      child: const Icon(
                        Icons.flag_outlined,
                        size: 36,
                        color: Colors.grey,
                      ),
                    ),
            ),
            // Conteúdo textual
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.common,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      country.official,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Chips de código e região
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _SmallChip(
                          label: country.code,
                          color: colorScheme.primary,
                        ),
                        _SmallChip(
                          label: country.region,
                          color: colorScheme.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Capital
                    _InfoLine(
                      icon: Icons.location_city_outlined,
                      text: country.capital,
                    ),
                    // População
                    if (country.population != null)
                      _InfoLine(
                        icon: Icons.people_outline,
                        text: _formatPop(country.population!),
                      ),
                    const Spacer(),
                    // Botão de favorito
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: onFavoriteToggle,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 22,
                            color: isFavorite
                                ? Colors.redAccent
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPop(int pop) {
    if (pop >= 1000000000) {
      return '${(pop / 1000000000).toStringAsFixed(1)}B';
    }
    if (pop >= 1000000) return '${(pop / 1000000).toStringAsFixed(1)}M';
    if (pop >= 1000) return '${(pop / 1000).toStringAsFixed(0)}K';
    return pop.toString();
  }
}

class _SmallChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 11, color: Colors.grey.shade500),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
