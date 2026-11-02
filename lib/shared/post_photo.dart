import 'package:flutter/material.dart';

import '../core/post_draft.dart';
import 'widgets.dart';

class DraftPhoto extends StatelessWidget {
  const DraftPhoto(this.draft, {super.key, this.radius = 8});
  final PostDraft draft;
  final double radius;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: ColorFiltered(
      colorFilter: ColorFilter.matrix(draft.matrix),
      child: RotatedBox(
        quarterTurns: draft.rotation,
        child: Photo(draft.image),
      ),
    ),
  );
}
