;;;;  CMPFLET  Flet, Labels, and Macrolet.

;;;;  Copyright (c) 1984, Taiichi Yuasa and Masami Hagiya.
;;;;  Copyright (c) 1990, Giuseppe Attardi.
;;;;
;;;;    This program is free software; you can redistribute it and/or
;;;;    modify it under the terms of the GNU Library General Public
;;;;    License as published by the Free Software Foundation; either
;;;;    version 2 of the License, or (at your option) any later version.
;;;;
;;;;    See file '../Copyright' for full details.

(in-package "COMPILER")

(defun c1flet (args &aux body ss ts is other-decl
	       (defs '()) (local-funs '()))
  (check-args-number 'FLET args 1)
  ;; On a first round, we extract the definitions of the functions,
  ;; and build empty function objects that record the references to
  ;; this functions in the processed body. In the end
  ;;	DEFS = ( { ( fun-object  function-body ) }* ).
  (let ((*funs* *funs*))
    (dolist (def (car args))
      (cmpck (or (endp def)
                 (not (si::valid-function-name-p (car def)))
                 (endp (cdr def)))
             "The function definition ~s is illegal." def)
      (let ((fun (make-fun :name (car def))))
        (push fun *funs*)
        (push (list fun (cdr def)) defs)))

    (multiple-value-setq (body ss ts is other-decl) (c1body (cdr args) t))

    (let ((*vars* *vars*))
      (c1add-globals ss)
      (check-vdecl nil ts is)
      (setq body (c1decl-body other-decl body))))

  ;; Now we can compile the function themselves. Notice that we have
  ;; emptied *fun* so that the functions do not see each other (that is
  ;; the difference with LABELS). In the end
  ;;	LOCAL-FUNS = ( { ( fun-object  lambda-c1form ) }* ).
  (dolist (def (nreverse defs))
    (let ((fun (car def)) lam CB/LB)
      (when (plusp (fun-ref fun))
	(setq CB/LB (if (fun-ref-ccb fun) 'CB 'LB))
	(setq lam
	      (let ((*funs* (cons CB/LB *funs*))
		    (*vars* (cons CB/LB *vars*))
		    (*blocks* (cons CB/LB *blocks*))
		    (*tags* (cons CB/LB *tags*)))
		(c1lambda-expr (second def)
			       (si::function-block-name (fun-name fun)))))
	(push (list fun lam) local-funs)
	(setf (fun-cfun fun) (next-cfun)))))

  ;; cant do in previous loop since closed var may be in later function
  (dolist (fun-lam local-funs)
    (setf (fun-closure (first fun-lam)) (closure-p (second fun-lam))))

  (if local-funs
      (make-c1form* 'LOCALS :type (c1form-type body)
		    :args (nreverse local-funs) body nil)
      body))

(defun closure-p (funob)
  ;; It's a closure if inside its body there is a reference (var)
  (dolist (var (c1form-referred-vars funob))
    ;; referred across CB
    (when (ref-ref-ccb var)
      ;; established outside the body
      (when (or
	     (member var *vars* :test #'eq)
	     (member var *funs* :test #'eq :key
		     #'(lambda (x) (unless (or (consp x) (symbolp x)) (fun-var x))))
	     (member var *blocks* :test #'eq :key
		     #'(lambda (x) (unless (symbolp x) (blk-var x))))
	     (member var *tags* :test #'eql :key
		     #'(lambda (x) (unless (symbolp x) (tag-var x)))))
	(return t)))))

(defun c2locals (funs body labels ;; labels is T when deriving from labels
		      &aux block-p
		      (level *level*)
		      (*env* *env*)
		      (*env-lvl* *env-lvl*) env-grows)
  ;; create location for each function which is returned,
  ;; either in lexical:
  (dolist (def funs)
    (let* ((fun (car def)) (var (fun-var fun)))
      (when (plusp (var-ref var))	; the function is returned
        (unless (member (var-kind var) '(LEXICAL CLOSURE))
          (setf (var-loc var) (next-lcl))
          (unless block-p
            (setq block-p t) (wt-nl "{ "))
          (wt "cl_object " var ";"))
	(unless env-grows
	  (setq env-grows (var-ref-ccb var))))))
  ;; or in closure environment:
  (when (env-grows env-grows)
    (unless block-p
      (wt-nl "{ ") (setq block-p t))
    (let ((env-lvl *env-lvl*))
      (wt "volatile cl_object env" (incf *env-lvl*) " = env" env-lvl ";")))
  ;; bind such locations:
  ;; - first create binding (because of possible circularities)
  (dolist (def funs)
    (let* ((fun (car def)) (var (fun-var fun)))
      (when (and var (plusp (var-ref var)))
	(when labels
	  (incf (fun-env fun)))		; var is included in the closure env
	(bind nil var))))
  ;; - then assign to it
  (dolist (def funs)
    (let* ((fun (car def)) (var (fun-var fun)))
      (when (and var (plusp (var-ref var)))
	(set-var (list 'MAKE-CCLOSURE fun) var))))
  ;; We need to introduce a new lex vector when lexical variables
  ;; are present in body and it is the outermost FLET or LABELS
  ;; (nested FLETS/LABELS can use a single lex).
  (when (plusp *lex*)
    (incf level))
  ;; create the functions:
  (dolist (def funs)
    (let* ((fun (car def)) (var (fun-var fun)) previous)
      (when (setq previous (new-local level fun (second def)))
	(format t "~%> ~A" previous)
	(setf (fun-level fun) (fun-level previous)
	      (fun-env fun) (fun-env previous)))))

  (c2expr body)
  (when block-p (wt-nl "}")))

(defun c1labels (args &aux body ss ts is other-decl defs fun local-funs
                      fnames (*funs* *funs*))
  (check-args-number 'LABELS args 1)

  ;;; bind local-functions
  (dolist (def (car args))
    (cmpck (or (endp def)
	       (not (si::valid-function-name-p (car def)))
	       (endp (cdr def)))
           "The local function definition ~s is illegal." def)
    (cmpck (member (car def) fnames)
           "The function ~s was already defined." (car def))
    (push (car def) fnames)
    (let ((fun (make-fun :name (car def))))
      (push fun *funs*)
      (push (list fun NIL (cdr def)) defs)))

  (setq defs (nreverse defs))

  ;;; Now DEFS holds ( { ( fun-object processed body ) }* ).

  (multiple-value-setq (body ss ts is other-decl) (c1body (cdr args) t))
  (let ((*vars* *vars*))
    (c1add-globals ss)
    (check-vdecl nil ts is)
    (setq body (c1decl-body other-decl body)))

  (do ((finished))
      (finished)
    (setq finished t)
    (dolist (def defs)
      (setq fun (car def))
      (when (and (plusp (fun-ref fun))	; referred
		 (not (fun-ref-ccb fun)) ; not within closure
                 (not (second def)))	; but not processed yet
        (setq finished nil)
        (let ((*vars* (cons 'LB *vars*))
              (*funs* (cons 'LB *funs*))
              (*blocks* (cons 'LB *blocks*))
              (*tags* (cons 'LB *tags*)))
          (let ((lam (c1lambda-expr (third def)
				    (si::function-block-name (fun-name fun)))))
            (push (list fun lam) local-funs)))
	(setf (second def) T)))
    )

  (do ((finished))
      (finished)
    (setq finished t)
    (dolist (def defs)
      (setq fun (car def))
      (when (and fun			; not processed yet
                 (fun-ref-ccb fun))	; referred across closure
	(setq finished nil)
	(when (second def)
	  ;; also processed as local, e.g.:
	  ;; (defun foo (z) (labels ((g () z) (h (y) #'g)) (list (h z) (g))))
	  (setq local-funs (delete fun local-funs :key #'car)))
	(let ((*vars* (cons 'CB *vars*))
	      (*funs* (cons 'CB *funs*))
	      (*blocks* (cons 'CB *blocks*))
	      (*tags* (cons 'CB *tags*)))
	  (let ((lam (c1lambda-expr (third def)
				    (si::function-block-name (fun-name fun)))))
	    (push (list fun lam) local-funs)))
	(setf (car def) NIL)))		; def processed
    )

  (dolist (fun-lam local-funs)
    (setq fun (first fun-lam))
    (setf (fun-closure fun) (closure-p (second fun-lam)))
    (setf (fun-cfun fun) (next-cfun)))

  (if local-funs
      (make-c1form* 'LOCALS :type (c1form-type body)
		    :args local-funs body T) ; T means labels
      body))

(defun c1locally (args)
  (multiple-value-bind (body ss ts is other-decl)
      (c1body args t)
    (c1add-globals ss)
    (check-vdecl nil ts is)
    (c1decl-body other-decl body)))

(defun c1macrolet (args &aux (*funs* *funs*))
  (check-args-number 'MACROLET args 1)
  (dolist (def (car args))
    (cmpck (or (endp def) (not (symbolp (car def))) (endp (cdr def)))
           "The macro definition ~s is illegal." def)
    (push (list (car def)
		'MACRO
		(si::make-lambda (car def)
				 (cdr (sys::expand-defmacro (car def) (second def) (cddr def)))))
          *funs*))
  (c1locally (cdr args)))

(defun c1symbol-macrolet (args &aux (*vars* *vars*))
  (check-args-number 'SYMBOL-MACROLET args 1)
  (dolist (def (car args))
    (cmpck (or (endp def) (not (symbolp (car def))) (endp (cdr def)))
           "The symbol-macro definition ~s is illegal." def)
    (push def *vars*))
  (c1locally (cdr args)))

(defun local-function-ref (fname &optional build-object &aux (ccb nil) (clb nil))
  (dolist (fun *funs*)
    (cond ((eq fun 'CB) (setq ccb t))
	  ((eq fun 'LB) (setq clb t))
	  ((and (symbolp fname) (consp fun))	; macro
	   (when (eq fname (car fun))
	     (when build-object
	       (cmperr "The name of a macro ~A was found in a call to FUNCTION."
		       fname))
	     (return nil)))
          ((same-fname-p (fun-name fun) fname)
	   (incf (fun-ref fun))
	   (when build-object
	     (setf (fun-ref-ccb fun) t))
	   ;; we introduce a variable to hold the funob
	   (let ((var (or (fun-var fun)
			  (setf (fun-var fun)
				(make-var :name fname :kind :OBJECT)))))
	     (cond (ccb (setf (var-ref-ccb var) t
			      (var-kind var) 'CLOSURE)
			(setf (fun-ref-ccb fun) t))
		   (clb (setf (var-ref-clb var) t
			      (var-kind var) 'LEXICAL))))
	   (return fun)))))

(defun sch-local-fun (fname)
  ;; Returns fun-ob for the local function (not locat macro) named FNAME,
  ;; if any.  Otherwise, returns FNAME itself.
  (dolist (fun *funs* fname)
    (when (and (not (eq fun 'CB))
               (not (consp fun))
               (same-fname-p (fun-name fun) fname))
          (return fun))))

(defun sch-local-macro (fname)
  (dolist (fun *funs*)
    (when (and (consp fun)
               (eq (first fun) fname))
          (return (third fun)))))

(defun c2call-local (fun args &optional narg)
  (declare (type fun fun))
  (multiple-value-bind (*unwind-exit* args narg)
      (maybe-push-args args)
    (when narg
      (c2call-local fun args narg)
      (wt-nl "}")
      (return-from c2call-local)))
  (cond
   ((and (listp args)
         *tail-recursion-info*
         (same-fname-p (car *tail-recursion-info*) (fun-name fun))
         (eq *exit* 'RETURN)
         (tail-recursion-possible)
         (= (length args) (length (cdr *tail-recursion-info*))))
    (let* ((*destination* 'TRASH)
           (*exit* (next-label))
           (*unwind-exit* (cons *exit* *unwind-exit*)))
          (c2psetq (cdr *tail-recursion-info*) args)
          (wt-label *exit*))
    (unwind-no-exit 'TAIL-RECURSION-MARK)
    (wt-nl "goto TTL;")
    (cmpnote "Tail-recursive call of ~s was replaced by iteration."
             (fun-name fun)))
   (t (let ((*inline-blocks* 0)
	    (fun (format nil "LC~d" (fun-cfun fun)))
	    (lex-level (fun-level fun))
	    (closure-p (fun-closure fun))
	    (fname (fun-name fun)))
	(unwind-exit
	 (list 'CALL-LOCAL fun lex-level closure-p
	       (if (eq args 'ARGS-PUSHED) 'ARGS-PUSHED (coerce-locs (inline-args args)))
	       narg fname))
	(close-inline-blocks)))))

(defun wt-call-local (fun lex-lvl closure-p args narg fname)
  (declare (fixnum lex-lvl))
  (cond ((not (eq args 'ARGS-PUSHED))
	 ;; if NARG is non-NIL it is location containing narg
	 (wt fun "(" (or narg (length args)))
	 (when (plusp lex-lvl)
	   (dotimes (n lex-lvl)
	     (wt ",lex" n)))
	 (when closure-p
	   ;; env of local fun is ALWAYS contained in current env (?)
	   (wt ", env" *env-lvl*))
	 (dolist (arg args)
	   (wt "," arg))
	 (wt ")"))
	((not narg)
	 ;; When getting arguments from lisp stack, a location with the number
	 ;; of arguments must have been supplied
	 (baboon))
	((not (or (plusp lex-lvl) closure-p))
	 (wt "APPLY(" narg "," fun "," `(STACK-POINTER ,narg) ")"))
	(t
	 (wt "(")
	 (when (plusp lex-lvl)
	   (dotimes (n lex-lvl)
	     (wt "cl_stack_push(lex" n ")," narg "++,")))
	 (when closure-p
	   (wt "cl_stack_push(env" *env-lvl* ")," narg "++,"))
	 (wt-nl "  APPLY(" narg "," fun "," `(STACK-POINTER ,narg) "))")))
  (when fname (wt-comment fname)))


;;; ----------------------------------------------------------------------

(put-sysprop 'FLET 'C1SPECIAL 'c1flet)
(put-sysprop 'LABELS 'C1SPECIAL 'c1labels)
(put-sysprop 'LOCALLY 'C1SPECIAL 'c1locally)
(put-sysprop 'MACROLET 'C1SPECIAL 'c1macrolet)
(put-sysprop 'SYMBOL-MACROLET 'C1SPECIAL 'c1symbol-macrolet)

(put-sysprop 'LOCALS 'c2 'c2locals)	; replaces both c2flet and c2lables
;;; c2macrolet is not defined, because MACROLET is replaced by PROGN
;;; during Pass 1.
(put-sysprop 'CALL-LOCAL 'C2 'c2call-local)

(put-sysprop 'CALL-LOCAL 'WT-LOC #'wt-call-local)
