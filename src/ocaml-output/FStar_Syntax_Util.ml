open Prims
let qual_id: FStar_Ident.lident -> FStar_Ident.ident -> FStar_Ident.lident =
  fun lid  ->
    fun id  ->
      let uu____7 =
        FStar_Ident.lid_of_ids
          (FStar_List.append lid.FStar_Ident.ns [lid.FStar_Ident.ident; id]) in
      FStar_Ident.set_lid_range uu____7 id.FStar_Ident.idRange
let mk_discriminator: FStar_Ident.lident -> FStar_Ident.lident =
  fun lid  ->
    FStar_Ident.lid_of_ids
      (FStar_List.append lid.FStar_Ident.ns
         [FStar_Ident.mk_ident
            ((Prims.strcat FStar_Ident.reserved_prefix
                (Prims.strcat "is_"
                   (lid.FStar_Ident.ident).FStar_Ident.idText)),
              ((lid.FStar_Ident.ident).FStar_Ident.idRange))])
let is_name: FStar_Ident.lident -> Prims.bool =
  fun lid  ->
    let c =
      FStar_Util.char_at (lid.FStar_Ident.ident).FStar_Ident.idText
        (Prims.parse_int "0") in
    FStar_Util.is_upper c
let arg_of_non_null_binder uu____25 =
  match uu____25 with
  | (b,imp) ->
      let uu____30 = FStar_Syntax_Syntax.bv_to_name b in (uu____30, imp)
let args_of_non_null_binders:
  FStar_Syntax_Syntax.binders ->
    (FStar_Syntax_Syntax.term* FStar_Syntax_Syntax.aqual) Prims.list
  =
  fun binders  ->
    FStar_All.pipe_right binders
      (FStar_List.collect
         (fun b  ->
            let uu____43 = FStar_Syntax_Syntax.is_null_binder b in
            if uu____43
            then []
            else (let uu____50 = arg_of_non_null_binder b in [uu____50])))
let args_of_binders:
  FStar_Syntax_Syntax.binders ->
    ((FStar_Syntax_Syntax.bv* FStar_Syntax_Syntax.aqual) Prims.list*
      (FStar_Syntax_Syntax.term* FStar_Syntax_Syntax.aqual) Prims.list)
  =
  fun binders  ->
    let uu____64 =
      FStar_All.pipe_right binders
        (FStar_List.map
           (fun b  ->
              let uu____86 = FStar_Syntax_Syntax.is_null_binder b in
              if uu____86
              then
                let b1 =
                  let uu____96 =
                    FStar_Syntax_Syntax.new_bv None
                      (Prims.fst b).FStar_Syntax_Syntax.sort in
                  (uu____96, (Prims.snd b)) in
                let uu____97 = arg_of_non_null_binder b1 in (b1, uu____97)
              else
                (let uu____105 = arg_of_non_null_binder b in (b, uu____105)))) in
    FStar_All.pipe_right uu____64 FStar_List.unzip
let name_binders:
  FStar_Syntax_Syntax.binder Prims.list ->
    (FStar_Syntax_Syntax.bv* FStar_Syntax_Syntax.aqual) Prims.list
  =
  fun binders  ->
    FStar_All.pipe_right binders
      (FStar_List.mapi
         (fun i  ->
            fun b  ->
              let uu____145 = FStar_Syntax_Syntax.is_null_binder b in
              if uu____145
              then
                let uu____148 = b in
                match uu____148 with
                | (a,imp) ->
                    let b1 =
                      let uu____154 =
                        let uu____155 = FStar_Util.string_of_int i in
                        Prims.strcat "_" uu____155 in
                      FStar_Ident.id_of_text uu____154 in
                    let b2 =
                      {
                        FStar_Syntax_Syntax.ppname = b1;
                        FStar_Syntax_Syntax.index = (Prims.parse_int "0");
                        FStar_Syntax_Syntax.sort =
                          (a.FStar_Syntax_Syntax.sort)
                      } in
                    (b2, imp)
              else b))
let name_function_binders t =
  match t.FStar_Syntax_Syntax.n with
  | FStar_Syntax_Syntax.Tm_arrow (binders,comp) ->
      let uu____183 =
        let uu____186 =
          let uu____187 =
            let uu____195 = name_binders binders in (uu____195, comp) in
          FStar_Syntax_Syntax.Tm_arrow uu____187 in
        FStar_Syntax_Syntax.mk uu____186 in
      uu____183 None t.FStar_Syntax_Syntax.pos
  | uu____212 -> t
let null_binders_of_tks:
  (FStar_Syntax_Syntax.typ* FStar_Syntax_Syntax.aqual) Prims.list ->
    (FStar_Syntax_Syntax.bv* FStar_Syntax_Syntax.aqual) Prims.list
  =
  fun tks  ->
    FStar_All.pipe_right tks
      (FStar_List.map
         (fun uu____232  ->
            match uu____232 with
            | (t,imp) ->
                let uu____239 =
                  let uu____240 = FStar_Syntax_Syntax.null_binder t in
                  FStar_All.pipe_left Prims.fst uu____240 in
                (uu____239, imp)))
let binders_of_tks:
  (FStar_Syntax_Syntax.typ* FStar_Syntax_Syntax.aqual) Prims.list ->
    (FStar_Syntax_Syntax.bv* FStar_Syntax_Syntax.aqual) Prims.list
  =
  fun tks  ->
    FStar_All.pipe_right tks
      (FStar_List.map
         (fun uu____266  ->
            match uu____266 with
            | (t,imp) ->
                let uu____279 =
                  FStar_Syntax_Syntax.new_bv
                    (Some (t.FStar_Syntax_Syntax.pos)) t in
                (uu____279, imp)))
let binders_of_freevars:
  FStar_Syntax_Syntax.bv FStar_Util.set ->
    FStar_Syntax_Syntax.binder Prims.list
  =
  fun fvs  ->
    let uu____286 = FStar_Util.set_elements fvs in
    FStar_All.pipe_right uu____286
      (FStar_List.map FStar_Syntax_Syntax.mk_binder)
let mk_subst s = [s]
let subst_of_list:
  FStar_Syntax_Syntax.binders ->
    FStar_Syntax_Syntax.args -> FStar_Syntax_Syntax.subst_t
  =
  fun formals  ->
    fun actuals  ->
      if (FStar_List.length formals) = (FStar_List.length actuals)
      then
        FStar_List.fold_right2
          (fun f  ->
             fun a  ->
               fun out  ->
                 (FStar_Syntax_Syntax.NT ((Prims.fst f), (Prims.fst a))) ::
                 out) formals actuals []
      else failwith "Ill-formed substitution"
let rename_binders:
  FStar_Syntax_Syntax.binders ->
    FStar_Syntax_Syntax.binders -> FStar_Syntax_Syntax.subst_t
  =
  fun replace_xs  ->
    fun with_ys  ->
      if (FStar_List.length replace_xs) = (FStar_List.length with_ys)
      then
        FStar_List.map2
          (fun uu____354  ->
             fun uu____355  ->
               match (uu____354, uu____355) with
               | ((x,uu____365),(y,uu____367)) ->
                   let uu____372 =
                     let uu____377 = FStar_Syntax_Syntax.bv_to_name y in
                     (x, uu____377) in
                   FStar_Syntax_Syntax.NT uu____372) replace_xs with_ys
      else failwith "Ill-formed substitution"
let rec unmeta: FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term =
  fun e  ->
    let e1 = FStar_Syntax_Subst.compress e in
    match e1.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_meta (e2,_)|FStar_Syntax_Syntax.Tm_ascribed
      (e2,_,_) -> unmeta e2
    | uu____407 -> e1
let rec univ_kernel:
  FStar_Syntax_Syntax.universe -> (FStar_Syntax_Syntax.universe* Prims.int) =
  fun u  ->
    match u with
    | FStar_Syntax_Syntax.U_unknown 
      |FStar_Syntax_Syntax.U_name _
       |FStar_Syntax_Syntax.U_unif _|FStar_Syntax_Syntax.U_zero  ->
        (u, (Prims.parse_int "0"))
    | FStar_Syntax_Syntax.U_succ u1 ->
        let uu____418 = univ_kernel u1 in
        (match uu____418 with | (k,n1) -> (k, (n1 + (Prims.parse_int "1"))))
    | FStar_Syntax_Syntax.U_max uu____425 ->
        failwith "Imposible: univ_kernel (U_max _)"
    | FStar_Syntax_Syntax.U_bvar uu____429 ->
        failwith "Imposible: univ_kernel (U_bvar _)"
let constant_univ_as_nat: FStar_Syntax_Syntax.universe -> Prims.int =
  fun u  -> let uu____435 = univ_kernel u in Prims.snd uu____435
let rec compare_univs:
  FStar_Syntax_Syntax.universe -> FStar_Syntax_Syntax.universe -> Prims.int =
  fun u1  ->
    fun u2  ->
      match (u1, u2) with
      | (FStar_Syntax_Syntax.U_bvar _,_)|(_,FStar_Syntax_Syntax.U_bvar _) ->
          failwith "Impossible: compare_univs"
      | (FStar_Syntax_Syntax.U_unknown ,FStar_Syntax_Syntax.U_unknown ) ->
          Prims.parse_int "0"
      | (FStar_Syntax_Syntax.U_unknown ,uu____448) -> - (Prims.parse_int "1")
      | (uu____449,FStar_Syntax_Syntax.U_unknown ) -> Prims.parse_int "1"
      | (FStar_Syntax_Syntax.U_zero ,FStar_Syntax_Syntax.U_zero ) ->
          Prims.parse_int "0"
      | (FStar_Syntax_Syntax.U_zero ,uu____450) -> - (Prims.parse_int "1")
      | (uu____451,FStar_Syntax_Syntax.U_zero ) -> Prims.parse_int "1"
      | (FStar_Syntax_Syntax.U_name u11,FStar_Syntax_Syntax.U_name u21) ->
          FStar_String.compare u11.FStar_Ident.idText u21.FStar_Ident.idText
      | (FStar_Syntax_Syntax.U_name uu____454,FStar_Syntax_Syntax.U_unif
         uu____455) -> - (Prims.parse_int "1")
      | (FStar_Syntax_Syntax.U_unif uu____458,FStar_Syntax_Syntax.U_name
         uu____459) -> Prims.parse_int "1"
      | (FStar_Syntax_Syntax.U_unif u11,FStar_Syntax_Syntax.U_unif u21) ->
          let uu____468 = FStar_Unionfind.uvar_id u11 in
          let uu____470 = FStar_Unionfind.uvar_id u21 in
          uu____468 - uu____470
      | (FStar_Syntax_Syntax.U_max us1,FStar_Syntax_Syntax.U_max us2) ->
          let n1 = FStar_List.length us1 in
          let n2 = FStar_List.length us2 in
          if n1 <> n2
          then n1 - n2
          else
            (let copt =
               let uu____492 = FStar_List.zip us1 us2 in
               FStar_Util.find_map uu____492
                 (fun uu____498  ->
                    match uu____498 with
                    | (u11,u21) ->
                        let c = compare_univs u11 u21 in
                        if c <> (Prims.parse_int "0") then Some c else None) in
             match copt with | None  -> Prims.parse_int "0" | Some c -> c)
      | (FStar_Syntax_Syntax.U_max uu____508,uu____509) ->
          - (Prims.parse_int "1")
      | (uu____511,FStar_Syntax_Syntax.U_max uu____512) ->
          Prims.parse_int "1"
      | uu____514 ->
          let uu____517 = univ_kernel u1 in
          (match uu____517 with
           | (k1,n1) ->
               let uu____522 = univ_kernel u2 in
               (match uu____522 with
                | (k2,n2) ->
                    let r = compare_univs k1 k2 in
                    if r = (Prims.parse_int "0") then n1 - n2 else r))
let eq_univs:
  FStar_Syntax_Syntax.universe -> FStar_Syntax_Syntax.universe -> Prims.bool
  =
  fun u1  ->
    fun u2  ->
      let uu____535 = compare_univs u1 u2 in
      uu____535 = (Prims.parse_int "0")
let ml_comp:
  (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
    FStar_Syntax_Syntax.syntax ->
    FStar_Range.range -> FStar_Syntax_Syntax.comp
  =
  fun t  ->
    fun r  ->
      FStar_Syntax_Syntax.mk_Comp
        {
          FStar_Syntax_Syntax.comp_univs = [FStar_Syntax_Syntax.U_unknown];
          FStar_Syntax_Syntax.effect_name =
            (FStar_Ident.set_lid_range FStar_Syntax_Const.effect_ML_lid r);
          FStar_Syntax_Syntax.result_typ = t;
          FStar_Syntax_Syntax.effect_args = [];
          FStar_Syntax_Syntax.flags = [FStar_Syntax_Syntax.MLEFFECT]
        }
let comp_effect_name c =
  match c.FStar_Syntax_Syntax.n with
  | FStar_Syntax_Syntax.Comp c1 -> c1.FStar_Syntax_Syntax.effect_name
  | FStar_Syntax_Syntax.Total uu____562 -> FStar_Syntax_Const.effect_Tot_lid
  | FStar_Syntax_Syntax.GTotal uu____568 ->
      FStar_Syntax_Const.effect_GTot_lid
let comp_flags c =
  match c.FStar_Syntax_Syntax.n with
  | FStar_Syntax_Syntax.Total uu____586 -> [FStar_Syntax_Syntax.TOTAL]
  | FStar_Syntax_Syntax.GTotal uu____592 -> [FStar_Syntax_Syntax.SOMETRIVIAL]
  | FStar_Syntax_Syntax.Comp ct -> ct.FStar_Syntax_Syntax.flags
let comp_set_flags:
  FStar_Syntax_Syntax.comp ->
    FStar_Syntax_Syntax.cflags Prims.list ->
      (FStar_Syntax_Syntax.comp',Prims.unit) FStar_Syntax_Syntax.syntax
  =
  fun c  ->
    fun f  ->
      let comp_to_comp_typ c1 =
        match c1.FStar_Syntax_Syntax.n with
        | FStar_Syntax_Syntax.Comp c2 -> c2
        | FStar_Syntax_Syntax.Total (t,u_opt)|FStar_Syntax_Syntax.GTotal
          (t,u_opt) ->
            let uu____628 =
              let uu____629 = FStar_Util.map_opt u_opt (fun x  -> [x]) in
              FStar_Util.dflt [] uu____629 in
            {
              FStar_Syntax_Syntax.comp_univs = uu____628;
              FStar_Syntax_Syntax.effect_name = (comp_effect_name c1);
              FStar_Syntax_Syntax.result_typ = t;
              FStar_Syntax_Syntax.effect_args = [];
              FStar_Syntax_Syntax.flags = (comp_flags c1)
            } in
      let uu___178_639 = c in
      let uu____640 =
        let uu____641 =
          let uu___179_642 = comp_to_comp_typ c in
          {
            FStar_Syntax_Syntax.comp_univs =
              (uu___179_642.FStar_Syntax_Syntax.comp_univs);
            FStar_Syntax_Syntax.effect_name =
              (uu___179_642.FStar_Syntax_Syntax.effect_name);
            FStar_Syntax_Syntax.result_typ =
              (uu___179_642.FStar_Syntax_Syntax.result_typ);
            FStar_Syntax_Syntax.effect_args =
              (uu___179_642.FStar_Syntax_Syntax.effect_args);
            FStar_Syntax_Syntax.flags = f
          } in
        FStar_Syntax_Syntax.Comp uu____641 in
      {
        FStar_Syntax_Syntax.n = uu____640;
        FStar_Syntax_Syntax.tk = (uu___178_639.FStar_Syntax_Syntax.tk);
        FStar_Syntax_Syntax.pos = (uu___178_639.FStar_Syntax_Syntax.pos);
        FStar_Syntax_Syntax.vars = (uu___178_639.FStar_Syntax_Syntax.vars)
      }
let comp_to_comp_typ:
  FStar_Syntax_Syntax.comp -> FStar_Syntax_Syntax.comp_typ =
  fun c  ->
    match c.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Comp c1 -> c1
    | FStar_Syntax_Syntax.Total (t,Some u)|FStar_Syntax_Syntax.GTotal
      (t,Some u) ->
        {
          FStar_Syntax_Syntax.comp_univs = [u];
          FStar_Syntax_Syntax.effect_name = (comp_effect_name c);
          FStar_Syntax_Syntax.result_typ = t;
          FStar_Syntax_Syntax.effect_args = [];
          FStar_Syntax_Syntax.flags = (comp_flags c)
        }
    | uu____667 ->
        failwith "Assertion failed: Computation type without universe"
let is_named_tot c =
  match c.FStar_Syntax_Syntax.n with
  | FStar_Syntax_Syntax.Comp c1 ->
      FStar_Ident.lid_equals c1.FStar_Syntax_Syntax.effect_name
        FStar_Syntax_Const.effect_Tot_lid
  | FStar_Syntax_Syntax.Total uu____680 -> true
  | FStar_Syntax_Syntax.GTotal uu____686 -> false
let is_total_comp c =
  FStar_All.pipe_right (comp_flags c)
    (FStar_Util.for_some
       (fun uu___166_704  ->
          match uu___166_704 with
          | FStar_Syntax_Syntax.TOTAL |FStar_Syntax_Syntax.RETURN  -> true
          | uu____705 -> false))
let is_total_lcomp: FStar_Syntax_Syntax.lcomp -> Prims.bool =
  fun c  ->
    (FStar_Ident.lid_equals c.FStar_Syntax_Syntax.eff_name
       FStar_Syntax_Const.effect_Tot_lid)
      ||
      (FStar_All.pipe_right c.FStar_Syntax_Syntax.cflags
         (FStar_Util.for_some
            (fun uu___167_710  ->
               match uu___167_710 with
               | FStar_Syntax_Syntax.TOTAL |FStar_Syntax_Syntax.RETURN  ->
                   true
               | uu____711 -> false)))
let is_tot_or_gtot_lcomp: FStar_Syntax_Syntax.lcomp -> Prims.bool =
  fun c  ->
    ((FStar_Ident.lid_equals c.FStar_Syntax_Syntax.eff_name
        FStar_Syntax_Const.effect_Tot_lid)
       ||
       (FStar_Ident.lid_equals c.FStar_Syntax_Syntax.eff_name
          FStar_Syntax_Const.effect_GTot_lid))
      ||
      (FStar_All.pipe_right c.FStar_Syntax_Syntax.cflags
         (FStar_Util.for_some
            (fun uu___168_716  ->
               match uu___168_716 with
               | FStar_Syntax_Syntax.TOTAL |FStar_Syntax_Syntax.RETURN  ->
                   true
               | uu____717 -> false)))
let is_partial_return c =
  FStar_All.pipe_right (comp_flags c)
    (FStar_Util.for_some
       (fun uu___169_730  ->
          match uu___169_730 with
          | FStar_Syntax_Syntax.RETURN |FStar_Syntax_Syntax.PARTIAL_RETURN 
              -> true
          | uu____731 -> false))
let is_lcomp_partial_return: FStar_Syntax_Syntax.lcomp -> Prims.bool =
  fun c  ->
    FStar_All.pipe_right c.FStar_Syntax_Syntax.cflags
      (FStar_Util.for_some
         (fun uu___170_736  ->
            match uu___170_736 with
            | FStar_Syntax_Syntax.RETURN |FStar_Syntax_Syntax.PARTIAL_RETURN 
                -> true
            | uu____737 -> false))
let is_tot_or_gtot_comp c =
  (is_total_comp c) ||
    (FStar_Ident.lid_equals FStar_Syntax_Const.effect_GTot_lid
       (comp_effect_name c))
let is_pure_effect: FStar_Ident.lident -> Prims.bool =
  fun l  ->
    ((FStar_Ident.lid_equals l FStar_Syntax_Const.effect_Tot_lid) ||
       (FStar_Ident.lid_equals l FStar_Syntax_Const.effect_PURE_lid))
      || (FStar_Ident.lid_equals l FStar_Syntax_Const.effect_Pure_lid)
let is_pure_comp c =
  match c.FStar_Syntax_Syntax.n with
  | FStar_Syntax_Syntax.Total uu____763 -> true
  | FStar_Syntax_Syntax.GTotal uu____769 -> false
  | FStar_Syntax_Syntax.Comp ct ->
      ((is_total_comp c) ||
         (is_pure_effect ct.FStar_Syntax_Syntax.effect_name))
        ||
        (FStar_All.pipe_right ct.FStar_Syntax_Syntax.flags
           (FStar_Util.for_some
              (fun uu___171_777  ->
                 match uu___171_777 with
                 | FStar_Syntax_Syntax.LEMMA  -> true
                 | uu____778 -> false)))
let is_ghost_effect: FStar_Ident.lident -> Prims.bool =
  fun l  ->
    ((FStar_Ident.lid_equals FStar_Syntax_Const.effect_GTot_lid l) ||
       (FStar_Ident.lid_equals FStar_Syntax_Const.effect_GHOST_lid l))
      || (FStar_Ident.lid_equals FStar_Syntax_Const.effect_Ghost_lid l)
let is_pure_or_ghost_comp c =
  (is_pure_comp c) || (is_ghost_effect (comp_effect_name c))
let is_pure_lcomp: FStar_Syntax_Syntax.lcomp -> Prims.bool =
  fun lc  ->
    ((is_total_lcomp lc) || (is_pure_effect lc.FStar_Syntax_Syntax.eff_name))
      ||
      (FStar_All.pipe_right lc.FStar_Syntax_Syntax.cflags
         (FStar_Util.for_some
            (fun uu___172_797  ->
               match uu___172_797 with
               | FStar_Syntax_Syntax.LEMMA  -> true
               | uu____798 -> false)))
let is_pure_or_ghost_lcomp: FStar_Syntax_Syntax.lcomp -> Prims.bool =
  fun lc  ->
    (is_pure_lcomp lc) || (is_ghost_effect lc.FStar_Syntax_Syntax.eff_name)
let is_pure_or_ghost_function: FStar_Syntax_Syntax.term -> Prims.bool =
  fun t  ->
    let uu____805 =
      let uu____806 = FStar_Syntax_Subst.compress t in
      uu____806.FStar_Syntax_Syntax.n in
    match uu____805 with
    | FStar_Syntax_Syntax.Tm_arrow (uu____809,c) -> is_pure_or_ghost_comp c
    | uu____821 -> true
let is_lemma: FStar_Syntax_Syntax.term -> Prims.bool =
  fun t  ->
    let uu____825 =
      let uu____826 = FStar_Syntax_Subst.compress t in
      uu____826.FStar_Syntax_Syntax.n in
    match uu____825 with
    | FStar_Syntax_Syntax.Tm_arrow (uu____829,c) ->
        (match c.FStar_Syntax_Syntax.n with
         | FStar_Syntax_Syntax.Comp ct ->
             FStar_Ident.lid_equals ct.FStar_Syntax_Syntax.effect_name
               FStar_Syntax_Const.effect_Lemma_lid
         | uu____842 -> false)
    | uu____843 -> false
let head_and_args:
  FStar_Syntax_Syntax.term ->
    ((FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
      FStar_Syntax_Syntax.syntax*
      ((FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
      FStar_Syntax_Syntax.syntax* FStar_Syntax_Syntax.aqual) Prims.list)
  =
  fun t  ->
    let t1 = FStar_Syntax_Subst.compress t in
    match t1.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_app (head1,args) -> (head1, args)
    | uu____889 -> (t1, [])
let un_uinst: FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term =
  fun t  ->
    let t1 = FStar_Syntax_Subst.compress t in
    match t1.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_uinst (t2,uu____904) ->
        FStar_Syntax_Subst.compress t2
    | uu____909 -> t1
let is_smt_lemma: FStar_Syntax_Syntax.term -> Prims.bool =
  fun t  ->
    let uu____913 =
      let uu____914 = FStar_Syntax_Subst.compress t in
      uu____914.FStar_Syntax_Syntax.n in
    match uu____913 with
    | FStar_Syntax_Syntax.Tm_arrow (uu____917,c) ->
        (match c.FStar_Syntax_Syntax.n with
         | FStar_Syntax_Syntax.Comp ct when
             FStar_Ident.lid_equals ct.FStar_Syntax_Syntax.effect_name
               FStar_Syntax_Const.effect_Lemma_lid
             ->
             (match ct.FStar_Syntax_Syntax.effect_args with
              | _req::_ens::(pats,uu____933)::uu____934 ->
                  let pats' = unmeta pats in
                  let uu____965 = head_and_args pats' in
                  (match uu____965 with
                   | (head1,uu____976) ->
                       let uu____991 =
                         let uu____992 = un_uinst head1 in
                         uu____992.FStar_Syntax_Syntax.n in
                       (match uu____991 with
                        | FStar_Syntax_Syntax.Tm_fvar fv ->
                            FStar_Syntax_Syntax.fv_eq_lid fv
                              FStar_Syntax_Const.cons_lid
                        | uu____996 -> false))
              | uu____997 -> false)
         | uu____1003 -> false)
    | uu____1004 -> false
let is_ml_comp c =
  match c.FStar_Syntax_Syntax.n with
  | FStar_Syntax_Syntax.Comp c1 ->
      (FStar_Ident.lid_equals c1.FStar_Syntax_Syntax.effect_name
         FStar_Syntax_Const.effect_ML_lid)
        ||
        (FStar_All.pipe_right c1.FStar_Syntax_Syntax.flags
           (FStar_Util.for_some
              (fun uu___173_1018  ->
                 match uu___173_1018 with
                 | FStar_Syntax_Syntax.MLEFFECT  -> true
                 | uu____1019 -> false)))
  | uu____1020 -> false
let comp_result c =
  match c.FStar_Syntax_Syntax.n with
  | FStar_Syntax_Syntax.Total (t,_)|FStar_Syntax_Syntax.GTotal (t,_) -> t
  | FStar_Syntax_Syntax.Comp ct -> ct.FStar_Syntax_Syntax.result_typ
let set_result_typ c t =
  match c.FStar_Syntax_Syntax.n with
  | FStar_Syntax_Syntax.Total uu____1064 -> FStar_Syntax_Syntax.mk_Total t
  | FStar_Syntax_Syntax.GTotal uu____1070 -> FStar_Syntax_Syntax.mk_GTotal t
  | FStar_Syntax_Syntax.Comp ct ->
      FStar_Syntax_Syntax.mk_Comp
        (let uu___180_1077 = ct in
         {
           FStar_Syntax_Syntax.comp_univs =
             (uu___180_1077.FStar_Syntax_Syntax.comp_univs);
           FStar_Syntax_Syntax.effect_name =
             (uu___180_1077.FStar_Syntax_Syntax.effect_name);
           FStar_Syntax_Syntax.result_typ = t;
           FStar_Syntax_Syntax.effect_args =
             (uu___180_1077.FStar_Syntax_Syntax.effect_args);
           FStar_Syntax_Syntax.flags =
             (uu___180_1077.FStar_Syntax_Syntax.flags)
         })
let is_trivial_wp c =
  FStar_All.pipe_right (comp_flags c)
    (FStar_Util.for_some
       (fun uu___174_1090  ->
          match uu___174_1090 with
          | FStar_Syntax_Syntax.TOTAL |FStar_Syntax_Syntax.RETURN  -> true
          | uu____1091 -> false))
let primops: FStar_Ident.lident Prims.list =
  [FStar_Syntax_Const.op_Eq;
  FStar_Syntax_Const.op_notEq;
  FStar_Syntax_Const.op_LT;
  FStar_Syntax_Const.op_LTE;
  FStar_Syntax_Const.op_GT;
  FStar_Syntax_Const.op_GTE;
  FStar_Syntax_Const.op_Subtraction;
  FStar_Syntax_Const.op_Minus;
  FStar_Syntax_Const.op_Addition;
  FStar_Syntax_Const.op_Multiply;
  FStar_Syntax_Const.op_Division;
  FStar_Syntax_Const.op_Modulus;
  FStar_Syntax_Const.op_And;
  FStar_Syntax_Const.op_Or;
  FStar_Syntax_Const.op_Negation]
let is_primop_lid: FStar_Ident.lident -> Prims.bool =
  fun l  ->
    FStar_All.pipe_right primops
      (FStar_Util.for_some (FStar_Ident.lid_equals l))
let is_primop f =
  match f.FStar_Syntax_Syntax.n with
  | FStar_Syntax_Syntax.Tm_fvar fv ->
      is_primop_lid (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
  | uu____1113 -> false
let rec unascribe: FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term =
  fun e  ->
    let e1 = FStar_Syntax_Subst.compress e in
    match e1.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_ascribed (e2,uu____1119,uu____1120) ->
        unascribe e2
    | uu____1149 -> e1
let rec ascribe t k =
  match t.FStar_Syntax_Syntax.n with
  | FStar_Syntax_Syntax.Tm_ascribed (t',uu____1191,uu____1192) ->
      ascribe t' k
  | uu____1221 ->
      FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_ascribed (t, k, None))
        None t.FStar_Syntax_Syntax.pos
type eq_result =
  | Equal
  | NotEqual
  | Unknown
let uu___is_Equal: eq_result -> Prims.bool =
  fun projectee  ->
    match projectee with | Equal  -> true | uu____1243 -> false
let uu___is_NotEqual: eq_result -> Prims.bool =
  fun projectee  ->
    match projectee with | NotEqual  -> true | uu____1247 -> false
let uu___is_Unknown: eq_result -> Prims.bool =
  fun projectee  ->
    match projectee with | Unknown  -> true | uu____1251 -> false
let rec eq_tm:
  FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> eq_result =
  fun t1  ->
    fun t2  ->
      let t11 = unascribe t1 in
      let t21 = unascribe t2 in
      let equal_if uu___175_1271 = if uu___175_1271 then Equal else Unknown in
      let equal_iff uu___176_1276 = if uu___176_1276 then Equal else NotEqual in
      let eq_and f g = match f with | Equal  -> g () | uu____1290 -> Unknown in
      match ((t11.FStar_Syntax_Syntax.n), (t21.FStar_Syntax_Syntax.n)) with
      | (FStar_Syntax_Syntax.Tm_name a,FStar_Syntax_Syntax.Tm_name b) ->
          equal_if (FStar_Syntax_Syntax.bv_eq a b)
      | (FStar_Syntax_Syntax.Tm_fvar f,FStar_Syntax_Syntax.Tm_fvar g) ->
          let uu____1295 = FStar_Syntax_Syntax.fv_eq f g in
          equal_if uu____1295
      | (FStar_Syntax_Syntax.Tm_uinst (f,us),FStar_Syntax_Syntax.Tm_uinst
         (g,vs)) ->
          let uu____1308 = eq_tm f g in
          eq_and uu____1308
            (fun uu____1309  ->
               let uu____1310 = eq_univs_list us vs in equal_if uu____1310)
      | (FStar_Syntax_Syntax.Tm_constant c,FStar_Syntax_Syntax.Tm_constant d)
          ->
          let uu____1313 = FStar_Const.eq_const c d in equal_iff uu____1313
      | (FStar_Syntax_Syntax.Tm_uvar
         (u1,uu____1315),FStar_Syntax_Syntax.Tm_uvar (u2,uu____1317)) ->
          let uu____1342 = FStar_Unionfind.equivalent u1 u2 in
          equal_if uu____1342
      | (FStar_Syntax_Syntax.Tm_app (h1,args1),FStar_Syntax_Syntax.Tm_app
         (h2,args2)) ->
          let uu____1378 = eq_tm h1 h2 in
          eq_and uu____1378 (fun uu____1379  -> eq_args args1 args2)
      | (FStar_Syntax_Syntax.Tm_type u,FStar_Syntax_Syntax.Tm_type v1) ->
          let uu____1382 = eq_univs u v1 in equal_if uu____1382
      | (FStar_Syntax_Syntax.Tm_meta (t12,uu____1384),uu____1385) ->
          eq_tm t12 t21
      | (uu____1390,FStar_Syntax_Syntax.Tm_meta (t22,uu____1392)) ->
          eq_tm t11 t22
      | uu____1397 -> Unknown
and eq_args:
  FStar_Syntax_Syntax.args -> FStar_Syntax_Syntax.args -> eq_result =
  fun a1  ->
    fun a2  ->
      match (a1, a2) with
      | ([],[]) -> Equal
      | ((a,uu____1421)::a11,(b,uu____1424)::b1) ->
          let uu____1462 = eq_tm a b in
          (match uu____1462 with
           | Equal  -> eq_args a11 b1
           | uu____1463 -> Unknown)
      | uu____1464 -> Unknown
and eq_univs_list:
  FStar_Syntax_Syntax.universes ->
    FStar_Syntax_Syntax.universes -> Prims.bool
  =
  fun us  ->
    fun vs  ->
      ((FStar_List.length us) = (FStar_List.length vs)) &&
        (FStar_List.forall2 eq_univs us vs)
let rec unrefine: FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term =
  fun t  ->
    let t1 = FStar_Syntax_Subst.compress t in
    match t1.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_refine (x,uu____1478) ->
        unrefine x.FStar_Syntax_Syntax.sort
    | FStar_Syntax_Syntax.Tm_ascribed (t2,uu____1484,uu____1485) ->
        unrefine t2
    | uu____1514 -> t1
let rec is_unit: FStar_Syntax_Syntax.term -> Prims.bool =
  fun t  ->
    let uu____1518 =
      let uu____1519 = unrefine t in uu____1519.FStar_Syntax_Syntax.n in
    match uu____1518 with
    | FStar_Syntax_Syntax.Tm_type uu____1522 -> true
    | FStar_Syntax_Syntax.Tm_fvar fv ->
        (FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.unit_lid) ||
          (FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.squash_lid)
    | FStar_Syntax_Syntax.Tm_uinst (t1,uu____1525) -> is_unit t1
    | uu____1530 -> false
let rec non_informative: FStar_Syntax_Syntax.term -> Prims.bool =
  fun t  ->
    let uu____1534 =
      let uu____1535 = unrefine t in uu____1535.FStar_Syntax_Syntax.n in
    match uu____1534 with
    | FStar_Syntax_Syntax.Tm_type uu____1538 -> true
    | FStar_Syntax_Syntax.Tm_fvar fv ->
        ((FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.unit_lid) ||
           (FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.squash_lid))
          || (FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.erased_lid)
    | FStar_Syntax_Syntax.Tm_app (head1,uu____1541) -> non_informative head1
    | FStar_Syntax_Syntax.Tm_uinst (t1,uu____1557) -> non_informative t1
    | FStar_Syntax_Syntax.Tm_arrow (uu____1562,c) ->
        (is_tot_or_gtot_comp c) && (non_informative (comp_result c))
    | uu____1574 -> false
let is_fun: FStar_Syntax_Syntax.term -> Prims.bool =
  fun e  ->
    let uu____1578 =
      let uu____1579 = FStar_Syntax_Subst.compress e in
      uu____1579.FStar_Syntax_Syntax.n in
    match uu____1578 with
    | FStar_Syntax_Syntax.Tm_abs uu____1582 -> true
    | uu____1597 -> false
let is_function_typ: FStar_Syntax_Syntax.term -> Prims.bool =
  fun t  ->
    let uu____1601 =
      let uu____1602 = FStar_Syntax_Subst.compress t in
      uu____1602.FStar_Syntax_Syntax.n in
    match uu____1601 with
    | FStar_Syntax_Syntax.Tm_arrow uu____1605 -> true
    | uu____1613 -> false
let rec pre_typ: FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term =
  fun t  ->
    let t1 = FStar_Syntax_Subst.compress t in
    match t1.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_refine (x,uu____1619) ->
        pre_typ x.FStar_Syntax_Syntax.sort
    | FStar_Syntax_Syntax.Tm_ascribed (t2,uu____1625,uu____1626) ->
        pre_typ t2
    | uu____1655 -> t1
let destruct:
  FStar_Syntax_Syntax.term ->
    FStar_Ident.lident ->
      ((FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
        FStar_Syntax_Syntax.syntax* FStar_Syntax_Syntax.aqual) Prims.list
        Prims.option
  =
  fun typ  ->
    fun lid  ->
      let typ1 = FStar_Syntax_Subst.compress typ in
      let uu____1669 =
        let uu____1670 = un_uinst typ1 in uu____1670.FStar_Syntax_Syntax.n in
      match uu____1669 with
      | FStar_Syntax_Syntax.Tm_app (head1,args) ->
          let head2 = un_uinst head1 in
          (match head2.FStar_Syntax_Syntax.n with
           | FStar_Syntax_Syntax.Tm_fvar tc when
               FStar_Syntax_Syntax.fv_eq_lid tc lid -> Some args
           | uu____1708 -> None)
      | FStar_Syntax_Syntax.Tm_fvar tc when
          FStar_Syntax_Syntax.fv_eq_lid tc lid -> Some []
      | uu____1724 -> None
let lids_of_sigelt:
  FStar_Syntax_Syntax.sigelt -> FStar_Ident.lident Prims.list =
  fun se  ->
    match se.FStar_Syntax_Syntax.sigel with
    | FStar_Syntax_Syntax.Sig_let (_,lids,_)|FStar_Syntax_Syntax.Sig_bundle
      (_,lids) -> lids
    | FStar_Syntax_Syntax.Sig_inductive_typ (lid,_,_,_,_,_)
      |FStar_Syntax_Syntax.Sig_effect_abbrev (lid,_,_,_,_)
       |FStar_Syntax_Syntax.Sig_datacon (lid,_,_,_,_,_)
        |FStar_Syntax_Syntax.Sig_declare_typ (lid,_,_)
         |FStar_Syntax_Syntax.Sig_assume (lid,_)
        -> [lid]
    | FStar_Syntax_Syntax.Sig_new_effect_for_free n1
      |FStar_Syntax_Syntax.Sig_new_effect n1 ->
        [n1.FStar_Syntax_Syntax.mname]
    | FStar_Syntax_Syntax.Sig_sub_effect _
      |FStar_Syntax_Syntax.Sig_pragma _|FStar_Syntax_Syntax.Sig_main _ -> []
let lid_of_sigelt:
  FStar_Syntax_Syntax.sigelt -> FStar_Ident.lident Prims.option =
  fun se  ->
    match lids_of_sigelt se with | l::[] -> Some l | uu____1778 -> None
let quals_of_sigelt:
  FStar_Syntax_Syntax.sigelt -> FStar_Syntax_Syntax.qualifier Prims.list =
  fun x  -> x.FStar_Syntax_Syntax.sigquals
let range_of_sigelt: FStar_Syntax_Syntax.sigelt -> FStar_Range.range =
  fun x  -> x.FStar_Syntax_Syntax.sigrng
let range_of_lb uu___177_1800 =
  match uu___177_1800 with
  | (FStar_Util.Inl x,uu____1807,uu____1808) ->
      FStar_Syntax_Syntax.range_of_bv x
  | (FStar_Util.Inr l,uu____1812,uu____1813) -> FStar_Ident.range_of_lid l
let range_of_arg uu____1830 =
  match uu____1830 with | (hd1,uu____1836) -> hd1.FStar_Syntax_Syntax.pos
let range_of_args args r =
  FStar_All.pipe_right args
    (FStar_List.fold_left
       (fun r1  -> fun a  -> FStar_Range.union_ranges r1 (range_of_arg a)) r)
let mk_app f args =
  let r = range_of_args args f.FStar_Syntax_Syntax.pos in
  FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_app (f, args)) None r
let mk_data l args =
  match args with
  | [] ->
      let uu____1950 =
        let uu____1953 =
          let uu____1954 =
            let uu____1959 =
              FStar_Syntax_Syntax.fvar l FStar_Syntax_Syntax.Delta_constant
                (Some FStar_Syntax_Syntax.Data_ctor) in
            (uu____1959,
              (FStar_Syntax_Syntax.Meta_desugared
                 FStar_Syntax_Syntax.Data_app)) in
          FStar_Syntax_Syntax.Tm_meta uu____1954 in
        FStar_Syntax_Syntax.mk uu____1953 in
      uu____1950 None (FStar_Ident.range_of_lid l)
  | uu____1968 ->
      let e =
        let uu____1977 =
          FStar_Syntax_Syntax.fvar l FStar_Syntax_Syntax.Delta_constant
            (Some FStar_Syntax_Syntax.Data_ctor) in
        mk_app uu____1977 args in
      FStar_Syntax_Syntax.mk
        (FStar_Syntax_Syntax.Tm_meta
           (e,
             (FStar_Syntax_Syntax.Meta_desugared FStar_Syntax_Syntax.Data_app)))
        None e.FStar_Syntax_Syntax.pos
let mangle_field_name: FStar_Ident.ident -> FStar_Ident.ident =
  fun x  ->
    FStar_Ident.mk_ident
      ((Prims.strcat "^fname^" x.FStar_Ident.idText),
        (x.FStar_Ident.idRange))
let unmangle_field_name: FStar_Ident.ident -> FStar_Ident.ident =
  fun x  ->
    if FStar_Util.starts_with x.FStar_Ident.idText "^fname^"
    then
      let uu____1992 =
        let uu____1995 =
          FStar_Util.substring_from x.FStar_Ident.idText
            (Prims.parse_int "7") in
        (uu____1995, (x.FStar_Ident.idRange)) in
      FStar_Ident.mk_ident uu____1992
    else x
let field_projector_prefix: Prims.string = "__proj__"
let field_projector_sep: Prims.string = "__item__"
let field_projector_contains_constructor: Prims.string -> Prims.bool =
  fun s  -> FStar_Util.starts_with s field_projector_prefix
let mk_field_projector_name_from_string:
  Prims.string -> Prims.string -> Prims.string =
  fun constr  ->
    fun field  ->
      Prims.strcat field_projector_prefix
        (Prims.strcat constr (Prims.strcat field_projector_sep field))
let mk_field_projector_name_from_ident:
  FStar_Ident.lident -> FStar_Ident.ident -> FStar_Ident.lident =
  fun lid  ->
    fun i  ->
      let j = unmangle_field_name i in
      let jtext = j.FStar_Ident.idText in
      let newi =
        if field_projector_contains_constructor jtext
        then j
        else
          FStar_Ident.mk_ident
            ((mk_field_projector_name_from_string
                (lid.FStar_Ident.ident).FStar_Ident.idText jtext),
              (i.FStar_Ident.idRange)) in
      FStar_Ident.lid_of_ids (FStar_List.append lid.FStar_Ident.ns [newi])
let mk_field_projector_name:
  FStar_Ident.lident ->
    FStar_Syntax_Syntax.bv ->
      Prims.int -> (FStar_Ident.lident* FStar_Syntax_Syntax.bv)
  =
  fun lid  ->
    fun x  ->
      fun i  ->
        let nm =
          let uu____2028 = FStar_Syntax_Syntax.is_null_bv x in
          if uu____2028
          then
            let uu____2029 =
              let uu____2032 =
                let uu____2033 = FStar_Util.string_of_int i in
                Prims.strcat "_" uu____2033 in
              let uu____2034 = FStar_Syntax_Syntax.range_of_bv x in
              (uu____2032, uu____2034) in
            FStar_Ident.mk_ident uu____2029
          else x.FStar_Syntax_Syntax.ppname in
        let y =
          let uu___181_2037 = x in
          {
            FStar_Syntax_Syntax.ppname = nm;
            FStar_Syntax_Syntax.index =
              (uu___181_2037.FStar_Syntax_Syntax.index);
            FStar_Syntax_Syntax.sort =
              (uu___181_2037.FStar_Syntax_Syntax.sort)
          } in
        let uu____2038 = mk_field_projector_name_from_ident lid nm in
        (uu____2038, y)
let set_uvar uv t =
  let uu____2055 = FStar_Unionfind.find uv in
  match uu____2055 with
  | FStar_Syntax_Syntax.Fixed uu____2058 ->
      let uu____2059 =
        let uu____2060 =
          let uu____2061 = FStar_Unionfind.uvar_id uv in
          FStar_All.pipe_left FStar_Util.string_of_int uu____2061 in
        FStar_Util.format1 "Changing a fixed uvar! ?%s\n" uu____2060 in
      failwith uu____2059
  | uu____2063 -> FStar_Unionfind.change uv (FStar_Syntax_Syntax.Fixed t)
let qualifier_equal:
  FStar_Syntax_Syntax.qualifier ->
    FStar_Syntax_Syntax.qualifier -> Prims.bool
  =
  fun q1  ->
    fun q2  ->
      match (q1, q2) with
      | (FStar_Syntax_Syntax.Discriminator
         l1,FStar_Syntax_Syntax.Discriminator l2) ->
          FStar_Ident.lid_equals l1 l2
      | (FStar_Syntax_Syntax.Projector
         (l1a,l1b),FStar_Syntax_Syntax.Projector (l2a,l2b)) ->
          (FStar_Ident.lid_equals l1a l2a) &&
            (l1b.FStar_Ident.idText = l2b.FStar_Ident.idText)
      | (FStar_Syntax_Syntax.RecordType
         (ns1,f1),FStar_Syntax_Syntax.RecordType (ns2,f2))
        |(FStar_Syntax_Syntax.RecordConstructor
          (ns1,f1),FStar_Syntax_Syntax.RecordConstructor (ns2,f2)) ->
          ((((FStar_List.length ns1) = (FStar_List.length ns2)) &&
              (FStar_List.forall2
                 (fun x1  ->
                    fun x2  -> x1.FStar_Ident.idText = x2.FStar_Ident.idText)
                 f1 f2))
             && ((FStar_List.length f1) = (FStar_List.length f2)))
            &&
            (FStar_List.forall2
               (fun x1  ->
                  fun x2  -> x1.FStar_Ident.idText = x2.FStar_Ident.idText)
               f1 f2)
      | uu____2110 -> q1 = q2
let abs:
  FStar_Syntax_Syntax.binders ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.lcomp,(FStar_Ident.lident*
                                   FStar_Syntax_Syntax.cflags Prims.list))
        FStar_Util.either Prims.option -> FStar_Syntax_Syntax.term
  =
  fun bs  ->
    fun t  ->
      fun lopt  ->
        let close_lopt lopt1 =
          match lopt1 with
          | None |Some (FStar_Util.Inr _) -> lopt1
          | Some (FStar_Util.Inl lc) ->
              let uu____2185 =
                let uu____2191 = FStar_Syntax_Subst.close_lcomp bs lc in
                FStar_Util.Inl uu____2191 in
              Some uu____2185 in
        match bs with
        | [] -> t
        | uu____2202 ->
            let body =
              let uu____2204 = FStar_Syntax_Subst.close bs t in
              FStar_Syntax_Subst.compress uu____2204 in
            (match ((body.FStar_Syntax_Syntax.n), lopt) with
             | (FStar_Syntax_Syntax.Tm_abs (bs',t1,lopt'),None ) ->
                 let uu____2247 =
                   let uu____2250 =
                     let uu____2251 =
                       let uu____2266 =
                         let uu____2270 = FStar_Syntax_Subst.close_binders bs in
                         FStar_List.append uu____2270 bs' in
                       let uu____2276 = close_lopt lopt' in
                       (uu____2266, t1, uu____2276) in
                     FStar_Syntax_Syntax.Tm_abs uu____2251 in
                   FStar_Syntax_Syntax.mk uu____2250 in
                 uu____2247 None t1.FStar_Syntax_Syntax.pos
             | uu____2302 ->
                 let uu____2311 =
                   let uu____2314 =
                     let uu____2315 =
                       let uu____2330 = FStar_Syntax_Subst.close_binders bs in
                       let uu____2331 = close_lopt lopt in
                       (uu____2330, body, uu____2331) in
                     FStar_Syntax_Syntax.Tm_abs uu____2315 in
                   FStar_Syntax_Syntax.mk uu____2314 in
                 uu____2311 None t.FStar_Syntax_Syntax.pos)
let arrow:
  (FStar_Syntax_Syntax.bv* FStar_Syntax_Syntax.aqual) Prims.list ->
    (FStar_Syntax_Syntax.comp',Prims.unit) FStar_Syntax_Syntax.syntax ->
      (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
        FStar_Syntax_Syntax.syntax
  =
  fun bs  ->
    fun c  ->
      match bs with
      | [] -> comp_result c
      | uu____2374 ->
          let uu____2378 =
            let uu____2381 =
              let uu____2382 =
                let uu____2390 = FStar_Syntax_Subst.close_binders bs in
                let uu____2391 = FStar_Syntax_Subst.close_comp bs c in
                (uu____2390, uu____2391) in
              FStar_Syntax_Syntax.Tm_arrow uu____2382 in
            FStar_Syntax_Syntax.mk uu____2381 in
          uu____2378 None c.FStar_Syntax_Syntax.pos
let flat_arrow:
  (FStar_Syntax_Syntax.bv* FStar_Syntax_Syntax.aqual) Prims.list ->
    (FStar_Syntax_Syntax.comp',Prims.unit) FStar_Syntax_Syntax.syntax ->
      (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
        FStar_Syntax_Syntax.syntax
  =
  fun bs  ->
    fun c  ->
      let t = arrow bs c in
      let uu____2421 =
        let uu____2422 = FStar_Syntax_Subst.compress t in
        uu____2422.FStar_Syntax_Syntax.n in
      match uu____2421 with
      | FStar_Syntax_Syntax.Tm_arrow (bs1,c1) ->
          (match c1.FStar_Syntax_Syntax.n with
           | FStar_Syntax_Syntax.Total (tres,uu____2442) ->
               let uu____2449 =
                 let uu____2450 = FStar_Syntax_Subst.compress tres in
                 uu____2450.FStar_Syntax_Syntax.n in
               (match uu____2449 with
                | FStar_Syntax_Syntax.Tm_arrow (bs',c') ->
                    let uu____2467 = FStar_ST.read t.FStar_Syntax_Syntax.tk in
                    (FStar_Syntax_Syntax.mk
                       (FStar_Syntax_Syntax.Tm_arrow
                          ((FStar_List.append bs1 bs'), c'))) uu____2467
                      t.FStar_Syntax_Syntax.pos
                | uu____2487 -> t)
           | uu____2488 -> t)
      | uu____2489 -> t
let refine:
  FStar_Syntax_Syntax.bv ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
        FStar_Syntax_Syntax.syntax
  =
  fun b  ->
    fun t  ->
      let uu____2498 =
        FStar_ST.read (b.FStar_Syntax_Syntax.sort).FStar_Syntax_Syntax.tk in
      let uu____2503 =
        let uu____2504 = FStar_Syntax_Syntax.range_of_bv b in
        FStar_Range.union_ranges uu____2504 t.FStar_Syntax_Syntax.pos in
      let uu____2505 =
        let uu____2508 =
          let uu____2509 =
            let uu____2514 =
              let uu____2515 =
                let uu____2516 = FStar_Syntax_Syntax.mk_binder b in
                [uu____2516] in
              FStar_Syntax_Subst.close uu____2515 t in
            (b, uu____2514) in
          FStar_Syntax_Syntax.Tm_refine uu____2509 in
        FStar_Syntax_Syntax.mk uu____2508 in
      uu____2505 uu____2498 uu____2503
let branch: FStar_Syntax_Syntax.branch -> FStar_Syntax_Syntax.branch =
  fun b  -> FStar_Syntax_Subst.close_branch b
let rec arrow_formals_comp:
  FStar_Syntax_Syntax.term ->
    ((FStar_Syntax_Syntax.bv* FStar_Syntax_Syntax.aqual) Prims.list*
      FStar_Syntax_Syntax.comp)
  =
  fun k  ->
    let k1 = FStar_Syntax_Subst.compress k in
    match k1.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_arrow (bs,c) ->
        let uu____2554 = FStar_Syntax_Subst.open_comp bs c in
        (match uu____2554 with
         | (bs1,c1) ->
             let uu____2564 = is_tot_or_gtot_comp c1 in
             if uu____2564
             then
               let uu____2570 = arrow_formals_comp (comp_result c1) in
               (match uu____2570 with
                | (bs',k2) -> ((FStar_List.append bs1 bs'), k2))
             else (bs1, c1))
    | uu____2595 ->
        let uu____2596 = FStar_Syntax_Syntax.mk_Total k1 in ([], uu____2596)
let rec arrow_formals:
  FStar_Syntax_Syntax.term ->
    ((FStar_Syntax_Syntax.bv* FStar_Syntax_Syntax.aqual) Prims.list*
      (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
      FStar_Syntax_Syntax.syntax)
  =
  fun k  ->
    let uu____2612 = arrow_formals_comp k in
    match uu____2612 with | (bs,c) -> (bs, (comp_result c))
let abs_formals:
  FStar_Syntax_Syntax.term ->
    (FStar_Syntax_Syntax.binders* FStar_Syntax_Syntax.term*
      (FStar_Syntax_Syntax.lcomp,(FStar_Ident.lident*
                                   FStar_Syntax_Syntax.cflags Prims.list))
      FStar_Util.either Prims.option)
  =
  fun t  ->
    let subst_lcomp_opt s l =
      match l with
      | Some (FStar_Util.Inl l1) ->
          let l2 =
            let uu___182_2693 = l1 in
            let uu____2694 =
              FStar_Syntax_Subst.subst s l1.FStar_Syntax_Syntax.res_typ in
            {
              FStar_Syntax_Syntax.eff_name =
                (uu___182_2693.FStar_Syntax_Syntax.eff_name);
              FStar_Syntax_Syntax.res_typ = uu____2694;
              FStar_Syntax_Syntax.cflags =
                (uu___182_2693.FStar_Syntax_Syntax.cflags);
              FStar_Syntax_Syntax.comp =
                (fun uu____2697  ->
                   let uu____2698 = l1.FStar_Syntax_Syntax.comp () in
                   FStar_Syntax_Subst.subst_comp s uu____2698)
            } in
          Some (FStar_Util.Inl l2)
      | uu____2707 -> l in
    let rec aux t1 abs_body_lcomp =
      let uu____2745 =
        let uu____2746 =
          let uu____2749 = FStar_Syntax_Subst.compress t1 in
          FStar_All.pipe_left unascribe uu____2749 in
        uu____2746.FStar_Syntax_Syntax.n in
      match uu____2745 with
      | FStar_Syntax_Syntax.Tm_abs (bs,t2,what) ->
          let uu____2787 = aux t2 what in
          (match uu____2787 with
           | (bs',t3,what1) -> ((FStar_List.append bs bs'), t3, what1))
      | uu____2844 -> ([], t1, abs_body_lcomp) in
    let uu____2856 = aux t None in
    match uu____2856 with
    | (bs,t1,abs_body_lcomp) ->
        let uu____2904 = FStar_Syntax_Subst.open_term' bs t1 in
        (match uu____2904 with
         | (bs1,t2,opening) ->
             let abs_body_lcomp1 = subst_lcomp_opt opening abs_body_lcomp in
             (bs1, t2, abs_body_lcomp1))
let mk_letbinding:
  (FStar_Syntax_Syntax.bv,FStar_Syntax_Syntax.fv) FStar_Util.either ->
    FStar_Syntax_Syntax.univ_name Prims.list ->
      (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
        FStar_Syntax_Syntax.syntax ->
        FStar_Ident.lident ->
          (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
            FStar_Syntax_Syntax.syntax -> FStar_Syntax_Syntax.letbinding
  =
  fun lbname  ->
    fun univ_vars  ->
      fun typ  ->
        fun eff  ->
          fun def  ->
            {
              FStar_Syntax_Syntax.lbname = lbname;
              FStar_Syntax_Syntax.lbunivs = univ_vars;
              FStar_Syntax_Syntax.lbtyp = typ;
              FStar_Syntax_Syntax.lbeff = eff;
              FStar_Syntax_Syntax.lbdef = def
            }
let close_univs_and_mk_letbinding:
  FStar_Syntax_Syntax.fv Prims.list Prims.option ->
    (FStar_Syntax_Syntax.bv,FStar_Syntax_Syntax.fv) FStar_Util.either ->
      FStar_Ident.ident Prims.list ->
        FStar_Syntax_Syntax.term ->
          FStar_Ident.lident ->
            FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.letbinding
  =
  fun recs  ->
    fun lbname  ->
      fun univ_vars  ->
        fun typ  ->
          fun eff  ->
            fun def  ->
              let def1 =
                match (recs, univ_vars) with
                | (None ,_)|(_,[]) -> def
                | (Some fvs,uu____3004) ->
                    let universes =
                      FStar_All.pipe_right univ_vars
                        (FStar_List.map
                           (fun _0_25  -> FStar_Syntax_Syntax.U_name _0_25)) in
                    let inst1 =
                      FStar_All.pipe_right fvs
                        (FStar_List.map
                           (fun fv  ->
                              (((fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v),
                                universes))) in
                    FStar_Syntax_InstFV.instantiate inst1 def in
              let typ1 = FStar_Syntax_Subst.close_univ_vars univ_vars typ in
              let def2 = FStar_Syntax_Subst.close_univ_vars univ_vars def1 in
              mk_letbinding lbname univ_vars typ1 eff def2
let open_univ_vars_binders_and_comp:
  FStar_Syntax_Syntax.univ_names ->
    (FStar_Syntax_Syntax.bv* FStar_Syntax_Syntax.aqual) Prims.list ->
      FStar_Syntax_Syntax.comp ->
        (FStar_Syntax_Syntax.univ_names* (FStar_Syntax_Syntax.bv*
          FStar_Syntax_Syntax.aqual) Prims.list* FStar_Syntax_Syntax.comp)
  =
  fun uvs  ->
    fun binders  ->
      fun c  ->
        match binders with
        | [] ->
            let uu____3065 = FStar_Syntax_Subst.open_univ_vars_comp uvs c in
            (match uu____3065 with | (uvs1,c1) -> (uvs1, [], c1))
        | uu____3081 ->
            let t' = arrow binders c in
            let uu____3088 = FStar_Syntax_Subst.open_univ_vars uvs t' in
            (match uu____3088 with
             | (uvs1,t'1) ->
                 let uu____3099 =
                   let uu____3100 = FStar_Syntax_Subst.compress t'1 in
                   uu____3100.FStar_Syntax_Syntax.n in
                 (match uu____3099 with
                  | FStar_Syntax_Syntax.Tm_arrow (binders1,c1) ->
                      (uvs1, binders1, c1)
                  | uu____3126 -> failwith "Impossible"))
let is_tuple_constructor: FStar_Syntax_Syntax.typ -> Prims.bool =
  fun t  ->
    match t.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_fvar fv ->
        FStar_Util.starts_with
          ((fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v).FStar_Ident.str
          "Prims.tuple"
    | uu____3141 -> false
let mk_tuple_lid: Prims.int -> FStar_Range.range -> FStar_Ident.lident =
  fun n1  ->
    fun r  ->
      let t =
        let uu____3149 = FStar_Util.string_of_int n1 in
        FStar_Util.format1 "tuple%s" uu____3149 in
      let uu____3150 = FStar_Syntax_Const.pconst t in
      FStar_Ident.set_lid_range uu____3150 r
let mk_tuple_data_lid: Prims.int -> FStar_Range.range -> FStar_Ident.lident =
  fun n1  ->
    fun r  ->
      let t =
        let uu____3158 = FStar_Util.string_of_int n1 in
        FStar_Util.format1 "Mktuple%s" uu____3158 in
      let uu____3159 = FStar_Syntax_Const.pconst t in
      FStar_Ident.set_lid_range uu____3159 r
let is_tuple_data_lid: FStar_Ident.lident -> Prims.int -> Prims.bool =
  fun f  ->
    fun n1  ->
      let uu____3166 = mk_tuple_data_lid n1 FStar_Range.dummyRange in
      FStar_Ident.lid_equals f uu____3166
let is_tuple_data_lid': FStar_Ident.lident -> Prims.bool =
  fun f  ->
    (f.FStar_Ident.nsstr = "Prims") &&
      (FStar_Util.starts_with (f.FStar_Ident.ident).FStar_Ident.idText
         "Mktuple")
let is_tuple_constructor_lid: FStar_Ident.lident -> Prims.bool =
  fun lid  ->
    FStar_Util.starts_with (FStar_Ident.text_of_lid lid) "Prims.tuple"
let is_dtuple_constructor_lid: FStar_Ident.lident -> Prims.bool =
  fun lid  ->
    (lid.FStar_Ident.nsstr = "Prims") &&
      (FStar_Util.starts_with (lid.FStar_Ident.ident).FStar_Ident.idText
         "Prims.dtuple")
let is_dtuple_constructor: FStar_Syntax_Syntax.typ -> Prims.bool =
  fun t  ->
    match t.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_fvar fv ->
        is_dtuple_constructor_lid
          (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
    | uu____3184 -> false
let mk_dtuple_lid: Prims.int -> FStar_Range.range -> FStar_Ident.lident =
  fun n1  ->
    fun r  ->
      let t =
        let uu____3192 = FStar_Util.string_of_int n1 in
        FStar_Util.format1 "dtuple%s" uu____3192 in
      let uu____3193 = FStar_Syntax_Const.pconst t in
      FStar_Ident.set_lid_range uu____3193 r
let mk_dtuple_data_lid: Prims.int -> FStar_Range.range -> FStar_Ident.lident
  =
  fun n1  ->
    fun r  ->
      let t =
        let uu____3201 = FStar_Util.string_of_int n1 in
        FStar_Util.format1 "Mkdtuple%s" uu____3201 in
      let uu____3202 = FStar_Syntax_Const.pconst t in
      FStar_Ident.set_lid_range uu____3202 r
let is_dtuple_data_lid': FStar_Ident.lident -> Prims.bool =
  fun f  -> FStar_Util.starts_with (FStar_Ident.text_of_lid f) "Mkdtuple"
let is_lid_equality: FStar_Ident.lident -> Prims.bool =
  fun x  -> FStar_Ident.lid_equals x FStar_Syntax_Const.eq2_lid
let is_forall: FStar_Ident.lident -> Prims.bool =
  fun lid  -> FStar_Ident.lid_equals lid FStar_Syntax_Const.forall_lid
let is_exists: FStar_Ident.lident -> Prims.bool =
  fun lid  -> FStar_Ident.lid_equals lid FStar_Syntax_Const.exists_lid
let is_qlid: FStar_Ident.lident -> Prims.bool =
  fun lid  -> (is_forall lid) || (is_exists lid)
let is_equality x = is_lid_equality x.FStar_Syntax_Syntax.v
let lid_is_connective: FStar_Ident.lident -> Prims.bool =
  let lst =
    [FStar_Syntax_Const.and_lid;
    FStar_Syntax_Const.or_lid;
    FStar_Syntax_Const.not_lid;
    FStar_Syntax_Const.iff_lid;
    FStar_Syntax_Const.imp_lid] in
  fun lid  -> FStar_Util.for_some (FStar_Ident.lid_equals lid) lst
let is_constructor:
  FStar_Syntax_Syntax.term -> FStar_Ident.lident -> Prims.bool =
  fun t  ->
    fun lid  ->
      let uu____3240 =
        let uu____3241 = pre_typ t in uu____3241.FStar_Syntax_Syntax.n in
      match uu____3240 with
      | FStar_Syntax_Syntax.Tm_fvar tc ->
          FStar_Ident.lid_equals
            (tc.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v lid
      | uu____3249 -> false
let rec is_constructed_typ:
  FStar_Syntax_Syntax.term -> FStar_Ident.lident -> Prims.bool =
  fun t  ->
    fun lid  ->
      let uu____3256 =
        let uu____3257 = pre_typ t in uu____3257.FStar_Syntax_Syntax.n in
      match uu____3256 with
      | FStar_Syntax_Syntax.Tm_fvar uu____3260 -> is_constructor t lid
      | FStar_Syntax_Syntax.Tm_app (t1,uu____3262) ->
          is_constructed_typ t1 lid
      | uu____3277 -> false
let rec get_tycon:
  FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term Prims.option =
  fun t  ->
    let t1 = pre_typ t in
    match t1.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_bvar _
      |FStar_Syntax_Syntax.Tm_name _|FStar_Syntax_Syntax.Tm_fvar _ -> 
        Some t1
    | FStar_Syntax_Syntax.Tm_app (t2,uu____3288) -> get_tycon t2
    | uu____3303 -> None
let is_interpreted: FStar_Ident.lident -> Prims.bool =
  fun l  ->
    let theory_syms =
      [FStar_Syntax_Const.op_Eq;
      FStar_Syntax_Const.op_notEq;
      FStar_Syntax_Const.op_LT;
      FStar_Syntax_Const.op_LTE;
      FStar_Syntax_Const.op_GT;
      FStar_Syntax_Const.op_GTE;
      FStar_Syntax_Const.op_Subtraction;
      FStar_Syntax_Const.op_Minus;
      FStar_Syntax_Const.op_Addition;
      FStar_Syntax_Const.op_Multiply;
      FStar_Syntax_Const.op_Division;
      FStar_Syntax_Const.op_Modulus;
      FStar_Syntax_Const.op_And;
      FStar_Syntax_Const.op_Or;
      FStar_Syntax_Const.op_Negation] in
    FStar_Util.for_some (FStar_Ident.lid_equals l) theory_syms
let ktype:
  (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
    FStar_Syntax_Syntax.syntax
  =
  (FStar_Syntax_Syntax.mk
     (FStar_Syntax_Syntax.Tm_type FStar_Syntax_Syntax.U_unknown)) None
    FStar_Range.dummyRange
let ktype0:
  (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
    FStar_Syntax_Syntax.syntax
  =
  (FStar_Syntax_Syntax.mk
     (FStar_Syntax_Syntax.Tm_type FStar_Syntax_Syntax.U_zero)) None
    FStar_Range.dummyRange
let type_u:
  Prims.unit ->
    ((FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
      FStar_Syntax_Syntax.syntax* FStar_Syntax_Syntax.universe)
  =
  fun uu____3333  ->
    let u =
      let uu____3337 = FStar_Unionfind.fresh None in
      FStar_All.pipe_left (fun _0_26  -> FStar_Syntax_Syntax.U_unif _0_26)
        uu____3337 in
    let uu____3343 =
      (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_type u)) None
        FStar_Range.dummyRange in
    (uu____3343, u)
let kt_kt: FStar_Syntax_Syntax.term = FStar_Syntax_Const.kunary ktype0 ktype0
let kt_kt_kt: FStar_Syntax_Syntax.term =
  FStar_Syntax_Const.kbin ktype0 ktype0 ktype0
let fvar_const: FStar_Ident.lident -> FStar_Syntax_Syntax.term =
  fun l  ->
    FStar_Syntax_Syntax.fvar l FStar_Syntax_Syntax.Delta_constant None
let tand: FStar_Syntax_Syntax.term = fvar_const FStar_Syntax_Const.and_lid
let tor: FStar_Syntax_Syntax.term = fvar_const FStar_Syntax_Const.or_lid
let timp: FStar_Syntax_Syntax.term = fvar_const FStar_Syntax_Const.imp_lid
let tiff: FStar_Syntax_Syntax.term = fvar_const FStar_Syntax_Const.iff_lid
let t_bool: FStar_Syntax_Syntax.term = fvar_const FStar_Syntax_Const.bool_lid
let t_false: FStar_Syntax_Syntax.term =
  fvar_const FStar_Syntax_Const.false_lid
let t_true: FStar_Syntax_Syntax.term = fvar_const FStar_Syntax_Const.true_lid
let b2t_v: FStar_Syntax_Syntax.term = fvar_const FStar_Syntax_Const.b2t_lid
let t_not: FStar_Syntax_Syntax.term = fvar_const FStar_Syntax_Const.not_lid
let mk_conj_opt:
  FStar_Syntax_Syntax.term Prims.option ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
        FStar_Syntax_Syntax.syntax Prims.option
  =
  fun phi1  ->
    fun phi2  ->
      match phi1 with
      | None  -> Some phi2
      | Some phi11 ->
          let uu____3370 =
            let uu____3373 =
              FStar_Range.union_ranges phi11.FStar_Syntax_Syntax.pos
                phi2.FStar_Syntax_Syntax.pos in
            let uu____3374 =
              let uu____3377 =
                let uu____3378 =
                  let uu____3388 =
                    let uu____3390 = FStar_Syntax_Syntax.as_arg phi11 in
                    let uu____3391 =
                      let uu____3393 = FStar_Syntax_Syntax.as_arg phi2 in
                      [uu____3393] in
                    uu____3390 :: uu____3391 in
                  (tand, uu____3388) in
                FStar_Syntax_Syntax.Tm_app uu____3378 in
              FStar_Syntax_Syntax.mk uu____3377 in
            uu____3374 None uu____3373 in
          Some uu____3370
let mk_binop op_t phi1 phi2 =
  let uu____3428 =
    FStar_Range.union_ranges phi1.FStar_Syntax_Syntax.pos
      phi2.FStar_Syntax_Syntax.pos in
  let uu____3429 =
    let uu____3432 =
      let uu____3433 =
        let uu____3443 =
          let uu____3445 = FStar_Syntax_Syntax.as_arg phi1 in
          let uu____3446 =
            let uu____3448 = FStar_Syntax_Syntax.as_arg phi2 in [uu____3448] in
          uu____3445 :: uu____3446 in
        (op_t, uu____3443) in
      FStar_Syntax_Syntax.Tm_app uu____3433 in
    FStar_Syntax_Syntax.mk uu____3432 in
  uu____3429 None uu____3428
let mk_neg phi =
  let uu____3469 =
    let uu____3472 =
      let uu____3473 =
        let uu____3483 =
          let uu____3485 = FStar_Syntax_Syntax.as_arg phi in [uu____3485] in
        (t_not, uu____3483) in
      FStar_Syntax_Syntax.Tm_app uu____3473 in
    FStar_Syntax_Syntax.mk uu____3472 in
  uu____3469 None phi.FStar_Syntax_Syntax.pos
let mk_conj phi1 phi2 = mk_binop tand phi1 phi2
let mk_conj_l:
  FStar_Syntax_Syntax.term Prims.list -> FStar_Syntax_Syntax.term =
  fun phi  ->
    match phi with
    | [] ->
        FStar_Syntax_Syntax.fvar FStar_Syntax_Const.true_lid
          FStar_Syntax_Syntax.Delta_constant None
    | hd1::tl1 -> FStar_List.fold_right mk_conj tl1 hd1
let mk_disj phi1 phi2 = mk_binop tor phi1 phi2
let mk_disj_l:
  FStar_Syntax_Syntax.term Prims.list -> FStar_Syntax_Syntax.term =
  fun phi  ->
    match phi with
    | [] -> t_false
    | hd1::tl1 -> FStar_List.fold_right mk_disj tl1 hd1
let mk_imp phi1 phi2 = mk_binop timp phi1 phi2
let mk_iff phi1 phi2 = mk_binop tiff phi1 phi2
let b2t e =
  let uu____3576 =
    let uu____3579 =
      let uu____3580 =
        let uu____3590 =
          let uu____3592 = FStar_Syntax_Syntax.as_arg e in [uu____3592] in
        (b2t_v, uu____3590) in
      FStar_Syntax_Syntax.Tm_app uu____3580 in
    FStar_Syntax_Syntax.mk uu____3579 in
  uu____3576 None e.FStar_Syntax_Syntax.pos
let teq: FStar_Syntax_Syntax.term = fvar_const FStar_Syntax_Const.eq2_lid
let mk_untyped_eq2 e1 e2 =
  let uu____3616 =
    FStar_Range.union_ranges e1.FStar_Syntax_Syntax.pos
      e2.FStar_Syntax_Syntax.pos in
  let uu____3617 =
    let uu____3620 =
      let uu____3621 =
        let uu____3631 =
          let uu____3633 = FStar_Syntax_Syntax.as_arg e1 in
          let uu____3634 =
            let uu____3636 = FStar_Syntax_Syntax.as_arg e2 in [uu____3636] in
          uu____3633 :: uu____3634 in
        (teq, uu____3631) in
      FStar_Syntax_Syntax.Tm_app uu____3621 in
    FStar_Syntax_Syntax.mk uu____3620 in
  uu____3617 None uu____3616
let mk_eq2:
  FStar_Syntax_Syntax.universe ->
    FStar_Syntax_Syntax.typ ->
      FStar_Syntax_Syntax.term ->
        FStar_Syntax_Syntax.term ->
          (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
            FStar_Syntax_Syntax.syntax
  =
  fun u  ->
    fun t  ->
      fun e1  ->
        fun e2  ->
          let eq_inst = FStar_Syntax_Syntax.mk_Tm_uinst teq [u] in
          let uu____3659 =
            FStar_Range.union_ranges e1.FStar_Syntax_Syntax.pos
              e2.FStar_Syntax_Syntax.pos in
          let uu____3660 =
            let uu____3663 =
              let uu____3664 =
                let uu____3674 =
                  let uu____3676 = FStar_Syntax_Syntax.iarg t in
                  let uu____3677 =
                    let uu____3679 = FStar_Syntax_Syntax.as_arg e1 in
                    let uu____3680 =
                      let uu____3682 = FStar_Syntax_Syntax.as_arg e2 in
                      [uu____3682] in
                    uu____3679 :: uu____3680 in
                  uu____3676 :: uu____3677 in
                (eq_inst, uu____3674) in
              FStar_Syntax_Syntax.Tm_app uu____3664 in
            FStar_Syntax_Syntax.mk uu____3663 in
          uu____3660 None uu____3659
let mk_has_type t x t' =
  let t_has_type = fvar_const FStar_Syntax_Const.has_type_lid in
  let t_has_type1 =
    FStar_Syntax_Syntax.mk
      (FStar_Syntax_Syntax.Tm_uinst
         (t_has_type,
           [FStar_Syntax_Syntax.U_zero; FStar_Syntax_Syntax.U_zero])) None
      FStar_Range.dummyRange in
  let uu____3720 =
    let uu____3723 =
      let uu____3724 =
        let uu____3734 =
          let uu____3736 = FStar_Syntax_Syntax.iarg t in
          let uu____3737 =
            let uu____3739 = FStar_Syntax_Syntax.as_arg x in
            let uu____3740 =
              let uu____3742 = FStar_Syntax_Syntax.as_arg t' in [uu____3742] in
            uu____3739 :: uu____3740 in
          uu____3736 :: uu____3737 in
        (t_has_type1, uu____3734) in
      FStar_Syntax_Syntax.Tm_app uu____3724 in
    FStar_Syntax_Syntax.mk uu____3723 in
  uu____3720 None FStar_Range.dummyRange
let lex_t: FStar_Syntax_Syntax.term = fvar_const FStar_Syntax_Const.lex_t_lid
let lex_top: FStar_Syntax_Syntax.term =
  FStar_Syntax_Syntax.fvar FStar_Syntax_Const.lextop_lid
    FStar_Syntax_Syntax.Delta_constant (Some FStar_Syntax_Syntax.Data_ctor)
let lex_pair: FStar_Syntax_Syntax.term =
  FStar_Syntax_Syntax.fvar FStar_Syntax_Const.lexcons_lid
    FStar_Syntax_Syntax.Delta_constant (Some FStar_Syntax_Syntax.Data_ctor)
let tforall: FStar_Syntax_Syntax.term =
  FStar_Syntax_Syntax.fvar FStar_Syntax_Const.forall_lid
    (FStar_Syntax_Syntax.Delta_defined_at_level (Prims.parse_int "1")) None
let t_haseq: FStar_Syntax_Syntax.term =
  FStar_Syntax_Syntax.fvar FStar_Syntax_Const.haseq_lid
    FStar_Syntax_Syntax.Delta_constant None
let lcomp_of_comp:
  (FStar_Syntax_Syntax.comp',Prims.unit) FStar_Syntax_Syntax.syntax ->
    FStar_Syntax_Syntax.lcomp
  =
  fun c0  ->
    let uu____3761 =
      match c0.FStar_Syntax_Syntax.n with
      | FStar_Syntax_Syntax.Total uu____3768 ->
          (FStar_Syntax_Const.effect_Tot_lid, [FStar_Syntax_Syntax.TOTAL])
      | FStar_Syntax_Syntax.GTotal uu____3775 ->
          (FStar_Syntax_Const.effect_GTot_lid,
            [FStar_Syntax_Syntax.SOMETRIVIAL])
      | FStar_Syntax_Syntax.Comp c ->
          ((c.FStar_Syntax_Syntax.effect_name),
            (c.FStar_Syntax_Syntax.flags)) in
    match uu____3761 with
    | (eff_name,flags) ->
        {
          FStar_Syntax_Syntax.eff_name = eff_name;
          FStar_Syntax_Syntax.res_typ = (comp_result c0);
          FStar_Syntax_Syntax.cflags = flags;
          FStar_Syntax_Syntax.comp = ((fun uu____3788  -> c0))
        }
let mk_forall_aux fa x body =
  let uu____3812 =
    let uu____3815 =
      let uu____3816 =
        let uu____3826 =
          let uu____3828 =
            FStar_Syntax_Syntax.iarg x.FStar_Syntax_Syntax.sort in
          let uu____3829 =
            let uu____3831 =
              let uu____3832 =
                let uu____3833 =
                  let uu____3834 = FStar_Syntax_Syntax.mk_binder x in
                  [uu____3834] in
                let uu____3835 =
                  let uu____3842 =
                    let uu____3848 =
                      let uu____3849 = FStar_Syntax_Syntax.mk_Total ktype0 in
                      FStar_All.pipe_left lcomp_of_comp uu____3849 in
                    FStar_Util.Inl uu____3848 in
                  Some uu____3842 in
                abs uu____3833 body uu____3835 in
              FStar_Syntax_Syntax.as_arg uu____3832 in
            [uu____3831] in
          uu____3828 :: uu____3829 in
        (fa, uu____3826) in
      FStar_Syntax_Syntax.Tm_app uu____3816 in
    FStar_Syntax_Syntax.mk uu____3815 in
  uu____3812 None FStar_Range.dummyRange
let mk_forall_no_univ:
  FStar_Syntax_Syntax.bv ->
    FStar_Syntax_Syntax.typ ->
      (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
        FStar_Syntax_Syntax.syntax
  = fun x  -> fun body  -> mk_forall_aux tforall x body
let mk_forall:
  FStar_Syntax_Syntax.universe ->
    FStar_Syntax_Syntax.bv ->
      FStar_Syntax_Syntax.typ ->
        (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
          FStar_Syntax_Syntax.syntax
  =
  fun u  ->
    fun x  ->
      fun body  ->
        let tforall1 = FStar_Syntax_Syntax.mk_Tm_uinst tforall [u] in
        mk_forall_aux tforall1 x body
let close_forall_no_univs:
  FStar_Syntax_Syntax.binder Prims.list ->
    FStar_Syntax_Syntax.typ -> FStar_Syntax_Syntax.typ
  =
  fun bs  ->
    fun f  ->
      FStar_List.fold_right
        (fun b  ->
           fun f1  ->
             let uu____3899 = FStar_Syntax_Syntax.is_null_binder b in
             if uu____3899 then f1 else mk_forall_no_univ (Prims.fst b) f1)
        bs f
let rec is_wild_pat p =
  match p.FStar_Syntax_Syntax.v with
  | FStar_Syntax_Syntax.Pat_wild uu____3912 -> true
  | uu____3913 -> false
let if_then_else b t1 t2 =
  let then_branch =
    let uu____3956 =
      FStar_Syntax_Syntax.withinfo
        (FStar_Syntax_Syntax.Pat_constant (FStar_Const.Const_bool true))
        FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n
        t1.FStar_Syntax_Syntax.pos in
    (uu____3956, None, t1) in
  let else_branch =
    let uu____3979 =
      FStar_Syntax_Syntax.withinfo
        (FStar_Syntax_Syntax.Pat_constant (FStar_Const.Const_bool false))
        FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n
        t2.FStar_Syntax_Syntax.pos in
    (uu____3979, None, t2) in
  let uu____3991 =
    let uu____3992 =
      FStar_Range.union_ranges t1.FStar_Syntax_Syntax.pos
        t2.FStar_Syntax_Syntax.pos in
    FStar_Range.union_ranges b.FStar_Syntax_Syntax.pos uu____3992 in
  FStar_Syntax_Syntax.mk
    (FStar_Syntax_Syntax.Tm_match (b, [then_branch; else_branch])) None
    uu____3991
type qpats = FStar_Syntax_Syntax.args Prims.list
type connective =
  | QAll of (FStar_Syntax_Syntax.binders* qpats* FStar_Syntax_Syntax.typ)
  | QEx of (FStar_Syntax_Syntax.binders* qpats* FStar_Syntax_Syntax.typ)
  | BaseConn of (FStar_Ident.lident* FStar_Syntax_Syntax.args)
let uu___is_QAll: connective -> Prims.bool =
  fun projectee  ->
    match projectee with | QAll _0 -> true | uu____4065 -> false
let __proj__QAll__item___0:
  connective -> (FStar_Syntax_Syntax.binders* qpats* FStar_Syntax_Syntax.typ)
  = fun projectee  -> match projectee with | QAll _0 -> _0
let uu___is_QEx: connective -> Prims.bool =
  fun projectee  ->
    match projectee with | QEx _0 -> true | uu____4089 -> false
let __proj__QEx__item___0:
  connective -> (FStar_Syntax_Syntax.binders* qpats* FStar_Syntax_Syntax.typ)
  = fun projectee  -> match projectee with | QEx _0 -> _0
let uu___is_BaseConn: connective -> Prims.bool =
  fun projectee  ->
    match projectee with | BaseConn _0 -> true | uu____4112 -> false
let __proj__BaseConn__item___0:
  connective -> (FStar_Ident.lident* FStar_Syntax_Syntax.args) =
  fun projectee  -> match projectee with | BaseConn _0 -> _0
let destruct_typ_as_formula:
  FStar_Syntax_Syntax.term -> connective Prims.option =
  fun f  ->
    let rec unmeta_monadic f1 =
      let f2 = FStar_Syntax_Subst.compress f1 in
      match f2.FStar_Syntax_Syntax.n with
      | FStar_Syntax_Syntax.Tm_meta (t,FStar_Syntax_Syntax.Meta_monadic _)
        |FStar_Syntax_Syntax.Tm_meta
        (t,FStar_Syntax_Syntax.Meta_monadic_lift _) -> unmeta_monadic t
      | uu____4147 -> f2 in
    let destruct_base_conn f1 =
      let connectives =
        [(FStar_Syntax_Const.true_lid, (Prims.parse_int "0"));
        (FStar_Syntax_Const.false_lid, (Prims.parse_int "0"));
        (FStar_Syntax_Const.and_lid, (Prims.parse_int "2"));
        (FStar_Syntax_Const.or_lid, (Prims.parse_int "2"));
        (FStar_Syntax_Const.imp_lid, (Prims.parse_int "2"));
        (FStar_Syntax_Const.iff_lid, (Prims.parse_int "2"));
        (FStar_Syntax_Const.ite_lid, (Prims.parse_int "3"));
        (FStar_Syntax_Const.not_lid, (Prims.parse_int "1"));
        (FStar_Syntax_Const.eq2_lid, (Prims.parse_int "3"));
        (FStar_Syntax_Const.eq2_lid, (Prims.parse_int "2"));
        (FStar_Syntax_Const.eq3_lid, (Prims.parse_int "4"));
        (FStar_Syntax_Const.eq3_lid, (Prims.parse_int "2"))] in
      let rec aux f2 uu____4192 =
        match uu____4192 with
        | (lid,arity) ->
            let uu____4198 =
              let uu____4208 = unmeta_monadic f2 in head_and_args uu____4208 in
            (match uu____4198 with
             | (t,args) ->
                 let t1 = un_uinst t in
                 let uu____4227 =
                   (is_constructor t1 lid) &&
                     ((FStar_List.length args) = arity) in
                 if uu____4227 then Some (BaseConn (lid, args)) else None) in
      FStar_Util.find_map connectives (aux f1) in
    let patterns t =
      let t1 = FStar_Syntax_Subst.compress t in
      match t1.FStar_Syntax_Syntax.n with
      | FStar_Syntax_Syntax.Tm_meta
          (t2,FStar_Syntax_Syntax.Meta_pattern pats) ->
          let uu____4278 = FStar_Syntax_Subst.compress t2 in
          (pats, uu____4278)
      | uu____4285 ->
          let uu____4286 = FStar_Syntax_Subst.compress t1 in ([], uu____4286) in
    let destruct_q_conn t =
      let is_q fa fv =
        if fa
        then is_forall (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
        else is_exists (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v in
      let flat t1 =
        let uu____4328 = head_and_args t1 in
        match uu____4328 with
        | (t2,args) ->
            let uu____4359 = un_uinst t2 in
            let uu____4360 =
              FStar_All.pipe_right args
                (FStar_List.map
                   (fun uu____4376  ->
                      match uu____4376 with
                      | (t3,imp) ->
                          let uu____4383 = unascribe t3 in (uu____4383, imp))) in
            (uu____4359, uu____4360) in
      let rec aux qopt out t1 =
        let uu____4406 = let uu____4415 = flat t1 in (qopt, uu____4415) in
        match uu____4406 with
        | (Some
           fa,({ FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar tc;
                 FStar_Syntax_Syntax.tk = _; FStar_Syntax_Syntax.pos = _;
                 FStar_Syntax_Syntax.vars = _;_},({
                                                    FStar_Syntax_Syntax.n =
                                                      FStar_Syntax_Syntax.Tm_abs
                                                      (b::[],t2,_);
                                                    FStar_Syntax_Syntax.tk =
                                                      _;
                                                    FStar_Syntax_Syntax.pos =
                                                      _;
                                                    FStar_Syntax_Syntax.vars
                                                      = _;_},_)::[]))
          |(Some
            fa,({ FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar tc;
                  FStar_Syntax_Syntax.tk = _; FStar_Syntax_Syntax.pos = _;
                  FStar_Syntax_Syntax.vars = _;_},_::({
                                                        FStar_Syntax_Syntax.n
                                                          =
                                                          FStar_Syntax_Syntax.Tm_abs
                                                          (b::[],t2,_);
                                                        FStar_Syntax_Syntax.tk
                                                          = _;
                                                        FStar_Syntax_Syntax.pos
                                                          = _;
                                                        FStar_Syntax_Syntax.vars
                                                          = _;_},_)::[]))
            when is_q fa tc -> aux qopt (b :: out) t2
        | (None
           ,({ FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar tc;
               FStar_Syntax_Syntax.tk = _; FStar_Syntax_Syntax.pos = _;
               FStar_Syntax_Syntax.vars = _;_},({
                                                  FStar_Syntax_Syntax.n =
                                                    FStar_Syntax_Syntax.Tm_abs
                                                    (b::[],t2,_);
                                                  FStar_Syntax_Syntax.tk = _;
                                                  FStar_Syntax_Syntax.pos = _;
                                                  FStar_Syntax_Syntax.vars =
                                                    _;_},_)::[]))
          |(None
            ,({ FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar tc;
                FStar_Syntax_Syntax.tk = _; FStar_Syntax_Syntax.pos = _;
                FStar_Syntax_Syntax.vars = _;_},_::({
                                                      FStar_Syntax_Syntax.n =
                                                        FStar_Syntax_Syntax.Tm_abs
                                                        (b::[],t2,_);
                                                      FStar_Syntax_Syntax.tk
                                                        = _;
                                                      FStar_Syntax_Syntax.pos
                                                        = _;
                                                      FStar_Syntax_Syntax.vars
                                                        = _;_},_)::[]))
            when
            is_qlid (tc.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v ->
            aux
              (Some
                 (is_forall
                    (tc.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v))
              (b :: out) t2
        | (Some b,uu____4674) ->
            let bs = FStar_List.rev out in
            let uu____4692 = FStar_Syntax_Subst.open_term bs t1 in
            (match uu____4692 with
             | (bs1,t2) ->
                 let uu____4698 = patterns t2 in
                 (match uu____4698 with
                  | (pats,body) ->
                      if b
                      then Some (QAll (bs1, pats, body))
                      else Some (QEx (bs1, pats, body))))
        | uu____4736 -> None in
      aux None [] t in
    let phi = unmeta_monadic f in
    let uu____4748 = destruct_base_conn phi in
    match uu____4748 with | Some b -> Some b | None  -> destruct_q_conn phi
let action_as_lb:
  FStar_Ident.lident ->
    FStar_Syntax_Syntax.action -> FStar_Syntax_Syntax.sigelt
  =
  fun eff_lid  ->
    fun a  ->
      let lb =
        let uu____4759 =
          let uu____4762 =
            FStar_Syntax_Syntax.lid_as_fv a.FStar_Syntax_Syntax.action_name
              FStar_Syntax_Syntax.Delta_equational None in
          FStar_Util.Inr uu____4762 in
        let uu____4763 =
          let uu____4764 =
            FStar_Syntax_Syntax.mk_Total a.FStar_Syntax_Syntax.action_typ in
          arrow a.FStar_Syntax_Syntax.action_params uu____4764 in
        let uu____4767 =
          abs a.FStar_Syntax_Syntax.action_params
            a.FStar_Syntax_Syntax.action_defn None in
        close_univs_and_mk_letbinding None uu____4759
          a.FStar_Syntax_Syntax.action_univs uu____4763
          FStar_Syntax_Const.effect_Tot_lid uu____4767 in
      {
        FStar_Syntax_Syntax.sigel =
          (FStar_Syntax_Syntax.Sig_let
             ((false, [lb]), [a.FStar_Syntax_Syntax.action_name], []));
        FStar_Syntax_Syntax.sigrng =
          ((a.FStar_Syntax_Syntax.action_defn).FStar_Syntax_Syntax.pos);
        FStar_Syntax_Syntax.sigquals =
          [FStar_Syntax_Syntax.Visible_default;
          FStar_Syntax_Syntax.Action eff_lid];
        FStar_Syntax_Syntax.sigmeta = FStar_Syntax_Syntax.default_sigmeta
      }
let mk_reify t =
  let reify_ =
    FStar_Syntax_Syntax.mk
      (FStar_Syntax_Syntax.Tm_constant FStar_Const.Const_reify) None
      t.FStar_Syntax_Syntax.pos in
  let uu____4800 =
    let uu____4803 =
      let uu____4804 =
        let uu____4814 =
          let uu____4816 = FStar_Syntax_Syntax.as_arg t in [uu____4816] in
        (reify_, uu____4814) in
      FStar_Syntax_Syntax.Tm_app uu____4804 in
    FStar_Syntax_Syntax.mk uu____4803 in
  uu____4800 None t.FStar_Syntax_Syntax.pos
let rec delta_qualifier:
  FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.delta_depth =
  fun t  ->
    let t1 = FStar_Syntax_Subst.compress t in
    match t1.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_delayed uu____4832 -> failwith "Impossible"
    | FStar_Syntax_Syntax.Tm_fvar fv -> fv.FStar_Syntax_Syntax.fv_delta
    | FStar_Syntax_Syntax.Tm_bvar _
      |FStar_Syntax_Syntax.Tm_name _
       |FStar_Syntax_Syntax.Tm_match _
        |FStar_Syntax_Syntax.Tm_uvar _|FStar_Syntax_Syntax.Tm_unknown  ->
        FStar_Syntax_Syntax.Delta_equational
    | FStar_Syntax_Syntax.Tm_type _
      |FStar_Syntax_Syntax.Tm_constant _|FStar_Syntax_Syntax.Tm_arrow _ ->
        FStar_Syntax_Syntax.Delta_constant
    | FStar_Syntax_Syntax.Tm_uinst (t2,_)
      |FStar_Syntax_Syntax.Tm_refine
       ({ FStar_Syntax_Syntax.ppname = _; FStar_Syntax_Syntax.index = _;
          FStar_Syntax_Syntax.sort = t2;_},_)
       |FStar_Syntax_Syntax.Tm_meta (t2,_)
        |FStar_Syntax_Syntax.Tm_ascribed (t2,_,_)
         |FStar_Syntax_Syntax.Tm_app (t2,_)
          |FStar_Syntax_Syntax.Tm_abs (_,t2,_)|FStar_Syntax_Syntax.Tm_let
           (_,t2)
        -> delta_qualifier t2
let incr_delta_qualifier:
  FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.delta_depth =
  fun t  ->
    let d = delta_qualifier t in
    let rec aux d1 =
      match d1 with
      | FStar_Syntax_Syntax.Delta_equational  -> d1
      | FStar_Syntax_Syntax.Delta_constant  ->
          FStar_Syntax_Syntax.Delta_defined_at_level (Prims.parse_int "1")
      | FStar_Syntax_Syntax.Delta_defined_at_level i ->
          FStar_Syntax_Syntax.Delta_defined_at_level
            (i + (Prims.parse_int "1"))
      | FStar_Syntax_Syntax.Delta_abstract d2 -> aux d2 in
    aux d
let is_unknown: FStar_Syntax_Syntax.term -> Prims.bool =
  fun t  ->
    let uu____4943 =
      let uu____4944 = FStar_Syntax_Subst.compress t in
      uu____4944.FStar_Syntax_Syntax.n in
    match uu____4943 with
    | FStar_Syntax_Syntax.Tm_unknown  -> true
    | uu____4947 -> false
let rec list_elements:
  FStar_Syntax_Syntax.term ->
    FStar_Syntax_Syntax.term Prims.list Prims.option
  =
  fun e  ->
    let uu____4955 = let uu____4965 = unmeta e in head_and_args uu____4965 in
    match uu____4955 with
    | (head1,args) ->
        let uu____4984 =
          let uu____4992 =
            let uu____4993 = un_uinst head1 in
            uu____4993.FStar_Syntax_Syntax.n in
          (uu____4992, args) in
        (match uu____4984 with
         | (FStar_Syntax_Syntax.Tm_fvar fv,uu____5004) when
             FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.nil_lid ->
             Some []
         | (FStar_Syntax_Syntax.Tm_fvar
            fv,uu____5017::(hd1,uu____5019)::(tl1,uu____5021)::[]) when
             FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.cons_lid ->
             let uu____5055 =
               let uu____5059 =
                 let uu____5063 = list_elements tl1 in
                 FStar_Util.must uu____5063 in
               hd1 :: uu____5059 in
             Some uu____5055
         | uu____5072 -> None)
let rec apply_last f l =
  match l with
  | [] -> failwith "apply_last: got empty list"
  | a::[] -> let uu____5103 = f a in [uu____5103]
  | x::xs -> let uu____5107 = apply_last f xs in x :: uu____5107
let dm4f_lid:
  FStar_Syntax_Syntax.eff_decl -> Prims.string -> FStar_Ident.lident =
  fun ed  ->
    fun name  ->
      let p = FStar_Ident.path_of_lid ed.FStar_Syntax_Syntax.mname in
      let p' =
        apply_last
          (fun s  ->
             Prims.strcat "_dm4f_" (Prims.strcat s (Prims.strcat "_" name)))
          p in
      FStar_Ident.lid_of_path p' FStar_Range.dummyRange
let rec mk_list:
  FStar_Syntax_Syntax.term ->
    FStar_Range.range ->
      FStar_Syntax_Syntax.term Prims.list -> FStar_Syntax_Syntax.term
  =
  fun typ  ->
    fun rng  ->
      fun l  ->
        let ctor l1 =
          let uu____5137 =
            let uu____5140 =
              let uu____5141 =
                FStar_Syntax_Syntax.lid_as_fv l1
                  FStar_Syntax_Syntax.Delta_constant
                  (Some FStar_Syntax_Syntax.Data_ctor) in
              FStar_Syntax_Syntax.Tm_fvar uu____5141 in
            FStar_Syntax_Syntax.mk uu____5140 in
          uu____5137 None rng in
        let cons1 args pos =
          let uu____5159 =
            let uu____5160 =
              let uu____5161 = ctor FStar_Syntax_Const.cons_lid in
              FStar_Syntax_Syntax.mk_Tm_uinst uu____5161
                [FStar_Syntax_Syntax.U_zero] in
            FStar_Syntax_Syntax.mk_Tm_app uu____5160 args in
          uu____5159 None pos in
        let nil args pos =
          let uu____5175 =
            let uu____5176 =
              let uu____5177 = ctor FStar_Syntax_Const.nil_lid in
              FStar_Syntax_Syntax.mk_Tm_uinst uu____5177
                [FStar_Syntax_Syntax.U_zero] in
            FStar_Syntax_Syntax.mk_Tm_app uu____5176 args in
          uu____5175 None pos in
        let uu____5182 =
          let uu____5183 =
            let uu____5184 = FStar_Syntax_Syntax.iarg typ in [uu____5184] in
          nil uu____5183 rng in
        FStar_List.fold_right
          (fun t  ->
             fun a  ->
               let uu____5187 =
                 let uu____5188 = FStar_Syntax_Syntax.iarg typ in
                 let uu____5189 =
                   let uu____5191 = FStar_Syntax_Syntax.as_arg t in
                   let uu____5192 =
                     let uu____5194 = FStar_Syntax_Syntax.as_arg a in
                     [uu____5194] in
                   uu____5191 :: uu____5192 in
                 uu____5188 :: uu____5189 in
               cons1 uu____5187 t.FStar_Syntax_Syntax.pos) l uu____5182
let rec eqlist eq1 xs ys =
  match (xs, ys) with
  | ([],[]) -> true
  | (x::xs1,y::ys1) -> (eq1 x y) && (eqlist eq1 xs1 ys1)
  | uu____5238 -> false
let eqsum e1 e2 x y =
  match (x, y) with
  | (FStar_Util.Inl x1,FStar_Util.Inl y1) -> e1 x1 y1
  | (FStar_Util.Inr x1,FStar_Util.Inr y1) -> e2 x1 y1
  | uu____5311 -> false
let eqprod e1 e2 x y =
  match (x, y) with | ((x1,x2),(y1,y2)) -> (e1 x1 y1) && (e2 x2 y2)
let eqopt e x y =
  match (x, y) with | (Some x1,Some y1) -> e x1 y1 | uu____5419 -> false
let rec term_eq:
  FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.bool =
  fun t1  ->
    fun t2  ->
      let uu____5512 =
        let uu____5515 =
          let uu____5516 = FStar_Syntax_Subst.compress t1 in
          uu____5516.FStar_Syntax_Syntax.n in
        let uu____5519 =
          let uu____5520 = FStar_Syntax_Subst.compress t2 in
          uu____5520.FStar_Syntax_Syntax.n in
        (uu____5515, uu____5519) in
      match uu____5512 with
      | (FStar_Syntax_Syntax.Tm_bvar x,FStar_Syntax_Syntax.Tm_bvar y) ->
          x.FStar_Syntax_Syntax.index = y.FStar_Syntax_Syntax.index
      | (FStar_Syntax_Syntax.Tm_name x,FStar_Syntax_Syntax.Tm_name y) ->
          FStar_Syntax_Syntax.bv_eq x y
      | (FStar_Syntax_Syntax.Tm_fvar x,FStar_Syntax_Syntax.Tm_fvar y) ->
          FStar_Syntax_Syntax.fv_eq x y
      | (FStar_Syntax_Syntax.Tm_constant x,FStar_Syntax_Syntax.Tm_constant y)
          -> x = y
      | (FStar_Syntax_Syntax.Tm_type x,FStar_Syntax_Syntax.Tm_type y) ->
          x = y
      | (FStar_Syntax_Syntax.Tm_abs (b1,t11,k1),FStar_Syntax_Syntax.Tm_abs
         (b2,t21,k2)) -> (eqlist binder_eq b1 b2) && (term_eq t11 t21)
      | (FStar_Syntax_Syntax.Tm_app (f1,a1),FStar_Syntax_Syntax.Tm_app
         (f2,a2)) -> (term_eq f1 f2) && (eqlist arg_eq a1 a2)
      | (FStar_Syntax_Syntax.Tm_arrow (b1,c1),FStar_Syntax_Syntax.Tm_arrow
         (b2,c2)) -> (eqlist binder_eq b1 b2) && (comp_eq c1 c2)
      | (FStar_Syntax_Syntax.Tm_refine (b1,t11),FStar_Syntax_Syntax.Tm_refine
         (b2,t21)) -> (FStar_Syntax_Syntax.bv_eq b1 b2) && (term_eq t11 t21)
      | (FStar_Syntax_Syntax.Tm_match (t11,bs1),FStar_Syntax_Syntax.Tm_match
         (t21,bs2)) -> (term_eq t11 t21) && (eqlist branch_eq bs1 bs2)
      | (uu____5725,uu____5726) -> false
and arg_eq:
  ((FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
    FStar_Syntax_Syntax.syntax* FStar_Syntax_Syntax.aqual) ->
    ((FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
      FStar_Syntax_Syntax.syntax* FStar_Syntax_Syntax.aqual) -> Prims.bool
  =
  fun a1  -> fun a2  -> eqprod term_eq (fun q1  -> fun q2  -> q1 = q2) a1 a2
and binder_eq:
  (FStar_Syntax_Syntax.bv* FStar_Syntax_Syntax.aqual) ->
    (FStar_Syntax_Syntax.bv* FStar_Syntax_Syntax.aqual) -> Prims.bool
  =
  fun b1  ->
    fun b2  ->
      eqprod
        (fun b11  ->
           fun b21  ->
             term_eq b11.FStar_Syntax_Syntax.sort
               b21.FStar_Syntax_Syntax.sort) (fun q1  -> fun q2  -> q1 = q2)
        b1 b2
and lcomp_eq c1 c2 = false
and residual_eq r1 r2 = false
and comp_eq:
  (FStar_Syntax_Syntax.comp',Prims.unit) FStar_Syntax_Syntax.syntax ->
    (FStar_Syntax_Syntax.comp',Prims.unit) FStar_Syntax_Syntax.syntax ->
      Prims.bool
  =
  fun c1  ->
    fun c2  ->
      match ((c1.FStar_Syntax_Syntax.n), (c2.FStar_Syntax_Syntax.n)) with
      | (FStar_Syntax_Syntax.Total (t1,u1),FStar_Syntax_Syntax.Total (t2,u2))
          -> term_eq t1 t2
      | (FStar_Syntax_Syntax.GTotal (t1,u1),FStar_Syntax_Syntax.GTotal
         (t2,u2)) -> term_eq t1 t2
      | (FStar_Syntax_Syntax.Comp c11,FStar_Syntax_Syntax.Comp c21) ->
          ((((c11.FStar_Syntax_Syntax.comp_univs =
                c21.FStar_Syntax_Syntax.comp_univs)
               &&
               (c11.FStar_Syntax_Syntax.effect_name =
                  c21.FStar_Syntax_Syntax.effect_name))
              &&
              (term_eq c11.FStar_Syntax_Syntax.result_typ
                 c21.FStar_Syntax_Syntax.result_typ))
             &&
             (eqlist arg_eq c11.FStar_Syntax_Syntax.effect_args
                c21.FStar_Syntax_Syntax.effect_args))
            &&
            (eq_flags c11.FStar_Syntax_Syntax.flags
               c21.FStar_Syntax_Syntax.flags)
      | (uu____5797,uu____5798) -> false
and eq_flags:
  FStar_Syntax_Syntax.cflags Prims.list ->
    FStar_Syntax_Syntax.cflags Prims.list -> Prims.bool
  = fun f1  -> fun f2  -> false
and branch_eq:
  ((FStar_Syntax_Syntax.pat',FStar_Syntax_Syntax.term')
    FStar_Syntax_Syntax.withinfo_t*
    (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
    FStar_Syntax_Syntax.syntax Prims.option*
    (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
    FStar_Syntax_Syntax.syntax) ->
    ((FStar_Syntax_Syntax.pat',FStar_Syntax_Syntax.term')
      FStar_Syntax_Syntax.withinfo_t*
      (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
      FStar_Syntax_Syntax.syntax Prims.option*
      (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
      FStar_Syntax_Syntax.syntax) -> Prims.bool
  =
  fun uu____5803  ->
    fun uu____5804  ->
      match (uu____5803, uu____5804) with | ((p1,w1,t1),(p2,w2,t2)) -> false
let rec bottom_fold:
  (FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term) ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term
  =
  fun f  ->
    fun t  ->
      let ff = bottom_fold f in
      let tn =
        let uu____5914 = un_uinst t in uu____5914.FStar_Syntax_Syntax.n in
      let tn1 =
        match tn with
        | FStar_Syntax_Syntax.Tm_app (f1,args) ->
            let uu____5934 =
              let uu____5944 = ff f1 in
              let uu____5945 =
                FStar_List.map
                  (fun uu____5953  ->
                     match uu____5953 with
                     | (a,q) -> let uu____5960 = ff a in (uu____5960, q))
                  args in
              (uu____5944, uu____5945) in
            FStar_Syntax_Syntax.Tm_app uu____5934
        | FStar_Syntax_Syntax.Tm_abs (bs,t1,k) ->
            let uu____5989 = FStar_Syntax_Subst.open_term bs t1 in
            (match uu____5989 with
             | (bs1,t') ->
                 let t'' = ff t' in
                 let uu____5995 =
                   let uu____6010 = FStar_Syntax_Subst.close bs1 t'' in
                   (bs1, uu____6010, k) in
                 FStar_Syntax_Syntax.Tm_abs uu____5995)
        | FStar_Syntax_Syntax.Tm_arrow (bs,k) -> tn
        | uu____6029 -> tn in
      f
        (let uu___183_6030 = t in
         {
           FStar_Syntax_Syntax.n = tn1;
           FStar_Syntax_Syntax.tk = (uu___183_6030.FStar_Syntax_Syntax.tk);
           FStar_Syntax_Syntax.pos = (uu___183_6030.FStar_Syntax_Syntax.pos);
           FStar_Syntax_Syntax.vars =
             (uu___183_6030.FStar_Syntax_Syntax.vars)
         })