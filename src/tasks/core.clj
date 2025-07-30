(ns tasks.core
  (:require
   [babashka.fs :as fs]
   [babashka.process :as p]
   [clojure.set :as set]
   [clojure.string :as str]))

(def workspace-root (fs/canonicalize "."))

(defn expand-home [path]
  (if (str/starts-with? path "~")
    (str/replace-first path "~" (System/getProperty "user.home"))
    path))

;; Which OS needs this config module?
(def common-modules #{"fish" "doom"})
(def macos-modules #{})
(def linux-modules #{"hypr" "foot" "systemd" "eww" "kmonad" "kanata"})

(def mac? (str/starts-with? (System/getProperty "os.name") "Mac"))

(defn link-dotfiles []
  (let [base-src            (fs/path workspace-root "configuration")
        base-dest           (expand-home "~/.config")
        os-specific-modules (if mac?
                              macos-modules
                              linux-modules)]

    (doseq [module (set/union common-modules os-specific-modules)]
      (let [src (fs/path base-src module)
            dest (fs/path base-dest module)]
        (if (fs/exists? dest)
          (println (str  "Destination file exists for " module " => " dest))
          (fs/create-sym-link dest src))))))

(defn brew-install []
  (if-not mac?
    (println "Can only use `brew-install` on MacOS")
    (p/shell {:continue true}
             (str "brew bundle --file="
                  workspace-root "/configuration/Brewfile"))))
