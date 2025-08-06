#! /usr/bin/env bb
(ns bluetooth
  (:require [cheshire.core :as json]
            [clojure.string :as str]
            [babashka.process :as p]))

(defn enabled?
  []
  (not (re-find #"disabled"
                (:out (p/shell {:out :string, :continue true}
                               "systemctl is-enabled bluetooth.service")))))

(defn get-all-devices-info
  []
  (let [get-device-data
          (fn [line]
            (let [[_ id] (str/split line #" " 3)
                  base (->> (p/shell {:out :string}
                                     (str "bluetoothctl info " id))
                            :out
                            str/split-lines
                            (map (fn [line]
                                   (when-let [[_ k v] (re-find #"\t(\w+): (.*)"
                                                               line)]
                                     [k v])))
                            (remove nil?)
                            (into {}))]
              (assoc base "ID" id)))]
    (->> (p/shell {:out :string} "bluetoothctl devices")
         :out
         str/split-lines
         (filter #(str/starts-with? % "Device"))
         (map get-device-data))))


(defn eng->bool
  [word]
  (case word
    "yes" true
    "no" false))

(defn get-bluetooth-device-data
  []
  (mapv (fn [device]
          {:id (get device "ID"),
           :name (get device "Name"),
           :connected (eng->bool (get device "Connected"))})
    (get-all-devices-info)))

(defn connected? [device] (= "yes" (get device "Connected")))

(defn headset? [device] (= "audio-headset" (get device "Icon")))

(if-not (enabled?)
  (println "BT off")
  (case (first *command-line-args*)
    nil (println (json/encode (get-bluetooth-device-data)))
    "current" (let [device (first (filter (every-pred connected? headset?)
                                    (get-all-devices-info)))]
                (println (str "󰂰 " (get device "Name" "None"))))
    "disconnect" (do (p/shell "bluetoothctl disconnect "
                              (second *command-line-args*))
                     (p/process "eww poll current-bluetooth-device"))
    "connect" (do (p/shell "bluetoothctl connect " (second *command-line-args*))
                  (p/process "eww poll current-bluetooth-device"))))
