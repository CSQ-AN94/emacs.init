;;; init.el -*- lexical-binding: t no-byte-compile: t -*-

;; (use-package which-key
;;   :hook (after-init . which-key-mode)
;;   :ensure t
;;   :init
;;   (setq which-key-side-window-location 'bottom))



;; 这一行代码，将函数 open-init-file 绑定到 <f2> 键上
(global-set-key (kbd "<f2>") 'open-init-file)

(global-set-key (kbd "<f1>") 'restart-emacs)

;;; 让复制/粘贴直连系统剪贴板
(setq select-enable-clipboard t)

;;; 默认不启用 CUA，由各个 state 钩子来控制
(cua-mode 0)
;; 开启 CUA 的按键接管（在开启时，裸 C-x/C-c/C-v/C-z 像系统一样用）
(setq cua-enable-cua-keys t)

(with-eval-after-load 'evil
  ;; 进入这些场景时开启 CUA；离开时关闭（避免 normal/visual 常驻）
  (add-hook 'evil-insert-state-entry-hook (lambda () (cua-mode 1)))
  (add-hook 'evil-emacs-state-entry-hook  (lambda () (cua-mode 1)))
  (add-hook 'minibuffer-setup-hook        (lambda () (cua-mode 1)))

  (add-hook 'evil-insert-state-exit-hook  (lambda () (cua-mode -1)))
  (add-hook 'evil-emacs-state-exit-hook   (lambda () (cua-mode -1)))
  (add-hook 'minibuffer-exit-hook         (lambda () (cua-mode -1)))

  ;; 让 CUA 的系统手势也走 undo-tree（不改变你 CUA 何时开关）
 (with-eval-after-load 'cua-base
  (define-key cua--cua-keys-keymap (kbd "C-z")   #'undo-tree-undo)
  (define-key cua--cua-keys-keymap (kbd "C-y")   #'undo-tree-redo)
  (define-key cua--cua-keys-keymap (kbd "C-S-z") #'undo-tree-redo))

  ;; Visual state：不整体开 CUA，但让选区里的 C-x/C-c 走“系统剪切/复制”
  ;; （不会影响 C-x 前缀命令，因为这里只有有选区时才会用得到）
  (define-key evil-visual-state-map (kbd "C-x") #'cua-cut-region)
  (define-key evil-visual-state-map (kbd "C-c") #'cua-copy-region)

  ;; 如果还想在 Visual 里用 C-v 粘贴（可选）：
  ;; (define-key evil-visual-state-map (kbd "C-v") #'cua-paste)
)

(global-set-key (kbd "C-z")   #'undo-tree-undo)
(global-set-key (kbd "C-y")   #'undo-tree-redo)
(global-set-key (kbd "C-S-z") #'undo-tree-redo)

(defun csq/evil-toggle-emacs-state ()
    "在 Evil 中用 C-/ 在 emacs-state 与 normal-state 之间切换。"
    (interactive)
    (if (evil-emacs-state-p)
        (evil-normal-state)
      (evil-emacs-state)))

;; --- Evil：C-/ 切换 emacs-state；C-y 作为 redo（不再滚动） ---
(with-eval-after-load 'evil
  (defun csq/evil-toggle-emacs-state ()
    (interactive)
    (if (evil-emacs-state-p) (evil-normal-state) (evil-emacs-state)))

  ;; 先取消 Evil 自带的 C-y 上滚，避免抢键
  (define-key evil-motion-state-map (kbd "C-y") nil)

  ;; 在所有常见 state 里统一绑定
  (let ((maps (list evil-normal-state-map
                    evil-insert-state-map
                    evil-visual-state-map
                    evil-replace-state-map
                    evil-motion-state-map
                    evil-emacs-state-map)))
    (dolist (m maps)
      (define-key m (kbd "C-/")   #'csq/evil-toggle-emacs-state) ; 切换 emacs-state
      (define-key m (kbd "C-z")   #'undo-tree-undo)              ; 撤销
      (define-key m (kbd "C-y")   #'undo-tree-redo)              ; 恢复
      (define-key m (kbd "C-S-z") #'undo-tree-redo))))           ; 恢复

(with-eval-after-load 'evil
  (defun csq/evil-visual-backspace ()
    "在 Visual state：若有选区则直接删除选区（不入寄存器），
若无选区则后退删一个字符。"
    (interactive)
    (if (use-region-p)
        (progn
          (delete-region (region-beginning) (region-end)) ; 不 yank
          (evil-normal-state))                            ; 回到 normal（符合直觉）
      (backward-delete-char-untabify 1)))

  (define-key evil-visual-state-map (kbd "DEL")         #'csq/evil-visual-backspace)
  (define-key evil-visual-state-map (kbd "<backspace>") #'csq/evil-visual-backspace))


(global-set-key (kbd "M-[") #'scroll-down-command)
(global-set-key (kbd "M-]") #'scroll-up-command)

(global-set-key (kbd "C-h C-f") 'find-function)
(global-set-key (kbd "C-h C-v") 'find-variable)
(global-set-key (kbd "C-h C-k") 'find-function-on-key)

(global-set-key (kbd "<f5>") 'quickrun)

(global-set-key (kbd "C-;") 'embark-act)

(global-set-key (kbd "C-s") 'consult-line)

;; ;; company mode 默认选择上一条和下一条候选项命令 M-n M-p
;; (define-key company-active-map (kbd "C-n") 'company-select-next)
;; (define-key company-active-map (kbd "C-p") 'company-select-previous)

(global-set-key (kbd "C-x b") 'consult-buffer)

;; 这个快捷键绑定可以用之后的插件 counsel 代替
(global-set-key (kbd "C-x C-r") 'recentf-open-files)

(define-key minibuffer-local-map (kbd "C-c C-e") #'embark-export-write)

(global-set-key (kbd "C-c p f") 'project-find-file)
(global-set-key (kbd "C-c p s") 'consult-ripgrep)

(with-eval-after-load 'corfu
  (define-key corfu-map (kbd "RET") nil)
  (define-key corfu-map (kbd "<return>") nil))


(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c C-c") 'org-toggle-checkbox))

(evil-define-key 'normal dired-mode-map
    (kbd "<RET>") 'dired-find-alternate-file
    (kbd "C-k") 'dired-up-directory
    "`" 'dired-open-term
    "q" 'quit-window
    "o" 'dired-find-file-other-window
     ;;"s" 'hydra-dired-quick-sort/body
     ;;"z" 'dired-get-size
     ;;"!" 'zilongshanren/do-shell-and-copy-to-kill-ring
     ")" 'dired-omit-mode)

(use-package general
  :init
  (with-eval-after-load 'evil
    (general-add-hook 'after-init-hook
                      (lambda (&rest _)
                        (when-let ((messages-buffer (get-buffer "*Messages*")))
                          (with-current-buffer messages-buffer
                            (evil-normalize-keymaps))))
                      nil
                      nil
                      t))


  (general-create-definer global-definer
    :keymaps 'override
    :states '(insert emacs normal hybrid motion visual operator)
    :prefix "SPC"
    :non-normal-prefix "C-SPC")

  (defmacro +general-global-menu! (name infix-key &rest body)
    "Create a definer named +general-global-NAME wrapping global-definer.
Create prefix map: +general-global-NAME. Prefix bindings in BODY with INFIX-KEY."
    (declare (indent 2))
    `(progn
       (general-create-definer ,(intern (concat "+general-global-" name))
         :wrapping global-definer
         :prefix-map ',(intern (concat "+general-global-" name "-map"))
         :infix ,infix-key
         :wk-full-keys nil
         "" '(:ignore t :which-key ,name))
       (,(intern (concat "+general-global-" name))
        ,@body)))

  (general-create-definer global-leader
    :keymaps 'override
    :states '(emacs normal hybrid motion visual operator)
    :prefix ","
    "" '(:ignore t :which-key (lambda (arg) `(,(cadr (split-string (car arg) " ")) . ,(replace-regexp-in-string "-mode$" "" (symbol-name major-mode)))))))

(use-package general
  :init
  (global-definer
    "!" 'shell-command
    "s"  'shell
    "SPC" 'execute-extended-command
    "'" 'vertico-repeat
    "+" 'text-scale-increase
    "-" 'text-scale-decrease
    "v" 'er/expand-region
    "u" 'universal-argument
    "hdf" 'describe-function
    "hdv" 'describe-variable
    "hdk" 'describe-key
    )

  (+general-global-menu! "buffer" "b"
    "d" 'kill-current-buffer
    "b" '(consult-buffer :which-key "consult buffer")
    "B" 'switch-to-buffer
    "p" 'previous-buffer
    "R" 'rename-buffer
    "M" '((lambda () (interactive) (switch-to-buffer "*Messages*"))
          :which-key "messages-buffer")
    "n" 'next-buffer
    "i" 'ibuffer
    "f" 'my-open-current-directory
    "k" 'kill-buffer
    "y" 'copy-buffer-name
    "K" 'kill-other-buffers))

(with-eval-after-load 'evil
  (dolist (map '(evil-normal-state-map evil-insert-state-map evil-visual-state-map
                                       evil-emacs-state-map evil-replace-state-map evil-operator-state-map))
(define-key (symbol-value map) (kbd "C-, m") #'evil-motion-state))
(define-key evil-motion-state-map (kbd "C-, m") #'evil-normal-state))

(with-eval-after-load 'evil
  ;; 解绑 Evil 各种状态下的 C-u
  (define-key evil-normal-state-map  (kbd "C-u") nil)
  (define-key evil-visual-state-map  (kbd "C-u") nil)
  (define-key evil-motion-state-map  (kbd "C-u") nil)
  ;; （如果你还想在 Emacs 原生状态里也能用 C-u，就绑定 universal-argument）
  (define-key evil-emacs-state-map   (kbd "C-u") 'universal-argument))


(provide 'init-keybindings)
