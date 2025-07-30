(ns socket-listener
  (:require [clojure.java.io :as io]
            [clojure.core.async :as async]
            [clojure.string :as str]
            [babashka.process :as p]
            [babashka.fs :as fs])
  (:import [java.net StandardProtocolFamily UnixDomainSocketAddress]
           [java.nio.channels SocketChannel]
           [java.nio ByteBuffer]
           [java.nio.file Files Paths]))

(defn get-hyprland-socket-path []
  "Get the Hyprland event socket path from environment"
  (let [instance-sig (System/getenv "HYPRLAND_INSTANCE_SIGNATURE")
        xdg-run-dir  (System/getenv "XDG_RUNTIME_DIR")]
    (if instance-sig
      (str xdg-run-dir "/hypr/" instance-sig "/.socket2.sock")
      (throw (ex-info "Could not find hyprland instance sig" {})))))

(defn parse-hyprland-event [raw-data]
  "Parse Hyprland event data format"
  (when raw-data
    (let [lines (str/split-lines raw-data)]
      (for [line lines
            :when (not (str/blank? line))]
        (if-let [event-match (re-find #"^([^>]+)>>(.*)$" line)]
          {:event-type (second event-match)
           :data (nth event-match 2)
           :raw line}
          {:raw line})))))

(defn read-from-socket [channel]
  "Read data from the socket channel"
  (let [buffer (ByteBuffer/allocate 4096)]
    (try
      (let [bytes-read (.read channel buffer)]
        (when (pos? bytes-read)
          (.flip buffer)
          (let [data (byte-array (.remaining buffer))]
            (.get buffer data)
            (String. data "UTF-8"))))
      (catch Exception e
        (binding [*out* *err*]
         (println "Error reading from socket:" (.getMessage e)))
        nil))))

(defn connect-to-hyprland-socket [socket-path]
  "Connect to the Hyprland IPC socket"
  (try
    (let [channel (SocketChannel/open StandardProtocolFamily/UNIX)
          socket-address (UnixDomainSocketAddress/of socket-path)]
      (.connect channel socket-address)
      channel)
    (catch Exception e
      (binding [*out* *err*]

        (println "Failed to connect to socket:" (.getMessage e))
        (println "Make sure Hyprland is running and socket exists at:" socket-path))
      nil)))

(defn listen-to-events [channel f]
  (try
    (loop []
      (when-let [raw-data (read-from-socket channel)]
        (let [events (parse-hyprland-event raw-data)]
          (doseq [event events]
            (when (:event-type event)
              (f event))))
        (recur)))
    (catch Exception e
      (binding [*out* *err*]
       (println "Error while listening:" (.getMessage e))))
    (finally
      (try
        (.close channel)
        (catch Exception e
          (binding [*out* *err*]
            (println "Error closing connection:" (.getMessage e))))))))

(defn hyprland-responder [f]
  (if-let [socket-path (get-hyprland-socket-path)]
    (if (fs/exists? socket-path)
      (if-let [channel (connect-to-hyprland-socket socket-path)]
        (listen-to-events channel f)
        (binding [*out* *err*]
         (println "Failed to connect to Hyprland socket")))
      (binding [*out* *err*]
       (println "Socket file does not exist:" socket-path)))

    (binding [*out* *err*]
      (println "Could not find Hyprland socket!")
      (println "Make sure:")
      (println "1. Hyprland is running")
      (println "2. HYPRLAND_INSTANCE_SIGNATURE environment variable is set")
      (println "3. Or socket exists in /tmp/hypr/*/socket2.sock")
      (System/exit 1))))
