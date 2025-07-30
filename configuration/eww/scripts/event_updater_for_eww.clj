#!/usr/bin/env bb
(ns event-updater-for-eww
  (:require [clojure.java.io :as io]
            [socket-listener :refer [hyprland-responder]]
            [clojure.string :as str]
            [babashka.process :as p]
            [babashka.fs :as fs])
  (:import [java.net StandardProtocolFamily UnixDomainSocketAddress]
           [java.nio.channels SocketChannel]
           [java.nio ByteBuffer]
           [java.nio.file Files Paths]))

(defmulti handle (fn [{:keys [event-type]}]
                   event-type))

(defmethod handle :default [_] nil)

(defmethod handle "workspace" [{:keys [data]}]
  (println data))

(defn -main [& args]
  (println (str/trim
            (:out (->
                   (p/shell {:out :string} "hyprctl -j activeworkspace")
                   (p/shell {:out :string} "jq '.id")))))
  (hyprland-responder handle))

;; Run if executed directly
(when (= *file* (System/getProperty "babashka.file"))
  (-main))
