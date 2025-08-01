
(setq c-basic-offset 4)
;; 全局设置：用空格替代字面 Tab，宽度 4 列
(setq-default indent-tabs-mode nil
              tab-width 4)

;; 等待 cc-mode 加载完，再去掉它对 TAB 的专用绑定
(with-eval-after-load 'cc-mode)
  ;; 在 C/C++ 模式下，TAB 只做普通缩进（跳到下一个制表位或插入空格）
  ;;(define-key c-mode-map  (kbd "TAB") #'indent-for-tab-command)
  ;;(define-key c++-mode-map(kbd "TAB") #'indent-for-tab-command))

;; 指定 clang-format 可执行文件全路径
;; (setq clang-format-executable
;;       "C:/Users/KevinCSQ/AppData/Local/Programs/Python/Python310/Lib/site-packages/clang_format/data/bin/clang-format.exe")



(add-to-list 'exec-path (expand-file-name "bin" user-emacs-directory))
(use-package clang-format
  :ensure t
  :defer nil        ;; 立刻加载，不延迟
  :demand t         ;; 强制加载
  :config
  (setq clang-format-executable "clang-format.exe")
  :bind (("C-c f" . clang-format-buffer)))  ;; C-c f 一键整档

;; init.el / .emacs 中加：
(with-eval-after-load 'cc-mode
  ;; 子语句的 “{” 和 “}” 都不额外缩进
  (c-set-offset 'substatement-open 0)
  (c-set-offset 'block-close        0))

(provide 'init-style)
