(defpackage health-parser
  (:use :cl))
(in-package :health-parser)

(defparameter *xlsx* #P"/home/brandon/Downloads/Combined Categories for Python DB.xlsx")
(defparameter *xlsx-sheet-contents* (cl-xlsx:read-xlsx *xlsx*))
(defvar *db* nil)
(defvar *availability* 0) ;; todo make these params for constistancy
(defvar *type* 1)
(defvar *hidden-category* 2)
(defvar *hidden-subcategory* 3)
(defvar *visible-category* 4)
(defvar *extension-codes* 5)

(defun select-sheet (sheet-name)
  "Return a list of lists of sheet data given a SHEET-NAME."
  (cdr (assoc sheet-name *xlsx-sheet-contents* :test #'string=)))

(defun rnest-categories (extension-data availability)
  (let (hidden-categories hidden-subcategories visible-categories (visible-cat-stash '()))
    (setq hidden-categories (map 'list #'(lambda (x) (nth *hidden-category* x)) extension-data)) ;; these can probably be optimized with apply?
    (setq hidden-subcategories (map 'list #'(lambda (x) (nth *hidden-subcategory* x)) extension-data))
    (setq visible-categories (map 'list #'(lambda (x) (nth *visible-category* x)) extension-data))
  (dotimes (i (length visible-categories))
    (cond
      ((and (nth i hidden-subcategories) (nth i hidden-categories) (nth i visible-categories))
       (progn (push (nth i visible-categories) visible-cat-stash) (print visible-cat-stash) (setq visible-cat-stash '()))) ;; visible cat and hidden subcat and hidden cat
      ((and (nth i hidden-subcategories) (nth i visible-categories))
       (progn (push (nth i visible-categories) visible-cat-stash) (print visible-cat-stash) (setq visible-cat-stash '()))) ;; visible cat and hidden subcat
      ((and (nth i hidden-categories) (nth i visible-categories))
       (progn (push (nth i visible-categories) visible-cat-stash) (print visible-cat-stash) (setq visible-cat-stash '()))) ;; visible cat and hidden subcat
      ((nth i visible-categories) (push (nth i visible-categories) visible-cat-stash))))))

  ;; if only visible cat, make visible cat and stash
  ;; if visible cat and hidden subcat, make visible cat add to stash, then make hidden subcat and add that stash, then clear stash
  ;; if visible cat and hidden subcat and hidden cat make visible cat add to stash, then make hidden subcat and add that stash, then make hidden cat and save hidden subcat to it, then clear stash
  ;; if hidden cat and visible cat, make visible cat add to stash and make hidden cat and add stash, clear stash

(defun test ()
  (let
      ((extension nil)
       (extension-data '())
       (tag-data '()))
    (dolist (ss (select-sheet "Health"))
      (cond
	((and (string-equal (nth *type* ss) "Extension") (equalp extension nil))
	 (progn
	   (setq extension t)
	   (setq extension-data '()))) ;; Start watching
	((and (string-equal (nth *type* ss) "Extension") (equalp extension t))
	 (progn
	   (setq extension nil) (rnest-categories extension-data (nth *availability* ss)) (setq extension-data '())))) ;; Summarize data 
      (if (string-equal (nth *type* ss) "Extension") ;; After summary and saving data form, if extension, turn back t
	  (setq extension t))
      (if (equalp extension t)
	  (push ss extension-data)))
    (if extension-data (rnest-categories extension-data "Both")))) ;; is still data push it
