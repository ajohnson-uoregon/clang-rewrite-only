; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -mtriple=powerpc64le-unknown-linux-gnu -O2 \
; RUN:     -ppc-asm-full-reg-names -mcpu=pwr10 < %s | FileCheck %s
; RUN: llc -verify-machineinstrs -mtriple=powerpc64-unknown-linux-gnu -O2 \
; RUN:     -ppc-asm-full-reg-names -mcpu=pwr10 < %s | FileCheck %s

define dso_local <4 x i32> @testZero() local_unnamed_addr {
; CHECK-LABEL: testZero:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxlxor vs34, vs34, vs34
; CHECK-NEXT:    blr

entry:
  ret <4 x i32> zeroinitializer
}

define dso_local <4 x float> @testZeroF() local_unnamed_addr {
; CHECK-LABEL: testZeroF:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxlxor vs34, vs34, vs34
; CHECK-NEXT:    blr

entry:
  ret <4 x float> zeroinitializer
}

define dso_local <4 x i32> @testAllOneS() local_unnamed_addr {
; CHECK-LABEL: testAllOneS:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxleqv vs34, vs34, vs34
; CHECK-NEXT:    blr

entry:
  ret <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>
}

define dso_local <4 x i32> @test5Bit() local_unnamed_addr {
; CHECK-LABEL: test5Bit:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vspltisw v2, 7
; CHECK-NEXT:    blr

entry:
  ret <4 x i32> <i32 7, i32 7, i32 7, i32 7>
}

define dso_local <16 x i8> @test1ByteChar() local_unnamed_addr {
; CHECK-LABEL: test1ByteChar:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltib vs34, 7
; CHECK-NEXT:    blr

entry:
  ret <16 x i8> <i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7>
}

define dso_local <4 x i32> @test1ByteSplatInt() local_unnamed_addr {
; Here the splat of 171 or 0xABABABAB can be done using a byte splat
; of 0xAB using xxspltib while avoiding the use of xxspltiw.
; CHECK-LABEL: test1ByteSplatInt:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltib vs34, 171
; CHECK-NEXT:    blr

entry:
  ret <4 x i32> <i32 -1414812757, i32 -1414812757, i32 -1414812757, i32 -1414812757>
}

define dso_local <4 x i32> @test5Bit2Ins() local_unnamed_addr {
; Splats within the range [-32,31] can be done using two vsplti[bhw]
; instructions, but we prefer the xxspltiw instruction to them.
; CHECK-LABEL: test5Bit2Ins:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltiw vs34, 16
; CHECK-NEXT:    blr

entry:
  ret <4 x i32> <i32 16, i32 16, i32 16, i32 16>
}

define dso_local <4 x float> @testFloatNegZero() local_unnamed_addr {
; 0.0f is not the same as -0.0f. We try to splat -0.0f
; CHECK-LABEL: testFloatNegZero:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltiw vs34, -2147483648
; CHECK-NEXT:    blr

entry:
  ret <4 x float> <float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00>
}

define dso_local <4 x float> @testFloat() local_unnamed_addr {
; CHECK-LABEL: testFloat:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltiw vs34, 1135323709
; CHECK-NEXT:    blr

entry:
  ret <4 x float> <float 0x40757547A0000000, float 0x40757547A0000000, float 0x40757547A0000000, float 0x40757547A0000000>
}

define dso_local <4 x float> @testIntToFloat() local_unnamed_addr {
; CHECK-LABEL: testIntToFloat:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltiw vs34, 1135312896
; CHECK-NEXT:    blr

entry:
  ret <4 x float> <float 3.430000e+02, float 3.430000e+02, float 3.430000e+02, float 3.430000e+02>
}

define dso_local <4 x i32> @testUndefInt() local_unnamed_addr {
; CHECK-LABEL: testUndefInt:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltiw vs34, 18
; CHECK-NEXT:    blr

entry:
  ret <4 x i32> <i32 18, i32 undef, i32 undef, i32 18>
}

define dso_local <4 x float> @testUndefIntToFloat() local_unnamed_addr {
; CHECK-LABEL: testUndefIntToFloat:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltiw vs34, 1135312896
; CHECK-NEXT:    blr

entry:
  ret <4 x float> <float 3.430000e+02, float undef, float undef, float 3.430000e+02>
}

define dso_local <2 x i64> @testPseudo8Byte() local_unnamed_addr {
; CHECK-LABEL: testPseudo8Byte:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltiw vs34, -1430532899
; CHECK-NEXT:    blr

entry:
  ret <2 x i64> <i64 -6144092014192636707, i64 -6144092014192636707>
}

define dso_local <8 x i16> @test2Byte() local_unnamed_addr {
; CHECK-LABEL: test2Byte:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltiw vs34, 1179666
; CHECK-NEXT:    blr

entry:
  ret <8 x i16> <i16 18, i16 18, i16 18, i16 18, i16 18, i16 18, i16 18, i16 18>
}

define dso_local <8 x i16> @test2ByteUndef() local_unnamed_addr {
; CHECK-LABEL: test2ByteUndef:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltiw vs34, 1179666
; CHECK-NEXT:    blr

entry:
  ret <8 x i16> <i16 18, i16 undef, i16 18, i16 18, i16 18, i16 undef, i16 18, i16 18>
}

define dso_local <2 x double> @testFloatToDouble() local_unnamed_addr {
; CHECK-LABEL: testFloatToDouble:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltidp vs34, 1135290941
; CHECK-NEXT:    blr

entry:
  ret <2 x double> <double 0x40756547A0000000, double 0x40756547A0000000>
}

define dso_local <2 x double> @testDoubleLower4ByteZero() local_unnamed_addr {
; The expanded double will have 0 in the last 32 bits. Imprecise handling of
; return value of data structures like APInt, returned when calling getZextValue
; , like saving the return value into an unsigned instead of uint64_t may cause
; this test to fail.
; CHECK-LABEL: testDoubleLower4ByteZero:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltidp vs34, 1093664768
; CHECK-NEXT:    blr

entry:
  ret <2 x double> <double 1.100000e+01, double 1.100000e+01>
}

define dso_local <2 x double> @testDoubleToDoubleZero() local_unnamed_addr {
; Should be using canonicalized form to splat zero and use shorter instructions
; than xxspltidp.
; CHECK-LABEL: testDoubleToDoubleZero:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxlxor vs34, vs34, vs34
; CHECK-NEXT:    blr

entry:
  ret <2 x double> zeroinitializer
}

define dso_local <2 x double> @testDoubleToDoubleNegZero() local_unnamed_addr {
; CHECK-LABEL: testDoubleToDoubleNegZero:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltidp vs34, -2147483648
; CHECK-NEXT:    blr

entry:
  ret <2 x double> <double -0.000000e+00, double -0.000000e+00>
}

define dso_local <2 x double> @testDoubleToDoubleNaN() local_unnamed_addr {
; CHECK-LABEL: testDoubleToDoubleNaN:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltidp vs34, -16
; CHECK-NEXT:    blr

entry:
  ret <2 x double> <double 0xFFFFFFFE00000000, double 0xFFFFFFFE00000000>
}

define dso_local <2 x double> @testDoubleToDoubleInfinity() local_unnamed_addr {
; CHECK-LABEL: testDoubleToDoubleInfinity:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltidp vs34, 2139095040
; CHECK-NEXT:    blr

entry:
  ret <2 x double> <double 0x7FF0000000000000, double 0x7FF0000000000000>
}

define dso_local <2 x double> @testFloatToDoubleNaN() local_unnamed_addr {
; CHECK-LABEL: testFloatToDoubleNaN:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltidp vs34, -1
; CHECK-NEXT:    blr

entry:
  ret <2 x double> <double 0xFFFFFFFFE0000000, double 0xFFFFFFFFE0000000>
}

define dso_local <2 x double> @testFloatToDoubleInfinity() local_unnamed_addr {
; CHECK-LABEL: testFloatToDoubleInfinity:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltidp vs34, 2139095040
; CHECK-NEXT:    blr

entry:
  ret <2 x double> <double 0x7FF0000000000000, double 0x7FF0000000000000>
}

define dso_local float @testFloatScalar() local_unnamed_addr {
; CHECK-LABEL: testFloatScalar:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltidp vs1, 1135290941
; CHECK-NEXT:    blr

entry:
  ret float 0x40756547A0000000
}

define dso_local float @testFloatZeroScalar() local_unnamed_addr {
; CHECK-LABEL: testFloatZeroScalar:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxlxor f1, f1, f1
; CHECK-NEXT:    blr

entry:
  ret float 0.000000e+00
}

define dso_local double @testDoubleRepresentableScalar() local_unnamed_addr {
; CHECK-LABEL: testDoubleRepresentableScalar:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltidp vs1, 1135290941
; CHECK-NEXT:    blr

entry:
  ret double 0x40756547A0000000
}

define dso_local double @testDoubleZeroScalar() local_unnamed_addr {
; CHECK-LABEL: testDoubleZeroScalar:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxlxor f1, f1, f1
; CHECK-NEXT:    blr

entry:
  ret double 0.000000e+00
}

define dso_local <4 x i32> @vec_splati() local_unnamed_addr {
; CHECK-LABEL: vec_splati:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltiw vs34, -17
; CHECK-NEXT:    blr
entry:
  ret <4 x i32> <i32 -17, i32 -17, i32 -17, i32 -17>
}

define dso_local <2 x double> @vec_splatid() local_unnamed_addr {
; CHECK-LABEL: vec_splatid:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xxspltidp vs34, 1065353216
; CHECK-NEXT:    blr
entry:
  ret <2 x double> <double 1.000000e+00, double 1.000000e+00>
}
