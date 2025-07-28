;; 开启全局 Company 补全
(global-company-mode 1)
(setq company-minimum-prefix-length 1)
(setq company-idle-delay 0)

(setq tab-always-indent 'complete)

(package-install 'vertico)
(vertico-mode t)

(package-install 'orderless)
(setq completion-styles '(orderless))

(package-install 'marginalia)
(marginalia-mode t)

(package-install 'embark)

(setq prefix-help-command 'embark-prefix-help-command)

(package-install 'consult)

(use-package embark-consult
  :after (embark consult)   ;; 两个都加载后再启用集成功能
  :ensure t)

(eval-after-load
    'consult
  '(eval-after-load
       'embark
     '(progn
        (require 'embark-consult)
        (add-hook
         'embark-collect-mode-hook
         #'consult-preview-at-point-mode))))

(provide 'init-completion)
