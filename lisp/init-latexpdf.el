;; ===== LaTeX / AUCTeX 基础 =====
(use-package tex
  :ensure auctex
  :hook ((LaTeX-mode . TeX-PDF-mode)                 ; 默认生成 PDF
         (LaTeX-mode . TeX-source-correlate-mode)    ; 打开 synctex 正反向
         (LaTeX-mode . my/latex-hook))
  :config
  (setq TeX-parse-self t
        TeX-auto-save t
        TeX-source-correlate-method 'synctex
        TeX-source-correlate-start-server t          ; 起 server 给反向搜索用
        TeX-master t))                               ; 询问主文件

(defun my/latex-hook ()
  (turn-on-cdlatex)
  (turn-on-reftex))
(add-hook 'LaTeX-mode-hook 'my/latex-hook)
(add-hook 'latex-mode-hook 'my/latex-hook)

;; （可选）用包管理器安装 cdlatex，比手动 load-path 稳
(use-package cdlatex :ensure t :after tex)

(add-hook 'LaTeX-mode-hook #'auto-revert-mode)
;; ===== 选择 SumatraPDF 作为外部预览器 =====
;; 放在你的 init-latex.el 或 init.el 里
(when (eq system-type 'windows-nt)
  (setq TeX-view-program-list
        '(("SumatraPDF"
           "\"C:/Users/KevinCSQ/AppData/Local/SumatraPDF/SumatraPDF.exe\" \
-reuse-instance -forward-search %b %n %o")))
  (setq TeX-view-program-selection '((output-pdf "SumatraPDF"))))

(provide 'init-latexpdf)
