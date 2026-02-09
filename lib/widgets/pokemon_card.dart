import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';

/// Card แสดง Pokémon พร้อม staggered animation
/// รับ Animation<double> จาก parent เพื่อควบคุม slide-in + fade-in
class PokemonCard extends StatefulWidget {
  final Pokemon pokemon;
  final Animation<double> animation;
  final VoidCallback onTap;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.animation,
    required this.onTap,
  });

  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - widget.animation.value)),
          child: Opacity(
            opacity: widget.animation.value,
            child: child,
          ),
        );
      },
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final primaryColor = Pokemon.typeColor(widget.pokemon.types.first);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Stack(
          children: [
            // Background Pokéball watermark
            Positioned(
              bottom: -15,
              right: -15,
              child: Icon(
                Icons.catching_pokemon,
                size: 80,
                color: primaryColor.withOpacity(0.08),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID
                  Text(
                    '#${widget.pokemon.id.toString().padLeft(3, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryColor.withOpacity(0.6),
                    ),
                  ),
                  // Name
                  Text(
                    widget.pokemon.name[0].toUpperCase() + widget.pokemon.name.substring(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Type badges
                  Wrap(
                    spacing: 4,
                    children: widget.pokemon.types.map((type) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Pokemon.typeColor(type),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          type,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  // Hero image
                  Center(
                    child: Hero(
                      tag: 'pokemon-${widget.pokemon.id}',
                      child: CachedNetworkImage(
                        imageUrl: widget.pokemon.imageUrl,
                        height: 90,
                        width: 90,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.catching_pokemon, size: 60),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}
