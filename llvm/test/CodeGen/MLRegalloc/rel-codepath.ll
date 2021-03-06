; REQUIRES: have_tf_aot
; REQUIRES: x86_64-linux
;
; Check the code path for release mode is correctly taken. It is shared with
; development mode, and we separately test the internals of that (logged
; features, etc), so all we care about here is that the output is produced and
; is different from default policy.
;
; RUN: llc -mtriple=x86_64-linux-unknown -regalloc=greedy -regalloc-enable-advisor=default \
; RUN:   %S/Inputs/input.ll -o %t.default

; RUN: llc -mtriple=x86_64-linux-unknown -regalloc=greedy -regalloc-enable-advisor=release \
; RUN:   %S/Inputs/input.ll -o %t.release

; RUN: not diff %t.release %t.default
