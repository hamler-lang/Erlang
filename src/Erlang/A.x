{
module Erlang.A where
import Control.Monad (forM_)

import Data.Char (ord)
import qualified Data.Bits
import Data.Word(Word8)
}

-- %wrapper "basic"

-- sign ::= + | -
$sign = [\+ \-]

-- digit ::= 0 | 1 | . . . | 9
$digit = 0-9			-- digits

-- uppercase ::= A | . . . | Z | \u00c0 | . . . | \u00d6 | \u00d8 | . . . | \u00de
$uppercase = [   A-          Z     \xc0-            \xd6     \xd8-            \xde]

-- lowercase ::= a | . . . | z | \u00df | . . . | \u00f6 | \u00f8 | . . . | \u00ff
$lowercase = [   a-          z     \xdf-            \xf6     \xf8-            \xff]

-- inputchar ::= any character except CR and LF
$inputchar = . # [\r \n]

-- control ::= \u0000 | . . . | \u001f
$control  = [    \x00 -           \x1f]

-- space ::= \u0020
$space = \x20

-- namechar ::= uppercase | lowercase | digit | @ | _ | ?
$namechar = [$uppercase $lowercase $digit \@ \_ ]

-- octaldigit ::= 0 | 1 | . . . | 7
$octaldigit = 0-7

$hex = [0-9 a-f A-F]

-- ctrlchar ::= \u0040 | . . . | \u005f
$ctrlchar = [     \x40 -           \x5f]


-- escapechar ::= b | d | e | f | n | r | s | t | v | " | ’ | \
$escapechar = [b d e f n r s t v \" \' \\ ]

-- octal ::= octaldigit (octaldigit octaldigit? )?
@octal = $octaldigit ($octaldigit $octaldigit?)?

-- escape ::= \ (octal | (^ ctrlchar ) | escapechar )
@escape = \\(@octal | \^$ctrlchar | $escapechar)

-- 'after' 'begin' 'case' 'try' 'catch' 'end' 'fun' 'if' 'of' 'receive' 'when'
-- 'andalso' 'orelse'
-- 'bnot' 'not'
-- '*' '/' 'div' 'rem' 'band' 'and'
-- '+' '-' 'bor' 'bxor' 'bsl' 'bsr' 'or' 'xor'
-- '++' '--'
-- '==' '/=' '=<' '<' '>=' '>' '=:=' '=/=' '<=' '=>' ':='
-- '<<' '>>'
-- '!' '=' '::' '..' '...'
-- 'spec' 'callback' % helper
-- dot


@keywords = after | begin | case | try | catch | end | fun | if | of | receive | when
          | andalso |  orelse
          | bnot | not
          | \* | \/ | div | rem  | band | and
          | \+ | \- | bor | bxor | bsl | bsr | or | xor
          | \+\+ | \-\-
          | \=\= | \/\= | \=\< | \< | \>\= | > | \=\:\= | \=\/\= | \<\= | \=\> | \:\=
          | \<\< | \>\>
          | \! | \= | \:\: | \.\. | \.\.\.
          | spec | callback


--             '(' ')' ','    '->' '{' '}' '[' ']'      '|' '||'    '<-'   ';'  ':'  '#' '.'
@separators = \( | \) | \, | \-\> | \{ | \} | \[ | \] | \| | \|\| | \<\- | \; | \: | \# | \. 

-- $namechar1 = [$lowercase $digit \@ \_ ]
$namechar1 = [$lowercase ]

@namechars = $namechar1 $namechar* | \_



tokens :-
  $white+                                           ;

  -- comments
  \%$inputchar*[\r \n]                              ; -- TODO { \s -> TComment $ init s}

  $digit+ \# $hex+                                  { \s -> TSInt s }

  -- sign? digit+
  $sign? $digit+                                    { \s -> TInt (read $ dropPlus s)}


  @keywords                                         { \s -> TKeywords s}

  -- sign? digit+. digit+ ((E | e) sign? digit+)?
  $sign? $digit+ \. $digit+ ((E|e) $sign? $digit+)? { \s -> TFloat (read $ dropPlus s)}

  --’ ((inputchar except control and \ and ’ ) | escape)* ’
  \'(($inputchar # [$control \\ \'])|@escape)*\'    { \s -> TAtom $ tail $ init $ readEscape s}

  @namechars                                        { \s -> mkAtom s}

  -- $ ((inputchar except control and space and \ ) | escape)
  \$(($inputchar # [$control $space \\])|@escape)   { \s -> TChar $ escapeToChar $ drop 1 s}

  --" ((inputchar except control and \ and " ) | escape)* "
  \"(($inputchar # [$control \\ \"])|@escape)*\"    { \s -> TString $ tail $ init $ readEscape s}


  @separators                                       { \s -> TSeparators s}

  --(uppercase | (_ namechar )) namechar*
  ($uppercase | \_$namechar )$namechar*              { \s -> TVarName s}



{

rkeywords = [ "after" , "begin" , "case" , "try" , "catch" , "end" , "fun" , "if" , "of" , "receive" , "when" , "andalso" , "orelse" ,"bnot" , "not" ,"div" , "rem" , "band" , "and","bor" , "bxor" , "bsl" , "bsr" , "or" , "xor"]

mkAtom :: String -> Token
mkAtom s = if s `elem` rkeywords
       then TKeywords s
       else TAtom s


-- The token type:
data Token
  = TComment String
  | TInt Integer
  | TSInt String
  | TFloat Double
  | TAtom String
  | TChar Char
  | TString String
  | TVarName String
  | TKeywords String
  | TSeparators String
  deriving Show


type Byte = Word8

type AlexInput = (Char,[Byte],String)

-- | Encode a Haskell String to a list of Word8 values, in UTF8 format.
utf8Encode :: Char -> [Word8]
utf8Encode = uncurry (:) . utf8Encode'

utf8Encode' :: Char -> (Word8, [Word8])
utf8Encode' c = case go (ord c) of
                  (x, xs) -> (fromIntegral x, map fromIntegral xs)
 where
  go oc
   | oc <= 0x7f       = ( oc
                        , [
                        ])

   | oc <= 0x7ff      = ( 0xc0 + (oc `Data.Bits.shiftR` 6)
                        , [0x80 + oc Data.Bits..&. 0x3f
                        ])

   | oc <= 0xffff     = ( 0xe0 + (oc `Data.Bits.shiftR` 12)
                        , [0x80 + ((oc `Data.Bits.shiftR` 6) Data.Bits..&. 0x3f)
                        , 0x80 + oc Data.Bits..&. 0x3f
                        ])
   | otherwise        = ( 0xf0 + (oc `Data.Bits.shiftR` 18)
                        , [0x80 + ((oc `Data.Bits.shiftR` 12) Data.Bits..&. 0x3f)
                        , 0x80 + ((oc `Data.Bits.shiftR` 6) Data.Bits..&. 0x3f)
                        , 0x80 + oc Data.Bits..&. 0x3f
                        ])


alexInputPrevChar :: AlexInput -> Char
alexInputPrevChar (c,_,_) = c

-- alexScanTokens :: String -> [token]
alexScanTokens str = go ('\n',[],str)
 where
  go inp__@(_,_bs,s) =
    case alexScan inp__ 0 of
      AlexEOF -> []
      AlexError _ -> error $ take 40 s
      AlexSkip  inp__' _ln     -> go inp__'
      AlexToken inp__' len act -> act (take len s) : go inp__'

alexGetByte :: AlexInput -> Maybe (Byte,AlexInput)
alexGetByte (c,(b:bs),s) = Just (b,(c,bs,s))
alexGetByte (_,[],[])    = Nothing
alexGetByte (_,[],(c:s)) = case utf8Encode' c of
                       (b, bs) -> Just (b, (c, bs, s))


dropPlus :: String -> String
dropPlus ('+' : xs) = xs
dropPlus xs = xs

atomDropQupte :: String -> String
atomDropQupte = init . tail

-- [b d e f n r s t v \" \' \\ ]
escapeToChar :: String -> Char
escapeToChar "\\b" = '\b'
escapeToChar "\\d" = '\x7f'
escapeToChar "\\e" = '\x1b'
escapeToChar "\\f" = '\f'
escapeToChar "\\n" = '\n'
escapeToChar "\\r" = '\r'
escapeToChar "\\s" = '\x20'
escapeToChar "\\t" = '\t'
escapeToChar "\\v" = '\v'
escapeToChar "\\\"" = '"'
escapeToChar "\\'" = '\''
escapeToChar "\\\\" = '\\'
-------------------------------
escapeToChar "\\^@" = '\x0'
escapeToChar "\\^A" = '\x1'
escapeToChar "\\^B" = '\x2'
escapeToChar "\\^C" = '\x3'
escapeToChar "\\^D" = '\x4'
escapeToChar "\\^E" = '\x5'
escapeToChar "\\^F" = '\x6'
escapeToChar "\\^G" = '\x7'
escapeToChar "\\^H" = '\x8'
escapeToChar "\\^I" = '\x9'
escapeToChar "\\^J" = '\xA'
escapeToChar "\\^K" = '\xB'
escapeToChar "\\^L" = '\xC'
escapeToChar "\\^M" = '\xD'
escapeToChar "\\^N" = '\xE'
escapeToChar "\\^O" = '\xF'
escapeToChar "\\^P" = '\x10'
escapeToChar "\\^Q" = '\x11'
escapeToChar "\\^R" = '\x12'
escapeToChar "\\^S" = '\x13'
escapeToChar "\\^T" = '\x14'
escapeToChar "\\^U" = '\x15'
escapeToChar "\\^V" = '\x16'
escapeToChar "\\^W" = '\x17'
escapeToChar "\\^X" = '\x18'
escapeToChar "\\^Y" = '\x19'
escapeToChar "\\^Z" = '\x1A'
-----------------------------
escapeToChar "\\^[" = '\x1B'
escapeToChar "\\^\\" = '\x1C'
escapeToChar "\\^]" = '\x1D'
escapeToChar "\\^^" = '\x1E'
escapeToChar "\\^_" = '\x1F'
escapeToChar "\\^?" = '\x7F'
-----------------------------
escapeToChar  s = head s
-- escapeToChar ('\\': xs) = undefined -- TODO: @octal

-- TODO: finish read escape function
readEscape :: String -> String
readEscape a = a

comment = "% This is a comment; it ends just before the line break.\n"
integers = "\n 8 +17 299792458 -4711"
fpnumbers = "0.0 2.7182818 -3.14 +1.2E-6 -1.23e12 1.0e+9"
atoms = "'foo' 'Bar' 'foo bar' '' '%#\\010@\\n!' '_hello_world '"
characters = "$A $$ $你  $\\n    $\\s    $\\\\  $\\^A"
strings = "\"Hello, world\" \"Two\\nlines\" \"Ring\\^G\" \"My\\7\" \"Bell\\007\""
varNames = "X Bar Value_2 One2There Stay@home _hello_world"
keywords = "after begin =:= <- =/= .. ..."
separators = "( ) { } [ ]  = -> | ||"

test = map alexScanTokens [comment, integers, fpnumbers, atoms, characters, strings, varNames, keywords, separators]

}
