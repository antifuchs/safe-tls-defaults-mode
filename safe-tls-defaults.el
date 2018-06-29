;;; safe-tls-defaults.el --- Harden emacs's TLS default settings

;; Copyright (C) 2018 Andreas Fuchs <asf@boinkor.net>

;; Author: Andreas Fuchs <asf@boinkor.net>
;; Version: 0.1.0
;; Created: 29 Jun 2018
;; Keywords: ssl security
;; Homepage: https://github.com/antifuchs/safe-tls-defaults-mode
;; Package-Requires: (("tls"))

;; This file is not part of GNU Emacs.

;;; Commentary:
;;
;; Run `turn-on-safe-tls-defaults' in emacs startup to:
;; * turn off the built-in gnutls,
;; * use the `openssl' binary to establish TLS connections,
;; * activate a set of ciphers that are considered safe on the web.
;;
;;; Code:

(defun safe-tls-disable-gnutls (&rest args) nil)

;;;###autoload
(defun turn-on-safe-tls-defaults ()
  "Turn on hardened SSL defaults."
  (interactive)
  (require 'tls)
  (advice-add 'gnutls-available-p :override 'safe-tls-disable-gnutls)
  (setq tls-checktrust t
        tls-program
        '("gnutls-cli -p %p --dh-bits=2048 --ocsp --x509cafile=%t --priority='SECURE192:+SECURE128:-VERS-ALL:+VERS-TLS1.2:%%PROFILE_MEDIUM' %h")
        ;; I wish this worked, but it fails way too many tests, too:
        ;; '("openssl s_client -connect %h:%p -servername %h -CAfile %t -nbio -cipher 'ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS'")
        ))

;;; safe-tls-defaults ends here
