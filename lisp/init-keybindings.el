;;; init.el -*- lexical-binding: t no-byte-compile: t -*-

;; (use-package which-key
;;   :hook (after-init . which-key-mode)
;;   :ensure t
;;   :init
;;   (setq which-key-side-window-location 'bottom))



;; 这一行代码，将函数 open-init-file 绑定到 <f2> 键上
(global-set-key (kbd "<f2>") 'open-init-file)

(global-set-key (kbd "<f1>") 'restart-emacs)

(global-set-key (kbd "C-/") #'undo-only)
(global-set-key (kbd "C-?") #'undo-redo)

;; 启用 CUA（含 Ctrl+C/X/V、Shift 选区、C-RET 矩形）
(cua-mode 0)
(with-eval-after-load 'evil
  ;; 插入/Emacs 模式进出时开关 CUA
  (add-hook 'evil-insert-state-entry-hook (lambda () (cua-mode +1)))
  (add-hook 'evil-emacs-state-entry-hook  (lambda () (cua-mode +1)))
  (add-hook 'evil-insert-state-exit-hook  (lambda () (cua-mode -1)))
  (add-hook 'evil-emacs-state-exit-hook   (lambda () (cua-mode -1)))
  (add-hook 'minibuffer-setup-hook (lambda () (cua-mode +1)))
  (add-hook 'minibuffer-exit-hook  (lambda () (cua-mode -1)))

  ;; **只在 Visual State 下** 用 C-c 来拷贝选区
  (define-key evil-visual-state-map (kbd "C-c") #'cua-copy-region))

;; 保留你之前对 C-z 的清除
(with-eval-after-load 'cua-base
  (define-key cua--cua-keys-keymap (kbd "C-z") nil))

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


(provide 'init-keybindings)
