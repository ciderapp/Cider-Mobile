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
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: icon,
        label: Text(title),
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: const BorderSide(
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
    }

    return IconButton(
      icon: icon,
      onPressed: onTap,
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ...items,
      ],
    );
  }
}
