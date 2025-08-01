;;; init-gdb.el --- something -*- lexical-binding: t; -*-


;; 依赖：clangd 或 gcc/g++ + gdb 已安装（Windows 可用 MSYS2 的 mingw64-gdb）
(use-package lsp-mode
  :ensure t
  :hook ((c-mode c++-mode) . lsp-deferred)
  :custom (lsp-prefer-flymake nil))

(use-package lsp-ui :ensure t :commands lsp-ui-mode)

(use-package dap-mode
  :ensure t
  :after lsp-mode
  :init
  (setq dap-auto-configure-features '(sessions locals controls tooltip))
  :config
  (dap-ui-mode 1)
  (dap-tooltip-mode 1)
  (require 'dap-gdb-lldb)     ;; 直接走 gdb/lldb
  (require 'dap-cpptools)     ;; VS Code 的 cpptools 适配（可选）
  (dap-ui-controls-mode 1)

  ;; VS Code 风格快捷键
  (define-key dap-mode-map [f5]  #'dap-continue)        ; F5 运行/继续
  (define-key dap-mode-map [f9]  #'dap-breakpoint-toggle) ; F9 断点
  (define-key dap-mode-map [f10] #'dap-next)            ; F10 下一步
  (define-key dap-mode-map [f11] #'dap-step-in)         ; F11 进入
  (define-key dap-mode-map [(shift f11)] #'dap-step-out) ; Shift+F11 跳出
  (define-key dap-mode-map [(shift f5)] #'dap-disconnect) ; Shift+F5 停止

  ;; 启动/停止时自动弹出/收起 VS Code 式面板
  (add-hook 'dap-stopped-hook (lambda (_args) (dap-ui-show-many-windows t)))
  (add-hook 'dap-terminated-hook (lambda (_args) (dap-ui-hide-many-windows))))



(provide 'init-gdb)
