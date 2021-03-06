; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; Test that the stpcpy library call simplifier works correctly.
; RUN: opt < %s -instcombine -S | FileCheck %s
;
; This transformation requires the pointer size, as it assumes that size_t is
; the size of a pointer.
target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:128:128-n8:16:32"

@hello = constant [6 x i8] c"hello\00"
@a = common global [32 x i8] zeroinitializer, align 1
@b = common global [32 x i8] zeroinitializer, align 1
@percent_s = constant [3 x i8] c"%s\00"

declare i32 @sprintf(i8**, i32*, ...)
declare i8* @stpcpy(i8*, i8*)

define i8* @test_simplify1() {
; CHECK-LABEL: @test_simplify1(
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i32(i8* noundef nonnull align 1 dereferenceable(6) getelementptr inbounds ([32 x i8], [32 x i8]* @a, i32 0, i32 0), i8* noundef nonnull align 1 dereferenceable(6) getelementptr inbounds ([6 x i8], [6 x i8]* @hello, i32 0, i32 0), i32 6, i1 false)
; CHECK-NEXT:    ret i8* getelementptr inbounds ([32 x i8], [32 x i8]* @a, i32 0, i32 5)
;
  %dst = getelementptr [32 x i8], [32 x i8]* @a, i32 0, i32 0
  %src = getelementptr [6 x i8], [6 x i8]* @hello, i32 0, i32 0
  %ret = call i8* @stpcpy(i8* %dst, i8* %src)
  ret i8* %ret
}

define i8* @test_simplify2() {
; CHECK-LABEL: @test_simplify2(
; CHECK-NEXT:    [[STRLEN:%.*]] = call i32 @strlen(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([32 x i8], [32 x i8]* @a, i32 0, i32 0))
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [32 x i8], [32 x i8]* @a, i32 0, i32 [[STRLEN]]
; CHECK-NEXT:    ret i8* [[TMP1]]
;
  %dst = getelementptr [32 x i8], [32 x i8]* @a, i32 0, i32 0
  %ret = call i8* @stpcpy(i8* %dst, i8* %dst)
  ret i8* %ret
}

define void @test_simplify3(i8* %dst) {
; CHECK-LABEL: @test_simplify3(
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i32(i8* noundef nonnull align 1 dereferenceable(6) [[DST:%.*]], i8* noundef nonnull align 1 dereferenceable(6) getelementptr inbounds ([6 x i8], [6 x i8]* @hello, i32 0, i32 0), i32 6, i1 false)
; CHECK-NEXT:    ret void
;
  %src = getelementptr [6 x i8], [6 x i8]* @hello, i32 0, i32 0
  call i8* @stpcpy(i8* dereferenceable(80) %dst, i8* %src)
  ret void
}

define i8* @test_no_simplify1() {
; CHECK-LABEL: @test_no_simplify1(
; CHECK-NEXT:    [[RET:%.*]] = call i8* @stpcpy(i8* getelementptr inbounds ([32 x i8], [32 x i8]* @a, i32 0, i32 0), i8* getelementptr inbounds ([32 x i8], [32 x i8]* @b, i32 0, i32 0))
; CHECK-NEXT:    ret i8* [[RET]]
;
  %dst = getelementptr [32 x i8], [32 x i8]* @a, i32 0, i32 0
  %src = getelementptr [32 x i8], [32 x i8]* @b, i32 0, i32 0
  %ret = call i8* @stpcpy(i8* %dst, i8* %src)
  ret i8* %ret
}

define i8* @test_no_simplify2(i8* %dst, i8* %src) {
; CHECK-LABEL: @test_no_simplify2(
; CHECK-NEXT:    %ret = musttail call i8* @stpcpy(i8* %dst, i8* %src)
; CHECK-NEXT:    ret i8* %ret
;
  %ret = musttail call i8* @stpcpy(i8* %dst, i8* %src)
  ret i8* %ret
}

define i8* @test_no_incompatible_attr() {
; CHECK-LABEL: @test_no_incompatible_attr(
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i32(i8* noundef nonnull align 1 dereferenceable(6) getelementptr inbounds ([32 x i8], [32 x i8]* @a, i32 0, i32 0), i8* noundef nonnull align 1 dereferenceable(6) getelementptr inbounds ([6 x i8], [6 x i8]* @hello, i32 0, i32 0), i32 6, i1 false)
; CHECK-NEXT:    ret i8* getelementptr inbounds ([32 x i8], [32 x i8]* @a, i32 0, i32 5)
;
  %dst = getelementptr [32 x i8], [32 x i8]* @a, i32 0, i32 0
  %src = getelementptr [6 x i8], [6 x i8]* @hello, i32 0, i32 0
  %ret = call dereferenceable(1) i8* @stpcpy(i8* %dst, i8* %src)
  ret i8* %ret
}

; The libcall prototype checker does not check for exact pointer type
; (just pointer of some type), so we identify this as a standard sprintf
; call. This requires a cast to operate on mismatched pointer types.

define i32 @PR51200(i8** %p, i32* %p2) {
; CHECK-LABEL: @PR51200(
; CHECK-NEXT:    [[CSTR:%.*]] = bitcast i8** [[P:%.*]] to i8*
; CHECK-NEXT:    [[CSTR1:%.*]] = bitcast i32* [[P2:%.*]] to i8*
; CHECK-NEXT:    [[STPCPY:%.*]] = call i8* @stpcpy(i8* [[CSTR]], i8* [[CSTR1]])
; CHECK-NEXT:    [[TMP1:%.*]] = ptrtoint i8* [[STPCPY]] to i32
; CHECK-NEXT:    [[TMP2:%.*]] = zext i32 [[TMP1]] to i64
; CHECK-NEXT:    [[TMP3:%.*]] = ptrtoint i8** [[P]] to i32
; CHECK-NEXT:    [[TMP4:%.*]] = zext i32 [[TMP3]] to i64
; CHECK-NEXT:    [[TMP5:%.*]] = sub nsw i64 [[TMP2]], [[TMP4]]
; CHECK-NEXT:    [[TMP6:%.*]] = lshr exact i64 [[TMP5]], 2
; CHECK-NEXT:    [[TMP7:%.*]] = trunc i64 [[TMP6]] to i32
; CHECK-NEXT:    ret i32 [[TMP7]]
;
  %call = call i32 (i8**, i32*, ...) @sprintf(i8** %p, i32* bitcast ([3 x i8]* @percent_s to i32*), i32* %p2)
  ret i32 %call
}
