; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple thumbv4t-eabi    < %s | FileCheck %s --check-prefix=CHECK-V4T
; RUN: llc -mtriple armv8m.base-eabi < %s | FileCheck %s --check-prefix=CHECK-V8M

target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"

; Function Attrs: nounwind
define <4 x i32> @f() local_unnamed_addr #0 {
; CHECK-V4T-LABEL: f:
; CHECK-V4T:       @ %bb.0: @ %entry
; CHECK-V4T-NEXT:    .save {r7, lr}
; CHECK-V4T-NEXT:    push {r7, lr}
; CHECK-V4T-NEXT:    .setfp r7, sp
; CHECK-V4T-NEXT:    add r7, sp, #0
; CHECK-V4T-NEXT:    movs r0, #1
; CHECK-V4T-NEXT:    bl h
; CHECK-V4T-NEXT:    movs r1, #2
; CHECK-V4T-NEXT:    movs r2, #3
; CHECK-V4T-NEXT:    movs r3, #4
; CHECK-V4T-NEXT:    bl g
; CHECK-V4T-NEXT:    pop {r7}
; CHECK-V4T-NEXT:    mov r12, r0
; CHECK-V4T-NEXT:    pop {r0}
; CHECK-V4T-NEXT:    mov lr, r0
; CHECK-V4T-NEXT:    mov r0, r12
; CHECK-V4T-NEXT:    bx lr
;
; CHECK-V8M-LABEL: f:
; CHECK-V8M:       @ %bb.0: @ %entry
; CHECK-V8M-NEXT:    .save {r7, lr}
; CHECK-V8M-NEXT:    push {r7, lr}
; CHECK-V8M-NEXT:    .setfp r7, sp
; CHECK-V8M-NEXT:    add r7, sp, #0
; CHECK-V8M-NEXT:    movs r0, #1
; CHECK-V8M-NEXT:    bl h
; CHECK-V8M-NEXT:    movs r1, #2
; CHECK-V8M-NEXT:    movs r2, #3
; CHECK-V8M-NEXT:    movs r3, #4
; CHECK-V8M-NEXT:    pop {r7}
; CHECK-V8M-NEXT:    mov r12, r0
; CHECK-V8M-NEXT:    pop {r0}
; CHECK-V8M-NEXT:    mov lr, r0
; CHECK-V8M-NEXT:    mov r0, r12
; CHECK-V8M-NEXT:    b g
entry:
  %call = tail call i32 @h(i32 1)
  %call1 = tail call <4 x i32> @g(i32 %call, i32 2, i32 3, i32 4)
  ret <4 x i32> %call1
}

declare <4 x i32> @g(i32, i32, i32, i32) local_unnamed_addr

declare i32 @h(i32) local_unnamed_addr

attributes #0 = { "disable-tail-calls"="false" "frame-pointer"="all" }
