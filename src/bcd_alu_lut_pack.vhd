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
--	Package: bcd_alu_lut_pack
--
--	Defines a BCD ALU via a LUT (Look Up Table)
--
--

library ieee;
use ieee.std_logic_1164.all;

package bcd_alu_lut_pack is
  
  type BcdAluLutType is array (natural range 0 to 1023) of std_logic_vector(4 downto 0);
  
  -- Inputs (i.e. LUT address):
  -- A         = bits(3:0)
  -- B         = bits(7:4)
  -- Carry In  = bit(8)  (or borrow in for subtraction)
  -- Add/Sub   = bit(9) ('0' for addition, '1' for subtration)
  -- Outputs (i.e. LUT data):
  -- Y         = bits(3:0) (result)
  -- Carry Out = bit(4)  (or borrow out for subtraction)
  
  constant BCD_ALU_LUT : BcdAluLutType := (
    16#000# => '0'&X"0",  -- 0+0+0 = 0 (carry=0)
    16#001# => '0'&X"1",  -- 1+0+0 = 1 (carry=0)
    16#002# => '0'&X"2",  -- 2+0+0 = 2 (carry=0)
    16#003# => '0'&X"3",  -- 3+0+0 = 3 (carry=0)
    16#004# => '0'&X"4",  -- 4+0+0 = 4 (carry=0)
    16#005# => '0'&X"5",  -- 5+0+0 = 5 (carry=0)
    16#006# => '0'&X"6",  -- 6+0+0 = 6 (carry=0)
    16#007# => '0'&X"7",  -- 7+0+0 = 7 (carry=0)
    16#008# => '0'&X"8",  -- 8+0+0 = 8 (carry=0)
    16#009# => '0'&X"9",  -- 9+0+0 = 9 (carry=0)
    16#010# => '0'&X"1",  -- 0+1+0 = 1 (carry=0)
    16#011# => '0'&X"2",  -- 1+1+0 = 2 (carry=0)
    16#012# => '0'&X"3",  -- 2+1+0 = 3 (carry=0)
    16#013# => '0'&X"4",  -- 3+1+0 = 4 (carry=0)
    16#014# => '0'&X"5",  -- 4+1+0 = 5 (carry=0)
    16#015# => '0'&X"6",  -- 5+1+0 = 6 (carry=0)
    16#016# => '0'&X"7",  -- 6+1+0 = 7 (carry=0)
    16#017# => '0'&X"8",  -- 7+1+0 = 8 (carry=0)
    16#018# => '0'&X"9",  -- 8+1+0 = 9 (carry=0)
    16#019# => '1'&X"0",  -- 9+1+0 = 0 (carry=1)
    16#020# => '0'&X"2",  -- 0+2+0 = 2 (carry=0)
    16#021# => '0'&X"3",  -- 1+2+0 = 3 (carry=0)
    16#022# => '0'&X"4",  -- 2+2+0 = 4 (carry=0)
    16#023# => '0'&X"5",  -- 3+2+0 = 5 (carry=0)
    16#024# => '0'&X"6",  -- 4+2+0 = 6 (carry=0)
    16#025# => '0'&X"7",  -- 5+2+0 = 7 (carry=0)
    16#026# => '0'&X"8",  -- 6+2+0 = 8 (carry=0)
    16#027# => '0'&X"9",  -- 7+2+0 = 9 (carry=0)
    16#028# => '1'&X"0",  -- 8+2+0 = 0 (carry=1)
    16#029# => '1'&X"1",  -- 9+2+0 = 1 (carry=1)
    16#030# => '0'&X"3",  -- 0+3+0 = 3 (carry=0)
    16#031# => '0'&X"4",  -- 1+3+0 = 4 (carry=0)
    16#032# => '0'&X"5",  -- 2+3+0 = 5 (carry=0)
    16#033# => '0'&X"6",  -- 3+3+0 = 6 (carry=0)
    16#034# => '0'&X"7",  -- 4+3+0 = 7 (carry=0)
    16#035# => '0'&X"8",  -- 5+3+0 = 8 (carry=0)
    16#036# => '0'&X"9",  -- 6+3+0 = 9 (carry=0)
    16#037# => '1'&X"0",  -- 7+3+0 = 0 (carry=1)
    16#038# => '1'&X"1",  -- 8+3+0 = 1 (carry=1)
    16#039# => '1'&X"2",  -- 9+3+0 = 2 (carry=1)
    16#040# => '0'&X"4",  -- 0+4+0 = 4 (carry=0)
    16#041# => '0'&X"5",  -- 1+4+0 = 5 (carry=0)
    16#042# => '0'&X"6",  -- 2+4+0 = 6 (carry=0)
    16#043# => '0'&X"7",  -- 3+4+0 = 7 (carry=0)
    16#044# => '0'&X"8",  -- 4+4+0 = 8 (carry=0)
    16#045# => '0'&X"9",  -- 5+4+0 = 9 (carry=0)
    16#046# => '1'&X"0",  -- 6+4+0 = 0 (carry=1)
    16#047# => '1'&X"1",  -- 7+4+0 = 1 (carry=1)
    16#048# => '1'&X"2",  -- 8+4+0 = 2 (carry=1)
    16#049# => '1'&X"3",  -- 9+4+0 = 3 (carry=1)
    16#050# => '0'&X"5",  -- 0+5+0 = 5 (carry=0)
    16#051# => '0'&X"6",  -- 1+5+0 = 6 (carry=0)
    16#052# => '0'&X"7",  -- 2+5+0 = 7 (carry=0)
    16#053# => '0'&X"8",  -- 3+5+0 = 8 (carry=0)
    16#054# => '0'&X"9",  -- 4+5+0 = 9 (carry=0)
    16#055# => '1'&X"0",  -- 5+5+0 = 0 (carry=1)
    16#056# => '1'&X"1",  -- 6+5+0 = 1 (carry=1)
    16#057# => '1'&X"2",  -- 7+5+0 = 2 (carry=1)
    16#058# => '1'&X"3",  -- 8+5+0 = 3 (carry=1)
    16#059# => '1'&X"4",  -- 9+5+0 = 4 (carry=1)
    16#060# => '0'&X"6",  -- 0+6+0 = 6 (carry=0)
    16#061# => '0'&X"7",  -- 1+6+0 = 7 (carry=0)
    16#062# => '0'&X"8",  -- 2+6+0 = 8 (carry=0)
    16#063# => '0'&X"9",  -- 3+6+0 = 9 (carry=0)
    16#064# => '1'&X"0",  -- 4+6+0 = 0 (carry=1)
    16#065# => '1'&X"1",  -- 5+6+0 = 1 (carry=1)
    16#066# => '1'&X"2",  -- 6+6+0 = 2 (carry=1)
    16#067# => '1'&X"3",  -- 7+6+0 = 3 (carry=1)
    16#068# => '1'&X"4",  -- 8+6+0 = 4 (carry=1)
    16#069# => '1'&X"5",  -- 9+6+0 = 5 (carry=1)
    16#070# => '0'&X"7",  -- 0+7+0 = 7 (carry=0)
    16#071# => '0'&X"8",  -- 1+7+0 = 8 (carry=0)
    16#072# => '0'&X"9",  -- 2+7+0 = 9 (carry=0)
    16#073# => '1'&X"0",  -- 3+7+0 = 0 (carry=1)
    16#074# => '1'&X"1",  -- 4+7+0 = 1 (carry=1)
    16#075# => '1'&X"2",  -- 5+7+0 = 2 (carry=1)
    16#076# => '1'&X"3",  -- 6+7+0 = 3 (carry=1)
    16#077# => '1'&X"4",  -- 7+7+0 = 4 (carry=1)
    16#078# => '1'&X"5",  -- 8+7+0 = 5 (carry=1)
    16#079# => '1'&X"6",  -- 9+7+0 = 6 (carry=1)
    16#080# => '0'&X"8",  -- 0+8+0 = 8 (carry=0)
    16#081# => '0'&X"9",  -- 1+8+0 = 9 (carry=0)
    16#082# => '1'&X"0",  -- 2+8+0 = 0 (carry=1)
    16#083# => '1'&X"1",  -- 3+8+0 = 1 (carry=1)
    16#084# => '1'&X"2",  -- 4+8+0 = 2 (carry=1)
    16#085# => '1'&X"3",  -- 5+8+0 = 3 (carry=1)
    16#086# => '1'&X"4",  -- 6+8+0 = 4 (carry=1)
    16#087# => '1'&X"5",  -- 7+8+0 = 5 (carry=1)
    16#088# => '1'&X"6",  -- 8+8+0 = 6 (carry=1)
    16#089# => '1'&X"7",  -- 9+8+0 = 7 (carry=1)
    16#090# => '0'&X"9",  -- 0+9+0 = 9 (carry=0)
    16#091# => '1'&X"0",  -- 1+9+0 = 0 (carry=1)
    16#092# => '1'&X"1",  -- 2+9+0 = 1 (carry=1)
    16#093# => '1'&X"2",  -- 3+9+0 = 2 (carry=1)
    16#094# => '1'&X"3",  -- 4+9+0 = 3 (carry=1)
    16#095# => '1'&X"4",  -- 5+9+0 = 4 (carry=1)
    16#096# => '1'&X"5",  -- 6+9+0 = 5 (carry=1)
    16#097# => '1'&X"6",  -- 7+9+0 = 6 (carry=1)
    16#098# => '1'&X"7",  -- 8+9+0 = 7 (carry=1)
    16#099# => '1'&X"8",  -- 9+9+0 = 8 (carry=1)
    16#100# => '0'&X"1",  -- 0+0+1 = 1 (carry=0)
    16#101# => '0'&X"2",  -- 1+0+1 = 2 (carry=0)
    16#102# => '0'&X"3",  -- 2+0+1 = 3 (carry=0)
    16#103# => '0'&X"4",  -- 3+0+1 = 4 (carry=0)
    16#104# => '0'&X"5",  -- 4+0+1 = 5 (carry=0)
    16#105# => '0'&X"6",  -- 5+0+1 = 6 (carry=0)
    16#106# => '0'&X"7",  -- 6+0+1 = 7 (carry=0)
    16#107# => '0'&X"8",  -- 7+0+1 = 8 (carry=0)
    16#108# => '0'&X"9",  -- 8+0+1 = 9 (carry=0)
    16#109# => '1'&X"0",  -- 9+0+1 = 0 (carry=1)
    16#110# => '0'&X"2",  -- 0+1+1 = 2 (carry=0)
    16#111# => '0'&X"3",  -- 1+1+1 = 3 (carry=0)
    16#112# => '0'&X"4",  -- 2+1+1 = 4 (carry=0)
    16#113# => '0'&X"5",  -- 3+1+1 = 5 (carry=0)
    16#114# => '0'&X"6",  -- 4+1+1 = 6 (carry=0)
    16#115# => '0'&X"7",  -- 5+1+1 = 7 (carry=0)
    16#116# => '0'&X"8",  -- 6+1+1 = 8 (carry=0)
    16#117# => '0'&X"9",  -- 7+1+1 = 9 (carry=0)
    16#118# => '1'&X"0",  -- 8+1+1 = 0 (carry=1)
    16#119# => '1'&X"1",  -- 9+1+1 = 1 (carry=1)
    16#120# => '0'&X"3",  -- 0+2+1 = 3 (carry=0)
    16#121# => '0'&X"4",  -- 1+2+1 = 4 (carry=0)
    16#122# => '0'&X"5",  -- 2+2+1 = 5 (carry=0)
    16#123# => '0'&X"6",  -- 3+2+1 = 6 (carry=0)
    16#124# => '0'&X"7",  -- 4+2+1 = 7 (carry=0)
    16#125# => '0'&X"8",  -- 5+2+1 = 8 (carry=0)
    16#126# => '0'&X"9",  -- 6+2+1 = 9 (carry=0)
    16#127# => '1'&X"0",  -- 7+2+1 = 0 (carry=1)
    16#128# => '1'&X"1",  -- 8+2+1 = 1 (carry=1)
    16#129# => '1'&X"2",  -- 9+2+1 = 2 (carry=1)
    16#130# => '0'&X"4",  -- 0+3+1 = 4 (carry=0)
    16#131# => '0'&X"5",  -- 1+3+1 = 5 (carry=0)
    16#132# => '0'&X"6",  -- 2+3+1 = 6 (carry=0)
    16#133# => '0'&X"7",  -- 3+3+1 = 7 (carry=0)
    16#134# => '0'&X"8",  -- 4+3+1 = 8 (carry=0)
    16#135# => '0'&X"9",  -- 5+3+1 = 9 (carry=0)
    16#136# => '1'&X"0",  -- 6+3+1 = 0 (carry=1)
    16#137# => '1'&X"1",  -- 7+3+1 = 1 (carry=1)
    16#138# => '1'&X"2",  -- 8+3+1 = 2 (carry=1)
    16#139# => '1'&X"3",  -- 9+3+1 = 3 (carry=1)
    16#140# => '0'&X"5",  -- 0+4+1 = 5 (carry=0)
    16#141# => '0'&X"6",  -- 1+4+1 = 6 (carry=0)
    16#142# => '0'&X"7",  -- 2+4+1 = 7 (carry=0)
    16#143# => '0'&X"8",  -- 3+4+1 = 8 (carry=0)
    16#144# => '0'&X"9",  -- 4+4+1 = 9 (carry=0)
    16#145# => '1'&X"0",  -- 5+4+1 = 0 (carry=1)
    16#146# => '1'&X"1",  -- 6+4+1 = 1 (carry=1)
    16#147# => '1'&X"2",  -- 7+4+1 = 2 (carry=1)
    16#148# => '1'&X"3",  -- 8+4+1 = 3 (carry=1)
    16#149# => '1'&X"4",  -- 9+4+1 = 4 (carry=1)
    16#150# => '0'&X"6",  -- 0+5+1 = 6 (carry=0)
    16#151# => '0'&X"7",  -- 1+5+1 = 7 (carry=0)
    16#152# => '0'&X"8",  -- 2+5+1 = 8 (carry=0)
    16#153# => '0'&X"9",  -- 3+5+1 = 9 (carry=0)
    16#154# => '1'&X"0",  -- 4+5+1 = 0 (carry=1)
    16#155# => '1'&X"1",  -- 5+5+1 = 1 (carry=1)
    16#156# => '1'&X"2",  -- 6+5+1 = 2 (carry=1)
    16#157# => '1'&X"3",  -- 7+5+1 = 3 (carry=1)
    16#158# => '1'&X"4",  -- 8+5+1 = 4 (carry=1)
    16#159# => '1'&X"5",  -- 9+5+1 = 5 (carry=1)
    16#160# => '0'&X"7",  -- 0+6+1 = 7 (carry=0)
    16#161# => '0'&X"8",  -- 1+6+1 = 8 (carry=0)
    16#162# => '0'&X"9",  -- 2+6+1 = 9 (carry=0)
    16#163# => '1'&X"0",  -- 3+6+1 = 0 (carry=1)
    16#164# => '1'&X"1",  -- 4+6+1 = 1 (carry=1)
    16#165# => '1'&X"2",  -- 5+6+1 = 2 (carry=1)
    16#166# => '1'&X"3",  -- 6+6+1 = 3 (carry=1)
    16#167# => '1'&X"4",  -- 7+6+1 = 4 (carry=1)
    16#168# => '1'&X"5",  -- 8+6+1 = 5 (carry=1)
    16#169# => '1'&X"6",  -- 9+6+1 = 6 (carry=1)
    16#170# => '0'&X"8",  -- 0+7+1 = 8 (carry=0)
    16#171# => '0'&X"9",  -- 1+7+1 = 9 (carry=0)
    16#172# => '1'&X"0",  -- 2+7+1 = 0 (carry=1)
    16#173# => '1'&X"1",  -- 3+7+1 = 1 (carry=1)
    16#174# => '1'&X"2",  -- 4+7+1 = 2 (carry=1)
    16#175# => '1'&X"3",  -- 5+7+1 = 3 (carry=1)
    16#176# => '1'&X"4",  -- 6+7+1 = 4 (carry=1)
    16#177# => '1'&X"5",  -- 7+7+1 = 5 (carry=1)
    16#178# => '1'&X"6",  -- 8+7+1 = 6 (carry=1)
    16#179# => '1'&X"7",  -- 9+7+1 = 7 (carry=1)
    16#180# => '0'&X"9",  -- 0+8+1 = 9 (carry=0)
    16#181# => '1'&X"0",  -- 1+8+1 = 0 (carry=1)
    16#182# => '1'&X"1",  -- 2+8+1 = 1 (carry=1)
    16#183# => '1'&X"2",  -- 3+8+1 = 2 (carry=1)
    16#184# => '1'&X"3",  -- 4+8+1 = 3 (carry=1)
    16#185# => '1'&X"4",  -- 5+8+1 = 4 (carry=1)
    16#186# => '1'&X"5",  -- 6+8+1 = 5 (carry=1)
    16#187# => '1'&X"6",  -- 7+8+1 = 6 (carry=1)
    16#188# => '1'&X"7",  -- 8+8+1 = 7 (carry=1)
    16#189# => '1'&X"8",  -- 9+8+1 = 8 (carry=1)
    16#190# => '1'&X"0",  -- 0+9+1 = 0 (carry=1)
    16#191# => '1'&X"1",  -- 1+9+1 = 1 (carry=1)
    16#192# => '1'&X"2",  -- 2+9+1 = 2 (carry=1)
    16#193# => '1'&X"3",  -- 3+9+1 = 3 (carry=1)
    16#194# => '1'&X"4",  -- 4+9+1 = 4 (carry=1)
    16#195# => '1'&X"5",  -- 5+9+1 = 5 (carry=1)
    16#196# => '1'&X"6",  -- 6+9+1 = 6 (carry=1)
    16#197# => '1'&X"7",  -- 7+9+1 = 7 (carry=1)
    16#198# => '1'&X"8",  -- 8+9+1 = 8 (carry=1)
    16#199# => '1'&X"9",  -- 9+9+1 = 9 (carry=1)
    16#200# => '0'&X"0",  -- 0-0-0 = 0 (borrow=0)
    16#201# => '0'&X"1",  -- 1-0-0 = 1 (borrow=0)
    16#202# => '0'&X"2",  -- 2-0-0 = 2 (borrow=0)
    16#203# => '0'&X"3",  -- 3-0-0 = 3 (borrow=0)
    16#204# => '0'&X"4",  -- 4-0-0 = 4 (borrow=0)
    16#205# => '0'&X"5",  -- 5-0-0 = 5 (borrow=0)
    16#206# => '0'&X"6",  -- 6-0-0 = 6 (borrow=0)
    16#207# => '0'&X"7",  -- 7-0-0 = 7 (borrow=0)
    16#208# => '0'&X"8",  -- 8-0-0 = 8 (borrow=0)
    16#209# => '0'&X"9",  -- 9-0-0 = 9 (borrow=0)
    16#210# => '1'&X"9",  -- 0-1-0 = 9 (borrow=1)
    16#211# => '0'&X"0",  -- 1-1-0 = 0 (borrow=0)
    16#212# => '0'&X"1",  -- 2-1-0 = 1 (borrow=0)
    16#213# => '0'&X"2",  -- 3-1-0 = 2 (borrow=0)
    16#214# => '0'&X"3",  -- 4-1-0 = 3 (borrow=0)
    16#215# => '0'&X"4",  -- 5-1-0 = 4 (borrow=0)
    16#216# => '0'&X"5",  -- 6-1-0 = 5 (borrow=0)
    16#217# => '0'&X"6",  -- 7-1-0 = 6 (borrow=0)
    16#218# => '0'&X"7",  -- 8-1-0 = 7 (borrow=0)
    16#219# => '0'&X"8",  -- 9-1-0 = 8 (borrow=0)
    16#220# => '1'&X"8",  -- 0-2-0 = 8 (borrow=1)
    16#221# => '1'&X"9",  -- 1-2-0 = 9 (borrow=1)
    16#222# => '0'&X"0",  -- 2-2-0 = 0 (borrow=0)
    16#223# => '0'&X"1",  -- 3-2-0 = 1 (borrow=0)
    16#224# => '0'&X"2",  -- 4-2-0 = 2 (borrow=0)
    16#225# => '0'&X"3",  -- 5-2-0 = 3 (borrow=0)
    16#226# => '0'&X"4",  -- 6-2-0 = 4 (borrow=0)
    16#227# => '0'&X"5",  -- 7-2-0 = 5 (borrow=0)
    16#228# => '0'&X"6",  -- 8-2-0 = 6 (borrow=0)
    16#229# => '0'&X"7",  -- 9-2-0 = 7 (borrow=0)
    16#230# => '1'&X"7",  -- 0-3-0 = 7 (borrow=1)
    16#231# => '1'&X"8",  -- 1-3-0 = 8 (borrow=1)
    16#232# => '1'&X"9",  -- 2-3-0 = 9 (borrow=1)
    16#233# => '0'&X"0",  -- 3-3-0 = 0 (borrow=0)
    16#234# => '0'&X"1",  -- 4-3-0 = 1 (borrow=0)
    16#235# => '0'&X"2",  -- 5-3-0 = 2 (borrow=0)
    16#236# => '0'&X"3",  -- 6-3-0 = 3 (borrow=0)
    16#237# => '0'&X"4",  -- 7-3-0 = 4 (borrow=0)
    16#238# => '0'&X"5",  -- 8-3-0 = 5 (borrow=0)
    16#239# => '0'&X"6",  -- 9-3-0 = 6 (borrow=0)
    16#240# => '1'&X"6",  -- 0-4-0 = 6 (borrow=1)
    16#241# => '1'&X"7",  -- 1-4-0 = 7 (borrow=1)
    16#242# => '1'&X"8",  -- 2-4-0 = 8 (borrow=1)
    16#243# => '1'&X"9",  -- 3-4-0 = 9 (borrow=1)
    16#244# => '0'&X"0",  -- 4-4-0 = 0 (borrow=0)
    16#245# => '0'&X"1",  -- 5-4-0 = 1 (borrow=0)
    16#246# => '0'&X"2",  -- 6-4-0 = 2 (borrow=0)
    16#247# => '0'&X"3",  -- 7-4-0 = 3 (borrow=0)
    16#248# => '0'&X"4",  -- 8-4-0 = 4 (borrow=0)
    16#249# => '0'&X"5",  -- 9-4-0 = 5 (borrow=0)
    16#250# => '1'&X"5",  -- 0-5-0 = 5 (borrow=1)
    16#251# => '1'&X"6",  -- 1-5-0 = 6 (borrow=1)
    16#252# => '1'&X"7",  -- 2-5-0 = 7 (borrow=1)
    16#253# => '1'&X"8",  -- 3-5-0 = 8 (borrow=1)
    16#254# => '1'&X"9",  -- 4-5-0 = 9 (borrow=1)
    16#255# => '0'&X"0",  -- 5-5-0 = 0 (borrow=0)
    16#256# => '0'&X"1",  -- 6-5-0 = 1 (borrow=0)
    16#257# => '0'&X"2",  -- 7-5-0 = 2 (borrow=0)
    16#258# => '0'&X"3",  -- 8-5-0 = 3 (borrow=0)
    16#259# => '0'&X"4",  -- 9-5-0 = 4 (borrow=0)
    16#260# => '1'&X"4",  -- 0-6-0 = 4 (borrow=1)
    16#261# => '1'&X"5",  -- 1-6-0 = 5 (borrow=1)
    16#262# => '1'&X"6",  -- 2-6-0 = 6 (borrow=1)
    16#263# => '1'&X"7",  -- 3-6-0 = 7 (borrow=1)
    16#264# => '1'&X"8",  -- 4-6-0 = 8 (borrow=1)
    16#265# => '1'&X"9",  -- 5-6-0 = 9 (borrow=1)
    16#266# => '0'&X"0",  -- 6-6-0 = 0 (borrow=0)
    16#267# => '0'&X"1",  -- 7-6-0 = 1 (borrow=0)
    16#268# => '0'&X"2",  -- 8-6-0 = 2 (borrow=0)
    16#269# => '0'&X"3",  -- 9-6-0 = 3 (borrow=0)
    16#270# => '1'&X"3",  -- 0-7-0 = 3 (borrow=1)
    16#271# => '1'&X"4",  -- 1-7-0 = 4 (borrow=1)
    16#272# => '1'&X"5",  -- 2-7-0 = 5 (borrow=1)
    16#273# => '1'&X"6",  -- 3-7-0 = 6 (borrow=1)
    16#274# => '1'&X"7",  -- 4-7-0 = 7 (borrow=1)
    16#275# => '1'&X"8",  -- 5-7-0 = 8 (borrow=1)
    16#276# => '1'&X"9",  -- 6-7-0 = 9 (borrow=1)
    16#277# => '0'&X"0",  -- 7-7-0 = 0 (borrow=0)
    16#278# => '0'&X"1",  -- 8-7-0 = 1 (borrow=0)
    16#279# => '0'&X"2",  -- 9-7-0 = 2 (borrow=0)
    16#280# => '1'&X"2",  -- 0-8-0 = 2 (borrow=1)
    16#281# => '1'&X"3",  -- 1-8-0 = 3 (borrow=1)
    16#282# => '1'&X"4",  -- 2-8-0 = 4 (borrow=1)
    16#283# => '1'&X"5",  -- 3-8-0 = 5 (borrow=1)
    16#284# => '1'&X"6",  -- 4-8-0 = 6 (borrow=1)
    16#285# => '1'&X"7",  -- 5-8-0 = 7 (borrow=1)
    16#286# => '1'&X"8",  -- 6-8-0 = 8 (borrow=1)
    16#287# => '1'&X"9",  -- 7-8-0 = 9 (borrow=1)
    16#288# => '0'&X"0",  -- 8-8-0 = 0 (borrow=0)
    16#289# => '0'&X"1",  -- 9-8-0 = 1 (borrow=0)
    16#290# => '1'&X"1",  -- 0-9-0 = 1 (borrow=1)
    16#291# => '1'&X"2",  -- 1-9-0 = 2 (borrow=1)
    16#292# => '1'&X"3",  -- 2-9-0 = 3 (borrow=1)
    16#293# => '1'&X"4",  -- 3-9-0 = 4 (borrow=1)
    16#294# => '1'&X"5",  -- 4-9-0 = 5 (borrow=1)
    16#295# => '1'&X"6",  -- 5-9-0 = 6 (borrow=1)
    16#296# => '1'&X"7",  -- 6-9-0 = 7 (borrow=1)
    16#297# => '1'&X"8",  -- 7-9-0 = 8 (borrow=1)
    16#298# => '1'&X"9",  -- 8-9-0 = 9 (borrow=1)
    16#299# => '0'&X"0",  -- 9-9-0 = 0 (borrow=0)
    16#300# => '1'&X"9",  -- 0-0-1 = 9 (borrow=1)
    16#301# => '0'&X"0",  -- 1-0-1 = 0 (borrow=0)
    16#302# => '0'&X"1",  -- 2-0-1 = 1 (borrow=0)
    16#303# => '0'&X"2",  -- 3-0-1 = 2 (borrow=0)
    16#304# => '0'&X"3",  -- 4-0-1 = 3 (borrow=0)
    16#305# => '0'&X"4",  -- 5-0-1 = 4 (borrow=0)
    16#306# => '0'&X"5",  -- 6-0-1 = 5 (borrow=0)
    16#307# => '0'&X"6",  -- 7-0-1 = 6 (borrow=0)
    16#308# => '0'&X"7",  -- 8-0-1 = 7 (borrow=0)
    16#309# => '0'&X"8",  -- 9-0-1 = 8 (borrow=0)
    16#310# => '1'&X"8",  -- 0-1-1 = 8 (borrow=1)
    16#311# => '1'&X"9",  -- 1-1-1 = 9 (borrow=1)
    16#312# => '0'&X"0",  -- 2-1-1 = 0 (borrow=0)
    16#313# => '0'&X"1",  -- 3-1-1 = 1 (borrow=0)
    16#314# => '0'&X"2",  -- 4-1-1 = 2 (borrow=0)
    16#315# => '0'&X"3",  -- 5-1-1 = 3 (borrow=0)
    16#316# => '0'&X"4",  -- 6-1-1 = 4 (borrow=0)
    16#317# => '0'&X"5",  -- 7-1-1 = 5 (borrow=0)
    16#318# => '0'&X"6",  -- 8-1-1 = 6 (borrow=0)
    16#319# => '0'&X"7",  -- 9-1-1 = 7 (borrow=0)
    16#320# => '1'&X"7",  -- 0-2-1 = 7 (borrow=1)
    16#321# => '1'&X"8",  -- 1-2-1 = 8 (borrow=1)
    16#322# => '1'&X"9",  -- 2-2-1 = 9 (borrow=1)
    16#323# => '0'&X"0",  -- 3-2-1 = 0 (borrow=0)
    16#324# => '0'&X"1",  -- 4-2-1 = 1 (borrow=0)
    16#325# => '0'&X"2",  -- 5-2-1 = 2 (borrow=0)
    16#326# => '0'&X"3",  -- 6-2-1 = 3 (borrow=0)
    16#327# => '0'&X"4",  -- 7-2-1 = 4 (borrow=0)
    16#328# => '0'&X"5",  -- 8-2-1 = 5 (borrow=0)
    16#329# => '0'&X"6",  -- 9-2-1 = 6 (borrow=0)
    16#330# => '1'&X"6",  -- 0-3-1 = 6 (borrow=1)
    16#331# => '1'&X"7",  -- 1-3-1 = 7 (borrow=1)
    16#332# => '1'&X"8",  -- 2-3-1 = 8 (borrow=1)
    16#333# => '1'&X"9",  -- 3-3-1 = 9 (borrow=1)
    16#334# => '0'&X"0",  -- 4-3-1 = 0 (borrow=0)
    16#335# => '0'&X"1",  -- 5-3-1 = 1 (borrow=0)
    16#336# => '0'&X"2",  -- 6-3-1 = 2 (borrow=0)
    16#337# => '0'&X"3",  -- 7-3-1 = 3 (borrow=0)
    16#338# => '0'&X"4",  -- 8-3-1 = 4 (borrow=0)
    16#339# => '0'&X"5",  -- 9-3-1 = 5 (borrow=0)
    16#340# => '1'&X"5",  -- 0-4-1 = 5 (borrow=1)
    16#341# => '1'&X"6",  -- 1-4-1 = 6 (borrow=1)
    16#342# => '1'&X"7",  -- 2-4-1 = 7 (borrow=1)
    16#343# => '1'&X"8",  -- 3-4-1 = 8 (borrow=1)
    16#344# => '1'&X"9",  -- 4-4-1 = 9 (borrow=1)
    16#345# => '0'&X"0",  -- 5-4-1 = 0 (borrow=0)
    16#346# => '0'&X"1",  -- 6-4-1 = 1 (borrow=0)
    16#347# => '0'&X"2",  -- 7-4-1 = 2 (borrow=0)
    16#348# => '0'&X"3",  -- 8-4-1 = 3 (borrow=0)
    16#349# => '0'&X"4",  -- 9-4-1 = 4 (borrow=0)
    16#350# => '1'&X"4",  -- 0-5-1 = 4 (borrow=1)
    16#351# => '1'&X"5",  -- 1-5-1 = 5 (borrow=1)
    16#352# => '1'&X"6",  -- 2-5-1 = 6 (borrow=1)
    16#353# => '1'&X"7",  -- 3-5-1 = 7 (borrow=1)
    16#354# => '1'&X"8",  -- 4-5-1 = 8 (borrow=1)
    16#355# => '1'&X"9",  -- 5-5-1 = 9 (borrow=1)
    16#356# => '0'&X"0",  -- 6-5-1 = 0 (borrow=0)
    16#357# => '0'&X"1",  -- 7-5-1 = 1 (borrow=0)
    16#358# => '0'&X"2",  -- 8-5-1 = 2 (borrow=0)
    16#359# => '0'&X"3",  -- 9-5-1 = 3 (borrow=0)
    16#360# => '1'&X"3",  -- 0-6-1 = 3 (borrow=1)
    16#361# => '1'&X"4",  -- 1-6-1 = 4 (borrow=1)
    16#362# => '1'&X"5",  -- 2-6-1 = 5 (borrow=1)
    16#363# => '1'&X"6",  -- 3-6-1 = 6 (borrow=1)
    16#364# => '1'&X"7",  -- 4-6-1 = 7 (borrow=1)
    16#365# => '1'&X"8",  -- 5-6-1 = 8 (borrow=1)
    16#366# => '1'&X"9",  -- 6-6-1 = 9 (borrow=1)
    16#367# => '0'&X"0",  -- 7-6-1 = 0 (borrow=0)
    16#368# => '0'&X"1",  -- 8-6-1 = 1 (borrow=0)
    16#369# => '0'&X"2",  -- 9-6-1 = 2 (borrow=0)
    16#370# => '1'&X"2",  -- 0-7-1 = 2 (borrow=1)
    16#371# => '1'&X"3",  -- 1-7-1 = 3 (borrow=1)
    16#372# => '1'&X"4",  -- 2-7-1 = 4 (borrow=1)
    16#373# => '1'&X"5",  -- 3-7-1 = 5 (borrow=1)
    16#374# => '1'&X"6",  -- 4-7-1 = 6 (borrow=1)
    16#375# => '1'&X"7",  -- 5-7-1 = 7 (borrow=1)
    16#376# => '1'&X"8",  -- 6-7-1 = 8 (borrow=1)
    16#377# => '1'&X"9",  -- 7-7-1 = 9 (borrow=1)
    16#378# => '0'&X"0",  -- 8-7-1 = 0 (borrow=0)
    16#379# => '0'&X"1",  -- 9-7-1 = 1 (borrow=0)
    16#380# => '1'&X"1",  -- 0-8-1 = 1 (borrow=1)
    16#381# => '1'&X"2",  -- 1-8-1 = 2 (borrow=1)
    16#382# => '1'&X"3",  -- 2-8-1 = 3 (borrow=1)
    16#383# => '1'&X"4",  -- 3-8-1 = 4 (borrow=1)
    16#384# => '1'&X"5",  -- 4-8-1 = 5 (borrow=1)
    16#385# => '1'&X"6",  -- 5-8-1 = 6 (borrow=1)
    16#386# => '1'&X"7",  -- 6-8-1 = 7 (borrow=1)
    16#387# => '1'&X"8",  -- 7-8-1 = 8 (borrow=1)
    16#388# => '1'&X"9",  -- 8-8-1 = 9 (borrow=1)
    16#389# => '0'&X"0",  -- 9-8-1 = 0 (borrow=0)
    16#390# => '1'&X"0",  -- 0-9-1 = 0 (borrow=1)
    16#391# => '1'&X"1",  -- 1-9-1 = 1 (borrow=1)
    16#392# => '1'&X"2",  -- 2-9-1 = 2 (borrow=1)
    16#393# => '1'&X"3",  -- 3-9-1 = 3 (borrow=1)
    16#394# => '1'&X"4",  -- 4-9-1 = 4 (borrow=1)
    16#395# => '1'&X"5",  -- 5-9-1 = 5 (borrow=1)
    16#396# => '1'&X"6",  -- 6-9-1 = 6 (borrow=1)
    16#397# => '1'&X"7",  -- 7-9-1 = 7 (borrow=1)
    16#398# => '1'&X"8",  -- 8-9-1 = 8 (borrow=1)
    16#399# => '1'&X"9",  -- 9-9-1 = 9 (borrow=1)
    others  => '0'&X"0"
    );

end bcd_alu_lut_pack;

package body bcd_alu_lut_pack is
end bcd_alu_lut_pack;
