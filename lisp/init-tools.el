
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



(provide 'init-tools)
