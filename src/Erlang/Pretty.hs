{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}

module Erlang.Pretty where

import Data.Char
import Data.Functor.Foldable
import Data.Text (Text)
import Erlang.Type
import Text.DocLayout
import Unsafe.Coerce (unsafeCoerce)
import Utils

instance Pretty Var where
  pretty (Var s) = text s

instance Pretty Atom where
  pretty (Atom "_") = text "_"
  pretty (Atom "") = text ""
  pretty (Atom s) =
    if s `notElem` keyWord && isLower (head s) && all (`notElem` escapeChar) s
      then text s
      else quotes (text $ concatMap handleEc s)

keyWord = ["after", "begin", "case", "try", "catch", "end", "fun", "if", "of", "receive", "when", "andalso", "orelse", "bnot", "not", "div", "rem", "band", "and", "bor", "bxor", "bsl", "bsr", "or", "xor" ]

escapeChar =
  [ '\b',
    '\f',
    '\n',
    '\r',
    '\t',
    '\v',
    '\"',
    '\'',
    '\\'
  ]

instance Pretty Forms where
  pretty (Forms0 f) = pretty f
  pretty (Forms1 f fs) = pretty f <> blankline <> pretty fs

instance Pretty Form where
  pretty (Form0 a) = pretty a <> "."
  pretty (Form1 a) = pretty a <> "."

instance Pretty Attribute where
  pretty (Attribute0 a av) = "-" <> pretty a <> pretty av
  pretty (Attribute1 a tav) = "-" <> pretty a <> parens (pretty tav)
  pretty (Attribute2 ts) = "-" <> "spec" <> pretty ts
  pretty (Attribute3 ts) = "-" <> "callback" <> pretty ts

instance Pretty TypeSpec where
  pretty (TypeSpec sf ts) = parens (pretty sf <> pretty ts)

instance Pretty SpecFunc where
  pretty (SpecFunc0 a) = pretty a
  pretty (SpecFunc1 a b) = pretty a <> ":" <> pretty b

instance Pretty TypedAttrVal where
  pretty (TypedAttrVal0 e trf) = pretty e <> "," <> pretty trf
  pretty (TypedAttrVal1 e tt) = pretty e <> "::" <> pretty tt

instance Pretty TypedRecordFields where
  pretty (TypedRecordFields te) = braces $ pretty te

instance Pretty TypedExprs where
  pretty (TypedExprs0 te) = pretty te
  pretty (TypedExprs1 te tes) = pretty te <> "," <> pretty tes
  pretty (TypedExprs2 te tes) = pretty te <> "," <> pretty tes
  pretty (TypedExprs3 te tes) = pretty te <> "," <> pretty tes

instance Pretty TypedExpr where
  pretty (TypedExpr e tt) = pretty e <> "::" <> pretty tt

instance Pretty TypeSigs where
  pretty (TypeSigs0 ts) = pretty ts
  pretty (TypeSigs1 ts tss) = pretty ts <> ";" <> pretty tss

instance Pretty TypeSig where
  pretty (TypeSig0 ft) = pretty ft
  pretty (TypeSig1 ft tg) = pretty ft <> " when " <> pretty tg

instance Pretty TypeGuards where
  pretty (TypeGuards0 tg) = pretty tg
  pretty (TypeGuards1 tg tgs) = pretty tg <> "," <> pretty tgs

instance Pretty TypeGuard where
  pretty (TypeGuard0 a tt) = pretty a <> parens (pretty tt)
  pretty (TypeGuard1 v tt) = pretty v <> "::" <> pretty tt

instance Pretty TopTypes where
  pretty (TopTypes0 tt) = pretty tt
  pretty (TopTypes1 tt tts) = pretty tt <> "," <> pretty tts

instance Pretty TopType where
  pretty (TopType0 v tt) = pretty v <> "::" <> pretty tt
  pretty (TopType1 v tt) = pretty v <> "|" <> pretty tt
  pretty (TopType2 t) = pretty t

instance Pretty Type where
  pretty (Type0 t0 t1) = pretty t0 <> ".." <> pretty t1
  pretty (Type1 t0 ap t1) = pretty t0 <> pretty ap <> pretty t1
  pretty (Type2 t0 ap t1) = pretty t0 <> pretty ap <> pretty t1
  pretty (Type3 ap t1) = pretty ap <> pretty t1
  pretty (Type4 tt) = parens $ pretty tt
  pretty (Type5 v) = pretty v
  pretty (Type6 a) = pretty a
  pretty (Type7 a) = pretty a <> "()"
  pretty (Type8 a tts) = pretty a <> parens (pretty tts)
  pretty (Type9 a a1) = pretty a <> ":" <> pretty a1 <> "()"
  pretty (Type10 a a1 tts) = pretty a <> ":" <> pretty a1 <> parens (pretty tts)
  pretty Type11 = "[]"
  pretty (Type12 tt) = brackets (pretty tt)
  pretty (Type13 tt) = brackets (pretty tt <> ", ...")
  pretty Type14 = "#{}"
  pretty (Type15 mpt) = "#" <> braces (pretty mpt)
  pretty Type16 = "{}"
  pretty (Type17 tt) = braces (pretty tt)
  pretty (Type18 a) = "#" <> pretty a <> "{}"
  pretty (Type19 a ft) = "#" <> pretty a <> braces (pretty ft)
  pretty (Type20 bt) = pretty bt
  pretty (Type21 i) = text (show i)
  pretty (Type22 c) = char c
  pretty Type23 = "fun()"
  pretty (Type24 ft) = "fun(" <> pretty ft <> ")"

instance Pretty FunType where
  pretty (FunType0 tt) = "(...) -> " <> pretty tt
  pretty (FunType1 tt) = "() -> " <> pretty tt
  pretty (FunType2 tts tt) = "(" <> pretty tts <> ") -> " <> pretty tt

instance Pretty MapPairTypes where
  pretty (MapPairTypes0 mpt) = pretty mpt
  pretty (MapPairTypes1 mpt mpts) = pretty mpt <> "," <> pretty mpts

instance Pretty MapPairType where
  pretty (MapPairType0 tt tt1) = pretty tt <> " => " <> pretty tt1
  pretty (MapPairType1 tt tt1) = pretty tt <> " := " <> pretty tt1

instance Pretty FieldTypes where
  pretty (FieldTypes0 ft) = pretty ft
  pretty (FieldTypes1 ft fts) = pretty ft <> "," <> pretty fts

instance Pretty FieldType where
  pretty (FieldType a tt) = pretty a <> "::" <> pretty tt

instance Pretty BinaryType where
  pretty BinaryType0 = "<<" <> ">>"
  pretty (BinaryType1 bt) = "<<" <> pretty bt <> ">>"
  pretty (BinaryType2 bt) = "<<" <> pretty bt <> ">>"
  pretty (BinaryType3 bt bt1) = "<<" <> pretty bt <> "," <> pretty bt1 <> ">>"

instance Pretty BinBaseType where
  pretty (BinBaseType v t) = pretty v <> ":" <> pretty t

instance Pretty BinUnitType where
  pretty (BinUnitType v v1 t) = pretty v <> ":" <> pretty v <> "*" <> pretty t

instance Pretty AttrVal where
  pretty (AttrVal0 e) = pretty e
  pretty (AttrVal1 e es) = parens (pretty e <> ", " <> pretty es)

instance Pretty Function where
  pretty (Function fc) = pretty fc

instance Pretty FunctionClauses where
  pretty (FunctionClauses0 fc) = pretty fc
  pretty (FunctionClauses1 fc fcs) = pretty fc <> ";" <> cr <> pretty fcs

instance Pretty FunctionClause where
  pretty (FunctionClause a ca cg cb) =
    pretty a
      <> pretty ca
      <> space
      <> pretty cg
      <> pretty cb

instance Pretty ClauseArgs where
  pretty (ClauseArgs pal) = pretty pal

instance Pretty ClauseGuard where
  pretty (ClauseGuard0 g) = cr <> nest 4 ("when " <> pretty g)
  pretty ClauseGuard1 = empty

instance Pretty ClauseBody where
  pretty (ClauseBody es) = "->" <> cr <> nest 4 (pretty es)

instance Pretty Expr where
  pretty (Expr0 e) = " catch " <> pretty e
  pretty (Expr1 e e1) = pretty e <> " = " <> pretty e1
  pretty (Expr2 e e1) = pretty e <> " ! " <> pretty e1
  pretty (Expr3 e e1) = pretty e <> " orelse " <> pretty e1
  pretty (Expr4 e e1) = pretty e <> " andalso " <> pretty e1
  pretty (Expr5 e op e1) = pretty e <> pretty op <> pretty e1
  pretty (Expr6 e op e1) = pretty e <> pretty op <> pretty e1
  pretty (Expr7 e op e1) = pretty e <> pretty op <> pretty e1
  pretty (Expr8 e op e1) = pretty e <> pretty op <> pretty e1
  pretty (Expr9 po e1) = pretty po <> pretty e1
  pretty (Expr10 me) = pretty me
  pretty (Expr11 me) = pretty me
  pretty (Expr12 me) = pretty me
  pretty (Expr13 me) = pretty me

instance Pretty ExprRemote where
  pretty (ExprRemote0 em em1) = pretty em <> ":" <> pretty em1
  pretty (ExprRemote1 em) = pretty em

instance Pretty ExprMax where
  pretty (ExprMax0 v) = pretty v
  pretty (ExprMax1 a) = pretty a
  pretty (ExprMax2 a) = pretty a
  pretty (ExprMax3 a) = pretty a
  pretty (ExprMax4 a) = pretty a
  pretty (ExprMax5 a) = pretty a
  pretty (ExprMax6 a) = pretty a
  pretty (ExprMax7 a) = parens $ pretty a
  pretty (ExprMax8 a) = "begin " <> pretty a <> " end"
  pretty (ExprMax9 a) = pretty a
  pretty (ExprMax10 a) = pretty a
  pretty (ExprMax11 a) = pretty a
  pretty (ExprMax12 a) = pretty a
  pretty (ExprMax13 a) = pretty a

instance Pretty PatExpr where
  pretty (PatExpr0 p p1) = pretty p <> " = " <> pretty p1
  pretty (PatExpr1 p op p1) = pretty p <> space <> pretty op <> space <> pretty p1
  pretty (PatExpr2 p op p1) = pretty p <> pretty op <> pretty p1
  pretty (PatExpr3 p op p1) = pretty p <> pretty op <> pretty p1
  pretty (PatExpr4 p op p1) = pretty p <> pretty op <> pretty p1
  pretty (PatExpr5 op p1) = pretty op <> pretty p1
  pretty (PatExpr6 p) = pretty p
  pretty (PatExpr7 p) = pretty p
  pretty (PatExpr8 p) = pretty p

instance Pretty PatExprMax where
  pretty (PatExprMax0 v) = pretty v
  pretty (PatExprMax1 v) = pretty v
  pretty (PatExprMax2 v) = pretty v
  pretty (PatExprMax3 v) = pretty v
  pretty (PatExprMax4 v) = pretty v
  pretty (PatExprMax5 v) = parens $ pretty v

instance Pretty MapPatExpr where
  pretty (MapPatExpr0 mt) = "#" <> pretty mt
  pretty (MapPatExpr1 pem mt) = pretty pem <> " # " <> pretty mt
  pretty (MapPatExpr2 pem mt) = pretty pem <> " # " <> pretty mt

instance Pretty RecordPatExpr where
  pretty (RecordPatExpr0 a a1) = "#" <> pretty a <> "." <> pretty a1
  pretty (RecordPatExpr1 a a1) = "#" <> pretty a <> pretty a1

instance Pretty List where
  pretty List0 = "[]"
  pretty (List1 e t) = "[" <> pretty e <> pretty t

instance Pretty Tail where
  pretty Tail0 = "]"
  pretty (Tail1 e) = "| " <> pretty e <> "]"
  pretty (Tail2 e t) = ", " <> pretty e <> pretty t

instance Pretty Binary where
  pretty Binary0 = "<<" <> ">>"
  pretty (Binary1 p) = "<<" <> pretty p <> ">>"

instance Pretty BinElements where
  pretty (BinElements0 b) = pretty b
  pretty (BinElements1 b bs) = pretty b <> "," <> pretty bs

instance Pretty BinElement where
  pretty (BinElement a b c) = pretty a <> pretty b <> pretty c

instance Pretty BitExpr where
  pretty (BitExpr0 po em) = pretty po <> space <> pretty em
  pretty (BitExpr1 em) = pretty em

instance Pretty OptBitSizeExpr where
  pretty (OptBitSizeExpr0 e) = ":" <> pretty e
  pretty OptBitSizeExpr1 = empty

instance Pretty OptBitTypeList where
  pretty (OptBitTypeList0 btl) = "/" <> pretty btl
  pretty OptBitTypeList1 = empty

instance Pretty BitTypeList where
  pretty (BitTypeList0 a b) = pretty a <> "-" <> pretty b
  pretty (BitTypeList1 a) = pretty a

instance Pretty BitType where
  pretty (BitType0 a) = pretty a
  pretty (BitType1 a i) = pretty a <> ":" <> text (show i)

instance Pretty BitSizeExpr where
  pretty (BitSizeExpr e) = pretty e

instance Pretty ListComprehension where
  pretty (ListComprehension e l) = "[" <> pretty e <> " || " <> pretty l <> "]"

instance Pretty BinaryComprehension where
  pretty (BinaryComprehension e l) = "<<" <> pretty e <> " || " <> pretty l <> ">>"

instance Pretty LcExprs where
  pretty (LcExprs0 l) = pretty l
  pretty (LcExprs1 l ls) = pretty l <> "," <> pretty ls

instance Pretty LcExpr where
  pretty (LcExpr0 e) = pretty e
  pretty (LcExpr1 e e1) = pretty e <> " <- " <> pretty e1
  pretty (LcExpr2 e e1) = pretty e <> " <= " <> pretty e1

instance Pretty Tuple where
  pretty Tuple0 = "{}"
  pretty (Tuple1 e) = braces $ prettyExprs e

instance Pretty MapExpr where
  pretty (MapExpr0 m) = "#" <> pretty m
  pretty (MapExpr1 m m1) = pretty m <> "#" <> pretty m1
  pretty (MapExpr2 m m1) = pretty m <> "#" <> pretty m1

instance Pretty MapTuple where
  pretty MapTuple0 = "{}"
  pretty (MapTuple1 m) = "{" <> pretty m <> "}"

instance Pretty MapFields where
  pretty (MapFields0 m) = pretty m
  pretty (MapFields1 m s) = pretty m <> "," <> pretty s

instance Pretty MapField where
  pretty (MapField0 e) = pretty e
  pretty (MapField1 e) = pretty e

instance Pretty MapFieldAssoc where
  pretty (MapFieldAssoc m e) = pretty m <> "=>" <> pretty e

instance Pretty MapFieldExact where
  pretty (MapFieldExact m e) = pretty m <> ":=" <> pretty e

instance Pretty MapKey where
  pretty (MapKey e) = pretty e

instance Pretty RecordExpr where
  pretty (RecordExpr0 a a1) = "#" <> pretty a <> "." <> pretty a1
  pretty (RecordExpr1 a a1) = "#" <> pretty a <> pretty a1
  pretty (RecordExpr2 a a1 a2) = pretty a <> "#" <> pretty a1 <> "." <> pretty a2
  pretty (RecordExpr3 a a1 a2) = pretty a <> "#" <> pretty a1 <> pretty a2
  pretty (RecordExpr4 a a1 a2) = pretty a <> "#" <> pretty a1 <> "." <> pretty a2
  pretty (RecordExpr5 a a1 a2) = pretty a <> "#" <> pretty a1 <> pretty a2

instance Pretty RecordTuple where
  pretty RecordTuple0 = "{}"
  pretty (RecordTuple1 r) = "{" <> pretty r <> "}"

instance Pretty RecordFields where
  pretty (RecordFields0 r) = pretty r
  pretty (RecordFields1 r rs) = pretty r <> "," <> pretty rs

instance Pretty RecordField where
  pretty (RecordField0 v e) = pretty v <> " = " <> pretty e
  pretty (RecordField1 v e) = pretty v <> " = " <> pretty e

instance Pretty FunctionCall where
  pretty (FunctionCall a b) = pretty a <> pretty b

instance Pretty IfExpr where
  pretty (IfExpr i) = "if " <> pretty i <> " end"

instance Pretty IfClauses where
  pretty (IfClauses0 i) = pretty i
  pretty (IfClauses1 i si) = pretty i <> ";" <> pretty si

instance Pretty IfClause where
  pretty (IfClause g c) = pretty g <> space <> pretty c

instance Pretty CaseExpr where
  pretty (CaseExpr e c) = "case " <> pretty e <> " of" <> cr <> nest 4 (pretty c) <> cr <> "end"

instance Pretty CrClauses where
  pretty (CrClauses0 c) = pretty c
  pretty (CrClauses1 c cs) = pretty c <> ";" <> cr <> pretty cs

instance Pretty CrClause where
  pretty (CrClause a b c) = pretty a <> pretty b <> pretty c

instance Pretty ReceiveExpr where
  pretty (ReceiveExpr0 c) = "receive " <> pretty c <> " end"
  pretty (ReceiveExpr1 c c1) = "receive after " <> pretty c <> pretty c1 <> " end"
  pretty (ReceiveExpr2 c c1 c2) = "receive " <> pretty c <> " after " <> pretty c1 <> pretty c2 <> " end"

instance Pretty FunExpr where
  pretty (FunExpr0 a i) = "fun " <> pretty a <> "/" <> text (show i)
  pretty (FunExpr1 a b c) = "fun " <> pretty a <> ":" <> pretty b <> "/" <> pretty c
  pretty (FunExpr2 a) = "fun " <> pretty a <> " end"

instance Pretty AtomOrVar where
  pretty (AtomOrVar0 a) = pretty a
  pretty (AtomOrVar1 a) = pretty a

instance Pretty IntegerOrVar where
  pretty (IntegerOrVar0 i) = text $ show i
  pretty (IntegerOrVar1 i) = pretty i

instance Pretty FunClauses where
  pretty (FunClauses0 f) = pretty f
  pretty (FunClauses1 f fs) = pretty f <> ";" <> pretty fs

instance Pretty FunClause where
  pretty (FunClause0 a b c) = pretty a <> pretty b <> pretty c
  pretty (FunClause1 a b c d) = pretty a <> pretty b <> pretty c <> pretty d

instance Pretty TryExpr where
  pretty (TryExpr0 a b c) = "try " <> pretty a <> " of " <> cr <> nest 4 (pretty b <> cr <> pretty c)
  pretty (TryExpr1 a b) = "try " <> pretty a <> cr <> nest 4 (pretty b)

instance Pretty TryCatch where
  pretty (TryCatch0 t) = "catch" <> cr <> nest 4 (pretty t) <> " end"
  pretty (TryCatch1 t e) = "catch" <> cr <> nest 4 (pretty t) <> " after " <> pretty e <> " end"
  pretty (TryCatch2 e) = "after " <> pretty e <> " end"

instance Pretty TryClauses where
  pretty (TryClauses0 t) = pretty t
  pretty (TryClauses1 t ts) = pretty t <> ";" <> cr <> pretty ts

instance Pretty TryClause where
  pretty (TryClause0 a b c) = pretty a <> pretty b <> pretty c
  pretty (TryClause1 a b c d e) = pretty a <> ":" <> pretty b <> pretty c <> pretty d <> pretty e
  pretty (TryClause2 a b c d e) = pretty a <> ":" <> pretty b <> pretty c <> pretty d <> pretty e

instance Pretty TryOptStacktrace where
  pretty (TryOptStacktrace0 v) = ":" <> pretty v
  pretty TryOptStacktrace1 = empty

instance Pretty ArgumentList where
  pretty ArgumentList0 = "()"
  pretty (ArgumentList1 e) = "(" <> prettyExprs e <> ")"

prettyExprs :: HasChars a => Exprs -> Doc a
prettyExprs (Exprs0 e) = pretty e
prettyExprs (Exprs1 e es) = pretty e <> "," <> prettyExprs es

instance Pretty PatArgumentList where
  pretty PatArgumentList0 = "()"
  pretty (PatArgumentList1 e) = "(" <> pretty e <> ")"

instance Pretty Exprs where
  pretty (Exprs0 e) = pretty e
  pretty (Exprs1 e es) = pretty e <> "," <> cr <> pretty es

instance Pretty PatExprs where
  pretty (PatExprs0 e) = pretty e
  pretty (PatExprs1 e es) = pretty e <> "," <> pretty es

instance Pretty Guard where
  pretty (Guard0 e) = pretty e
  pretty (Guard1 e es) = pretty e <> ";" <> cr <> pretty es

handleEc :: Char -> String
handleEc '\b' = "\\b"
handleEc '\f' = "\\f"
handleEc '\n' = "\\n"
handleEc '\r' = "\\r"
handleEc '\t' = "\\t"
handleEc '\v' = "\\v"
handleEc '\"' = "\\\""
handleEc '\'' = "\\\'"
handleEc '\\' = "\\\\"
handleEc e = [e]

instance Pretty Atomic where
  pretty (Atomic0 c) = "$" <> text (handleEc c)
  pretty (Atomic1 i) = text $ show i
  pretty (Atomic11 i) = text i
  pretty (Atomic2 i) = text $ show i
  pretty (Atomic3 i) = pretty i
  pretty (Atomic4 i) = pretty i

instance Pretty Strings where
  pretty (Strings0 s) = doubleQuotes (text s)
  pretty (Strings1 s ss) = doubleQuotes (text s) <> space <> pretty ss

instance Pretty PrefixOp where
  pretty PPlus = "+"
  pretty PSub = "-"
  pretty PBnot = " bnot "
  pretty PNot = " not "

instance Pretty MultOp where
  pretty Mx = "/"
  pretty Mmult = " * "
  pretty Mdiv = " div "
  pretty Mrem = " rem "
  pretty Mband = " band "
  pretty Mand = " and "

instance Pretty AddOp where
  pretty Aplus = " + "
  pretty Asub = " - "
  pretty Abor = " bor "
  pretty Abxor = " bxor "
  pretty Absl = " bsl "
  pretty Absr = " bsr "
  pretty Aor = " or "
  pretty Axor = " xor "

instance Pretty ListOp where
  pretty Lpp = " ++ "
  pretty Lss = " -- "

instance Pretty CompOp where
  pretty Ce = " == "
  pretty Cne = " /= "
  pretty Cle = " =< "
  pretty Cl = " < "
  pretty Cge = " >= "
  pretty Cg = " > "
  pretty Cme = " =:= "
  pretty Cmn = " =/= "
