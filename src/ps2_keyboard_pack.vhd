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
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package ps2_keyboard_pack is

  subtype keyCodeType is std_logic_vector(8 downto 0);
  type    keyLutType  is array (natural range 0 to 256*8-1) of keyCodeType;

  constant INVALID_KEY   : keyCodeType := '1' & X"00";
  constant L_SHIFT_KEY   : keyCodeType := '1' & X"01";
  constant R_SHIFT_KEY   : keyCodeType := '1' & X"02";
  constant L_CONTROL_KEY : keyCodeType := '1' & X"03";
  constant R_CONTROL_KEY : keyCodeType := '1' & X"04";
  constant L_ALT_KEY     : keyCodeType := '1' & X"05";
  constant R_ALT_KEY     : keyCodeType := '1' & X"06";
  constant L_GUI_KEY     : keyCodeType := '1' & X"07";
  constant R_GUI_KEY     : keyCodeType := '1' & X"08";
  constant APPS_KEY      : keyCodeType := '1' & X"09";
  constant KEY_BREAK     : keyCodeType := '1' & X"0A";
  constant EXTENDED      : keyCodeType := '1' & X"0B";

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
constant KEY_LUT_HP35 : keyLutType := (
-- LUT Address: cntl & shift & ext & code 
   16#00E# => O"077",             -- ` Special key to control LED brightness -- not a keycode for the HP Calc core!
   
   16#070# => O"044",             -- 0 (keypad)
   16#069# => O"034",             -- 1 (keypad)
   16#072# => O"033",             -- 2 (keypad)
   16#07A# => O"032",             -- 3 (keypad)
   16#06B# => O"024",             -- 4 (keypad)
   16#073# => O"023",             -- 5 (keypad)
   16#074# => O"022",             -- 6 (keypad)
   16#06C# => O"064",             -- 7 (keypad)
   16#075# => O"063",             -- 8 (keypad)
   16#07D# => O"062",             -- 9 (keypad)
   16#071# => O"043",             -- . (keypad)
   16#15A# => O"076",             -- Enter (keypad)
   16#079# => O"026",             -- + (keypad)
   16#07B# => O"066",             -- - (keypad)
   16#07C# => O"036",             -- * (keypad)
   16#14A# => O"046",             -- / (keypad)
   16#045# => O"044",             -- 0
   16#016# => O"034",             -- 1
   16#01E# => O"033",             -- 2
   16#026# => O"032",             -- 3
   16#025# => O"024",             -- 4
   16#02E# => O"023",             -- 5
   16#036# => O"022",             -- 6
   16#03D# => O"064",             -- 7
   16#03E# => O"063",             -- 8
   16#046# => O"062",             -- 9
   16#049# => O"043",             -- .
   16#05A# => O"076",             -- Enter
   16#255# => O"026",             -- +
   16#04E# => O"066",             -- -
   16#23E# => O"036",             -- *
   16#04A# => O"046",             -- /
   
   16#171# => O"070",             -- Delete  (do: Clx)
   16#066# => O"070",             -- BackSpace  (do: Clx)

   16#04D# => O"042",             -- p  (do: PI)
   16#24D# => O"042",             -- P  (do: PI)
   16#024# => O"072",             -- e  (do: EEX)
   16#224# => O"072",             -- E  (do: EEX)

   16#05D# => O"073",             -- \  (do: CHS)

   16#005# => O"054",             -- F1  (do: arc)
   16#006# => O"053",             -- F2  (do: sin)
   16#004# => O"052",             -- F3  (do: cos)
   16#00C# => O"050",             -- F4  (do: tan)

   16#003# => O"003",             -- F5        (do: ln)
   16#203# => O"002",             -- shift-F5  (do: e^x)
   16#00B# => O"004",             -- F6        (do: log)
   16#20B# => O"006",             -- shift-F6  (do: x^y)
   16#083# => O"016",             -- F7        (do: 1/x)
   16#283# => O"056",             -- shift-F7  (do: SQR)
   16#00A# => O"012",             -- F8        (do: STO)
   16#20A# => O"010",             -- shift-F8  (do: RCL)

   16#001# => O"014",             -- F9        (do: x<>y)
   16#201# => O"013",             -- shift-F9  (do: Roll Down Stack)
   16#009# => O"072",             -- F10       (do: EEX)
   16#209# => O"042",             -- shift-F10 (do: PI)
   16#078# => O"073",             -- F11       (do: CHS)
   16#007# => O"070",             -- F12       (do: CLx)
   16#207# => O"000",             -- shift-F12 (do: CLr)

--   16#222# => O"016",             -- X  (do: 1/x)
--   16#41A# => O"016",             -- cntl-Z  (do: 1/x)
   
   16#0E0# => EXTENDED,           -- Extended keycode prefix
   16#2E0# => EXTENDED,           -- Extended keycode prefix
   16#4E0# => EXTENDED,           -- Extended keycode prefix
   16#6E0# => EXTENDED,           -- Extended keycode prefix

   16#0F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#1F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#2F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#3F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#4F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#5F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#6F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#7F0# => KEY_BREAK,              -- Key break (key release) prefix

   16#012# => L_SHIFT_KEY,           
   16#212# => L_SHIFT_KEY,           
   16#412# => L_SHIFT_KEY,           
   16#612# => L_SHIFT_KEY,           
   
   16#059# => R_SHIFT_KEY,           
   16#259# => R_SHIFT_KEY,           
   16#459# => R_SHIFT_KEY,           
   16#659# => R_SHIFT_KEY,           
   
   16#014# => L_CONTROL_KEY,
   16#214# => L_CONTROL_KEY,
   16#414# => L_CONTROL_KEY,
   16#614# => L_CONTROL_KEY,
   
   16#114# => R_CONTROL_KEY,
   16#314# => R_CONTROL_KEY,
   16#514# => R_CONTROL_KEY,
   16#714# => R_CONTROL_KEY,
   
   others  => INVALID_KEY
  );  -- End: HP35

constant KEY_LUT_HP45 : keyLutType := (
-- LUT Address: cntl & shift & ext & code 
   16#00E# => O"077",             -- ` Special key to control LED brightness -- not a keycode for the HP Calc core!
   
   16#070# => O"044",             -- 0 (keypad)
   16#069# => O"034",             -- 1 (keypad)
   16#072# => O"033",             -- 2 (keypad)
   16#07A# => O"032",             -- 3 (keypad)
   16#06B# => O"024",             -- 4 (keypad)
   16#073# => O"023",             -- 5 (keypad)
   16#074# => O"022",             -- 6 (keypad)
   16#06C# => O"064",             -- 7 (keypad)
   16#075# => O"063",             -- 8 (keypad)
   16#07D# => O"062",             -- 9 (keypad)
   16#071# => O"043",             -- . (keypad)
   16#15A# => O"076",             -- Enter (keypad)
   16#079# => O"026",             -- + (keypad)
   16#07B# => O"066",             -- - (keypad)
   16#07C# => O"036",             -- * (keypad)
   16#14A# => O"046",             -- / (keypad)
   16#045# => O"044",             -- 0
   16#016# => O"034",             -- 1
   16#01E# => O"033",             -- 2
   16#026# => O"032",             -- 3
   16#025# => O"024",             -- 4
   16#02E# => O"023",             -- 5
   16#036# => O"022",             -- 6
   16#03D# => O"064",             -- 7
   16#03E# => O"063",             -- 8
   16#046# => O"062",             -- 9
   16#049# => O"043",             -- .
   16#05A# => O"076",             -- Enter
   16#255# => O"026",             -- +
   16#04E# => O"066",             -- -
   16#23E# => O"036",             -- *
   16#04A# => O"046",             -- /
   
   16#171# => O"070",             -- Delete  (do: Clx)
   16#066# => O"070",             -- BackSpace  (do: Clx)

   16#029# => O"000",             -- Space  (do: Yellow Shift)

--   16#04D# => O"042",             -- p  (do: PI)
--   16#24D# => O"042",             -- P  (do: PI)
   16#024# => O"072",             -- e  (do: EEX)
   16#224# => O"072",             -- E  (do: EEX)

   16#22E# => O"010",             -- %  (do: %)

   16#05D# => O"073",             -- \  (do: CHS)

   16#005# => O"056",             -- F1  (do: x^2)
   16#006# => O"053",             -- F2  (do: sin)
   16#004# => O"052",             -- F3  (do: cos)
   16#00C# => O"050",             -- F4  (do: tan)

   16#003# => O"006",             -- F5        (do: 1/x)
--   16#203# => O"002",             -- shift-F5  (do: e^x)
   16#00B# => O"004",             -- F6        (do: ln)
   16#20B# => O"042",             -- shift-F6  (do: Sigma +)
   16#083# => O"003",             -- F7        (do: e^x)
   16#283# => O"010",             -- shift-F7  (do: %)
   16#00A# => O"002",             -- F8        (do: FIX)
   16#20A# => O"054",             -- shift-F8  (do: ->P)

   16#001# => O"016",             -- F9        (do: x<>y)
   16#201# => O"076",             -- shift-F9  (do: Enter)
   16#009# => O"014",             -- F10       (do: Roll Down)
   16#209# => O"073",             -- shift-F10 (do: CHS)
   16#078# => O"013",             -- F11       (do: STO)
   16#278# => O"072",             -- shift-F11 (do: EEX)
   16#007# => O"012",             -- F12       (do: RCL)
   16#207# => O"070",             -- shift-F12 (do: CLX)

--   16#222# => O"016",             -- X  (do: 1/x)
--   16#41A# => O"016",             -- cntl-Z  (do: 1/x)
   
   16#0E0# => EXTENDED,           -- Extended keycode prefix
   16#2E0# => EXTENDED,           -- Extended keycode prefix
   16#4E0# => EXTENDED,           -- Extended keycode prefix
   16#6E0# => EXTENDED,           -- Extended keycode prefix

   16#0F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#1F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#2F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#3F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#4F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#5F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#6F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#7F0# => KEY_BREAK,              -- Key break (key release) prefix

   16#012# => L_SHIFT_KEY,           
   16#212# => L_SHIFT_KEY,           
   16#412# => L_SHIFT_KEY,           
   16#612# => L_SHIFT_KEY,           
   
   16#059# => R_SHIFT_KEY,           
   16#259# => R_SHIFT_KEY,           
   16#459# => R_SHIFT_KEY,           
   16#659# => R_SHIFT_KEY,           
   
   16#014# => L_CONTROL_KEY,
   16#214# => L_CONTROL_KEY,
   16#414# => L_CONTROL_KEY,
   16#614# => L_CONTROL_KEY,
   
   16#114# => R_CONTROL_KEY,
   16#314# => R_CONTROL_KEY,
   16#514# => R_CONTROL_KEY,
   16#714# => R_CONTROL_KEY,
   
   others  => INVALID_KEY
  );  -- End: HP45

constant KEY_LUT_HP55 : keyLutType := (
-- LUT Address: cntl & shift & ext & code 
   16#00E# => O"077",             -- ` Special key to control LED brightness -- not a keycode for the HP Calc core!
   16#02D# => O"007",             -- r Special key for switch set to RUN     -- not a keycode for the HP Calc core!
   16#22D# => O"007",             -- R Special key for switch set to RUN     -- not a keycode for the HP Calc core!
   16#04D# => O"017",             -- p Special key for switch set to PROG    -- not a keycode for the HP Calc core!
   16#24D# => O"017",             -- P Special key for switch set to PROG    -- not a keycode for the HP Calc core!
   16#02C# => O"027",             -- t Special key for switch set to TIMER   -- not a keycode for the HP Calc core!
   16#22C# => O"027",             -- T Special key for switch set to TIMER   -- not a keycode for the HP Calc core!

   16#01B# => O"037",             -- s Special key for RealSpeede            -- not a keycode for the HP Calc core!
   16#21B# => O"037",             -- S Special key for RealSpeede            -- not a keycode for the HP Calc core!
   16#02B# => O"047",             -- f Special key for full speed            -- not a keycode for the HP Calc core!
   16#22B# => O"047",             -- F Special key for full speed            -- not a keycode for the HP Calc core!
   
   16#070# => O"044",             -- 0 (keypad)
   16#069# => O"034",             -- 1 (keypad)
   16#072# => O"033",             -- 2 (keypad)
   16#07A# => O"032",             -- 3 (keypad)
   16#06B# => O"024",             -- 4 (keypad)
   16#073# => O"023",             -- 5 (keypad)
   16#074# => O"022",             -- 6 (keypad)
   16#06C# => O"064",             -- 7 (keypad)
   16#075# => O"063",             -- 8 (keypad)
   16#07D# => O"062",             -- 9 (keypad)
   16#071# => O"043",             -- . (keypad)
   16#15A# => O"076",             -- Enter (keypad)
   16#079# => O"026",             -- + (keypad)
   16#07B# => O"066",             -- - (keypad)
   16#07C# => O"036",             -- * (keypad)
   16#14A# => O"046",             -- / (keypad)
   16#045# => O"044",             -- 0
   16#016# => O"034",             -- 1
   16#01E# => O"033",             -- 2
   16#026# => O"032",             -- 3
   16#025# => O"024",             -- 4
   16#02E# => O"023",             -- 5
   16#036# => O"022",             -- 6
   16#03D# => O"064",             -- 7
   16#03E# => O"063",             -- 8
   16#046# => O"062",             -- 9
   16#049# => O"043",             -- .
   16#05A# => O"076",             -- Enter
   16#255# => O"026",             -- +
   16#04E# => O"066",             -- -
   16#23E# => O"036",             -- *
   16#04A# => O"046",             -- /
   
   16#171# => O"070",             -- Delete  (do: Clx)
   16#066# => O"070",             -- BackSpace  (do: Clx)

   16#029# => O"016",             -- Space  (do: Yellow Shift)
   16#076# => O"014",             -- ESC  (do: Blue Shift)

   16#024# => O"072",             -- e  (do: EEX)
   16#224# => O"072",             -- E  (do: EEX)

   16#22E# => O"002",             -- %  (do: %)

   16#05D# => O"073",             -- \  (do: CHS)

   16#005# => O"006",             -- F1  (do: Sigma +)
   16#006# => O"004",             -- F2  (do: y^x)
   16#004# => O"003",             -- F3  (do: 1/x)
   16#00C# => O"002",             -- F4  (do: %)

   16#003# => O"056",             -- F5        (do: y-hat)
   16#00B# => O"054",             -- F6        (do: x<->y)
   16#083# => O"053",             -- F7        (do: Roll Down)
   16#00A# => O"052",             -- F8        (do: FIX)

   16#001# => O"010",             -- F9        (do: GTO)
   16#201# => O"042",             -- shift-F9  (do: R/S)
   16#009# => O"073",             -- F10       (do: CHS)
   --16#209# => O"073",             -- shift-F10 (do: CHS)
   16#078# => O"013",             -- F11       (do: STO)
   16#278# => O"000",             -- shift-F11 (do: BST)
   16#007# => O"012",             -- F12       (do: RCL)
   16#207# => O"050",             -- shift-F12 (do: SST)



   16#175# => O"000",             -- Up Arrow  (do: BST)
   16#172# => O"050",             -- Down Arrow  (do: SST)
   16#174# => O"042",             -- Right Arrow  (do: R/S)
   16#034# => O"010",             -- g  (do: GTO)
   16#234# => O"010",             -- G  (do: GTO)
   
--   16#41A# => O"016",             -- cntl-Z  (do: 1/x)
   
   16#0E0# => EXTENDED,           -- Extended keycode prefix
   16#2E0# => EXTENDED,           -- Extended keycode prefix
   16#4E0# => EXTENDED,           -- Extended keycode prefix
   16#6E0# => EXTENDED,           -- Extended keycode prefix

   16#0F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#1F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#2F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#3F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#4F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#5F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#6F0# => KEY_BREAK,              -- Key break (key release) prefix
   16#7F0# => KEY_BREAK,              -- Key break (key release) prefix

   16#012# => L_SHIFT_KEY,           
   16#212# => L_SHIFT_KEY,           
   16#412# => L_SHIFT_KEY,           
   16#612# => L_SHIFT_KEY,           
   
   16#059# => R_SHIFT_KEY,           
   16#259# => R_SHIFT_KEY,           
   16#459# => R_SHIFT_KEY,           
   16#659# => R_SHIFT_KEY,           
   
   16#014# => L_CONTROL_KEY,
   16#214# => L_CONTROL_KEY,
   16#414# => L_CONTROL_KEY,
   16#614# => L_CONTROL_KEY,
   
   16#114# => R_CONTROL_KEY,
   16#314# => R_CONTROL_KEY,
   16#514# => R_CONTROL_KEY,
   16#714# => R_CONTROL_KEY,
   
   others  => INVALID_KEY
  );  -- End: HP55

end ps2_keyboard_pack;

package body ps2_keyboard_pack is
 
end ps2_keyboard_pack;
