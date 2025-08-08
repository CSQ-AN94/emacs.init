;;(pdf-tools-install)

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

  (setq TeX-source-correlate-mode t) ;; 编译后开启正反向搜索
  (setq TeX-source-correlate-method 'synctex) ;; 正反向搜索的执行方式
  (setq TeX-source-correlate-start-server t) ;; 不再询问是否开启服务器以执行反向搜索

  (use-package cdlatex
    :after tex ; 保证 cdlatex 在 auctex 之后加载
    :load-path "cdlatex/" ; 需要手动从网盘或 https://github.com/cdominik/cdlatex/blob/master/cdlatex.el 下载 cdlatex.el 文件, 并置于 ~/.emacs.d/cdlatex/ 文件夹下
    )

  (setq TeX-view-program-list
   '(("Sumatra PDF" ("\"C:/Program Files/SumatraPDF/SumatraPDF.exe\" -reuse-instance" (mode-io-correlate " -forward-search %b %n ") " %o"))))
  (assq-delete-all (quote output-pdf) TeX-view-program-selection)
  (add-to-list 'TeX-view-program-selection '(output-pdf "Sumatra PDF"))

;;   (setq TeX-view-program-selection '((output-pdf "PDF Tools"))) ;; 用pdf-tools 打开 pdf
;;   (add-hook 'TeX-after-compilation-finished-functions
;;             #'TeX-revert-document-buffer) ;; 在完成编译后刷新 pdf 文件

;; (define-key pdf-view-mode-map
;;             "d" 'pdf-view-next-page-command) ;; 向后翻页
;; (define-key pdf-view-mode-map
;;             "a" 'pdf-view-previous-page-command) ;; 向前翻页
;; (define-key pdf-view-mode-map
;;             "s" 'pdf-view-scroll-up-or-next-page) ;; 向下滑动
;; (define-key pdf-view-mode-map
;;             "w" 'pdf-view-scroll-down-or-previous-page) ;; 向上滑动

;;   (require 'pdf-annot)
;;   (define-key pdf-annot-minor-mode-map (kbd "C-a a") 'pdf-annot-add-highlight-markup-annotation) ;; 高亮
;;   (define-key pdf-annot-minor-mode-map (kbd "C-a s") 'pdf-annot-add-squiggly-markup-annotation) ;; 波浪线
;;   (define-key pdf-annot-minor-mode-map (kbd "C-a u") 'pdf-annot-add-underline-markup-annotation) ;; 下划线
;;   (define-key pdf-annot-minor-mode-map (kbd "C-a d") 'pdf-annot-delete) ;; 删除

(provide 'init-latex)
