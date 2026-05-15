;;; ttml.el -*- lexical-binding: t; -*-

(require 'org)


(defgroup ttml nil
  "Daily review popup."
  :group 'convenience)

(defcustom ttml-directory nil
  "Directory containing files to review."
  :type 'directory)

(defcustom ttml-count 5
  "Number of files to review per day."
  :type 'integer)


(defcustom ttml-file-regexp "_english_word\\|_word_english"
  "Regexp used to match filenames."
  :type 'regexp)

(defcustom ttml-buffer-name "*ttml*"
  "Buffer name used for the vocab popup."
  :type 'string)

(defcustom ttml-window-side nil
  "Side where the vocab popup appears."
  :type '(choice (const right) (const left) (const bottom) (const top)))

(defcustom ttml-window-size nil
  "Popup window width/height fraction."
  :type 'number)

(defun ttml--today-seed ()
   (format-time-string "%Y%m%d"))

(defun ttml--files ()
  (directory-files ttml-directory t ttml-file-regexp))


(defun ttml--title-from-file (file)
  (if (fboundp 'denote-retrieve-filename-title)
      (denote-retrieve-filename-title file)
    (file-name-base file)))

(defun ttml-todays-alist ()
  "Return today's vocab alist (WORD . FILE)."
  (let* ((files (ttml--files))
         (result '()))
    (random (ttml--today-seed))
    (while (< (length result) ttml-count)
      (let* ((file (nth (random (length files)) files))
             (word (ttml--title-from-file file)))
        (unless (assoc word result)
          (push (cons word file) result))))
    (nreverse result)))

(defun ttml--insert-alist (alist)
  (dolist (entry alist)
    (insert (format "- [[file:%s][%s]]\n"
                    (expand-file-name (cdr entry))
                    (car entry)))))

(defun ttml-show ()
  "Show today's vocab words."
  (interactive)
  (let ((buf (get-buffer-create ttml-buffer-name))
        (alist (ttml-todays-alist)))
    (with-current-buffer buf
      (setq buffer-read-only nil)
      (erase-buffer)
      (ttml--insert-alist alist)
      (org-mode)
      (read-only-mode 1)
      (goto-char (point-min)))
    (display-buffer
     buf
     `((display-buffer-in-side-window)
       (side . ,ttml-window-side)
       ,(if (memq ttml-window-side '(left right))
            `(window-width . ,ttml-window-size)
          `(window-height . ,ttml-window-size))))))


(provide 'ttml)

;;; ttml.el ends here
