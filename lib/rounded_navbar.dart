import 'package:flutter/material.dart';

// FIXME: Overflows horizontally when Item doesn't fit
// FIXME: Items are not the same size when selected

class RoundedNavbarItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final bool selected;
  final void Function()? onTap;

  const RoundedNavbarItem({
    Key? key,
    required this.icon,
    required this.title,
    this.selected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final col = Column(
      children: [
        icon,
        Text(
          title,
          style: Theme.of(context).primaryTextTheme.headline6,
        ),
      ],
    );

    if (selected) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).primaryColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: col,
      );
    }

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        primary: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      child: col,
    );
  }
}

class RoundedNavbar extends StatefulWidget {
  final List<RoundedNavbarItem> items;
  final Function(int)? onTap;

  const RoundedNavbar({
    Key? key,
    required this.items,
    this.onTap,
  }) : super(key: key);

  @override
  State<RoundedNavbar> createState() => _RoundedNavbarState();
}

class _RoundedNavbarState extends State<RoundedNavbar> {
  var _active = 0;

  @override
  Widget build(BuildContext context) {
    final items = widget.items.map((item) => RoundedNavbarItem(
          icon: item.icon,
          title: item.title,
          selected: _active == widget.items.indexOf(item),
          onTap: () {
            setState(() {
              _active = widget.items.indexOf(item);
            });
            widget.onTap?.call(_active);
          },
        ));

    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 1,
          ),
        ),
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...items,
          ],
        ),
      ),
    );
  }
}
