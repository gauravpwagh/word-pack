import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/wp_tokens.dart';

/// Width of the permanent tree panel on wide layouts, for this session.
/// Whether it is open is saved in `UiState.treePanelOpen`.
@immutable
class TreePanelState {
  const TreePanelState({this.width = WpTreePanel.defaultWidth});

  final double width;

  TreePanelState copyWith({double? width}) =>
      TreePanelState(width: width ?? this.width);
}

class TreePanelController extends Notifier<TreePanelState> {
  @override
  TreePanelState build() => const TreePanelState();

  void resizeBy(double delta) {
    state = state.copyWith(
      width: (state.width + delta).clamp(
        WpTreePanel.minWidth,
        WpTreePanel.maxWidth,
      ),
    );
  }
}

final treePanelProvider = NotifierProvider<TreePanelController, TreePanelState>(
  TreePanelController.new,
);
