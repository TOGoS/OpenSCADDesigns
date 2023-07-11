(defn tog2305/walk [root-path file-callback &opt dir-pre-callback dir-post-callback]
  (def stat (os/stat root-path))
  (if (= :directory (stat :mode))
    (do
      (if dir-pre-callback (dir-pre-callback root-path))
      (each entry-name (os/dir root-path)
	(def entry-path (string root-path "/" entry-name))
	(tog2305/walk entry-path file-callback dir-pre-callback dir-post-callback))
      (if dir-post-callback (dir-post-callback root-path)))
    (file-callback root-path)))

# (pp (os/dir "."))

# (tog2305/walk "." (fn [path] (print "Found " path)))

(defn tog2305/make-ends-with-function [suffix]
  (def reversed-suffix (string/reverse suffix))
  (def peg1 (peg/compile ~(* ,reversed-suffix (capture (any 1)))))
  (fn [subject]
    (def reversed-subject (string/reverse subject))
    # (print "(peg/match " peg1 " " reversed-subject ")")
    (def match-result (peg/match peg1 reversed-subject))
    (and match-result (string/reverse (get match-result 0)))))

(defn find-scad-files [root-path]
  (def matcher (tog2305/make-ends-with-function ".scad"))
  (tog2305/walk root-path
		(fn [file-path]
		  # (print "Checking: " file-path)
		  (def prefix (matcher file-path))
		  (if prefix
		    (print "Found: " file-path)))))

(find-scad-files ".")
