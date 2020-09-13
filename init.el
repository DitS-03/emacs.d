; <Leaf-install-code
(eval-and-compile
  (customize-set-variable
   'package-archives '(("org" . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu" . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init (leaf hydra :ensure t)
          (leaf el-get :ensure t)
          (leaf blackout :ensure t)
          :config (leaf-keywords-init))

  (leaf leaf-tree :ensure t)
  (leaf leaf-convert :ensure t)
  (leaf transient-dwim
    :ensure t
    :bind (("M-=" . transient-dwim-dispatch))))
;; </leaf-install-code>


(leaf-keys (("C-h"     . backward-delete-char)
            ("C-c ;"   . comment-region)
            ("C-c M-;" . uncomment-region)
            ("C-/"     . undo)
            ("M-p"     . scroll-down)
            ("M-n"     . scroll-up)
            ("C-c r"   . replace-string)
            ("M-l"     . other-window)))
           
(leaf cus-start
  :doc "define customization properties of builtins"
  :tag "builtin" "internal"
  :custom ((user-full-name . "dtis")
           (user-mail-address . "dits.3rd@gmail.com")
           (user-login-name . "dits")
           (make-backup-files . nil)
           (read-file-name-completion-ignore-case . t)
           (menu-bar-mode . nil)
           (tool-bar-mode . nil)
           (scroll-bar-mode . nil)
           (indent-tabs-mode . nil)))

(leaf *display-line-numbers-mode
  :config (progn
             (global-display-line-numbers-mode)
             (set-face-attribute 'line-number-current-line nil
                                 :foreground "gold")))

(leaf autorevert
  :custom ((auto-revert-interval . 0.1))
  :global-minor-mode global-auto-revert-mode)

(leaf elpy
  :hook (python-mode)
  :custom ((elpy-rpc-python-command . "python3")
           (elpy-rpc-virtualenv-path . `current))
  :config (elpy-enable))

(leaf company
  :bind ((:company-active-map
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)
          ("C-s" . company-filter-candidates)
          ("C-f" . company-complete-selection)
          ("C-i" . company-complete-selection)
          ("<tab>" . company-complete-selection))
         (:company-search-map
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)))
  :custom ((company-transformers . '(company-sort-by-backend-importance))
           (company-idle-delay . 0)
           (company-minimum-prefix-length . 3)p
           (company-selection-wrap-around . t) 
           (completion-ignore-case . t)
           (company-dabbrev-downcase . nil))
  :config (global-company-mode))

(leaf rustic
  :custom ((rustic-format-trigger . 'on-save)
           (rustic-lsp-server . 'rust-analyzer)))

(leaf lsp-ui
  :hook (lsp-ui-mode))
              
(leaf imenu-list
  :bind (("C-v" . imenu-list-smart-toggle))
  :custom ((imenu-list-focus-after-activation . t)))

(leaf anzu
  :config (global-anzu-mode))

(leaf doom-themes
  :custom ((doom-themes-enable-italic . t)
           (doom-themes-enable-bold . t))
  :config (load-theme 'doom-dracula t)
          (doom-themes-neotree-config)
          (doom-themes-org-config))

(leaf all-the-icons
  :custom (all-the-icons-scale-factor . 1.0))

(leaf neotree
  :hook    (neotree-show neotree-hide neotree-dir neotree-find)
  :custom  ((neo-theme . 'icons))
  :bind    (("C-t" . neotree-projectile-toggle))
  :preface
  (defun neotree-projectile-toggle ()
    (interactive)
    (let ((project-dir
           (ignore-errors (projectile-project-root)))
          (file-name (buffer-file-name))
          (neo-smart-open t))
      (if (and (fboundp 'neo-global--window-exists-p)
               (neo-global--window-exists-p))
        (neotree-hide)
        (progn
          (neotree-show)
          (if project-dir
              (neotree-dir project-dir))
          (if file-name
              (neotree-find file-name)))))))

(leaf plantuml
  :mode   "\\.pu\\'" ;"\\.org\\'"
  :custom ((plantuml-jar-path . "/usr/local/Cellar/plantuml/1.2020.16/libexec/plantuml.jar")
           (plantuml-default-exec-mode . 'jar)
           (plantuml-java-options . "")
           (plantuml-options . "-charset UTF-8")
           (org-plantuml-jar-path . "/usr/local/Cellar/plantuml/1.2020.16/libexec/plantuml.jar")
           (org-startup-with-inline-images . t))
  :config
  (leaf plantuml-export
    :preface
    (defun plantuml-save-png ()
      (interactive)
      (when (buffer-modified-p)
        (map-y-or-n-p "Save this buffer before executing PlantUML?"
                      'save-buffer (list (current-buffer))))
      (let ((code (buffer-string))
            out-file
            cmd)
        (when (string-match "^\\s-*@startuml\\s-+\\(\\S-+\\)\\s*$" code)
          (setq out-file (match-string 1 code)))
        (setq cmd (concat
                   "java -Djava.awt.headless=true -jar " plantuml-java-options " "
                   (shell-quote-argument plantuml-jar-path) " "
                   (and out-file (concat "-t" (file-name-extension out-file))) " "
                   plantuml-options " "
                   (buffer-file-name)))
        (message cmd)
        (call-process-shell-command cmd nil 0)))
    :hook (after-save-hook)
    :config (plantuml-save-png)))

    
;; org-babelで使用する言語を登録
(leaf org
  ;:custom ((org-src-lang-modes . '("plantuml" . plantuml-mode)))
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((plantuml . t))))

(leaf twittering-mode
  :el-get hayamiz/twittering-mode
  :custom ((twittering-use-master-password . t)
           (twittering-retweet-format . '(nil _ " %u"))))
    
    
  

;;;;;;;;;;;;;;;;;
;;; auto edit ;;;
;;;;;;;;;;;;;;;;;
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-revert-interval 0.1)
 '(company-dabbrev-downcase nil t)
 '(company-idle-delay 0 t)
 '(company-minimum-prefix-length 3 t)
 '(company-selection-wrap-around t t)
 '(company-transformers (quote (company-sort-by-backend-importance)) t)
 '(completion-ignore-case t t)
 '(doom-themes-enable-bold t)
 '(doom-themes-enable-italic t)
 '(elpy-rpc-python-command "python3" t)
 '(elpy-rpc-virtualenv-path (quote current) t)
 '(indent-tabs-mode nil)
 '(make-backup-files nil)
 '(menu-bar-mode nil)
 '(p nil t)
 '(package-archives
   (quote
    (("org" . "https://orgmode.org/elpa/")
     ("melpa" . "https://melpa.org/packages/")
     ("gnu" . "https://elpa.gnu.org/packages/"))))
 '(package-selected-packages
   (quote
    (doom-modeline all-the-icons-dired all-the-icons neotree doom-themes helm anzu flycheck lsp-ui lsp-mode rustic transient-dwim leaf-convert leaf-tree blackout el-get hydra leaf-keywords leaf elpy)))
 '(read-file-name-completion-ignore-case t)
 '(rustic-format-trigger (quote on-save) t)
 '(rustic-lsp-server (quote rust-analyzer) t)
 '(scroll-bar-mode nil)
 '(tool-bar-mode nil)
 '(user-full-name "DitS")
 '(user-login-name "dits" t)
 '(user-mail-address "dits.3rd@gmail.com"))
 
'(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-builtin-face ((t (:foreground "green"))))
 '(font-lock-comment-face ((t (:foreground "brightgreen"))))
 '(font-lock-function-name-face ((t (:foreground "blue"))))
 '(font-lock-keyword-face ((t (:foreground "red"))))
 '(font-lock-string-face ((t (:foreground "magenta"))))
 '(font-lock-variable-name-face ((t (:foreground "yellow"))))
 '(highlight-indentation-face ((t (:inherit fringe :background "color-236"))))
 '(line-number ((t (:inherit (shadow default) :background "#131521" :foreground "brightmagenta"))))
 '(minibuffer-prompt ((t (:foreground "green")))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
