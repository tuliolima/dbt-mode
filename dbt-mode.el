(require 'pyvenv)

(defcustom dbt-mode-python-virtual-env nil
  "Virtual environment to use for dbt commands"
  :type 'directory
  :group 'dbt-mode)

(defcustom dbt-mode-project-root nil
  "Root of the dbt project"
  :type 'directory
  :group 'dbt-mode)

(defcustom dbt-mode-output-buffer (get-buffer-create "dbt-output")
  "Buffer to display dbt command output."
  :type 'buffer
  :group 'dbt-mode)

(defun dbt-mode-load-virtual-env ()
  (interactive)
  (unless dbt-mode-python-virtual-env
    (let ((virtual-env-path (read-directory-name "Path for Python virtual environment: ")))
      (setq dbt-mode-python-virtual-env virtual-env-path)))
  (pyvenv-activate dbt-mode-python-virtual-env))

(defun dbt-mode-find-project-root ()
  (if-let ((dbt-project-root (locate-dominating-file default-directory "dbt_project.yml")))
      (progn
        (message (concat "dbt project root: " dbt-project-root))
        (setq dbt-mode-project-root dbt-project-root)
        ;change the working directory to the project root
        (cd dbt-project-root))
    (error "Not in a dbt project.")))

(defun setup-environment ()
  (when dbt-mode
    (message "--------------")
    (dbt-mode-find-project-root)
    (dbt-mode-load-virtual-env)))

(add-hook 'dbt-mode-hook #'setup-environment)

(defvar-local dbt-model-name nil)

(defun dbt-mode-run ()
  (interactive)
  (let ((buffer-name (buffer-name)))
    (string-match "\\(.*\\).sql" buffer-name)
    (let ((model-name (match-string 1 buffer-name)))
      (message (concat "model: " model-name))
      (with-current-buffer dbt-mode-output-buffer
        (erase-buffer)
        (display-buffer dbt-mode-output-buffer)
        (cd dbt-mode-project-root)
        (shell-command (concat "dbt run -s " model-name " &")
                       dbt-mode-output-buffer
                       dbt-mode-output-buffer)))))

(defvar dbt-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-c") 'dbt-mode-run)
    map))

(define-minor-mode dbt-mode
  "Minor mode for running dbt commands"
  :lighter " dbt"
  :keymap dbt-mode-map
  :group 'dbt-mode)

(provide 'dbt-mode)
