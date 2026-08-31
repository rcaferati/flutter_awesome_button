part of 'demo_app.dart';

enum _DemoIconName {
  paintbrush('solid/paintbrush'),
  gauge('solid/gauge'),
  shareNodes('solid/share-nodes'),
  sizeChanges('solid/up-right-and-down-left-from-center'),
  rightLeft('solid/right-left'),
  forwardStep('solid/forward-step'),
  bars('solid/bars'),
  tableCellsLarge('solid/table-cells-large'),
  trashCan('solid/trash-can'),
  squarePlus('solid/square-plus'),
  userPlus('solid/user-plus'),
  locationArrow('solid/location-arrow'),
  facebook('brands/facebook-f'),
  x('brands/x-twitter'),
  messenger('brands/facebook-messenger'),
  instagram('brands/instagram'),
  whatsapp('brands/whatsapp'),
  youtube('brands/youtube'),
  linkedin('brands/linkedin-in'),
  pinterest('brands/pinterest-p');

  const _DemoIconName(this.assetPath);

  final String assetPath;
}

class _DemoIcon extends StatelessWidget {
  const _DemoIcon({
    required this.name,
    required this.size,
    required this.color,
  });

  final _DemoIconName name;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: SvgPicture.asset(
        'assets/icons/font-awesome/${name.assetPath}.svg',
        width: size,
        height: size,
        alignment: Alignment.center,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        excludeFromSemantics: true,
      ),
    );
  }
}
