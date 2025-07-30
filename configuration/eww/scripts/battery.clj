#! /usr/bin/env bb
(ns battery
  (:require
   [cheshire.core :as json]
   [clojure.string :as str]
   [babashka.process :as p]))

(defn get-percentage []
  (Integer/parseInt (str/trim (:out (p/shell {:out :string} "cat /sys/class/power_supply/BAT0/capacity")))))

(defn get-icon [percentage]
  (cond
    (<= 0 percentage 20)  ""
    (<= 21 percentage 40) ""
    (<= 41 percentage 60) ""
    (<= 61 percentage 80) ""
    (<= 81 percentage 100)""))

(let [percentage (get-percentage)]
  (println (json/encode {:percentage percentage
                 :icon (get-icon percentage)})))
