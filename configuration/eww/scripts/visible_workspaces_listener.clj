#! /usr/bin/env bb
(ns visible-workspaces-listener
  (:require
   [clojure.java.io :as io]
   [cheshire.core :as json]
   [socket-listener :refer [hyprland-responder]]
   [babashka.process :as p]))

(defn get-current-workspaces []
   (into [] (sort (map :id (json/parse-stream (io/reader (:out (p/process "hyprctl workspaces -j"))) keyword)))))

(defn output-workspaces [ws]
  (println (json/encode ws)))

(def workspaces (atom (get-current-workspaces)))
(output-workspaces @workspaces)

(defn add-workspace [ws]
  (swap! workspaces (fn [coll]
                      (into []
                            (sort (conj coll ws))))))

(defn remove-workspace [ws]
  (swap! workspaces (fn [coll]
                      (into []
                            (remove #(= ws %) coll)))))

(defn handle [{:keys [event-type data]}]
  (case event-type
    "createworkspace" (add-workspace (Integer/parseInt data))
    "destroyworkspace" (remove-workspace (Integer/parseInt data))

    nil)
  (output-workspaces @workspaces))

(hyprland-responder handle)
