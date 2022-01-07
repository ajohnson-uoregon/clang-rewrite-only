; NOTE: Assertions have been autogenerated by utils/update_analyze_test_checks.py
; RUN: opt -disable-output "-passes=print<scalar-evolution>" %s 2>&1 | FileCheck %s

; exact-not-taken cannot be umin(n, m) because it is possible for (n, m) to be (0, poison)
; https://alive2.llvm.org/ce/z/NsP9ue
define i32 @logical_and_2ops(i32 %n, i32 %m) {
; CHECK-LABEL: 'logical_and_2ops'
; CHECK-NEXT:  Classifying expressions for: @logical_and_2ops
; CHECK-NEXT:    %i = phi i32 [ 0, %entry ], [ %i.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %i.next = add i32 %i, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %cond = select i1 %cond_p0, i1 %cond_p1, i1 false
; CHECK-NEXT:    --> %cond U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @logical_and_2ops
; CHECK-NEXT:  Loop %loop: Unpredictable backedge-taken count.
; CHECK-NEXT:  Loop %loop: max backedge-taken count is -1
; CHECK-NEXT:  Loop %loop: Unpredictable predicated backedge-taken count.
;
entry:
  br label %loop
loop:
  %i = phi i32 [0, %entry], [%i.next, %loop]
  %i.next = add i32 %i, 1
  %cond_p0 = icmp ult i32 %i, %n
  %cond_p1 = icmp ult i32 %i, %m
  %cond = select i1 %cond_p0, i1 %cond_p1, i1 false
  br i1 %cond, label %loop, label %exit
exit:
  ret i32 %i
}

; exact-not-taken cannot be umin(n, m) because it is possible for (n, m) to be (0, poison)
; https://alive2.llvm.org/ce/z/ApRitq
define i32 @logical_or_2ops(i32 %n, i32 %m) {
; CHECK-LABEL: 'logical_or_2ops'
; CHECK-NEXT:  Classifying expressions for: @logical_or_2ops
; CHECK-NEXT:    %i = phi i32 [ 0, %entry ], [ %i.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %i.next = add i32 %i, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %cond = select i1 %cond_p0, i1 true, i1 %cond_p1
; CHECK-NEXT:    --> %cond U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @logical_or_2ops
; CHECK-NEXT:  Loop %loop: Unpredictable backedge-taken count.
; CHECK-NEXT:  Loop %loop: max backedge-taken count is -1
; CHECK-NEXT:  Loop %loop: Unpredictable predicated backedge-taken count.
;
entry:
  br label %loop
loop:
  %i = phi i32 [0, %entry], [%i.next, %loop]
  %i.next = add i32 %i, 1
  %cond_p0 = icmp uge i32 %i, %n
  %cond_p1 = icmp uge i32 %i, %m
  %cond = select i1 %cond_p0, i1 true, i1 %cond_p1
  br i1 %cond, label %exit, label %loop
exit:
  ret i32 %i
}

define i32 @logical_and_3ops(i32 %n, i32 %m, i32 %k) {
; CHECK-LABEL: 'logical_and_3ops'
; CHECK-NEXT:  Classifying expressions for: @logical_and_3ops
; CHECK-NEXT:    %i = phi i32 [ 0, %entry ], [ %i.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %i.next = add i32 %i, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %cond_p3 = select i1 %cond_p0, i1 %cond_p1, i1 false
; CHECK-NEXT:    --> %cond_p3 U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %cond = select i1 %cond_p3, i1 %cond_p2, i1 false
; CHECK-NEXT:    --> %cond U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @logical_and_3ops
; CHECK-NEXT:  Loop %loop: Unpredictable backedge-taken count.
; CHECK-NEXT:  Loop %loop: max backedge-taken count is -1
; CHECK-NEXT:  Loop %loop: Unpredictable predicated backedge-taken count.
;
entry:
  br label %loop
loop:
  %i = phi i32 [0, %entry], [%i.next, %loop]
  %i.next = add i32 %i, 1
  %cond_p0 = icmp ult i32 %i, %n
  %cond_p1 = icmp ult i32 %i, %m
  %cond_p2 = icmp ult i32 %i, %k
  %cond_p3 = select i1 %cond_p0, i1 %cond_p1, i1 false
  %cond = select i1 %cond_p3, i1 %cond_p2, i1 false
  br i1 %cond, label %loop, label %exit
exit:
  ret i32 %i
}

define i32 @logical_or_3ops(i32 %n, i32 %m, i32 %k) {
; CHECK-LABEL: 'logical_or_3ops'
; CHECK-NEXT:  Classifying expressions for: @logical_or_3ops
; CHECK-NEXT:    %i = phi i32 [ 0, %entry ], [ %i.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %i.next = add i32 %i, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %cond_p3 = select i1 %cond_p0, i1 true, i1 %cond_p1
; CHECK-NEXT:    --> %cond_p3 U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %cond = select i1 %cond_p3, i1 true, i1 %cond_p2
; CHECK-NEXT:    --> %cond U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @logical_or_3ops
; CHECK-NEXT:  Loop %loop: Unpredictable backedge-taken count.
; CHECK-NEXT:  Loop %loop: max backedge-taken count is -1
; CHECK-NEXT:  Loop %loop: Unpredictable predicated backedge-taken count.
;
entry:
  br label %loop
loop:
  %i = phi i32 [0, %entry], [%i.next, %loop]
  %i.next = add i32 %i, 1
  %cond_p0 = icmp uge i32 %i, %n
  %cond_p1 = icmp uge i32 %i, %m
  %cond_p2 = icmp uge i32 %i, %k
  %cond_p3 = select i1 %cond_p0, i1 true, i1 %cond_p1
  %cond = select i1 %cond_p3, i1 true, i1 %cond_p2
  br i1 %cond, label %exit, label %loop
exit:
  ret i32 %i
}