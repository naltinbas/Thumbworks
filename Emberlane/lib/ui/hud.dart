import 'package:flutter/material.dart';

import '../sim/field.dart';
import '../sim/kinds.dart';
import '../sim/run.dart';
import '../sim/waves.dart';
import 'palette.dart';

/// The line above the field: embers, the keep, and which wave this is.
class Ledger extends StatelessWidget {
  const Ledger({super.key, required this.run, required this.onLeave});

  final Run run;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 14, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Leave the run',
          ),
          _Count(
            icon: Icons.local_fire_department_rounded,
            value: '${run.embers}',
            tint: Palette.ember,
            label: 'embers',
          ),
          const SizedBox(width: 18),
          _Count(
            icon: Icons.shield_rounded,
            value: '${run.keep}',
            tint: Palette.keep,
            label: 'keep',
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Wave ${run.wave.clamp(0, Waves.count - 1) + 1}',
                style: const TextStyle(
                  color: Palette.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'of ${Waves.count}',
                style: const TextStyle(color: Palette.inkDim, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({
    required this.icon,
    required this.value,
    required this.tint,
    required this.label,
  });

  final IconData icon;
  final String value;
  final Color tint;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '$value $label',
        child: Row(
          children: [
            Icon(icon, size: 17, color: tint),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                color: Palette.ink,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      );
}

/// The row of towers to build, along the bottom.
class Shop extends StatelessWidget {
  const Shop({
    super.key,
    required this.run,
    required this.placing,
    required this.onPlace,
  });

  final Run run;
  final Tower? placing;

  /// Start placing a tower, or stop by passing null.
  final ValueChanged<Tower?> onPlace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Row(
        children: [
          for (final tower in Tower.values) ...[
            Expanded(
              child: _Card(
                tower: tower,
                on: placing == tower,
                canAfford: run.embers >= tower.cost,
                onTap: () => onPlace(placing == tower ? null : tower),
              ),
            ),
            if (tower != Tower.values.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.tower,
    required this.on,
    required this.canAfford,
    required this.onTap,
  });

  final Tower tower;
  final bool on;
  final bool canAfford;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = Palette.of(tower);
    return Semantics(
      button: true,
      selected: on,
      label: '${tower.name}, ${tower.cost} embers',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            color: on ? tint.withValues(alpha: 0.18) : Palette.ground,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: on ? tint : Palette.lane,
              width: on ? 1.8 : 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tower.name,
                style: TextStyle(
                  color: canAfford ? Palette.ink : Palette.inkDim,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${tower.cost}',
                style: TextStyle(
                  color: canAfford ? Palette.ember : Palette.inkDim,
                  fontSize: 14,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What a tower on the field can be told to do.
class TowerPanel extends StatelessWidget {
  const TowerPanel({
    super.key,
    required this.run,
    required this.on,
    required this.onUpgrade,
    required this.onSell,
  });

  final Run run;
  final Cell on;
  final VoidCallback onUpgrade;
  final VoidCallback onSell;

  @override
  Widget build(BuildContext context) {
    final tower = run.towerOn(on);
    if (tower == null) return const SizedBox.shrink();
    final tint = Palette.of(tower.kind);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      padding: const EdgeInsets.fromLTRB(12, 9, 10, 9),
      decoration: BoxDecoration(
        color: Palette.ground,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: tint.withValues(alpha: 0.5), width: 1.2),
      ),
      // Everything on one line, and the line has to fit a 320 point phone,
      // so the name gives way before the buttons do. There is no close
      // button: tapping anywhere off the tower already puts the panel away,
      // and a third button here is what pushed this off the edge.
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tower.kind.name}${tower.level > 1 ? ' II' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tint,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  tower.kind.slows > 0
                      ? 'slows what it hits'
                      : '${tower.hits} a shot',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Palette.inkDim, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (tower.canUpgrade) ...[
            _Small(
              label: 'Upgrade ${tower.upgradeCost}',
              tint: Palette.ember,
              onTap: run.embers >= tower.upgradeCost ? onUpgrade : null,
            ),
            const SizedBox(width: 6),
          ],
          _Small(
            label: 'Sell ${tower.sellsFor}',
            tint: Palette.inkDim,
            onTap: onSell,
          ),
        ],
      ),
    );
  }
}

class _Small extends StatelessWidget {
  const _Small({required this.label, required this.tint, required this.onTap});

  final String label;
  final Color tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: onTap == null ? Palette.lane : tint.withValues(alpha: 0.7),
                width: 1.2,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: onTap == null ? Palette.inkDim : Palette.ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
}

/// Call the next wave, and go faster.
class Controls extends StatelessWidget {
  const Controls({
    super.key,
    required this.run,
    required this.hurrying,
    required this.onCall,
    required this.onHurry,
  });

  final Run run;
  final bool hurrying;
  final VoidCallback onCall;
  final ValueChanged<bool> onHurry;

  @override
  Widget build(BuildContext context) {
    final wave = run.nextWave;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: FilledButton(
                onPressed: run.waiting && wave != null ? onCall : null,
                style: FilledButton.styleFrom(
                  backgroundColor: Palette.ember,
                  foregroundColor: Palette.night,
                  disabledBackgroundColor: Palette.ground,
                  disabledForegroundColor: Palette.inkDim,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: Text(
                  run.waiting && wave != null
                      ? 'Send wave ${run.wave + 1}  ·  ${wave.walkers}'
                      : 'Wave ${run.wave + 1} under way',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            selected: hurrying,
            label: 'Double speed',
            child: GestureDetector(
              onTap: () => onHurry(!hurrying),
              child: Container(
                width: 56,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: hurrying ? Palette.ember.withValues(alpha: 0.18) : null,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: hurrying ? Palette.ember : Palette.lane,
                    width: hurrying ? 1.8 : 1.2,
                  ),
                ),
                child: Text(
                  '2x',
                  style: TextStyle(
                    color: hurrying ? Palette.ember : Palette.inkDim,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
