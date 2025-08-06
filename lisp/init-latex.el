 (defun my/latex-hook ()
    (turn-on-cdlatex)
    (turn-on-reftex))

  (use-package tex
    :ensure auctex
    ;; 若使用 straight, 注释前一行, 并取消下一行注释:
    ;; :straight auctex
    :custom
    (TeX-parse-self t) ; 自动解析 tex 文件
    (TeX-PDF-mode t)
    (TeX-DVI-via-PDFTeX t)
    :config
    (setq-default TeX-master t) ; 默认询问主文件
    (add-hook 'LaTeX-mode-hook 'my/latex-hook)) ; 加载LaTeX模式钩子

  (use-package cdlatex
    :after tex ; 保证 cdlatex 在 auctex 之后加载
    :load-path "cdlatex/" ; 需要手动从网盘或 https://github.com/cdominik/cdlatex/blob/master/cdlatex.el 下载 cdlatex.el 文件, 并置于 ~/.emacs.d/cdlatex/ 文件夹下
    )


(provide 'init-latex)
