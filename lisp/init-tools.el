;;; init-tools.el --- something -*- lexical-binding: t; -*-

(use-package expand-region
  :config
  (define-advice er/prepare-for-more-expansions-internal
  (:around (orig-fun &rest args) helm-ag/prepare-for-more-expansions-internal)
  (let* ((ret (apply orig-fun args))
         (new-msg (concat (car ret)
                          ", H to highlight in buffers"
                          ", / to search in project, "
                          "e iedit mode in functions"
                          "f to search in files, "
                          "b to search in opened buffers"))
         (new-bindings (cdr ret)))
    (cl-pushnew '("H" (lambda () (interactive) (call-interactively #'zilongshanren/highlight-dwim)))
                new-bindings :test #'equal)
    (cl-pushnew '("/" (lambda () (interactive) (call-interactively #'my/search-project-for-symbol-at-point)))
                new-bindings :test #'equal)
    (cl-pushnew '("e" (lambda () (interactive) (call-interactively #'evil-multiedit-match-all)))
                new-bindings :test #'equal)
    (cl-pushnew '("f" (lambda () (interactive) (call-interactively #'find-file)))
                new-bindings :test #'equal)
    (cl-pushnew '("b" (lambda () (interactive) (call-interactively #'consult-line)))
                new-bindings :test #'equal)
    (cons new-msg new-bindings))))

(use-package gcmh
  :ensure t
  :init (gcmh-mode 1))

;; 用 gcmh，把 GC 挪到空闲时
(use-package gcmh
  :ensure t
  :init
  (setq gcmh-idle-delay 2.0                  ; 空闲≥2s再 GC
        gcmh-high-cons-threshold (* 128 1024 1024)) ; 交互期阈值=128MB
  (gcmh-mode 1))

;; 避免“保存时刚好触发大GC”：保存前先小扫一下
(add-hook 'before-save-hook #'garbage-collect)

;; 失焦也扫一下（把停顿藏到后台）
(add-function :after after-focus-change-function
              (lambda () (unless (frame-focus-state) (garbage-collect))))


(defun zilongshanren/evil-quick-replace (beg end )
  (interactive "r")
  (when (evil-visual-state-p)
    (evil-exit-visual-state)
    (let ((selection (regexp-quote (buffer-substring-no-properties beg end))))
      (setq command-string (format "%%s /%s//g" selection))
      (minibuffer-with-setup-hook
          (lambda () (backward-char 2))
        (evil-ex command-string)))))

(define-key evil-visual-state-map (kbd "C-r") 'zilongshanren/evil-quick-replace)

(defun zilongshanren/highlight-dwim ()
  (interactive)
  (if (use-region-p)
      (progn
        (highlight-frame-toggle)
        (deactivate-mark))
    (symbol-overlay-put)))

(defun zilongshanren/clearn-highlight ()
  (interactive)
  (clear-highlight-frame)
  (symbol-overlay-remove-all))

(use-package symbol-overlay
  :config
  (define-key symbol-overlay-map (kbd "h") 'nil))

(use-package highlight-global
  :ensure nil
  :commands (highlight-frame-toggle)
  :quelpa (highlight-global :fetcher github :repo "glen-dai/highlight-global")
  :config
  (progn
    (setq-default highlight-faces
                  '(('hi-red-b . 0)
                    ('hi-aquamarine . 0)
                    ('hi-pink . 0)
                    ('hi-blue-b . 0)))))



(provide 'init-tools)
