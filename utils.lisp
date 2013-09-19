;;;; utils.lisp

(in-package #:cl-oneliner)

(defun hashcount (string)
  (let ((hc (make-hash-table :test 'equal))
        (words (split-sequence #\Space string)))
    (dolist (w words)
      (let ((low (string-downcase (regex-replace-all "[!-@]" w ""))))
        (if (gethash low hc)
            (incf (gethash low hc))
            (setf (gethash low hc) 1))))
    hc))

(defun hash-to-alist (hash)
  (loop for val being the hash-values of hash
     and key being the hash-keys of hash
     collect (cons key val)))

(defun most-frequent (hash)
  (let ((alist (hash-to-alist hash)))
    (car (reduce (lambda (x y) (if (> (cdr x) (cdr y)) x y )) alist))))

;;; Custom data structure for hash count
;;; An Alist where the value is another Alist, which holds count and next
;;; -----------------
;;; ((wordA (count . 3)
;;;         (next (wordB . 3)))
;;;  (wordB (count . 5)
;;;         (next (wordC . 2)
;;;               (wordD . 3))))
;;; -----------------
;;; This example shows a hashcount of words, and the word occurance of the words after the word
;;;  - wordA occured 3 times, always followed by wordB
;;;  - wordB occured 5 times, two times followed by wordC and three times by wordD

(defun alist-count (string)
  "Given a string, return an Alist counting the words"
  (let ((words (words-sorted string)))
    (labels ((iter (words alist &optional (count 1))
               (if (null words) alist
                   (let ((word (car words))
                         (next (cadr words)))
                     (if (string= word next)
                         (iter (cdr words) alist (1+ count))
                         (iter (cdr words) (acons word `((count . ,count)) alist)))))))
      (iter words '()))))

(defun simplify-word (word)
  "Given a word, put it to lower-case and remove all symbols"
  (string-downcase (regex-replace-all "[!-@]" word "")))

(defun words-sorted (sentence)
  (sort
   (mapcar #'simplify-word
           (split-sequence #\Space sentence))
   #'string<))

(defun aval (key alist)
  "Given alist and key, return value"
  (cdr (assoc key alist :test #'equal)))

(defun get-count (word alist-count)
  "Given a word and an alist-count, return number of occurence"
  (cdar (aval word alist-count)))

(defun alist-most-frequent (alist-count)
  "Given an alist-count, return most frequent word"
  (car (reduce (lambda (x y) (if (> (cdadr x) (cdadr y)) x y )) alist-count))))
