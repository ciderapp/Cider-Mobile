import 'package:flutter/material.dart';

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
    if (selected) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Theme.of(context).primaryColor,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).primaryTextTheme.headline6,
            ),
          ],
        ),
      );
    }

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          ),
        ),
        padding: const EdgeInsets.all(8),
        primary: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).primaryTextTheme.headline6,
          ),
        ],
      ),
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...items,
        ],
      ),
    );
  }
}
