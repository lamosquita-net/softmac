SEGURIDAD-PORTES-4 → LOCAL-6: reenvía este texto tal cual a la sesión activa de MOTOR (MOTOR-13 o MOTOR-14). LOCAL: la F12 tal cual no está lista para compilar.

«F12 f2699e58e7 (12bfef324f99): visto bueno de la regla 17. Es igual que la 131; 3aa7ad2a0d es un seguimiento especulativo y opcional, para la 1.15.3.
Hay que fundir dos ramas de seguridad (regla 2) antes de compilar:
1) seg/top-layer-box 1f7b9912 (upstream 0e454ce616, crbug 543070692). Va encima de la F11; la F12 no lo lleva. Solo toca layout_object.h.patch.
2) seg/subtree-roots-copy 49964845 (upstream c215f8e6f0, crbug 491994185). Va encima de la F12 y toca local_frame_view.cc.patch más dos parches nuevos de depth_ordered_layout_object_list. PerformLayout recorre por referencia el vector de layout_subtree_root_list_.Ordered(), y si un recálculo entrelazado (container queries) destruye una raíz, ese vector se vacía a mitad del bucle: posible UAF, presente en la 116.
Detalle en FS.22 (PR #405).»
