module FStar.Reflection.Formula

open FStar.Reflection.Syntax

noeq type formula =
  | True_  : formula
  | False_ : formula
  | Eq     : typ -> term -> term -> formula
  | And    : term -> term -> formula
  | Or     : term -> term -> formula
  | Not    : term -> formula
  | Implies: term -> term -> formula
  | Iff    : term -> term -> formula
  | Forall : binders -> term -> formula
  | Exists : binders -> term -> formula
  | App    : term -> term -> formula
  | Name   : binder -> formula
  | FV     : fv -> formula
  | IntLit : int -> formula
  | F_Unknown : formula // Also a baked-in "None"

// TODO: move away
let rec eqlist (f : 'a -> 'a -> bool) (xs : list 'a) (ys : list 'a) : Tot bool =
    match xs, ys with
    | [], [] -> true
    | x::xs, y::ys -> f x y && eqlist f xs ys
    | _ -> false

let eq_qn = eqlist (fun s1 s2 -> String.compare s1 s2 = 0) 

let rec collect_app' (args : list term) (t : term) : Tot (term * list term) (decreases t) =
    match inspect t with
    | Tv_App l r ->
        collect_app' (r::args) l
    | _ -> (t, args)
let collect_app = collect_app' []

let rec mk_app (t : term) (args : list term) : Tot term (decreases args) =
    match args with
    | [] -> t
    | (x::xs) -> mk_app (pack (Tv_App t x)) xs

val uncurry : ('a -> 'b -> 'c) -> ('a * 'b -> 'c)
let uncurry f (x, y) = f x y

val curry : ('a * 'b -> 'c) -> ('a -> 'b -> 'c)
let curry f x y = f (x, y)

val mk_app_collect_inv_s : (t:term) -> (args:list term) ->
                            Lemma (uncurry mk_app (collect_app' args t) == mk_app t args)
let rec mk_app_collect_inv_s t args =
    match inspect t with
    | Tv_App l r ->
        mk_app_collect_inv_s l (r::args);
        pack_inspect_inv t
    | _ -> ()

val mk_app_collect_inv : (t:term) -> Lemma (uncurry mk_app (collect_app t) == t)
let rec mk_app_collect_inv t = mk_app_collect_inv_s t []

(*
 * The way back is not stricly true: the list of arguments could grow.
 * It's annoying to even state, might do it later
 *)

let term_view_as_formula (tv:term_view) : Tot formula =
    match tv with
    | Tv_Var n ->
        Name n

    | Tv_FVar fv ->
        // Cannot use `when` clauses when verifying!
        let qn = inspect_fv fv in
        if eq_qn qn true_qn then True_
        else if eq_qn qn false_qn then False_
        else FV fv

    | Tv_App h0 t -> begin
        let (h, ts) = collect_app' [t] h0 in
        match inspect h, ts with
        | Tv_FVar fv, [a1; a2; a3] ->
            let qn = inspect_fv fv in
            if eq_qn qn eq2_qn then Eq a1 a2 a3
            else App h0 t
        | Tv_FVar fv, [a1; a2] ->
            let qn = inspect_fv fv in
            if eq_qn qn imp_qn then Implies a1 a2
            else if eq_qn qn and_qn then And a1 a2
            else if eq_qn qn or_qn  then Or a1 a2
            else App h0 t
        | Tv_FVar fv, [a] ->
            let qn = inspect_fv fv in
            if eq_qn qn not_qn then Not a
            else App h0 t
        | _ ->
            App h0 t
        end

    | Tv_Arrow b t ->
        // TODO: collect binders?
        // TODO: if not free, it's an implication?
        Forall [b] t
    | Tv_Const (C_Int i) ->
        IntLit i

    // TODO: all these
    | Tv_Type ()
    | Tv_Abs _ _
    | Tv_Refine _ _
    | Tv_Const (C_Unit)
    | _ -> 
        F_Unknown

let term_as_formula (t:term) : Tot formula =
    term_view_as_formula (inspect t)

let formula_as_term_view (f:formula) : Tot term_view =
    let mk_app' tv args = List.Tot.fold_left (fun tv a -> Tv_App (pack tv) a) tv args in
    match f with
    | True_  -> Tv_FVar (pack_fv true_qn)
    | False_ -> Tv_FVar (pack_fv false_qn)
    | Eq t l r    -> mk_app' (Tv_FVar (pack_fv eq2_qn)) [t;l;r]
    | And p q     -> mk_app' (Tv_FVar (pack_fv and_qn)) [p;q]
    | Or  p q     -> mk_app' (Tv_FVar (pack_fv  or_qn)) [p;q]
    | Implies p q -> mk_app' (Tv_FVar (pack_fv imp_qn)) [p;q]
    | Not p       -> mk_app' (Tv_FVar (pack_fv not_qn)) [p]
    | Iff p q     -> mk_app' (Tv_FVar (pack_fv iff_qn)) [p;q]
    | Forall bs t -> Tv_Unknown // TODO: decide on meaning of this
    | Exists bs t -> Tv_Unknown // TODO: ^

    | App p q ->
        Tv_App p q

    | Name b ->
        Tv_Var b

    | FV fv ->
        Tv_FVar fv

    | IntLit i ->
        Tv_Const (C_Int i)

    | F_Unknown ->
        Tv_Unknown

let formula_as_term (f:formula) : Tot term =
    pack (formula_as_term_view f)

let print_formula (f:formula) : string =
    match f with
    | True_ -> "True_"
    | False_ -> "False_"
    | Eq t l r -> "Eq (" ^ term_to_string t ^ ") (" ^ term_to_string l ^ ") (" ^ term_to_string r ^ ")"
    | And p q -> "And (" ^ term_to_string p ^ ") (" ^ term_to_string q ^ ")"
    | Or  p q ->  "Or (" ^ term_to_string p ^ ") (" ^ term_to_string q ^ ")"
    | Implies p q ->  "Implies (" ^ term_to_string p ^ ") (" ^ term_to_string q ^ ")"
    | Not p ->  "Not (" ^ term_to_string p ^ ")"
    | Iff p q ->  "Iff (" ^ term_to_string p ^ ") (" ^ term_to_string q ^ ")"
    | Forall bs t -> "Forall <bs> (" ^ term_to_string t ^ ")"
    | Exists bs t -> "Exists <bs> (" ^ term_to_string t ^ ")"
    | App p q ->  "App (" ^ term_to_string p ^ ") (" ^ term_to_string q ^ ")"
    | Name b ->  "Name (" ^ inspect_bv b ^ ")"
    | FV fv -> "FV (" ^ flatten_name (inspect_fv fv) ^ ")"
    | IntLit i -> "Int " ^ string_of_int i
    | F_Unknown -> "?"