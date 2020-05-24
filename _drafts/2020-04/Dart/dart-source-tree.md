---
title: Flutter 分支版本源码文件树记录
layout: post
categories:
 - dart
---

### 1.19.0-2.0.pre.140 

```
.
├── analysis_options_user.yaml
├── animation.dart
├── cupertino.dart
├── foundation.dart
├── gestures.dart
├── material.dart
├── painting.dart
├── physics.dart
├── rendering.dart
├── scheduler.dart
├── semantics.dart
├── services.dart
├── src
│   ├── animation
│   │   ├── animation.dart
│   │   ├── animation_controller.dart
│   │   ├── animations.dart
│   │   ├── curves.dart
│   │   ├── listener_helpers.dart
│   │   ├── tween.dart
│   │   └── tween_sequence.dart
│   ├── cupertino
│   │   ├── action_sheet.dart
│   │   ├── activity_indicator.dart
│   │   ├── app.dart
│   │   ├── bottom_tab_bar.dart
│   │   ├── button.dart
│   │   ├── colors.dart
│   │   ├── constants.dart
│   │   ├── context_menu.dart
│   │   ├── context_menu_action.dart
│   │   ├── date_picker.dart
│   │   ├── dialog.dart
│   │   ├── icon_theme_data.dart
│   │   ├── icons.dart
│   │   ├── interface_level.dart
│   │   ├── localizations.dart
│   │   ├── nav_bar.dart
│   │   ├── page_scaffold.dart
│   │   ├── picker.dart
│   │   ├── refresh.dart
│   │   ├── route.dart
│   │   ├── scrollbar.dart
│   │   ├── segmented_control.dart
│   │   ├── slider.dart
│   │   ├── sliding_segmented_control.dart
│   │   ├── switch.dart
│   │   ├── tab_scaffold.dart
│   │   ├── tab_view.dart
│   │   ├── text_field.dart
│   │   ├── text_selection.dart
│   │   ├── text_theme.dart
│   │   ├── theme.dart
│   │   └── thumb_painter.dart
│   ├── foundation
│   │   ├── README.md
│   │   ├── _bitfield_io.dart
│   │   ├── _bitfield_web.dart
│   │   ├── _isolates_io.dart
│   │   ├── _isolates_web.dart
│   │   ├── _platform_io.dart
│   │   ├── _platform_web.dart
│   │   ├── annotations.dart
│   │   ├── assertions.dart
│   │   ├── basic_types.dart
│   │   ├── binding.dart
│   │   ├── bitfield.dart
│   │   ├── change_notifier.dart
│   │   ├── collections.dart
│   │   ├── consolidate_response.dart
│   │   ├── constants.dart
│   │   ├── debug.dart
│   │   ├── diagnostics.dart
│   │   ├── isolates.dart
│   │   ├── key.dart
│   │   ├── licenses.dart
│   │   ├── node.dart
│   │   ├── object.dart
│   │   ├── observer_list.dart
│   │   ├── platform.dart
│   │   ├── print.dart
│   │   ├── profile.dart
│   │   ├── serialization.dart
│   │   ├── stack_frame.dart
│   │   ├── synchronous_future.dart
│   │   └── unicode.dart
│   ├── gestures
│   │   ├── arena.dart
│   │   ├── binding.dart
│   │   ├── constants.dart
│   │   ├── converter.dart
│   │   ├── debug.dart
│   │   ├── drag.dart
│   │   ├── drag_details.dart
│   │   ├── eager.dart
│   │   ├── events.dart
│   │   ├── force_press.dart
│   │   ├── hit_test.dart
│   │   ├── long_press.dart
│   │   ├── lsq_solver.dart
│   │   ├── monodrag.dart
│   │   ├── multidrag.dart
│   │   ├── multitap.dart
│   │   ├── pointer_router.dart
│   │   ├── pointer_signal_resolver.dart
│   │   ├── recognizer.dart
│   │   ├── scale.dart
│   │   ├── tap.dart
│   │   ├── team.dart
│   │   └── velocity_tracker.dart
│   ├── material
│   │   ├── about.dart
│   │   ├── animated_icons
│   │   │   ├── animated_icons.dart
│   │   │   ├── animated_icons_data.dart
│   │   │   └── data
│   │   │       ├── add_event.g.dart
│   │   │       ├── arrow_menu.g.dart
│   │   │       ├── close_menu.g.dart
│   │   │       ├── ellipsis_search.g.dart
│   │   │       ├── event_add.g.dart
│   │   │       ├── home_menu.g.dart
│   │   │       ├── list_view.g.dart
│   │   │       ├── menu_arrow.g.dart
│   │   │       ├── menu_close.g.dart
│   │   │       ├── menu_home.g.dart
│   │   │       ├── pause_play.g.dart
│   │   │       ├── play_pause.g.dart
│   │   │       ├── search_ellipsis.g.dart
│   │   │       └── view_list.g.dart
│   │   ├── animated_icons.dart
│   │   ├── app.dart
│   │   ├── app_bar.dart
│   │   ├── app_bar_theme.dart
│   │   ├── arc.dart
│   │   ├── back_button.dart
│   │   ├── banner.dart
│   │   ├── banner_theme.dart
│   │   ├── bottom_app_bar.dart
│   │   ├── bottom_app_bar_theme.dart
│   │   ├── bottom_navigation_bar.dart
│   │   ├── bottom_navigation_bar_theme.dart
│   │   ├── bottom_sheet.dart
│   │   ├── bottom_sheet_theme.dart
│   │   ├── button.dart
│   │   ├── button_bar.dart
│   │   ├── button_bar_theme.dart
│   │   ├── button_theme.dart
│   │   ├── card.dart
│   │   ├── card_theme.dart
│   │   ├── checkbox.dart
│   │   ├── checkbox_list_tile.dart
│   │   ├── chip.dart
│   │   ├── chip_theme.dart
│   │   ├── circle_avatar.dart
│   │   ├── color_scheme.dart
│   │   ├── colors.dart
│   │   ├── constants.dart
│   │   ├── curves.dart
│   │   ├── data_table.dart
│   │   ├── data_table_source.dart
│   │   ├── debug.dart
│   │   ├── dialog.dart
│   │   ├── dialog_theme.dart
│   │   ├── divider.dart
│   │   ├── divider_theme.dart
│   │   ├── drawer.dart
│   │   ├── drawer_header.dart
│   │   ├── dropdown.dart
│   │   ├── elevation_overlay.dart
│   │   ├── expand_icon.dart
│   │   ├── expansion_panel.dart
│   │   ├── expansion_tile.dart
│   │   ├── feedback.dart
│   │   ├── flat_button.dart
│   │   ├── flexible_space_bar.dart
│   │   ├── floating_action_button.dart
│   │   ├── floating_action_button_location.dart
│   │   ├── floating_action_button_theme.dart
│   │   ├── flutter_logo.dart
│   │   ├── grid_tile.dart
│   │   ├── grid_tile_bar.dart
│   │   ├── icon_button.dart
│   │   ├── icons.dart
│   │   ├── ink_decoration.dart
│   │   ├── ink_highlight.dart
│   │   ├── ink_ripple.dart
│   │   ├── ink_splash.dart
│   │   ├── ink_well.dart
│   │   ├── input_border.dart
│   │   ├── input_decorator.dart
│   │   ├── list_tile.dart
│   │   ├── material.dart
│   │   ├── material_button.dart
│   │   ├── material_localizations.dart
│   │   ├── material_state.dart
│   │   ├── mergeable_material.dart
│   │   ├── navigation_rail.dart
│   │   ├── navigation_rail_theme.dart
│   │   ├── outline_button.dart
│   │   ├── page.dart
│   │   ├── page_transitions_theme.dart
│   │   ├── paginated_data_table.dart
│   │   ├── pickers
│   │   │   ├── calendar_date_picker.dart
│   │   │   ├── calendar_date_range_picker.dart
│   │   │   ├── date_picker_common.dart
│   │   │   ├── date_picker_deprecated.dart
│   │   │   ├── date_picker_dialog.dart
│   │   │   ├── date_picker_header.dart
│   │   │   ├── date_range_picker_dialog.dart
│   │   │   ├── date_utils.dart
│   │   │   ├── input_date_picker.dart
│   │   │   ├── input_date_range_picker.dart
│   │   │   └── pickers.dart
│   │   ├── popup_menu.dart
│   │   ├── popup_menu_theme.dart
│   │   ├── progress_indicator.dart
│   │   ├── radio.dart
│   │   ├── radio_list_tile.dart
│   │   ├── raised_button.dart
│   │   ├── range_slider.dart
│   │   ├── refresh_indicator.dart
│   │   ├── reorderable_list.dart
│   │   ├── scaffold.dart
│   │   ├── scrollbar.dart
│   │   ├── search.dart
│   │   ├── selectable_text.dart
│   │   ├── shadows.dart
│   │   ├── slider.dart
│   │   ├── slider_theme.dart
│   │   ├── snack_bar.dart
│   │   ├── snack_bar_theme.dart
│   │   ├── stepper.dart
│   │   ├── switch.dart
│   │   ├── switch_list_tile.dart
│   │   ├── tab_bar_theme.dart
│   │   ├── tab_controller.dart
│   │   ├── tab_indicator.dart
│   │   ├── tabs.dart
│   │   ├── text_field.dart
│   │   ├── text_form_field.dart
│   │   ├── text_selection.dart
│   │   ├── text_theme.dart
│   │   ├── theme.dart
│   │   ├── theme_data.dart
│   │   ├── time.dart
│   │   ├── time_picker.dart
│   │   ├── toggle_buttons.dart
│   │   ├── toggle_buttons_theme.dart
│   │   ├── toggleable.dart
│   │   ├── tooltip.dart
│   │   ├── tooltip_theme.dart
│   │   ├── typography.dart
│   │   └── user_accounts_drawer_header.dart
│   ├── painting
│   │   ├── _network_image_io.dart
│   │   ├── _network_image_web.dart
│   │   ├── alignment.dart
│   │   ├── basic_types.dart
│   │   ├── beveled_rectangle_border.dart
│   │   ├── binding.dart
│   │   ├── border_radius.dart
│   │   ├── borders.dart
│   │   ├── box_border.dart
│   │   ├── box_decoration.dart
│   │   ├── box_fit.dart
│   │   ├── box_shadow.dart
│   │   ├── circle_border.dart
│   │   ├── clip.dart
│   │   ├── colors.dart
│   │   ├── continuous_rectangle_border.dart
│   │   ├── debug.dart
│   │   ├── decoration.dart
│   │   ├── decoration_image.dart
│   │   ├── edge_insets.dart
│   │   ├── flutter_logo.dart
│   │   ├── fractional_offset.dart
│   │   ├── geometry.dart
│   │   ├── gradient.dart
│   │   ├── image_cache.dart
│   │   ├── image_decoder.dart
│   │   ├── image_provider.dart
│   │   ├── image_resolution.dart
│   │   ├── image_stream.dart
│   │   ├── inline_span.dart
│   │   ├── matrix_utils.dart
│   │   ├── notched_shapes.dart
│   │   ├── paint_utilities.dart
│   │   ├── placeholder_span.dart
│   │   ├── rounded_rectangle_border.dart
│   │   ├── shader_warm_up.dart
│   │   ├── shape_decoration.dart
│   │   ├── stadium_border.dart
│   │   ├── strut_style.dart
│   │   ├── text_painter.dart
│   │   ├── text_span.dart
│   │   └── text_style.dart
│   ├── physics
│   │   ├── clamped_simulation.dart
│   │   ├── friction_simulation.dart
│   │   ├── gravity_simulation.dart
│   │   ├── simulation.dart
│   │   ├── spring_simulation.dart
│   │   ├── tolerance.dart
│   │   └── utils.dart
│   ├── rendering
│   │   ├── animated_size.dart
│   │   ├── binding.dart
│   │   ├── box.dart
│   │   ├── custom_layout.dart
│   │   ├── custom_paint.dart
│   │   ├── debug.dart
│   │   ├── debug_overflow_indicator.dart
│   │   ├── editable.dart
│   │   ├── error.dart
│   │   ├── flex.dart
│   │   ├── flow.dart
│   │   ├── image.dart
│   │   ├── layer.dart
│   │   ├── list_body.dart
│   │   ├── list_wheel_viewport.dart
│   │   ├── mouse_cursor.dart
│   │   ├── mouse_tracking.dart
│   │   ├── object.dart
│   │   ├── paragraph.dart
│   │   ├── performance_overlay.dart
│   │   ├── platform_view.dart
│   │   ├── proxy_box.dart
│   │   ├── proxy_sliver.dart
│   │   ├── rotated_box.dart
│   │   ├── shifted_box.dart
│   │   ├── sliver.dart
│   │   ├── sliver_fill.dart
│   │   ├── sliver_fixed_extent_list.dart
│   │   ├── sliver_grid.dart
│   │   ├── sliver_list.dart
│   │   ├── sliver_multi_box_adaptor.dart
│   │   ├── sliver_padding.dart
│   │   ├── sliver_persistent_header.dart
│   │   ├── stack.dart
│   │   ├── table.dart
│   │   ├── table_border.dart
│   │   ├── texture.dart
│   │   ├── tweens.dart
│   │   ├── view.dart
│   │   ├── viewport.dart
│   │   ├── viewport_offset.dart
│   │   └── wrap.dart
│   ├── scheduler
│   │   ├── binding.dart
│   │   ├── debug.dart
│   │   ├── priority.dart
│   │   └── ticker.dart
│   ├── semantics
│   │   ├── binding.dart
│   │   ├── debug.dart
│   │   ├── semantics.dart
│   │   ├── semantics_event.dart
│   │   └── semantics_service.dart
│   ├── services
│   │   ├── asset_bundle.dart
│   │   ├── autofill.dart
│   │   ├── binary_messenger.dart
│   │   ├── binding.dart
│   │   ├── clipboard.dart
│   │   ├── font_loader.dart
│   │   ├── haptic_feedback.dart
│   │   ├── keyboard_key.dart
│   │   ├── keyboard_maps.dart
│   │   ├── message_codec.dart
│   │   ├── message_codecs.dart
│   │   ├── platform_channel.dart
│   │   ├── platform_messages.dart
│   │   ├── platform_views.dart
│   │   ├── raw_keyboard.dart
│   │   ├── raw_keyboard_android.dart
│   │   ├── raw_keyboard_fuchsia.dart
│   │   ├── raw_keyboard_linux.dart
│   │   ├── raw_keyboard_macos.dart
│   │   ├── raw_keyboard_web.dart
│   │   ├── raw_keyboard_windows.dart
│   │   ├── system_channels.dart
│   │   ├── system_chrome.dart
│   │   ├── system_navigator.dart
│   │   ├── system_sound.dart
│   │   ├── text_editing.dart
│   │   ├── text_formatter.dart
│   │   └── text_input.dart
│   └── widgets
│       ├── actions.dart
│       ├── animated_cross_fade.dart
│       ├── animated_list.dart
│       ├── animated_size.dart
│       ├── animated_switcher.dart
│       ├── annotated_region.dart
│       ├── app.dart
│       ├── async.dart
│       ├── autofill.dart
│       ├── automatic_keep_alive.dart
│       ├── banner.dart
│       ├── basic.dart
│       ├── binding.dart
│       ├── bottom_navigation_bar_item.dart
│       ├── color_filter.dart
│       ├── constants.dart
│       ├── container.dart
│       ├── debug.dart
│       ├── dismissible.dart
│       ├── disposable_build_context.dart
│       ├── drag_target.dart
│       ├── draggable_scrollable_sheet.dart
│       ├── editable_text.dart
│       ├── fade_in_image.dart
│       ├── focus_manager.dart
│       ├── focus_scope.dart
│       ├── focus_traversal.dart
│       ├── form.dart
│       ├── framework.dart
│       ├── gesture_detector.dart
│       ├── grid_paper.dart
│       ├── heroes.dart
│       ├── icon.dart
│       ├── icon_data.dart
│       ├── icon_theme.dart
│       ├── icon_theme_data.dart
│       ├── image.dart
│       ├── image_filter.dart
│       ├── image_icon.dart
│       ├── implicit_animations.dart
│       ├── inherited_model.dart
│       ├── inherited_notifier.dart
│       ├── inherited_theme.dart
│       ├── layout_builder.dart
│       ├── list_wheel_scroll_view.dart
│       ├── localizations.dart
│       ├── media_query.dart
│       ├── modal_barrier.dart
│       ├── navigation_toolbar.dart
│       ├── navigator.dart
│       ├── nested_scroll_view.dart
│       ├── notification_listener.dart
│       ├── orientation_builder.dart
│       ├── overlay.dart
│       ├── overscroll_indicator.dart
│       ├── page_storage.dart
│       ├── page_view.dart
│       ├── pages.dart
│       ├── performance_overlay.dart
│       ├── placeholder.dart
│       ├── platform_view.dart
│       ├── preferred_size.dart
│       ├── primary_scroll_controller.dart
│       ├── raw_keyboard_listener.dart
│       ├── route_notification_messages.dart
│       ├── routes.dart
│       ├── safe_area.dart
│       ├── scroll_activity.dart
│       ├── scroll_aware_image_provider.dart
│       ├── scroll_configuration.dart
│       ├── scroll_context.dart
│       ├── scroll_controller.dart
│       ├── scroll_metrics.dart
│       ├── scroll_notification.dart
│       ├── scroll_physics.dart
│       ├── scroll_position.dart
│       ├── scroll_position_with_single_context.dart
│       ├── scroll_simulation.dart
│       ├── scroll_view.dart
│       ├── scrollable.dart
│       ├── scrollbar.dart
│       ├── semantics_debugger.dart
│       ├── shortcuts.dart
│       ├── single_child_scroll_view.dart
│       ├── size_changed_layout_notifier.dart
│       ├── sliver.dart
│       ├── sliver_fill.dart
│       ├── sliver_layout_builder.dart
│       ├── sliver_persistent_header.dart
│       ├── sliver_prototype_extent_list.dart
│       ├── spacer.dart
│       ├── status_transitions.dart
│       ├── table.dart
│       ├── text.dart
│       ├── text_selection.dart
│       ├── texture.dart
│       ├── ticker_provider.dart
│       ├── title.dart
│       ├── transitions.dart
│       ├── tween_animation_builder.dart
│       ├── unique_widget.dart
│       ├── value_listenable_builder.dart
│       ├── viewport.dart
│       ├── visibility.dart
│       ├── widget_inspector.dart
│       ├── widget_span.dart
│       └── will_pop_scope.dart
└── widgets.dart
```



* Flutter
	* Youtube Tutorial
	* Professional Article
* JAVA





