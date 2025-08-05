
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


;; pdf tools
(use-package pdf-tools
  :ensure t
  :init
  (pdf-loader-install))
  (add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1)))

(defun pdf-view-kill-rmn-ring-save ()
  "Copy the region to the `kill-ring' after remove all newline characters."
  (interactive)
  (pdf-view-assert-active-region)
  (let* ((txt (replace-regexp-in-string "\n" " "
        (car (pdf-view-active-region-text)))))
    (pdf-view-deactivate-region)
	(kill-new txt)))

(use-package pdf-view-mode
  :bind
  ("C-c C-w" . pdf-view-kill-rmn-ring-save))

;;LaTex
(use-package auctex
  :ensure t
  :defer t
  :hook ((LaTeX-mode . turn-on-reftex)    ;; 同时启动 RefTeX
         (LaTeX-mode . flyspell-mode)     ;; 拼写检查
         (LaTeX-mode . visual-line-mode)) ;; 折行显示
  :config
  (setq TeX-auto-save t
        TeX-parse-self t
        TeX-save-query nil
        TeX-PDF-mode t)                   ;; 默认生成 PDF
  ;; 使用 PDF Tools 打开输出
  (setq TeX-view-program-selection '((output-pdf "PDF Tools")))
  (setq TeX-source-correlate-method 'synctex)
  (add-hook 'TeX-after-compilation-finished-functions
            #'TeX-revert-document-buffer))

(provide 'init-tools)
