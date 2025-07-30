#! /usr/bin/env bb
(ns volume
  (:require
   [cheshire.core :as json]
   [clojure.string :as str]
   [babashka.process :as p]))

(Double/parseDouble
  ".2")
(defn parse-int [s]
  (try
    (Integer/parseInt s)
    (catch Exception _
      (if (number? s)
        s
        nil))))

(defn parse-double [s]
  (try
    (Double/parseDouble s)
    (catch Exception _
      (if (number? s)
        s
        nil))))

(defn get-main-sink []
  (let [cmd-output (str/trim (:out (p/shell {:out :string} "wpctl status")))
        output (->> cmd-output
                             str/split-lines
                             ;; move to sinks area
                             (drop-while #(not (re-find #"Sinks" %)))
                             rest
                             ;; drop everything past sinks
                             (take-while #(re-find #"\d+\. " %))
                             ;; Grab line with the asterisk and capture the volume (in brackets)
                             (some #(re-find #".*\*\s*(\d+)\..*\[vol: ([\d.]+)\]" %))
                             )
        [_ id vol-frac] output]
    {:id id :volume (or (some-> vol-frac
                                parse-double
                                (* 100)
                                int)
                        0)}))

(defn get-icon [percentage]
  (cond
    (zero? percentage)    ""
    (<= 1 percentage 50)  ""
    (<= 51 percentage)    ""))

(defn get-json-volume-data [sink-data]
  (let [{:keys [volume]} sink-data]
   (json/encode {:amount volume
                 :icon (get-icon volume)})))

(defn output-volume [sink]
  (println (get-json-volume-data sink)))

(def Direction [:enum "up" "down"])
(defn set-volume [direction]
  (let [{:keys [id]
         :as sink} (get-main-sink)
        direction (case direction
                    "up"   "+"
                    "down" "-")]
    (p/shell (str "wpctl set-volume " id " 1%" direction))
    (p/shell (str "eww update volume-data='" (get-json-volume-data sink) "'"))))

(defn -main []
  (case (first *command-line-args*)
    nil (output-volume (get-main-sink))
    "set" (set-volume (second *command-line-args*))
    "debug" (println (str "eww update volume-data=" (get-json-volume-data (get-main-sink))))))



(when (= *file* (System/getProperty "babashka.file"))
  (-main))
