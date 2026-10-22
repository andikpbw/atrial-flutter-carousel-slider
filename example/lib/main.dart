import 'package:flutter/material.dart';
import 'package:atrial_carousel_slider/atrial_carousel_slider.dart';

void main() {
  runApp(const CarouselDemoApp());
}

class CarouselDemoApp extends StatelessWidget {
  const CarouselDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atrial Carousel Slider Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const CarouselShowcasePage(),
    );
  }
}

class CarouselShowcasePage extends StatefulWidget {
  const CarouselShowcasePage({super.key});

  @override
  State<CarouselShowcasePage> createState() => _CarouselShowcasePageState();
}

class _CarouselShowcasePageState extends State<CarouselShowcasePage> {
  final AtrialCarouselController _controller = AtrialCarouselController();

  final List<Map<String, dynamic>> _slides = const [
    {
      'title': 'Stunning 3D Transitions',
      'subtitle':
          'Silky smooth 60/120fps animations with hardware acceleration.',
      'gradient': [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      'icon': Icons.view_carousel_rounded,
    },
    {
      'title': 'Auto-Play with Smart Pause',
      'subtitle': 'Pauses seamlessly on touch and desktop mouse hover.',
      'gradient': [Color(0xFFEC4899), Color(0xFFF43F5E)],
      'icon': Icons.play_circle_filled_rounded,
    },
    {
      'title': 'Interactive Indicators',
      'subtitle': 'Worm, Expanding, Scale, Slide, and Color transitions.',
      'gradient': [Color(0xFF06B6D4), Color(0xFF3B82F6)],
      'icon': Icons.linear_scale_rounded,
    },
    {
      'title': 'Full Programmatic Control',
      'subtitle': 'Next, previous, jump, animate, play, and pause with ease.',
      'gradient': [Color(0xFF10B981), Color(0xFF059669)],
      'icon': Icons.tune_rounded,
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atrial Carousel Slider'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('1. Modern Banner with Expanding Indicator'),
            const SizedBox(height: 12),
            AtrialCarouselSlider.builder(
              controller: _controller,
              itemCount: _slides.length,
              options: const AtrialCarouselOptions(
                height: 190,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 4),
                enlargeCenterPage: true,
                enlargeFactor: 0.15,
                viewportFraction: 0.88,
              ),
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return _buildCard(
                  title: slide['title'] as String,
                  subtitle: slide['subtitle'] as String,
                  gradient: slide['gradient'] as List<Color>,
                  icon: slide['icon'] as IconData,
                );
              },
            ),
            const SizedBox(height: 10),
            Center(
              child: AtrialCarouselIndicator(
                controller: _controller,
                count: _slides.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Color(0xFF6366F1),
                  dotColor: Color(0xFFCBD5E1),
                  expansionFactor: 3.0,
                  dotWidth: 8,
                  dotHeight: 8,
                  spacing: 6,
                ),
                onDotClicked: (index) => _controller.animateToPage(index),
              ),
            ),
            const SizedBox(height: 16),
            _buildControlsDashboard(),
            const SizedBox(height: 32),
            _buildSectionHeader('2. 3D Cube Transform'),
            const SizedBox(height: 12),
            AtrialCarouselSlider.builder(
              itemCount: _slides.length,
              options: const AtrialCarouselOptions(
                height: 180,
                viewportFraction: 0.85,
                slideTransform: CubeSlideTransform(),
              ),
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return _buildCard(
                  title: slide['title'] as String,
                  subtitle: slide['subtitle'] as String,
                  gradient: slide['gradient'] as List<Color>,
                  icon: slide['icon'] as IconData,
                );
              },
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('3. Parallax Depth Transform'),
            const SizedBox(height: 12),
            AtrialCarouselSlider.builder(
              itemCount: _slides.length,
              options: const AtrialCarouselOptions(
                height: 180,
                viewportFraction: 0.85,
                slideTransform: ParallaxSlideTransform(),
              ),
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return _buildCard(
                  title: slide['title'] as String,
                  subtitle: slide['subtitle'] as String,
                  gradient: slide['gradient'] as List<Color>,
                  icon: slide['icon'] as IconData,
                );
              },
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('4. Worm Indicator Effect'),
            const SizedBox(height: 12),
            Center(
              child: ValueListenableBuilder<int>(
                valueListenable: _controller.pageNotifier,
                builder: (context, activeIndex, _) {
                  return AtrialCarouselIndicator.builder(
                    count: _slides.length,
                    currentIndex: activeIndex,
                    effect: const WormIndicatorEffect(
                      activeDotColor: Color(0xFFEC4899),
                      dotColor: Color(0xFFCBD5E1),
                      dotWidth: 10,
                      dotHeight: 10,
                    ),
                    onDotClicked: (i) => _controller.animateToPage(i),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildControlsDashboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton.filledTonal(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Previous',
            onPressed: () => _controller.previousPage(),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            icon: const Icon(Icons.play_arrow_rounded),
            tooltip: 'Play',
            onPressed: () => _controller.startAutoPlay(),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            icon: const Icon(Icons.pause_rounded),
            tooltip: 'Pause',
            onPressed: () => _controller.stopAutoPlay(),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            icon: const Icon(Icons.arrow_forward_rounded),
            tooltip: 'Next',
            onPressed: () => _controller.nextPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withAlpha(76),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withAlpha(230),
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
