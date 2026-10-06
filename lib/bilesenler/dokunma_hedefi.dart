import 'package:flutter/widgets.dart';

import '../tema/olculer.dart';

/// Görseli büyütmeden dokunma alanını en az 44 px yapar (README: "tüm dokunma
/// hedefleri ≥ 44 px"). Çocuk ortalanır; çevresindeki boşluk da dokunmayı alır.
class DokunmaHedefi extends StatelessWidget {
  const DokunmaHedefi({
    super.key,
    required this.onTap,
    required this.child,
    this.onBasili,
    this.genis = false,
  });

  final VoidCallback? onTap;

  /// Basılı durum değişince çağrılır (düğmenin rengini koyulaştırmak için).
  final ValueChanged<bool>? onBasili;

  /// true ise bulunduğu genişliği doldurur (çocuk da doldurmalıdır).
  final bool genis;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onTapDown: (_) => onBasili?.call(true),
      onTapUp: (_) => onBasili?.call(false),
      onTapCancel: () => onBasili?.call(false),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: Olculer.dokunmaEnAz, minHeight: Olculer.dokunmaEnAz),
        child: Center(widthFactor: genis ? null : 1, heightFactor: 1, child: child),
      ),
    );
  }
}
