;; 开启全局 Company 补全
;; (global-company-mode 1)
;; (setq company-minimum-prefix-length 1)
;; (setq company-idle-delay 0)
(use-package corfu
  :init
  (progn
    (setq corfu-auto t)
    (setq corfu-cycle t)
    (setq corfu-quit-at-boundary t)
    (setq corfu-quit-no-match t)
    (setq corfu-preview-current nil)
    (setq corfu-min-width 80)
    (setq corfu-max-width 100)
    (setq corfu-auto-delay 0.2)
    (setq corfu-auto-prefix 1)
    (setq corfu-on-exact-match nil)
    (global-corfu-mode)
    ))

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
