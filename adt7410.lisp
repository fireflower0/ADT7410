;; Load packages
(load "packages.lisp" :external-format :utf-8)

(in-package :cl-cffi)

;; Load wrapper API
(load "libwiringPi.lisp" :external-format :utf-8)

;; I2C device address (0x48)
(defconstant +i2c-addr+ #X48)

(defun byte-swap (num-value)
  (let (str-value temp-msb temp-lsb)
    ;; 数値を文字列へ変換
    (setq str-value (write-to-string num-value :base 16))
    ;; 上位２桁(MSB)を取得
    (setq temp-msb (subseq str-value 0 2))
    ;; 下位２桁(LSB)を取得
    (setq temp-lsb (subseq str-value 2))
    ;; スワップして結合
    (setq str-value (concatenate 'string temp-lsb temp-msb))
    ;; 文字列を数値へ変換
    (parse-integer str-value :radix 16)))

(defun main ()
  (let (fd base-data actual-data result)
    ;; i2cの初期設定
    (setq fd (wiringPiI2CSetup +i2c-addr+))
    ;; 温度を16ビットのデータで取得するようレジスタ「0x03」に設定
    (wiringPiI2CWriteReg8 fd #X03 #X80)
    ;; ADT7410からデータを取得
    (setq base-data (wiringPiI2CReadReg16 fd #X00))
    ;; バイトスワップ
    (setq actual-data (byte-swap base-data))
    ;; 温度計算
    (setq result (* actual-data 0.0078))
    ;; 結果を標準出力
    (format t "~d~%" result)))

(main)
