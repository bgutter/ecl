;;;;  Copyright (c) 1992, Giuseppe Attardi.
;;;;
;;;;    This program is free software; you can redistribute it and/or
;;;;    modify it under the terms of the GNU Library General Public
;;;;    License as published by the Free Software Foundation; either
;;;;    version 2 of the License, or (at your option) any later version.
;;;;
;;;;    See file '../Copyright' for full details.

(in-package "CLOS")

;;; ----------------------------------------------------------------------
;;; Load forms
;;;

(defun make-load-form-saving-slots (object &key slot-names environment)
  (declare (ignore environment))
  (do* ((class (class-of object))
	(initialization (list 'progn))
	(slots (class-slots class) (cdr slots)))
      ((endp slots)
       (values `(allocate-instance ,class) (nreverse initialization)))
    (let* ((slot (first slots))
	   (slot-name (slotd-name slot)))
      (when (or (and (null slot-names)
		     (eq (slotd-allocation slot) :instance))
		(member slot-name slot-names))
	(push (if (slot-boundp object slot-name)
		  `(setf (slot-value ,object ',slot-name)
			 ',(slot-value object slot-name))
		  `(slot-makunbound ,object ',slot-name))
	      initialization)))))

(defmethod make-load-form ((object standard-object) &optional environment)
  (make-load-form-saving-slots object))

(defmethod make-load-form ((class class) &optional environment)
  (let ((name (class-name class)))
    (if (and name (eq (find-class name) class))
	`(find-class ',name)
	(error "Cannot externalize anonymous class ~A" class))))

;;; ----------------------------------------------------------------------
;;; Printing
;;; ----------------------------------------------------------------------

(defmethod print-object ((instance t) stream)
  (print-unreadable-object (instance stream)
	(format stream "a ~A"
		(class-name (si:instance-class instance))))
  instance)

(defmethod print-object ((class class) stream)
  (print-unreadable-object (class stream)
	(format stream "The ~A ~A"
		(class-name (si:instance-class class)) (class-name class)))
  class)

(defmethod print-object ((gf standard-generic-function) stream)
  (print-unreadable-object (gf stream :type t)
    (prin1 (generic-function-name gf) stream))
  gf)

(defmethod print-object ((m standard-method) stream)
  (print-unreadable-object (m stream :type t)
    (format stream "~A ~A" (generic-function-name (method-generic-function m))
	    (method-specializers m)))
  m)


;;; ----------------------------------------------------------------------
;;; Describe
;;; ----------------------------------------------------------------------

(defmethod describe-object ((obj t) &optional (stream t))
  (let* ((class (class-of obj))
	 (slotds (class-slots class)))
    (format stream "~%~A is an instance of class ~A"
	    obj (class-name class))
    (do ((scan slotds (cdr scan))
	 (i 0 (1+ i))
	 (sv))
	((null scan))
	(declare (fixnum i))
	(setq sv (si:instance-ref obj i))
	(print (slotd-name (car scan)) stream) (princ ":	" stream)
	(if (si:sl-boundp sv)
	    (prin1 sv stream)
	  (prin1 "Unbound" stream))))
  obj)

(defmethod describe-object ((obj class) &optional (stream t))
  (let* ((class  (si:instance-class obj))
	 (slotds (class-slots class)))
    (format stream "~%~A is an instance of class ~A"
	    obj (class-name class))
    (do ((scan slotds (cdr scan))
	 (i 0 (1+ i))
	 (sv))
	((null scan))
	(declare (fixnum i))
	(print (slotd-name (car scan)) stream) (princ ":	" stream)
	(case (slotd-name (car scan))
	      ((superiors inferiors)
	       (princ "(" stream)
	       (do* ((scan (si:instance-ref obj i) (cdr scan))
		     (e (car scan) (car scan)))
		    ((null scan))
		    (prin1 (class-name e) stream)
		    (when (cdr scan) (princ " " stream)))
	       (princ ")" stream))
	      (otherwise 
	       (setq sv (si:instance-ref obj i))
	       (if (si:sl-boundp sv)
		   (prin1 sv stream)
		 (prin1 "Unbound" stream))))))
  obj)

;;; ----------------------------------------------------------------------
