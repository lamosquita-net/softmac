# B1d (FM.55): ficheros tocados sobre la 156 de serie

Rama `flynk-b1d` de src en github.com/lamosquita-net/chromium; base: el padre de 95a974072b (la 156.0.8078.90 de serie). 
Estado: **M = modificado (añadido sobre la 156)**. Ningún fichero revertido a la 150 ni borrado; ningún fichero nuevo. 
Todas las líneas cambiadas llevan la marca `FlyWeb B1b` o `FlyWeb B1d`. `third_party/angle` y `third_party/dawn` son rolls de submódulo (ver `angle-*.patch`).

## base/allocator (1)

| estado | fichero | commits |
|---|---|---|
| M | `base/allocator/partition_allocator/src/partition_alloc/spinning_mutex.cc` | 95a974072b |

## base/apple (1)

| estado | fichero | commits |
|---|---|---|
| M | `base/apple/bridging.h` | 95a974072b |

## base/files (1)

| estado | fichero | commits |
|---|---|---|
| M | `base/files/drive_info_mac.cc` | 95a974072b |

## base/mac (3)

| estado | fichero | commits |
|---|---|---|
| M | `base/mac/launch_application.mm` | e798ced125 95a974072b |
| M | `base/mac/launch_services_spi.h` | 95a974072b |
| M | `base/mac/mac_util.mm` | e798ced125 95a974072b |

## base/power_monitor (2)

| estado | fichero | commits |
|---|---|---|
| M | `base/power_monitor/battery_level_provider_mac.mm` | 95a974072b |
| M | `base/power_monitor/iopm_power_source_sampling_event_source.cc` | 95a974072b |

## base/process (1)

| estado | fichero | commits |
|---|---|---|
| M | `base/process/launch_mac.cc` | 95a974072b |

## chrome/browser (11)

| estado | fichero | commits |
|---|---|---|
| M | `chrome/browser/chrome_browser_field_trials.cc` | 4147b70632 |
| M | `chrome/browser/device_reauth/mac/authenticator_mac.mm` | 95a974072b |
| M | `chrome/browser/extensions/api/image_writer_private/removable_storage_provider_mac.cc` | 95a974072b |
| M | `chrome/browser/icon_loader_mac.mm` | 4efc0e8e86 48f12e219e |
| M | `chrome/browser/local_discovery/service_discovery_client_mac.mm` | fe1f0ab4ba |
| M | `chrome/browser/mac/install_from_dmg.mm` | 95a974072b |
| M | `chrome/browser/obsolete_system/obsolete_system_mac.cc` | 9e194ebb5b |
| M | `chrome/browser/platform_util_mac.mm` | 4efc0e8e86 |
| M | `chrome/browser/shell_integration_mac.mm` | 164532514f |
| M | `chrome/browser/ui/cocoa/main_menu_builder.mm` | 95a974072b |
| M | `chrome/browser/ui/views/frame/browser_frame_view_mac.mm` | 95a974072b |

## chrome/services (1)

| estado | fichero | commits |
|---|---|---|
| M | `chrome/services/mac_notifications/mac_notification_service_un.mm` | cd334eec2a 48f12e219e |

## chrome/utility (1)

| estado | fichero | commits |
|---|---|---|
| M | `chrome/utility/image_writer/image_writer_mac.cc` | 95a974072b |

## components/metal_util (1)

| estado | fichero | commits |
|---|---|---|
| M | `components/metal_util/hdr_copier_layer.mm` | c11d8d173b |

## components/persistent_cache (1)

| estado | fichero | commits |
|---|---|---|
| M | `components/persistent_cache/sqlite/sqlite_backend_impl.cc` | 4147b70632 |

## components/power_metrics (2)

| estado | fichero | commits |
|---|---|---|
| M | `components/power_metrics/energy_impact_mac.mm` | 95a974072b |
| M | `components/power_metrics/smc_mac.mm` | 95a974072b |

## components/remote_cocoa (3)

| estado | fichero | commits |
|---|---|---|
| M | `components/remote_cocoa/app_shim/bridged_content_view.mm` | 95a974072b |
| M | `components/remote_cocoa/app_shim/immersive_mode_controller_cocoa.mm` | 89305ccf70 |
| M | `components/remote_cocoa/app_shim/immersive_mode_tabbed_controller_cocoa.mm` | 89305ccf70 |

## content/app_shim_remote_cocoa (2)

| estado | fichero | commits |
|---|---|---|
| M | `content/app_shim_remote_cocoa/render_widget_host_ns_view_bridge.mm` | 945c9881a9 |
| M | `content/app_shim_remote_cocoa/render_widget_host_view_cocoa.mm` | 95a974072b |

## content/browser (3)

| estado | fichero | commits |
|---|---|---|
| M | `content/browser/gpu/compositor_util.cc` | 12735ff98e |
| M | `content/browser/gpu/gpu_data_manager_impl_private.cc` | 12735ff98e |
| M | `content/browser/theme_helper_mac.mm` | 95a974072b |

## device/bluetooth (1)

| estado | fichero | commits |
|---|---|---|
| M | `device/bluetooth/bluetooth_adapter_mac.mm` | 95a974072b |

## device/gamepad (2)

| estado | fichero | commits |
|---|---|---|
| M | `device/gamepad/game_controller_gamepad.mm` | 2f15d02e94 |
| M | `device/gamepad/xbox_data_fetcher_mac.cc` | 95a974072b |

## gpu/command_buffer (1)

| estado | fichero | commits |
|---|---|---|
| M | `gpu/command_buffer/service/service_utils.cc` | c38651442c |

## gpu/config (4)

| estado | fichero | commits |
|---|---|---|
| M | `gpu/config/gpu_finch_features.cc` | c38651442c |
| M | `gpu/config/gpu_finch_features.h` | c38651442c |
| M | `gpu/config/gpu_info_collector.cc` | 8ed4229146 |
| M | `gpu/config/gpu_info_collector_mac.mm` | f1f243c376 |

## media/base (3)

| estado | fichero | commits |
|---|---|---|
| M | `media/base/mac/color_space_util_mac.mm` | 5660e8931d |
| M | `media/base/mac/video_capture_device_avfoundation_helpers.mm` | 5660e8931d |
| M | `media/base/mac/video_frame_mac.mm` | 6ad82400df |

## media/capture (1)

| estado | fichero | commits |
|---|---|---|
| M | `media/capture/video/mac/uvc_control_mac.mm` | 95a974072b |

## media/gpu (3)

| estado | fichero | commits |
|---|---|---|
| M | `media/gpu/mac/video_toolbox_decompression_session_manager.mm` | 95a974072b |
| M | `media/gpu/mac/video_toolbox_video_decoder.cc` | 95a974072b |
| M | `media/gpu/mac/vt_video_encode_accelerator_mac.mm` | 6ad82400df |

## media/midi (1)

| estado | fichero | commits |
|---|---|---|
| M | `media/midi/midi_manager_mac.cc` | 6ad82400df |

## net/base (1)

| estado | fichero | commits |
|---|---|---|
| M | `net/base/platform_mime_util_apple.mm` | 280094dc53 |

## net/ssl (1)

| estado | fichero | commits |
|---|---|---|
| M | `net/ssl/client_cert_store_mac.cc` | 95a974072b |

## rlz (1)

| estado | fichero | commits |
|---|---|---|
| M | `rlz/mac/lib/machine_id_mac.cc` | 95a974072b |

## sandbox (1)

| estado | fichero | commits |
|---|---|---|
| M | `sandbox/mac/system_services.cc` | 95a974072b |

## services/device (3)

| estado | fichero | commits |
|---|---|---|
| M | `services/device/hid/hid_service_mac.cc` | 95a974072b |
| M | `services/device/public/cpp/geolocation/system_geolocation_source_apple.mm` | 87f4e8b263 |
| M | `services/device/serial/serial_device_enumerator_mac.cc` | 95a974072b |

## services/preferences (1)

| estado | fichero | commits |
|---|---|---|
| M | `services/preferences/tracked/device_id_mac.cc` | 95a974072b |

## third_party/angle (1)

| estado | fichero | commits |
|---|---|---|
| M | `third_party/angle` | 8e24951091 a044206a97 |

## third_party/blink (1)

| estado | fichero | commits |
|---|---|---|
| M | `third_party/blink/renderer/core/editing/substring_util.mm` | 5c004645bc |

## third_party/crashpad (3)

| estado | fichero | commits |
|---|---|---|
| M | `third_party/crashpad/crashpad/util/mac/mac_util.cc` | 95a974072b |
| M | `third_party/crashpad/crashpad/util/mach/exc_client_variants.cc` | 95a974072b |
| M | `third_party/crashpad/crashpad/util/mach/exc_server_variants.cc` | 95a974072b |

## third_party/dawn (1)

| estado | fichero | commits |
|---|---|---|
| M | `third_party/dawn` | 64049f4755 |

## tools (1)

| estado | fichero | commits |
|---|---|---|
| M | `tools/mac/power/power_sampler/battery_sampler.mm` | 95a974072b |

## ui/accelerated_widget_mac (1)

| estado | fichero | commits |
|---|---|---|
| M | `ui/accelerated_widget_mac/ca_renderer_layer_tree.mm` | a58393ad85 95a974072b |

## ui/base (5)

| estado | fichero | commits |
|---|---|---|
| M | `ui/base/accelerators/media_keys_listener_mac.mm` | 95a974072b |
| M | `ui/base/clipboard/clipboard_format_type_mac.mm` | 48f12e219e |
| M | `ui/base/clipboard/clipboard_util_mac.mm` | 48f12e219e |
| M | `ui/base/cocoa/permissions_utils.mm` | 95a974072b |
| M | `ui/base/dragdrop/os_exchange_data_provider_mac.mm` | 48f12e219e |

## ui/color (1)

| estado | fichero | commits |
|---|---|---|
| M | `ui/color/mac/native_color_mixers_mac.mm` | 95a974072b |

## ui/display (3)

| estado | fichero | commits |
|---|---|---|
| M | `ui/display/mac/ca_display_link_mac.mm` | 95a974072b |
| M | `ui/display/mac/screen_mac.mm` | 95a974072b |
| M | `ui/display/mac/screen_utils_mac.mm` | 95a974072b |

## ui/gfx (2)

| estado | fichero | commits |
|---|---|---|
| M | `ui/gfx/mac/color_space_util.mm` | 95a974072b |
| M | `ui/gfx/mac/io_surface.cc` | 95a974072b |

Total: 77 ficheros.
