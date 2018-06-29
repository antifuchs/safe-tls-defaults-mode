(require 'ert)
(require 'cl-macs)

(defvar safe-tls-defaults-tests-unsafe-domains nil)
(defvar safe-tls-defaults-tests-safe-domains nil)
(progn
  (setq safe-tls-defaults-tests-unsafe-domains
    '(
      ("https://expired.badssl.com/")
      ("https://wrong.host.badssl.com/")
      ("https://self-signed.badssl.com/")
      ("https://untrusted-root.badssl.com/")
      ("https://revoked.badssl.com/")
      ("https://pinning-test.badssl.com/"
       "no known-unsafe pins on gnutls")
      ("https://sha1-intermediate.badssl.com/")
      ("https://rc4-md5.badssl.com/")
      ("https://rc4.badssl.com/")
      ("https://3des.badssl.com/")
      ("https://null.badssl.com/")
      ("https://mozilla-old.badssl.com/" "")
      ("https://dh480.badssl.com/")
      ("https://dh512.badssl.com/")
      ("https://dh-small-subgroup.badssl.com/"
       "allowed by gnutls")
      ("https://dh-composite.badssl.com/")
      ("https://invalid-expected-sct.badssl.com/"
       "gnutls-cli doesn't do signed cert timestamps")
      ("https://subdomain.preloaded-hsts.badssl.com/")
      ("https://superfish.badssl.com/")
      ("https://edellroot.badssl.com/")
      ("https://dsdtestprovider.badssl.com/")
      ("https://preact-cli.badssl.com/")
      ("https://webpack-dev-server.badssl.com/")
      ("https://captive-portal.badssl.com/")
      ("https://mitm-software.badssl.com/")
      ("https://sha1-2017.badssl.com/")
      ))

  (defmacro safe-tls-defaults-test-unsafe-domains ()
    `(progn
       ,@(mapcar
          (lambda (spec)
            (destructuring-bind (url &optional failure-reason) spec
             (let ((name (intern (format "safe-tls-defaults-test-unsafe-url-%s" url))))
               `(ert-deftest ,name ()
                  ,(format "Should refuse unsafe url %s%s" url
                           (when failure-reason (format ", but %s" failure-reason)))
                  ,@(when failure-reason
                      `(:expected-result :failed))
                  (should (eql 'safe
                               (condition-case c
                                   (let ((buf (url-retrieve-synchronously ,url nil t)))
                                     (with-current-buffer buf
                                       (cons 'unsafe
                                             (buffer-substring-no-properties (point-min) (point-max)))))
                                 (error 'safe))))))))
          safe-tls-defaults-tests-unsafe-domains)))

  (safe-tls-defaults-test-unsafe-domains))

(progn
  (setq safe-tls-defaults-tests-safe-domains
    '(
      "https://google.com/"
      "https://mozilla.org/"
      "https://badssl.com/"
      "https://sha256.badssl.com/"
      "https://sha384.badssl.com/"
      "https://sha512.badssl.com/"
      "https://ecc256.badssl.com/"
      "https://ecc384.badssl.com/"
      "https://rsa2048.badssl.com/"
      "https://rsa4096.badssl.com/"
      "https://mozilla-modern.badssl.com/"
      "https://mozilla-intermediate.badssl.com/"
      ))
  (defmacro safe-tls-defaults-test-safe-domains ()
    `(progn
       ,@(mapcar
          (lambda (d)
            (let ((name (intern (format "safe-tls-defaults-test-safe-domain-%s" d))))
              `(ert-deftest ,name ()
                 ,(format "Should connect to safe domain %s" d)
                 (should (eql 'ok
                              (condition-case c
                                  (progn (url-retrieve-synchronously ,d)
                                         'ok)
                                (error 'failed)))))))
          safe-tls-defaults-tests-safe-domains)))
  (safe-tls-defaults-test-safe-domains))
