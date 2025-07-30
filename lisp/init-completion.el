;; 开启全局 Company 补全
(global-company-mode 1)
(setq company-minimum-prefix-length 1)
(setq company-idle-delay 0)

(setq tab-always-indent 'complete)

(use-package vertico)
(vertico-mode t)

(use-package orderless)
(setq completion-styles '(orderless))

(use-package marginalia)
(marginalia-mode t)

(use-package embark)

(setq prefix-help-command 'embark-prefix-help-command)

(use-package consult)

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
