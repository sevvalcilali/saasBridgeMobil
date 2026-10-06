import 'package:flutter/widgets.dart';

import '../../tema/renkler.dart';

/// "Kartı alıcıya yaklaştırın" nabzı: 2 px vurgu halka `scale .8 → 1.8`,
/// `opacity .7 → 0`; 1,6 sn, ease-out, sonsuz. Ortada dolu daire.
class Nabiz extends StatefulWidget {
  const Nabiz({super.key, this.boyut = 56});

  final double boyut;

  @override
  State<Nabiz> createState() => _NabizState();
}

class _NabizState extends State<Nabiz> with SingleTickerProviderStateMixin {
  late final AnimationController _denetleyici = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  late final CurvedAnimation _egri = CurvedAnimation(parent: _denetleyici, curve: Curves.easeOut);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sistemde "hareketi azalt" açıksa halka sabit durur.
    if (MediaQuery.disableAnimationsOf(context)) {
      _denetleyici.stop();
      _denetleyici.value = 0.25;
    } else if (!_denetleyici.isAnimating) {
      _denetleyici.repeat();
    }
  }

  @override
  void dispose() {
    _egri.dispose();
    _denetleyici.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: widget.boyut,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _egri,
                builder: (context, child) => Opacity(
                  opacity: 0.7 * (1 - _egri.value),
                  child: Transform.scale(scale: 0.8 + _egri.value, child: child),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Renkler.vurgu, width: 2),
                  ),
                ),
              ),
            ),
            SizedBox.square(
              dimension: widget.boyut - 32,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Renkler.vurgu, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
