;;; dbt-mode.el --- Minor mode for running dbt commands -*- lexical-binding: t; -*-

;;; Commentary:

(require 'pyvenv)

;;; Code:

(defcustom dbt-mode-python-virtual-env nil
  "Virtual environment to use for dbt commands."
  :type 'directory
  :group 'dbt-mode)

(defcustom dbt-mode-project-root nil
  "Root of the dbt project."
  :type 'directory
  :group 'dbt-mode)

(defcustom dbt-mode-output-buffer (get-buffer-create "dbt-output")
  "Buffer to display dbt command output."
  :type 'buffer
  :group 'dbt-mode)

(defun dbt-mode-load-virtual-env ()
  "Load the Python virtual environment for dbt commands."
  (interactive)
  (unless dbt-mode-python-virtual-env
    (let ((virtual-env-path (read-directory-name "Path for Python virtual environment: ")))
      (setq dbt-mode-python-virtual-env virtual-env-path)))
  (pyvenv-activate dbt-mode-python-virtual-env))

(defun dbt-mode-find-project-root ()
  "Find the root of the dbt project."
  (if-let ((dbt-project-root (locate-dominating-file default-directory "dbt_project.yml")))
      (progn
        (message (concat "dbt project root: " dbt-project-root))
        (setq dbt-mode-project-root dbt-project-root))
    (error "Not in a dbt project")))

(defun setup-environment ()
  "Setup the environment for dbt-mode."
  (when dbt-mode
    (message "--------------")
    (dbt-mode-find-project-root)
    (dbt-mode-load-virtual-env)))

(add-hook 'dbt-mode-hook #'setup-environment)

(defvar-local dbt-model-name nil)

(defun dbt-mode-execute-command (command)
  "Execute a dbt COMMAND in the dbt project root."
  (with-current-buffer dbt-mode-output-buffer
    (erase-buffer)
    (cd dbt-mode-project-root)
    (display-buffer dbt-mode-output-buffer)
    (cd dbt-mode-project-root)
    (message (concat "Running command: " command))
    (shell-command (concat command " &")
                   dbt-mode-output-buffer
                   dbt-mode-output-buffer)))

(defun dbt-mode--run (&optional args)
  "Run the dbt model in the current buffer."
  (interactive
   (transient-args 'dbt-mode-run))
  (let* ((buffer-name (buffer-name))
         (_ (string-match "\\(.*\\).sql" buffer-name))
         (model-name (match-string 1 buffer-name))
         (command (concat "dbt run -s " model-name " " args)))
    (dbt-mode-execute-command command)))

(defun dbt-mode--test (&optional args)
  "Test the dbt model in the current buffer."
  (interactive
   (transient-args 'dbt-mode-test))
  (let* ((buffer-name (buffer-name))
         (_ (string-match "\\(.*\\).sql" buffer-name))
         (model-name (match-string 1 buffer-name))
         (command (concat "dbt test -s " model-name " " args)))
    (dbt-mode-execute-command command)))

(defun dbt-mode--compile (&optional args)
  "Compile the dbt model in the current buffer."
  (interactive
   (transient-args 'dbt-mode-compile))
  (let* ((buffer-name (buffer-name))
         (_ (string-match "\\(.*\\).sql" buffer-name))
         (model-name (match-string 1 buffer-name))
         (command (concat "dbt compile -s " model-name " " args)))
    (dbt-mode-execute-command command)))

(transient-define-prefix dbt-mode-run ()
  "A map for dbt run arguments."
  ["Arguments"
   [("f" "full-refresh" "--full-refresh")]]
  ["dbt run"
   [("r" "Run" dbt-mode--run)]])

(transient-define-prefix dbt-mode-test ()
  "A map for dbt test arguments."
  ["dbt test"
   [("t" "Test" dbt-mode--test)]])

(transient-define-prefix dbt-mode-compile ()
  "A map for dbt compile arguments."
  ["dbt compile"
   [("c" "Compile" dbt-mode--compile)]])

(defun dbt-mode-clean ()
  "Clean the dbt project."
  (interactive)
  (dbt-mode-execute-command "dbt clean"))

(transient-define-prefix dbt-mode-command-map ()
  "A map for dbt commands."
  ["dbt commands"
   [("r" "Run" dbt-mode-run)
    ("t" "Test" dbt-mode-test)
    ("k" "Clean" dbt-mode-clean)]])

(defvar dbt-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-d") 'dbt-mode-command-map)
    map))

(define-minor-mode dbt-mode
  "Minor mode for running dbt commands."
  :lighter " dbt"
  :keymap dbt-mode-map
  :group 'dbt-mode)

(provide 'dbt-mode)
;;; dbt-mode.el ends here
