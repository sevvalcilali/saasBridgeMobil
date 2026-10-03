import 'package:flutter/widgets.dart';

/// Satır düğmesi: basılıyken opaklık .7 (README "Basılı durum").
class BasiliOpaklik extends StatefulWidget {
  const BasiliOpaklik({super.key, required this.onTap, required this.child, this.opaklik = 0.7});

  final VoidCallback? onTap;
  final Widget child;
  final double opaklik;

  @override
  State<BasiliOpaklik> createState() => _BasiliOpaklikState();
}

class _BasiliOpaklikState extends State<BasiliOpaklik> {
  bool _basili = false;

  void _ayarla(bool deger) {
    if (mounted && _basili != deger) setState(() => _basili = deger);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _ayarla(true),
        onTapUp: (_) => _ayarla(false),
        onTapCancel: () => _ayarla(false),
        child: Opacity(opacity: _basili ? widget.opaklik : 1, child: widget.child),
      ),
    );
  }
}
