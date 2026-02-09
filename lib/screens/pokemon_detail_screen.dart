import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';
import '../widgets/pokemon_stats.dart';

/// หน้ารายละเอียด Pokémon
/// Animation ที่ใช้:
/// - Hero (รูปภาพ Pokémon)
/// - SlideTransition + FadeTransition (bottom sheet เลื่อนขึ้น)
/// - Rotating Pokéball background decoration
/// - Staggered stat bars (ใน PokemonStats widget)
class PokemonDetailScreen extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({super.key, required this.pokemon});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Rotation animation (หมุนอย่างต่อเนื่อง)
    _rotateController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Fade in delayed (เพื่อให้ Hero animation เล่นจบก่อน)
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.3, 1.0),
      ),
    );

    // Slide up bottom sheet
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pokemon = widget.pokemon;
    final primaryColor = Pokemon.typeColor(pokemon.types.first);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          // Background Pokéball decoration (หมุนช้าๆ)
          Positioned(
            top: -50,
            right: -50,
            child: AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _fadeController.value * 0.5,
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(
                      Icons.catching_pokemon,
                      size: 250,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),

          // Main content
          Column(
            children: [
              // Top section: back button + name + type + Hero image
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Custom app bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '#${pokemon.id.toString().padLeft(3, '0')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Name
                      Text(
                        pokemon.name[0].toUpperCase() +
                            pokemon.name.substring(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Type badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            pokemon.types.map((type) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  type,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Hero image with rotation
                      RotationTransition(
                        turns: _rotateController,
                        child: Hero(
                          tag: 'pokemon-${pokemon.id}',
                          child: CachedNetworkImage(
                            imageUrl: pokemon.imageUrl,
                            height: 200,
                            width: 200,
                            fit: BoxFit.contain,
                            placeholder: (_, __) =>
                                const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.catching_pokemon,
                              size: 120,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom sheet with stats (slide up + fade in)
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Physical info (height/weight)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildInfoItem(
                                  'Weight',
                                  '${pokemon.weight} kg',
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.grey.shade300,
                                ),
                                _buildInfoItem(
                                  'Height',
                                  '${pokemon.height} m',
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Animated stat bars
                            PokemonStats(pokemon: pokemon),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
