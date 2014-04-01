--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library ieee;   use ieee.std_logic_1164.all;
                use ieee.numeric_std.all;
                
                use work.ps2_keyboard_pack.all;
                use work.rom_pack.all;

package classic_pack is

  constant WSIZE  : natural := 14;    -- Arithmetic register size 
  constant SSIZE  : natural := 12;    -- Status word size
  
  subtype bcdDigitType is unsigned(3 downto 0);
  type    arthRegType  is array (natural range 0 to WSIZE-1) of bcdDigitType;
  type    ramType      is array (natural range <>) of arthRegType;  -- for models with RAM

  constant BCD_DIGIT_ZERO : bcdDigitType := (others => '0');
  constant REG_ZEROS      : arthRegType  := (others => BCD_DIGIT_ZERO);

  function vecLen(n : natural) return natural;
  
--
-- Declare functions and procedure
--
function IIF (signal test : boolean; signal a : std_logic; signal b : std_logic) return std_logic;
function IIF (constant test : boolean; constant a : std_logic_vector; constant b : std_logic_vector) return std_logic_vector;
function IIF (constant test : boolean; constant a : keyLutType; constant b : keyLutType) return keyLutType;
function IIF (constant test : boolean; constant a : RomType; constant b : RomType) return RomType;


end classic_pack;

package body classic_pack is
  --
  -- Compute the length of a bit vector that can count up to 'n'
  -- If you need a counter to count from 0 to 203, you can pass
  -- 203 to this function and it will return 8 (i.e. an 8 bit
  -- counter is required).  255 will return 8, also and 256 will 
  -- return 9.
  --
  function vecLen(n : natural) return natural is
    variable t : unsigned(31 downto 0) := to_unsigned(n,32);
  begin
    for i in t'range loop
      if t(i) = '1' then
        return i+1;
      end if;
    end loop;
    return 0;
  end function vecLen;

  function IIF (signal test : boolean; signal a : std_logic; signal b : std_logic) return std_logic is
  begin
    if test then return a; else return b; end if;
  end function IIF;

  function IIF (constant test : boolean; constant a : std_logic_vector; constant b : std_logic_vector) return std_logic_vector is
  begin
    if test then return a; else return b; end if;
  end function IIF;
 
  function IIF (constant test : boolean; constant a : keyLutType; constant b : keyLutType) return keyLutType is
  begin
    if test then return a; else return b; end if;
  end function IIF;
 
  function IIF (constant test : boolean; constant a : RomType; constant b : RomType) return RomType is
  begin
    if test then return a; else return b; end if;
  end function IIF;
 
end classic_pack;
