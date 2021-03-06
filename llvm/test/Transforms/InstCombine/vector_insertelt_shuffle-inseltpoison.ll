; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

; insertelements should fold to shuffle
define <4 x float> @foo(<4 x float> %x) {
; CHECK-LABEL: @foo(
; CHECK-NEXT:    [[INS2:%.*]] = shufflevector <4 x float> [[X:%.*]], <4 x float> <float poison, float 1.000000e+00, float 2.000000e+00, float poison>, <4 x i32> <i32 0, i32 5, i32 6, i32 3>
; CHECK-NEXT:    ret <4 x float> [[INS2]]
;
  %ins1 = insertelement<4 x float> %x, float 1.0, i32 1
  %ins2 = insertelement<4 x float> %ins1, float 2.0, i32 2
  ret <4 x float> %ins2
}

; Insert of a constant is canonicalized ahead of insert of a variable.

define <4 x float> @bar(<4 x float> %x, float %a) {
; CHECK-LABEL: @bar(
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <4 x float> [[X:%.*]], float 2.000000e+00, i64 2
; CHECK-NEXT:    [[INS2:%.*]] = insertelement <4 x float> [[TMP1]], float [[A:%.*]], i64 1
; CHECK-NEXT:    ret <4 x float> [[INS2]]
;
  %ins1 = insertelement<4 x float> %x, float %a, i32 1
  %ins2 = insertelement<4 x float> %ins1, float 2.0, i32 2
  ret <4 x float> %ins2
}

define <4 x float> @baz(<4 x float> %x, i32 %a) {
; CHECK-LABEL: @baz(
; CHECK-NEXT:    [[INS1:%.*]] = insertelement <4 x float> [[X:%.*]], float 1.000000e+00, i64 1
; CHECK-NEXT:    [[INS2:%.*]] = insertelement <4 x float> [[INS1]], float 2.000000e+00, i32 [[A:%.*]]
; CHECK-NEXT:    ret <4 x float> [[INS2]]
;
  %ins1 = insertelement<4 x float> %x, float 1.0, i32 1
  %ins2 = insertelement<4 x float> %ins1, float 2.0, i32 %a
  ret <4 x float> %ins2
}

; insertelements should fold to shuffle
define <4 x float> @bazz(<4 x float> %x, i32 %a) {
; CHECK-LABEL: @bazz(
; CHECK-NEXT:    [[INS1:%.*]] = insertelement <4 x float> [[X:%.*]], float 1.000000e+00, i64 3
; CHECK-NEXT:    [[INS2:%.*]] = insertelement <4 x float> [[INS1]], float 5.000000e+00, i32 [[A:%.*]]
; CHECK-NEXT:    [[INS5:%.*]] = shufflevector <4 x float> [[INS2]], <4 x float> <float poison, float 1.000000e+00, float 2.000000e+00, float poison>, <4 x i32> <i32 0, i32 5, i32 6, i32 3>
; CHECK-NEXT:    [[INS6:%.*]] = insertelement <4 x float> [[INS5]], float 7.000000e+00, i32 [[A]]
; CHECK-NEXT:    ret <4 x float> [[INS6]]
;
  %ins1 = insertelement<4 x float> %x, float 1.0, i32 3
  %ins2 = insertelement<4 x float> %ins1, float 5.0, i32 %a
  %ins3 = insertelement<4 x float> %ins2, float 3.0, i32 2
  %ins4 = insertelement<4 x float> %ins3, float 1.0, i32 1
  %ins5 = insertelement<4 x float> %ins4, float 2.0, i32 2
  %ins6 = insertelement<4 x float> %ins5, float 7.0, i32 %a
  ret <4 x float> %ins6
}

; Out of bounds index folds to poison
define <4 x float> @bazzz(<4 x float> %x) {
; CHECK-LABEL: @bazzz(
; CHECK-NEXT:    ret <4 x float> <float poison, float poison, float 2.000000e+00, float poison>
;
  %ins1 = insertelement<4 x float> %x, float 1.0, i32 5
  %ins2 = insertelement<4 x float> %ins1, float 2.0, i32 2
  ret <4 x float> %ins2
}

define <4 x float> @bazzzz(<4 x float> %x) {
; CHECK-LABEL: @bazzzz(
; CHECK-NEXT:    ret <4 x float> <float poison, float poison, float 2.000000e+00, float poison>
;
  %ins1 = insertelement<4 x float> %x, float 1.0, i32 undef
  %ins2 = insertelement<4 x float> %ins1, float 2.0, i32 2
  ret <4 x float> %ins2
}

define <4 x float> @bazzzzz() {
; CHECK-LABEL: @bazzzzz(
; CHECK-NEXT:    ret <4 x float> <float 1.000000e+00, float 5.000000e+00, float 1.000000e+01, float 4.000000e+00>
;
  %ins1 = insertelement <4 x float> insertelement (<4 x float> <float 1.0, float 2.0, float 3.0, float undef>, float 4.0, i32 3), float 5.0, i32 1
  %ins2 = insertelement<4 x float> %ins1, float 10.0, i32 2
  ret <4 x float> %ins2
}

define <4 x float> @bazzzzzz(<4 x float> %x, i32 %a) {
; CHECK-LABEL: @bazzzzzz(
; CHECK-NEXT:    ret <4 x float> <float poison, float 5.000000e+00, float undef, float 4.000000e+00>
;
  %ins1 = insertelement <4 x float> insertelement (<4 x float> shufflevector (<4 x float> poison, <4 x float> <float 1.0, float 2.0, float 3.0, float 4.0> , <4 x i32> <i32 0, i32 5, i32 undef, i32 6> ), float 4.0, i32 3), float 5.0, i32 1
  ret <4 x float> %ins1
}


