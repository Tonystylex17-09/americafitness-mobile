import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  final Function onComplete;

  OnboardingPage({required this.onComplete});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentPage = 0;
  final PageController _controller = PageController();

  final List<OnboardingData> pages = [
    OnboardingData(
      title: 'Bienvenido a AméricaFitness',
      description: 'La app que te ayuda a alcanzar tus metas fitness con rutinas personalizadas, nutrición y comunidad.',
      icon: Icons.fitness_center,
      color: Colors.red.shade800,
    ),
    OnboardingData(
      title: 'Registra tus entrenamientos',
      description: 'Lleva el control de tus ejercicios, series y pesos día a día. La app aprende de tu progreso.',
      icon: Icons.track_changes,
      color: Colors.red.shade800,
    ),
    OnboardingData(
      title: 'Gana puntos y canjea premios',
      description: 'Cada check-in te da puntos. Canjéalos por descuentos en membresías y productos.',
      icon: Icons.emoji_events,
      color: Colors.red.shade800,
    ),
    OnboardingData(
      title: 'Compra productos exclusivos',
      description: 'Suplementos, ropa y accesorios. Acumula puntos y ahorra en tus compras.',
      icon: Icons.shopping_bag,
      color: Colors.red.shade800,
    ),
    OnboardingData(
      title: 'Listo para empezar',
      description: 'Completa tu perfil y comienza tu camino hacia una mejor versión de ti.',
      icon: Icons.rocket_launch,
      color: Colors.red.shade800,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final page = pages[index];
                return Container(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [page.color.withOpacity(0.2), page.color.withOpacity(0.5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          page.icon,
                          size: 80,
                          color: page.color,
                        ),
                      ),
                      SizedBox(height: 40),
                      Text(
                        page.title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Text(
                        page.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    widget.onComplete();
                  },
                  child: Text(
                    'Saltar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Row(
                  children: List.generate(pages.length, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentPage == index
                            ? Colors.red.shade800
                            : Colors.grey,
                      ),
                    );
                  }),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (currentPage == pages.length - 1) {
                      widget.onComplete();
                    } else {
                      _controller.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    currentPage == pages.length - 1 ? 'Empezar' : 'Siguiente',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
