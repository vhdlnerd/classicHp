----------------------------------------------------------------------------------
-- The MIT License (MIT)
-- 
-- Copyright (c) 2014 Brian K. Nemetz
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
----------------------------------------------------------------------------------

--
--	Package File Template
--
--	Purpose: This package defines supplemental types" subtypes" 
--		 constants" and functions 
--
--   To use any of the example code shown below" uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package tm16xxFonts is

-- The bits are displayed by mapping below:
--   -- 0 --
--  |       |
--  5       1
--   -- 6 --
--  4       2
--  |       |
--   -- 3 --  .7

-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;
--
-- Declare constants
--
-- constant <constant_name>		: time := <time_unit> ns;
-- constant <constant_name>		: integer := <value;
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--
  type ledFontRomType is array (natural range <>) of std_logic_vector(7 downto 0);

  -- definition for standard hexadecimal numbers
  constant LED_HEX_FONT : ledFontRomType := (
    "00111111", -- 0
    "00000110", -- 1
    "01011011", -- 2
    "01001111", -- 3
    "01100110", -- 4
    "01101101", -- 5
    "01111101", -- 6
    "00000111", -- 7
    "01111111", -- 8
    "01101111", -- 9
    "01110111", -- A
    "01111100", -- B
    "00111001", -- C
    "01011110", -- D
    "01111001", -- E
    "01110001"  -- F
  );
  
  constant LED_FONT : ledFontRomType := (
    "00000000", -- (32)  <space>
    "10000110", -- (33)	!
    "00100010", -- (34)	"
    "01111110", -- (35)	#
    "01101101", -- (36)	$
    "00000000", -- (37)	%
    "00000000", -- (38)	&
    "00000010", -- (39)	'
    "00110000", -- (40)	(
    "00000110", -- (41)	)
    "01100011", -- (42)	*
    "00000000", -- (43)	+
    "00000100", -- (44)	,
    "01000000", -- (45)	-
    "10000000", -- (46)	.
    "01010010", -- (47)	/
    "00111111", -- (48)	0
    "00000110", -- (49)	1
    "01011011", -- (50)	2
    "01001111", -- (51)	3
    "01100110", -- (52)	4
    "01101101", -- (53)	5
    "01111101", -- (54)	6
    "00100111", -- (55)	7
    "01111111", -- (56)	8
    "01101111", -- (57)	9
    "00000000", -- (58)	:
    "00000000", -- (59)	;
    "00000000", -- (60)	<
    "01001000", -- (61)	=
    "00000000", -- (62)	>
    "01010011", -- (63)	?
    "01011111", -- (64)	@
    "01110111", -- (65)	A
    "01111111", -- (66)	B
    "00111001", -- (67)	C
    "00111111", -- (68)	D
    "01111001", -- (69)	E
    "01110001", -- (70)	F
    "00111101", -- (71)	G
    "01110110", -- (72)	H
    "00000110", -- (73)	I
    "00011111", -- (74)	J
    "01101001", -- (75)	K
    "00111000", -- (76)	L
    "00010101", -- (77)	M
    "00110111", -- (78)	N
    "00111111", -- (79)	O
    "01110011", -- (80)	P
    "01100111", -- (81)	Q
    "00110001", -- (82)	R
    "01101101", -- (83)	S
    "01111000", -- (84)	T
    "00111110", -- (85)	U
    "00101010", -- (86)	V
    "00011101", -- (87)	W
    "01110110", -- (88)	X
    "01101110", -- (89)	Y
    "01011011", -- (90)	Z
    "00111001", -- (91)	[
    "01100100", -- (92)	\ 
    "00001111", -- (93)	]
    "00000000", -- (94)	^
    "00001000", -- (95)	_
    "00100000", -- (96)	`
    "01011111", -- (97)	a
    "01111100", -- (98)	b
    "01011000", -- (99)	c
    "01011110", -- (100)	d
    "01111011", -- (101)	e
    "00110001", -- (102)	f
    "01101111", -- (103)	g
    "01110100", -- (104)	h
    "00000100", -- (105)	i
    "00001110", -- (106)	j
    "01110101", -- (107)	k
    "00110000", -- (108)	l
    "01010101", -- (109)	m
    "01010100", -- (110)	n
    "01011100", -- (111)	o
    "01110011", -- (112)	p
    "01100111", -- (113)	q
    "01010000", -- (114)	r
    "01101101", -- (115)	s
    "01111000", -- (116)	t
    "00011100", -- (117)	u
    "00101010", -- (118)	v
    "00011101", -- (119)	w
    "01110110", -- (120)	x
    "01101110", -- (121)	y
    "01000111", -- (122)	z
    "01000110", -- (123)	{
    "00000110", -- (124)	|
    "01110000", -- (125)	}
    "00000001"  -- (126)	~
  );
  
  constant LED_SPACE  : std_logic_vector(7 downto 0) := LED_FONT(32-32);
  constant LED_MINUS  : std_logic_vector(7 downto 0) := LED_FONT(45-32);
  constant LED_A      : std_logic_vector(7 downto 0) := LED_FONT(65-32);
  constant LED_F      : std_logic_vector(7 downto 0) := LED_FONT(70-32);
  constant LED_G      : std_logic_vector(7 downto 0) := LED_FONT(71-32);
  constant LED_H      : std_logic_vector(7 downto 0) := LED_FONT(72-32);
  constant LED_P      : std_logic_vector(7 downto 0) := LED_FONT(80-32);
  constant LED_0      : std_logic_vector(7 downto 0) := LED_FONT(48-32);
  constant LED_3      : std_logic_vector(7 downto 0) := LED_FONT(51-32);
  constant LED_4      : std_logic_vector(7 downto 0) := LED_FONT(52-32);
  constant LED_5      : std_logic_vector(7 downto 0) := LED_FONT(53-32);
  constant LED_DASH   : std_logic_vector(7 downto 0) := LED_FONT(45-32);
  constant LED_DP     : std_logic_vector(7 downto 0) := x"80";

  -- definition for "Error"  (padded out to 14 digits)
  constant LED_ERROR : ledFontRomType := (
    LED_SPACE,
    LED_MINUS,
    LED_MINUS,
    LED_SPACE,
    "01111001", -- E
    "01010000", -- r
    "01010000", -- r
    "01011100", -- o
    "01010000", -- r
    LED_SPACE,
    LED_MINUS,
    LED_MINUS,
    LED_SPACE,
    LED_SPACE
  );

  
end tm16xxFonts;

package body tm16xxFonts is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end tm16xxFonts;
