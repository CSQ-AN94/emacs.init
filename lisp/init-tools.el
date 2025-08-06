
(require 'eglot)
(with-eval-after-load 'eglot
  ;; 忽略服务器提供的三种格式化功能
  (setq eglot-ignored-server-capabilities
        '(:documentFormattingProvider
          :documentRangeFormattingProvider
          :documentOnTypeFormattingProvider)))
(add-to-list 'eglot-server-programs '((c++-mode c-mode) "clangd"))
(add-hook 'c-mode-hook #'eglot-ensure)
(add-hook 'c++-mode-hook #'eglot-ensure)

(use-package quickrun
  :ensure t
  :commands (quickrun)
  :init
  (quickrun-add-command "c++/c1z"
    '((:command . "g++")
      (:exec . ("%c -std=c++1z %o -o %e %s"
                "%e %a"))
      (:remove . ("%e")))
    :default "c++"))

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


(pdf-loader-install)


(provide 'init-tools)
