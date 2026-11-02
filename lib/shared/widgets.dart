import 'package:flutter/material.dart';

import '../core/theme.dart';

void go(BuildContext context, String route, {Object? arguments}) =>
    Navigator.of(context).pushNamed(route, arguments: arguments);
void home(BuildContext context) =>
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
void toast(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));

class Photo extends StatelessWidget {
  const Photo(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.radius = 0,
    this.fit = BoxFit.cover,
  });
  final String name;
  final double? width, height;
  final double radius;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.asset(
      'assets/images/$name.png',
      width: width,
      height: height,
      fit: fit,
    ),
  );
}

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.index = 0,
    this.size = 48,
    this.ring = true,
    this.asset,
  });
  final int index;
  final double size;
  final bool ring;
  final String? asset;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    padding: EdgeInsets.all(ring ? 3 : 0),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: ring ? Border.all(color: const Color(0xff7ac4da)) : null,
    ),
    child: ClipOval(child: Photo(asset ?? 'avatar_${index % 6}')),
  );
}

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.bottom,
    this.padding = const EdgeInsets.all(24),
    this.scroll = true,
  });
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottom;
  final EdgeInsets padding;
  final bool scroll;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: title == null
        ? null
        : AppBar(
            title: Text(title!),
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 24),
            ),
            actions: actions,
          ),
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff192022), BalbColors.background, Color(0xff211b1b)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          top: title == null,
          child: Column(
            children: [
              Expanded(
                child: scroll
                    ? SingleChildScrollView(padding: padding, child: child)
                    : Padding(padding: padding, child: child),
              ),
              if (bottom != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: bottom!,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) =>
      FilledButton(onPressed: onPressed, child: Text(label));
}

class Field extends StatefulWidget {
  const Field(
    this.hint, {
    super.key,
    this.icon,
    this.controller,
    this.password = false,
    this.validator,
    this.keyboardType,
    this.onChanged,
    this.maxLines = 1,
  });
  final String hint;
  final IconData? icon;
  final TextEditingController? controller;
  final bool password;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  @override
  State<Field> createState() => _FieldState();
}

class _FieldState extends State<Field> {
  bool obscured = true;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: widget.controller,
      obscureText: widget.password && obscured,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      maxLines: widget.maxLines,
      validator: widget.validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: widget.icon == null
            ? null
            : Icon(widget.icon, size: 22, color: const Color(0xff777b80)),
        suffixIcon: widget.password
            ? IconButton(
                tooltip: obscured ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => obscured = !obscured),
                icon: Icon(
                  obscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
              )
            : null,
      ),
    ),
  );
}

class SegmentBar extends StatelessWidget {
  const SegmentBar({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    height: 36,
    decoration: BoxDecoration(
      border: Border.all(color: BalbColors.line),
      borderRadius: BorderRadius.circular(9),
    ),
    padding: const EdgeInsets.all(1),
    child: Row(
      children: List.generate(
        labels.length,
        (i) => Expanded(
          child: InkWell(
            onTap: () => onChanged(i),
            borderRadius: BorderRadius.circular(7),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected == i ? BalbColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                labels[i].toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: selected == i ? Colors.white : BalbColors.muted,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class Heading extends StatelessWidget {
  const Heading(this.text, {super.key, this.action, this.onTap});
  final String text;
  final String? action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      children: [
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (action != null)
          InkWell(
            onTap: onTap,
            child: Text(
              action!,
              style: const TextStyle(color: BalbColors.muted),
            ),
          ),
      ],
    ),
  );
}

class FollowButton extends StatelessWidget {
  const FollowButton({
    super.key,
    required this.following,
    required this.onPressed,
  });
  final bool following;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 30,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: following ? Colors.transparent : BalbColors.primary,
        foregroundColor: Colors.white,
        side: BorderSide(
          color: following ? BalbColors.muted : BalbColors.primary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      child: Text(
        following ? 'Following' : 'Follow',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
