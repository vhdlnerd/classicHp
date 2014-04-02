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

----------------------------------------------------------------------------------
-- Engineer:  Brian Nemetz
-- 
-- Create Date:    08:59:31 10/12/2012 
-- Design Name: 
-- Module Name:    bcd_alu - lut and rtl
-- Project Name: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.classic_pack.all;
use work.bcd_alu_lut_pack.all;

entity bcd_alu is
    port ( clk_i       : in     std_logic;      -- clock input
           rst_i       : in     std_logic;      -- reset input
           a_i         : in     bcdDigitType;   -- BCD digit A (4-bits)
           b_i         : in     bcdDigitType;   -- BCD digit B (4-bits)
           carry_i     : in     std_logic;      -- Carry input
           subAddLow_i : in     std_logic;      -- Subtract or Add: 1=Subtract, 0=Add
           y_o         :   out  bcdDigitType;   -- BCD output
           carray_o    :   out  std_logic       -- Carry output
           );
end entity bcd_alu;

--
-- This version uses a large LUT to do the BCD math.
-- The LUT should infer a BRAM used as a ROM
--
architecture lut of bcd_alu is
  signal addr  : unsigned(9 downto 0);
  signal dataR : std_logic_vector(4 downto 0);
begin
  -- join the inputs into an address vector
  addr <= subAddLow_i & carry_i & b_i & a_i;

  rom_proc : process(clk_i)
  begin
    if rising_edge(clk_i) then
      dataR <= BCD_ALU_LUT(to_integer(addr));
    end if;
  end process rom_proc;

  -- Outputs:
  -- The output data of the LUT (i.e. the ROM above) is five bits wide.
  --    Bits 3 downto 0 is the result
  --    Bit 4 is the carry result
  y_o      <= unsigned(dataR(y_o'range));
  carray_o <= dataR(4);
end architecture lut;


-- This version does the BCD math in logic.
architecture rtl of bcd_alu is
  signal resultR  : bcdDigitType;
  signal carryR   : std_logic;
  signal iAdd     : unsigned(bcdDigitType'length downto 0);
  signal iSub     : unsigned(bcdDigitType'length downto 0);
  signal iAddBcd  : unsigned(bcdDigitType'length downto 0);
  signal iSubBcd  : unsigned(bcdDigitType'length downto 0);
  signal carry    : std_logic;
  signal borrow   : std_logic;
begin
  -- generate intermediate sum and difference of the two BCD inputs.
  -- NOTES:
  --     1) iAdd and iSub are 5 bits wide so overflow is not lost.
  --     2) iAdd and iSub are not valid BCD values (just the binary
  --        sum and difference of two BCD digits).
  iAdd    <= ('0'&a_i)+('0'&b_i)+("0000"&carry_i);
  iSub    <= ('0'&a_i)-('0'&b_i)-("0000"&carry_i);

  -- now generate correct BCD results with a correct carry/borrow bit
  alu_proc : process(iAdd, iSub)
  begin
    if iAdd > 9 then
      iAddBcd <= iAdd - 10;
      carry   <= '1';
    else
      iAddBcd <= iAdd;
      carry   <= '0';
    end if;
    if iSub(iSub'left) = '1' then
      iSubBcd <= iSub + 10;
      borrow  <= '1';
    else
      iSubBcd <= iSub;
      borrow  <= '0';
    end if;
  end process alu_proc;
  
  -- Finally, choose the sum or difference result.
  -- Note: the result is registered.
  clk_proc : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      resultR <= BCD_DIGIT_ZERO;
      carryR  <= '0';
    elsif rising_edge(clk_i) then
      if subAddLow_i = '0' then
        -- add
        resultR <= iAddBcd(resultR'range);
        carryR  <= carry;
      else
        -- sub
        resultR <= iSubBcd(resultR'range);
        carryR  <= borrow;
      end if;
    end if;
  end process clk_proc;

  -- connect to outputs
  y_o      <= resultR;
  carray_o <= carryR;

end architecture rtl;

