module Simple_Ifc_Reify

open FStar.DM4F.Heap.IntStoreFixed
open FStar.DM4F.IntStoreFixed
open Rel


(* A very simple program and with different simple properties that can or
cannot be shown *)

(*****************************************************************************)

reifiable val ifc_a : x:id ->
  IntStore unit
  (requires (fun _ -> True))
  (ensures (fun h0 _ h1 -> h1 = upd h0 x 0))
reifiable let ifc_a x = write x 0
(* works *)

(*****************************************************************************)

reifiable val ifc_b : x:id ->
  IntStore unit
  (requires (fun _ -> True))
  (ensures (fun h0 _ h1 -> sel h1 x = 0))
reifiable let ifc_b x = write x 0
(* does not work *)

(*****************************************************************************)


reifiable let ifc_c x = write x 0

let ifc_c_r h x =  (* normalize_term *) (snd (reify (ifc_c x) h))

val ni_ifc_c1 : (x:id) -> (h:rel heap) ->
  Lemma
  (requires (R?.l h == R?.r h))
  (ensures  ((ifc_c_r (R?.l h) x) == (ifc_c_r (R?.r h) x)))
let ni_ifc_c1 x h = ()
(* works *)

val ni_ifc_c2 : (x:id) -> (h:rel heap) ->
  Lemma
  (requires (R?.l h == R?.r h))
  (ensures  (sel (ifc_c_r (R?.l h) x) x = sel (ifc_c_r (R?.r h) x) x))
let ni_ifc_c2 x h = ()
(* works *)

val ni_ifc_c3 : (x:id) -> (h:rel heap) ->
  Lemma
  (requires (sel (R?.l h) x = sel (R?.r h) x))
  (ensures  (sel (ifc_c_r (R?.l h) x) x = sel (ifc_c_r (R?.r h) x) x))
let ni_ifc_c3 x h = ()
(* does not work *)

val ni_ifc_c4 : (x:id) -> (h:heap) ->
  Lemma
  (requires True)
  (ensures  (sel (ifc_c_r h x) x = 0))
let ni_ifc_c4 x h = ()
(* does not work *)