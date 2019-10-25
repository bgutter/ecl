;;;; -*- Mode: Lisp; Syntax: Common-Lisp; indent-tabs-mode: nil; Package: SYSTEM -*-
;;;; vim: set filetype=lisp tabstop=8 shiftwidth=2 expandtab:

;;;;
(in-package "SYSTEM")
(proclaim '(FTYPE (FUNCTION (T T T) T) DEFMACRO*))
(proclaim '(FTYPE (FUNCTION (T T T) T) DM-VL))
(proclaim '(FTYPE (FUNCTION (T T) T) DM-V))
(proclaim '(FTYPE (FUNCTION (T T) T) DM-NTH))
(proclaim '(FTYPE (FUNCTION (T T) T) DM-NTH-CDR))
(proclaim '(FTYPE (FUNCTION (T) T) DM-BAD-KEY))
(proclaim '(FTYPE (FUNCTION (T) T) DM-KEY-NOT-ALLOWED))
;(proclaim '(FTYPE (FUNCTION (T T) T) FIND-DOC))
;(proclaim '(FTYPE (FUNCTION (T) T) FIND-DECLARATIONS))
(proclaim '(FTYPE (FUNCTION (T) T) CLEAR-COMPILER-PROPERTIES))
(proclaim '(FTYPE (FUNCTION (T) T) TERMINAL-INTERRUPT))
(proclaim '(FTYPE (FUNCTION (T T) T) BREAK-LEVEL))
(proclaim '(FTYPE (FUNCTION (T T) T) TPL-MAKE-COMMAND))
(proclaim '(FTYPE (FUNCTION (T) T) TPL-PARSE-STRINGS))
(proclaim '(FTYPE (FUNCTION (T) T) TPL-PRINT))
(proclaim '(FTYPE (FUNCTION (T) T) TPL-UNKNOWN-COMMAND))
(proclaim '(FTYPE (FUNCTION (T) T) TPL-GO))
(proclaim '(FTYPE (FUNCTION (T) T) PRINT-IHS))
(proclaim '(FTYPE (FUNCTION (T) T) PRINT-FRS))
(proclaim '(FTYPE (FUNCTION (T) T) FRS-KIND))
(proclaim '(FTYPE (FUNCTION (T) T) TPL-HIDE))
(proclaim '(FTYPE (FUNCTION (T) T) TPL-UNHIDE))
(proclaim '(FTYPE (FUNCTION (T) T) TPL-UNHIDE-PACKAGE))
(proclaim '(FTYPE (FUNCTION (T) T) TPL-HIDE-PACKAGE))
(proclaim '(FTYPE (FUNCTION (T) T) IHS-VISIBLE))
(proclaim '(FTYPE (FUNCTION (T) T) IHS-FNAME))
(proclaim '(FTYPE (FUNCTION (T) T) IHS-COMPILED-P))
(proclaim '(FTYPE (FUNCTION (T T) T) SUPER-GO))
(proclaim '(FTYPE (FUNCTION (T) T) TPL-BACKWARD-SEARCH))
(proclaim '(FTYPE (FUNCTION (T) T) TPL-FORWARD-SEARCH))
(proclaim '(FTYPE (FUNCTION (T) T) PROVIDE))
(proclaim '(FTYPE (FUNCTION (T T) T) DOCUMENTATION))
(proclaim '(FTYPE (FUNCTION (T) T) FIND-DOCUMENTATION))
(proclaim '(FTYPE (FUNCTION (T) T) SIMPLE-ARRAY-P))
(proclaim '(FTYPE (FUNCTION (T T) T) TYPEP))
(proclaim '(FTYPE (FUNCTION (T T) T) SI::SUBCLASSP))
(proclaim '(FTYPE (FUNCTION (T) T) NORMALIZE-TYPE))
(proclaim '(FTYPE (FUNCTION (T) T) KNOWN-TYPE-P))
(proclaim '(FTYPE (FUNCTION (T T) T) SUBTYPEP))
(proclaim '(FTYPE (FUNCTION (T T) T) SUB-INTERVAL-P))
(proclaim '(FTYPE (FUNCTION (T T) T) IN-INTERVAL-P))
(proclaim '(FTYPE (FUNCTION (T T) T) MATCH-DIMENSIONS))
(proclaim '(FTYPE (FUNCTION (T T) T) COERCE))
(proclaim '(FTYPE (FUNCTION (T) T) CLEAR-COMPILER-PROPERTIES))
(proclaim '(FTYPE (FUNCTION (T) T) GET-SETF-METHOD))
(proclaim '(FTYPE (FUNCTION (T) T) GET-SETF-METHOD-MULTIPLE-VALUE))
(proclaim '(FTYPE (FUNCTION (T T T) T) SETF-EXPAND-1))
(proclaim '(FTYPE (FUNCTION (T T) T) SETF-EXPAND))
(proclaim '(FTYPE (FUNCTION (T T) T) INCREMENT-CURSOR))
(proclaim '(FTYPE (FUNCTION (T T) T) SEQUENCE-CURSOR))
(proclaim '(FTYPE (FUNCTION (T) T) ARRAY-DIMENSIONS))
(proclaim '(FTYPE (FUNCTION (T T) T) VECTOR-PUSH))
(proclaim '(FTYPE (FUNCTION (T) T) VECTOR-POP))
(proclaim '(FTYPE (FUNCTION (T) T) ASK-FOR-FORM))
(proclaim '(FTYPE (FUNCTION (T) T) BOIN-P))
(proclaim '(FTYPE (FUNCTION (T T T T T T T T T) T) MAKE-ACCESS-FUNCTION))
(proclaim '(FTYPE (FUNCTION (T T T T T) T) MAKE-CONSTRUCTOR))
(proclaim '(FTYPE (FUNCTION (T T T T) T) MAKE-COPIER))
(proclaim '(FTYPE (FUNCTION (T T T T T) T) MAKE-PREDICATE))
(proclaim '(FTYPE (FUNCTION (T T) T) PARSE-SLOT-DESCRIPTION))
(proclaim '(FTYPE (FUNCTION (T T) T) OVERWRITE-SLOT-DESCRIPTIONS))
(proclaim '(FTYPE (FUNCTION (T T T) T) SHARP-S-READER))
(proclaim '(FTYPE (FUNCTION (T T T) T) READ-INSPECT-COMMAND))
(proclaim '(FTYPE (FUNCTION (T) T) INSPECT-SYMBOL))
(proclaim '(FTYPE (FUNCTION (T) T) INSPECT-PACKAGE))
(proclaim '(FTYPE (FUNCTION (T) T) INSPECT-CHARACTER))
(proclaim '(FTYPE (FUNCTION (T) T) INSPECT-NUMBER))
(proclaim '(FTYPE (FUNCTION (T) T) INSPECT-CONS))
(proclaim '(FTYPE (FUNCTION (T) T) INSPECT-STRING))
(proclaim '(FTYPE (FUNCTION (T) T) INSPECT-VECTOR))
(proclaim '(FTYPE (FUNCTION (T) T) INSPECT-ARRAY))
(proclaim '(FTYPE (FUNCTION (T) T) INSPECT-OBJECT))
(proclaim '(FTYPE (FUNCTION (T) T) DESCRIBE))
(proclaim '(FTYPE (FUNCTION (T) T) INSPECT))
(proclaim '(FTYPE (FUNCTION (T) T) ARG-LIST))
(proclaim '(FTYPE (FUNCTION (T) T) PRIN1-TO-STRING))
(proclaim '(FTYPE (FUNCTION (T) T) PRINC-TO-STRING))
(proclaim '(FTYPE (FUNCTION (T T T) T) SHARP-A-READER))
(proclaim '(FTYPE (FUNCTION (T T T) T) SHARP-S-READER-SI))
(proclaim '(FTYPE (FUNCTION (T) T) LEAP-YEAR-P))
(proclaim '(FTYPE (FUNCTION (T) T) NUMBER-OF-DAYS-FROM-1900))
(proclaim '(FTYPE (FUNCTION (T) T) ISQRT))
(proclaim '(FTYPE (FUNCTION (T) T) ABS))
(proclaim '(FTYPE (FUNCTION (T) T) PHASE))
(proclaim '(FTYPE (FUNCTION (T) T) SIGNUM))
(proclaim '(FTYPE (FUNCTION (T) T) CIS))
(proclaim '(FTYPE (FUNCTION (T) T) ASIN))
(proclaim '(FTYPE (FUNCTION (T) T) ACOS))
(proclaim '(FTYPE (FUNCTION (T) T) SINH))
(proclaim '(FTYPE (FUNCTION (T) T) COSH))
(proclaim '(FTYPE (FUNCTION (T) T) TANH))
(proclaim '(FTYPE (FUNCTION (T) T) ASINH))
(proclaim '(FTYPE (FUNCTION (T) T) ACOSH))
(proclaim '(FTYPE (FUNCTION (T) T) ATANH))
(proclaim '(FTYPE (FUNCTION (T) T) RATIONAL))
(proclaim '(FTYPE (FUNCTION (T) T) RATIONALIZE))
(proclaim '(FTYPE (FUNCTION (T T) T) RATIONALIZE-FLOAT))
(proclaim '(FTYPE (FUNCTION (T T) T) LOGNAND))
(proclaim '(FTYPE (FUNCTION (T T) T) LOGNOR))
(proclaim '(FTYPE (FUNCTION (T T) T) LOGANDC1))
(proclaim '(FTYPE (FUNCTION (T T) T) LOGANDC2))
(proclaim '(FTYPE (FUNCTION (T T) T) LOGORC1))
(proclaim '(FTYPE (FUNCTION (T T) T) LOGORC2))
(proclaim '(FTYPE (FUNCTION (T) T) LOGNOT))
(proclaim '(FTYPE (FUNCTION (T T) T) LOGTEST))
(proclaim '(FTYPE (FUNCTION (T T) T) BYTE))
(proclaim '(FTYPE (FUNCTION (T) T) BYTE-SIZE))
(proclaim '(FTYPE (FUNCTION (T) T) BYTE-POSITION))
(proclaim '(FTYPE (FUNCTION (T T) T) LDB))
(proclaim '(FTYPE (FUNCTION (T T) T) LDB-TEST))
(proclaim '(FTYPE (FUNCTION (T T) T) MASK-FIELD))
(proclaim '(FTYPE (FUNCTION (T T T) T) DPB))
(proclaim '(FTYPE (FUNCTION (T T T) T) DEPOSIT-FIELD))
(proclaim '(FTYPE (FUNCTION (T) T) FIND-ALL-SYMBOLS))
(proclaim '(FTYPE (FUNCTION (T T) T) SUBSTRINGP))
(proclaim '(FTYPE (FUNCTION (T) T) PRINT-SYMBOL-APROPOS))
(proclaim '(FTYPE (FUNCTION (T) T) SEQTYPE))
(proclaim '(FTYPE (FUNCTION (T T T T) T) CALL-TEST))
(proclaim '(FTYPE (FUNCTION (T T) T) CHECK-SEQ-TEST))
(proclaim '(FTYPE (FUNCTION (T T) T) CHECK-SEQ-START-END))
(proclaim '(FTYPE (FUNCTION (T T T T) T) CHECK-SEQ-ARGS))
(proclaim '(FTYPE (FUNCTION (T T T) T) LIST-MERGE-SORT))
(proclaim '(FTYPE (FUNCTION (T FIXNUM FIXNUM T T) T) QUICK-SORT))
(proclaim '(FTYPE (FUNCTION (T) T) TRACE*))
(proclaim '(FTYPE (FUNCTION (T) T) UNTRACE*))
(proclaim '(FTYPE (FUNCTION (T) T) TRACE-ONE))
(proclaim '(FTYPE (FUNCTION (T) T) UNTRACE-ONE))
(proclaim '(FTYPE (FUNCTION (T) T) TRACING-BODY))
(proclaim '(FTYPE (FUNCTION (T) T) STEP*))
(proclaim '(FTYPE (FUNCTION (T T) T) LOOP-TEQUAL))
(proclaim '(FTYPE (FUNCTION (T T) T) LOOP-TMEMBER))
(proclaim '(FTYPE (FUNCTION (T T) T) LOOP-TASSOC))
(proclaim '(FTYPE (FUNCTION (T) T) LOOP-NAMED-VARIABLE))
(proclaim '(FTYPE (FUNCTION (T) T) PARSE-TYPE))
(proclaim '(FTYPE (FUNCTION (T T T) T) LV-BIND))
(proclaim '(FTYPE (FUNCTION (T) T) LV-SET))
(proclaim '(FTYPE (FUNCTION (T T) T) MERGE-INF))
(proclaim '(FTYPE (FUNCTION (T) T) SET-ITERATION))
(proclaim '(FTYPE (FUNCTION (T T T T T T) T) PARSE-FOR1))
(proclaim '(FTYPE (FUNCTION (T) T) PARSE-LOOP-PATH))
(proclaim '(FTYPE (FUNCTION (T) T) GET-ACC))
(proclaim '(FTYPE (FUNCTION (T) T) PARSE-WHEN))
