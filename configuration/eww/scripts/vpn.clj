#!/usr/bin/env bb
(ns vpn
  (:require [babashka.process :as p]
            [clojure.string :as str]))

(defn us? [output-data]
  (= "United States"
     (:country output-data)))

(defn get-data-from-output
  "Returns a map like

{:current-protocol \"UDP\",
 :ip \"181.214.196.148\",
 :transfer \"36.88 KiB received, 36.09 KiB sent\",
 :server \"United States #9707\",
 :uptime \"18 seconds\",
 :city \"Dallas\",
 :hostname \"us9707.nordvpn.com\",
 :status \"Connected\",
 :current-technology \"NORDLYNX\",
 :post-quantum-vpn \"Disabled\",
  :country \"United States \"}"
  [output]
  (->> output
       str/split-lines
       (map #(str/split % #": "))
       (filter #(= 2 (count %)))
       (map (fn [[k v]]
              [(-> k
                   str/lower-case
                   (str/replace " " "-")
                   keyword)
               v]))
       (into {})))


(defn get-vpn-data []
  (get-data-from-output (:out (p/shell {:out :string} "nordvpn status"))))

(defn output-vpn-data []
  (println
   (let [output (get-vpn-data)]
     (cond
       (= "Disconnected" (:status output))
       "󰌙 VPN off"

       (us? output)
       (str "󰌘 "(:city output))


       :else
       (str "󰌘 " (:city output) " | " (:country output))))))


(defn toggle-vpn []
  (let [{:keys [status]} (get-vpn-data)]
    (case status
      "Connected" (do
                    (p/shell "eww update vpn-data='Disconnecting'")
                    (p/check (p/process "nordvpn disconnect")))
      "Disconnected" (do
                       (p/shell "eww update vpn-data='Connecting'")
                       (p/check (p/process "nordvpn connect seattle"))))

    (p/shell "eww poll vpn-data")))

(let [command (first *command-line-args*)]
  (case command
    nil (output-vpn-data)

    "toggle" (toggle-vpn)))
