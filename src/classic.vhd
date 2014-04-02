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
-- Create Date:    15:19:05 10/12/2012 
-- Design Name: 
-- Module Name:    classic - rtl 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use work.rom_pack.all;

--
-- INPUTS:
-- clk_i        : Clock
-- rst_i        : Async Reset
-- inst_en_i    : Instruction Enable: An op-code is only executed when this is
--                a '1'. This input can be used to throttle the exection of
--                op-codes. Setting this a constant '1' will cause op-codes
--                execute at full speed.
-- keycode_i    : Key Code: keyvalid_i is used to qualify this input
-- keyvalid_i   : Key Valid: Pulses high for each new key press. This need to
--                pulse high for many cycles.  The ROM code will miss see this
--                high if its not on long enough.  A 10ms pulse seems to be
--                good.
-- flags_i      : External flags: Used for a HP-55
--              
-- OUTPUTS:     
-- error_o      : Indicates the core detected an error (all the error conditions
--                the original calculator's detected).  Sets on an error and
--                clears on the next valid key input.
-- display_en_o : Display Enable: Used on the original calculators to flash the
--                LEDs on an error.  This output is not very useful if the 
--                throttling it not used to match the original calculaotr's
--                speed.  Its better to use the error_o output.
-- xreg_o       : This is a copy of register A.  Used to create the formatted display.
-- mask_o       : This is a copy of register B.  Used to create the formatted display.
-- status_o     : The internal status bits. Can be used know when the calculator is
--                in different modes (i.e. shift active, run, prog, timer,...)
-- 

entity classic is
    generic (
              ROM       : RomType := ROM_45;
              CALC_NAME : string := "HP45"		-- should be "HP35", "HP45", or "HP55"
              );
    port ( clk_i       : in     std_logic;
           rst_i       : in     std_logic;
           inst_en_i   : in     std_logic := '1';
           keycode_i   : in     std_logic_vector (7 downto 0);
           keyvalid_i  : in     std_logic;
           flags_i     : in     std_logic_vector(11 downto 0) := (others => '0');  -- ext flags (for mode switch on HP55)
           error_o     :   out  std_logic;
           display_en_o:   out  std_logic;
           xreg_o      :   out  std_logic_vector (55 downto 0);
           mask_o      :   out  std_logic_vector (55 downto 0);
           status_o    :   out  std_logic_vector (11 downto 0)
           );
end classic;

architecture rtl of classic is
  constant HP35              : boolean := CALC_NAME="HP35";
  constant HP45              : boolean := CALC_NAME="HP45";
  constant HP55              : boolean := CALC_NAME="HP55";

  constant ROM_ADDR_LEN      : natural := vecLen(ROM'length-1);

  function RamSize return natural is
  begin
    if HP45 then
      return 10;
    elsif HP55 then
      return 30;
    end if;
    return 1;
  end function RamSize;
  
  constant RAM_SIZE          : natural := RamSize;
  constant RAM_ADDR_LEN      : natural := vecLen(RAM_SIZE-1);
  
  type     execFsmType  is (RESET, FETCH, DECODE, EXEC_WAIT, EXECUTE, STOP);
  subtype  subInxType is natural range 0 to 15;
  subtype  ramInxType is natural range 0 to RAM_SIZE-1;
  
  signal aRegR, bRegR, cRegR : arthRegType;
  signal dRegR, eRegR, fRegR : arthRegType;
  signal mRegR               : arthRegType;
  signal t0RegR, t1RegR      : arthRegType;  -- temp regs
  signal sRegR               : std_logic_vector(15 downto 0);   -- implement 16 bits for status (but only lower 12 are used)
  signal pRegR               : unsigned(3 downto 0);
  signal carryR, carryInR    : std_logic;
  signal pcR                 : unsigned(7 downto 0);
  signal retR                : unsigned(7 downto 0);
  signal keyCodeR            : unsigned(7 downto 0);
  signal romSelR             : unsigned(2 downto 0);
  signal romDelSelR          : unsigned(2 downto 0);    -- Delayed ROM Select (for HP55)
  signal grpSelR             : unsigned(0 downto 0);    -- Group select (for HP55)
  signal grpDelSelR          : unsigned(0 downto 0);    -- Delayed Group select (for HP55)

  signal ramDataR            : arthRegType;
  signal ramWrR              : std_logic;
  
  signal opcodeRomR          : std_logic_vector(9 downto 0);
  signal opcodeR             : std_logic_vector(9 downto 0);
  signal romAddrR            : unsigned(ROM_ADDR_LEN-1 downto 0);
  signal ramAddrR            : ramInxType;
  signal carryOutR           : std_logic;
  signal carry               : std_logic;
  signal displayEnR          : std_logic;
  signal subAddLowR          : std_logic;
  signal bcdDigitA           : bcdDigitType;
  signal bcdDigitB           : bcdDigitType;
  signal bcdDigitYR          : bcdDigitType;
  signal startR, endR        : subInxType;
  signal startRR             : subInxType;

  signal errorDetR           : std_logic;
  signal errorDet            : std_logic;
  signal keyValidR           : std_logic;
  
  signal execFsmStateR       : execFsmType;

	
  -- This fuction returns a single vector for addressing the ROM.  The address is built from 
  -- various interal core registers (the PC, ROM Select, Group Select)  
  function buildRomAddr(pc : unsigned(7 downto 0); romSel : unsigned(2 downto 0); grpSel : unsigned(0 downto 0):="0") return unsigned is
  begin
    if HP35 then
      -- a HP35 only has three ROMs (i.e. romSel is 0, 1, or 2)
      return romSel(1 downto 0) & pc;
    elsif HP45 then
      -- a HP45 has eight ROMs
      return romSel & pc;
    elsif HP55 then
      -- a HP55 has eight ROMs in two groups
      return grpSel & romSel & pc;
    end if;
    return "0";
  end function buildRomAddr;
  
begin
  status_o     <= sRegR(11 downto 0);
  display_en_o <= displayEnR;
  
  -- For each calculator supported, create a signal (errorDet) that
  -- pulses when a calculator error occurs.  This is done be looking
  -- for a certain ROM address, this address must be an address in the
  -- original calculator's error routine. This address is different
  -- for each calculator. 
  HP35_ERR : if HP35 generate
  begin
    errorDet <= '1' when romAddrR = '0' & O"277" else '0';
  end generate HP35_ERR;

  HP45_ERR : if HP45 generate
  begin
    -- detect at address 007 of rom #6  ??  or at 001 of rom #6
    errorDet <= '1' when romAddrR = "110" & X"07" else '0';
  end generate HP45_ERR;

  HP55_ERR : if HP55 generate
  begin
    -- detect at address 302 (octal) of rom #3  ??
    errorDet <= '1' when romAddrR = X"3C2" else '0';
  end generate HP55_ERR;
  
  -- This process creates the "sticky" version of the error detect signal.
  -- "errorDetR" is set on "errorDet" being high and cleared on the next
  -- key press.  "errorDetR" becomes the error output (port: error_o)
  error_detect : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      errorDetR <= '0';
      keyValidR <= '0';
    elsif rising_edge(clk_i) then
    	keyValidR <= keyvalid_i;
      if errorDet = '1' then
        -- set on error detect
        errorDetR <= '1';
      elsif keyValidR = '0' and keyvalid_i = '1' then
        -- clear on new key press (rising edge of keyvalid_i)
        errorDetR <= '0';
      end if;
    end if;
  end process error_detect;
  error_o <= errorDetR;

  -- generate the ROM address
  romAddrR <= buildRomAddr(pcR, romSelR, grpSelR);

  -- Create the ROM for the op-codes.  This code should infer a Block RAM
  -- configured as a ROM.
  rom_proc : process(clk_i)
  begin
    if rising_edge(clk_i) then
      opcodeRomR <= ROM(to_integer(romAddrR));
    end if;
  end process rom_proc;

  -- Create a RAM that holds the Rn registers and program steps.
  -- The older calculators only need a small memory so just infer FPGA FFs or LUTs.
  NO_BIG_RAM : if not HP55 generate
    signal ramR  : RamType(0 to RAM_SIZE-1);
  begin
    ram_proc : process(clk_i)
    begin
      if HP45 then
        if rising_edge(clk_i) then
          ramDataR <= ramR(ramAddrR);
          if ramWrR = '1' then
            ramR(ramAddrR) <= cRegR;
          end if;
        end if;
      else
        ramDataR <= REG_ZEROS;
      end if;
    end process ram_proc;
  end generate NO_BIG_RAM;

  -- The RAM is largest for the HP-55 and a Block RAM is inferred for
  -- this calculator.
  YES_BIG_RAM : if HP55 generate
    type ramType is array (natural range 0 to RAM_SIZE-1) of std_logic_vector(55 downto 0);
    signal d    : std_logic_vector (55 downto 0);
    signal q    : std_logic_vector (55 downto 0);
    signal ramR : ramType;
  	attribute ram_style: string;
  	attribute ram_style of ramR : signal is "block";
  begin
    -- need to rearrange the nibbles in the register format into a single
    -- std_logic_vector so a BRAM will be inferred.
    nibble_loop : for i in 0 to WSIZE-1 generate
    begin
      d((i+1)*4-1 downto i*4) <= std_logic_vector(cRegR(i));
      ramDataR(i)             <= unsigned(q((i+1)*4-1 downto i*4));
    end generate nibble_loop;

    da_ram : process (clk_i)
    begin
      if rising_edge(clk_i) then
        q <= ramR(ramAddrR);
        if ramWrR = '1' then
          ramR(ramAddrR) <= d;
        end if;
      end if;
    end process da_ram;
  end generate YES_BIG_RAM;
  
  -- This is it!  The main FSM where all the work is done. Op-code decode and
  -- execution is done here.
  execFsm_proc : process(clk_i, rst_i, pcR, pRegR, opcodeRomR)
    variable pc      : unsigned(7 downto 0);
    variable pRegP1  : unsigned(3 downto 0);
    variable pRegM1  : unsigned(3 downto 0);
    variable subIdx  : subInxType;
    variable startIdx: subInxType;
    variable endIdx  : subInxType;
    variable currAddr: natural;
  begin
    pc      := pcR   + 1;         -- the current PC plus one
    pRegP1  := pRegR + 1;         -- the current P reg plus one
    pRegM1  := pRegR - 1;         -- the current P reg minus one
    -- subIdx is used by the status register related op-codes
    subIdx  := to_integer(unsigned(opcodeRomR(9 downto 6)));

    -- decode start and stop indices for arth. operations
    case opcodeRomR(4 downto 2) is
      when "000" =>
        -- Digit pointed to by P
        startIdx := to_integer(pRegR);
        endIdx   := to_integer(pRegR);
      when "001" =>
        -- Mantissa
        startIdx := 3;
        endIdx   := 12;
      when "010" =>
        -- Exponent (and sign)
        startIdx := 0;
        endIdx   := 2;
      when "011" =>
        -- The whole register
        startIdx := 0;
        endIdx   := 13;
      when "100" =>
        -- WP => digits up to and including P
        startIdx := 0;
        endIdx   := to_integer(pRegR);
      when "101" =>
        -- Mantissa and sign
        startIdx := 3;
        endIdx   := 13;
      when "110" =>
        -- Exponent sign
        startIdx := 2;
        endIdx   := 2;
      when "111" =>
        -- Mantissa sign
        startIdx := 13;
        endIdx   := 13;
      when others =>
        startIdx := 13;
        endIdx   := 13;
    end case;
    
    -- Start of the clocked signals (i.e. FFs)
    if rst_i = '1' then
      pcR           <= (others => '0');
      retR          <= (others => '0');
      romSelR       <= (others => '0');
      romDelSelR    <= (others => '0');
      grpSelR       <= (others => '0');
      grpDelSelR    <= (others => '0');
      opcodeR       <= (others => '0');
      sRegR         <= (others => '0');
      pRegR         <= (others => '0');
      ramAddrR      <= 0;
      carryR        <= '0';
      carryInR      <= '0';
      displayEnR    <= '0';
      subAddLowR    <= '0';
      aRegR         <= REG_ZEROS;
      bRegR         <= REG_ZEROS;
      cRegR         <= REG_ZEROS;
      dRegR         <= REG_ZEROS;
      eRegR         <= REG_ZEROS;
      fRegR         <= REG_ZEROS;
      mRegR         <= REG_ZEROS;
      t0RegR        <= REG_ZEROS;
      t1RegR        <= REG_ZEROS;
      startR        <= 0;
      endR          <= 0;
      ramWrR        <= '0';
      mask_o        <=(others => '0');
      xreg_o        <=(others => '0');
      keyCodeR      <=(others => '0');
      execFsmStateR <= RESET;
    elsif rising_edge(clk_i) then
      -- synthesis translate_off
      -- for simulation:
      currAddr := to_integer(romAddrR);
      -- synthesis translate_on

      ramWrR  <= '0';
      startRR <= startR;
      
      -- catch any new key presses
      if keyvalid_i = '1' then
        keyCodeR <= unsigned(keycode_i);  -- remember the key pressed
        sRegR(0) <= '1';                  -- status bit #0 indicates a new key press to the core
      end if;

      -- The HP-55 has external input status bits (HW status).  Any active external bits,
      -- get copied to the internal status register.  The external bits are used to
      -- indicate the state of PROG-TIMER-RUN switch.
      if HP55 then
        for i in flags_i'range loop
          if flags_i(i) = '1' then
            sRegR(i) <= '1';
          end if;
        end loop;
      end if;
      
      -- Create the output vectors for the display.
      for i in 0 to WSIZE-1 loop
        xreg_o((i+1)*4-1 downto i*4) <= std_logic_vector(aRegR(i));
        mask_o((i+1)*4-1 downto i*4) <= std_logic_vector(bRegR(i));
      end loop;
      
      -- Start of the Finite State Machine
      case execFsmStateR is
        when RESET =>
          -- stays in this state during a core reset.
          execFsmStateR <= DECODE;
          
        when DECODE =>
          -- inst_en_i is used to create "real" timing of the original calculator
          -- inst_en_i pulses high once per the instruction period of the calculator
          if inst_en_i = '1' then
            opcodeR       <= opcodeRomR; -- remember the current op-code
            pcR           <= pc;         -- and the current PC
            carryR        <= '0';        -- carry clears by default
            execFsmStateR <= FETCH;      -- most instructions go to this state next
            
            -- decode & execute most opcode types
            case opcodeRomR(1 downto 0) is
              when "01" =>
                -- jump to subroutine
                retR <= pc;
                pcR  <= unsigned(opcodeRomR(9 downto 2));
                if HP55 then
                  romSelR <= romDelSelR;
                  grpSelR <= grpDelSelR;
                end if;
                -- synthesis translate_off
                -- sim debug
                assert false report integer'image(currAddr) & ": JSB "
                  severity note;
                -- synthesis translate_on
                
              when "11" =>
                -- jump
                if carryR = '0' then
                  pcR  <= unsigned(opcodeRomR(9 downto 2));
                  if HP55 then
                    romSelR <= romDelSelR;
                    grpSelR <= grpDelSelR;
                  end if;
                end if;
                
              when "10" =>
                -- arith
                startR        <= startIdx;
                endR          <= endIdx;
                -- arith operations take more clocks to complete and they
                -- are handled in a different part of the FSM.
                execFsmStateR <= EXEC_WAIT;
                
              when "00" =>
                -- all others
                case opcodeRomR(5 downto 2) is
                  when X"0" =>
                    -- NOP
                    -- Plus a few special instuctions for >HP45 models
                    --   memory and buffer instructions -- which Calc uses these?  HP55 uses some?
                    --   The HP55 uses one "rom address -> buffer" instruction (Opcode: 10000000000) -- what does it do???
                    --   Its a NOP here!!!

                  when X"1" =>
                    -- set status bits
                    sRegR(subIdx) <= '1';
                    
                  when X"2" =>
                    -- not used
                    
                  when X"3" =>
                    -- load P reg with constant
                    pRegR <= unsigned(opcodeRomR(9 downto 6));
                    
                  when X"4" =>
                    -- ROM Select and keys->rom address
                    if opcodeRomR(6) = '1' then
                      -- jump to key code address
                      pcR      <= keycodeR;
                      sRegR(0) <= '0';
                    else
                      -- ROM Select
                      romSelR <= unsigned(opcodeRomR(9 downto 7));
                      if HP55 then
                        grpSelR    <= grpDelSelR;
                        romDelSelR <= unsigned(opcodeRomR(9 downto 7));
                      end if;
                    end if;
  
                  when X"5" =>
                    -- test a status bit
                    carryR <= sRegR(subIdx);
  
                  when X"6" =>
                    -- load BCD digit into C[P] and decrement P
                    cRegR(to_integer(pRegR)) <= unsigned(opcodeRomR(9 downto 6));
                    pRegR <= pRegM1;
                    
                  when X"7" =>
                    -- decrement the P reg
                    pRegR <= pRegM1;
  
                  when X"8" =>
                    -- not used
                    
                  when X"9" =>
                    -- clear status bits
                    sRegR(subIdx) <= '0';
  
                  when X"A" =>
                    -- display/stack/M register stuff
                    case opcodeRomR(9 downto 7) is
                      when "000" =>
                        -- display toggle
                        displayEnR <= not displayEnR;
                      when "001" =>
                        -- C<->M   -- swap C and M
                        mRegR <= cRegR;
                        cRegR <= mRegR;
                      when "010" =>
                        -- push C on to stack
                        fRegR <= eRegR;
                        eRegR <= dRegR;
                        dRegR <= cRegR;
                      when "011" =>
                        -- pop A off the stack
                        aRegR <= dRegR;
                        dRegR <= eRegR;
                        eRegR <= fRegR;
                      when "100" =>
                        -- display off
                        displayEnR <= '0';
                      when "101" =>
                        -- M->C
                        cRegR <= mRegR;
                      when "110" =>
                        -- down rotate
                        cRegR <= dRegR;
                        dRegR <= eRegR;
                        eRegR <= fRegR;
                        fRegR <= cRegR;
                      when "111" =>
                        -- clear registers
                        aRegR <= REG_ZEROS;
                        bRegR <= REG_ZEROS;
                        cRegR <= REG_ZEROS;
                        dRegR <= REG_ZEROS;
                        eRegR <= REG_ZEROS;
                        fRegR <= REG_ZEROS;
                        mRegR <= REG_ZEROS;
                      when others =>
                        null;
                    end case;
                    
                  when X"B" =>
                    -- test P
                    if pRegR = unsigned(opcodeRomR(9 downto 6)) then
                      carryR <= '1';
                    end if;
  
                  when X"C" =>
                    -- return (and memory access for some calculators)
                    if HP35 then
                      pcR <= retR;
                    else
                      if opcodeRomR(9) = '0' then
                        pcR <= retR;
                      end if;
                    end if;
                    if not HP35 then
                      if opcodeRomR(9 downto 7) = "101" then
                        -- memory write
                        ramWrR <= '1';
                      end if;
                    end if;
                    if HP45 then
                      if opcodeRomR(9 downto 7) = "100" then
                        -- set memory address
                        ramAddrR <= to_integer(cRegR(12));
                      end if;
                    end if;
                    if HP55 then
                      if opcodeRomR(9 downto 7) = "100" then
                        -- set memory address (C[12]*10+C[11])
                        ramAddrR <= to_integer(cRegR(12)*10+cRegR(11));
                      end if;
                    end if;
  
                  when X"D" =>
                    -- clear status (and delayed ROM and group select for some calculators >HP45)
                    if not HP55 then
                      sRegR <= (others => '0');
                    end if;
                    -- The HP55 uses both delayed ROM and group selects
                    if HP55 then
                      if opcodeRomR(6) = '1' then
                        -- delayed ROM select
                        romDelSelR <= unsigned(opcodeRomR(9 downto 7));
                      elsif opcodeRomR(9) = '1' then
                        -- delayed Group select
                        grpDelSelR <= unsigned(opcodeRomR(7 downto 7));
                      else
                        -- clear status
                        sRegR <= (others => '0');
                      end if;
                    end if;
                    
                  when X"E" =>
                    -- memory store for some calculators
                    if not HP35 then
                      -- memory read
                      cRegR <= ramDataR;
                    end if;
                    
                  when X"F" =>
                    -- increment the P reg
                    pRegR <= pRegP1;
  
                  when others =>
                    -- for sim

                end case;
              when others =>
                -- for sim
                
            end case;
          
            -- decode arith. opcodes
            -- there are 32 arith opcodes (bits 9 downto 5)
            carryInR <= '0';
            case opcodeRomR(9 downto 5) is
              when X"0"&'0' =>
                -- if B[ws]=0 carry<=0 else carry<=1
                -- Do: 0 - B
                t0RegR     <= REG_ZEROS;
                t1RegR     <= bRegR;
                subAddLowR <= '1'; -- subtraction

              when X"1"&'0' =>
                -- if A>=C[ws] carry<=0 else carry<=1
                -- Do: A - C
                t0RegR     <= aRegR;
                t1RegR     <= cRegR;
                subAddLowR <= '1'; -- subtraction
  
              when X"2"&'0' =>
                -- b->C[ws]
                -- Do: B + 0 => C or 0 + B => C
                t0RegR     <= REG_ZEROS;
                t1RegR     <= bRegR;
                subAddLowR <= '0'; -- addition
  
              when X"3"&'0' =>
                -- 0->C[ws]
                -- Do: C - C => C (or B - B => C, ...)
                t0RegR     <= cRegR;
                t1RegR     <= cRegR;
                subAddLowR <= '1'; -- subtraction
  
              when X"4"&'0' =>
                -- shift left A[ws]
                for i in 0 to WSIZE-2 loop
                  t0RegR(i+1) <= aRegR(i);
                end loop;
                t0RegR(startIdx) <= (others => '0');  -- slow path??
                t1RegR           <= REG_ZEROS;
                subAddLowR       <= '0'; -- addition
                
              when X"5"&'0' =>
                -- A-C->C[ws]
                t0RegR     <= aRegR;
                t1RegR     <= cRegR;
                subAddLowR <= '1'; -- subtraction
                
              when X"6"&'0' =>
                -- C->A[ws]
                -- Do: C + 0 => A or 0 + C => A
                t0RegR     <= REG_ZEROS;
                t1RegR     <= cRegR;
                subAddLowR <= '0'; -- addition
  
              when X"7"&'0' =>
                -- A+C->C[ws]
                t0RegR     <= aRegR;
                t1RegR     <= cRegR;
                subAddLowR <= '0'; -- addition
  
              when X"8"&'0' =>
                -- if A>=B[ws] carry<=0 else carry<=1
                -- Do: A - B
                t0RegR     <= aRegR;
                t1RegR     <= bRegR;
                subAddLowR <= '1'; -- subtraction
  
              when X"9"&'0' =>
                -- shift right C[ws]
                for i in 0 to WSIZE-2 loop
                  t0RegR(i) <= cRegR(i+1);
                end loop;
                t0RegR(endIdx) <= (others => '0');  -- slow path??
                t1RegR         <= REG_ZEROS;
                subAddLowR     <= '0'; -- addition
                
              when X"A"&'0' =>
                -- shift right B[ws]
                for i in 0 to WSIZE-2 loop
                  t0RegR(i) <= bRegR(i+1);
                end loop;
                t0RegR(endIdx) <= (others => '0');  -- slow path??
                t1RegR         <= REG_ZEROS;
                subAddLowR     <= '0'; -- addition
                
              when X"B"&'0' =>
                -- shift right A[ws]
                for i in 0 to WSIZE-2 loop
                  t0RegR(i) <= aRegR(i+1);
                end loop;
                t0RegR(endIdx) <= (others => '0');  -- slow path??
                t1RegR         <= REG_ZEROS;
                subAddLowR     <= '0'; -- addition
                
              when X"C"&'0' =>
                -- A-B=>A
                t0RegR     <= aRegR;
                t1RegR     <= bRegR;
                subAddLowR <= '1'; -- subtraction
  
              when X"D"&'0' =>
                -- A-C=>A
                t0RegR     <= aRegR;
                t1RegR     <= cRegR;
                subAddLowR <= '1'; -- subtraction
  
              when X"E"&'0' =>
                -- A+B=>A
                t0RegR     <= aRegR;
                t1RegR     <= bRegR;
                subAddLowR <= '0'; -- addition
  
              when X"F"&'0' =>
                -- A+C=>A
                t0RegR     <= aRegR;
                t1RegR     <= cRegR;
                subAddLowR <= '0'; -- addition
  
              when X"0"&'1' =>
                -- 0->B[ws]
                -- Do: B - B => B (or C - C => B, ...)
                t0RegR     <= bRegR;
                t1RegR     <= bRegR;
                subAddLowR <= '1'; -- subtraction
  
              when X"1"&'1' =>
                -- if C[ws]>=1 carry<=0 else carry<=1
                -- Do: C - 0 - C1    (C1 == carry set to one)
                t0RegR     <= cRegR;
                t1RegR     <= REG_ZEROS;
                subAddLowR <= '1'; -- subtraction
                carryInR     <= '1';
  
              when X"2"&'1' =>
                -- 0-C=>C
                t0RegR     <= REG_ZEROS;
                t1RegR     <= cRegR;
                subAddLowR <= '1'; -- subtraction
  
              when X"3"&'1' =>
                -- 0-C-1=>C
                t0RegR     <= REG_ZEROS;
                t1RegR     <= cRegR;
                subAddLowR <= '1'; -- subtraction
                carryInR   <= '1';
  
              when X"4"&'1' =>
                -- A->B[ws]
                -- Do: A + 0 => B
                t0RegR     <= aRegR;
                t1RegR     <= REG_ZEROS;
                subAddLowR <= '0'; -- addition
                
              when X"5"&'1' =>
                -- C - 1 => C
                -- Do: C - 0 - C1 => C    (C1 == carry set to one)
                t0RegR     <= cRegR;
                t1RegR     <= REG_ZEROS;
                subAddLowR <= '1'; -- subtraction
                carryInR   <= '1';
  
              when X"6"&'1' =>
                -- if C[ws]=0 carry<=0 else carry<=1
                -- Do: 0 - C 
                t0RegR     <= REG_ZEROS;
                t1RegR     <= cRegR;
                subAddLowR <= '1'; -- subtraction
  
              when X"7"&'1' =>
                -- C + 1 => C
                -- Do: C + 0 + C1 => C    (C1 == carry set to one)
                t0RegR     <= cRegR;
                t1RegR     <= REG_ZEROS;
                subAddLowR <= '0'; -- addition
                carryInR   <= '1';
              
              when X"8"&'1' =>
                -- exchange B and C[ws]
                t0RegR     <= bRegR;
                t1RegR     <= cRegR;
          
              when X"9"&'1' =>
                -- if A[ws]>=1 carry<=0 else carry<=1
                -- Do: A - 0 - C1    (C1 == carry set to one)
                t0RegR     <= aRegR;
                t1RegR     <= REG_ZEROS;
                subAddLowR <= '1'; -- subtraction
                carryInR   <= '1';
  
              when X"A"&'1' =>
                -- C + C => C
                t0RegR     <= cRegR;
                t1RegR     <= cRegR;
                subAddLowR <= '0'; -- addition
              
              when X"B"&'1' =>
                -- 0->A[ws]
                -- Do: A - A => A (or C - C => A, ...)
                t0RegR     <= aRegR;
                t1RegR     <= aRegR;
                subAddLowR <= '1'; -- subtraction
  
              when X"C"&'1' =>
                -- exchange A and B[ws]
                t0RegR     <= aRegR;
                t1RegR     <= bRegR;
  
              when X"D"&'1' =>
                -- A - 1 => A
                -- Do: A - 0 - C1 => A    (C1 == carry set to one)
                t0RegR     <= aRegR;
                t1RegR     <= REG_ZEROS;
                subAddLowR <= '1'; -- subtraction
                carryInR   <= '1';
  
              when X"E"&'1' =>
                -- exchange A and C[ws]
                t0RegR     <= aRegR;
                t1RegR     <= cRegR;
  
              when X"F"&'1' =>
                -- A + 1 => A
                -- Do: A + 0 + C1 => A    (C1 == carry set to one)
                t0RegR     <= aRegR;
                t1RegR     <= REG_ZEROS;
                subAddLowR <= '0'; -- addition
                carryInR   <= '1';
  
              when others =>

            end case;
          end if;   -- inst_en_i = '1'
                    
        when FETCH =>
          -- this is just a wait state to allow the next opcode to be fetched from the ROM.
          execFsmStateR <= DECODE;

        when EXEC_WAIT =>
          -- start executing a arith. op-code
          if startR /= endR then
            startR <= startR + 1;
          end if;
          execFsmStateR <= EXECUTE;

        when EXECUTE =>
          -- Process all BCD digits in this state

          carryR <= carryOutR;
          if startR /= endR then
            startR <= startR + 1;
          end if;

          if startRR = endR then
            execFsmStateR <= DECODE;
          end if;

          -- there are 32 arith opcodes (bits 9 downto 5)
          case opcodeR(9 downto 5) is
            when X"0"&'0' =>
              -- if B[ws]=0 carry<=0 else carry<=1
              -- Do: 0 - B
              -- Only the carry out is generated for this instruction

            when X"1"&'0' =>
              -- if A>=C[ws] carry<=0 else carry<=1
              -- Do: A - C
              -- Only the carry out is generated for this instruction

            when X"2"&'0' =>
              -- b->C[ws]
              -- Do: B + 0 => C or 0 + B => C
              cRegR(startRR) <= bcdDigitYR;
              
            when X"3"&'0' =>
              -- 0->C[ws]
              -- Do: C - C => C (or B - B => C, ...)
              cRegR(startRR) <= bcdDigitYR;
              
            when X"4"&'0' =>
              -- shift left A[ws]
              aRegR(startRR) <= bcdDigitYR;
              carryR         <= '0';    -- keep carry cleared
              
            when X"5"&'0' =>
              -- A-C->C[ws]
              cRegR(startRR) <= bcdDigitYR;
              
            when X"6"&'0' =>
              -- C->A[ws]
              -- Do: C + 0 => A or 0 + C => A
              aRegR(startRR) <= bcdDigitYR;

            when X"7"&'0' =>
              -- A+C->C[ws]
              cRegR(startRR) <= bcdDigitYR;

            when X"8"&'0' =>
              -- if A>=B[ws] carry<=0 else carry<=1
              -- Do: A - B
              -- Only the carry out is generated for this instruction

            when X"9"&'0' =>
              -- shift right C[ws]
              cRegR(startRR) <= bcdDigitYR;
              carryR         <= '0';    -- keep carry cleared
              
            when X"A"&'0' =>
              -- shift right B[ws]
              bRegR(startRR) <= bcdDigitYR;
              carryR         <= '0';    -- keep carry cleared
              
            when X"B"&'0' =>
              -- shift right A[ws]
              aRegR(startRR) <= bcdDigitYR;
              carryR         <= '0';    -- keep carry cleared
              
            when X"C"&'0' =>
              -- A-B=>A
              aRegR(startRR) <= bcdDigitYR;

            when X"D"&'0' =>
              -- A-C=>A
              aRegR(startRR) <= bcdDigitYR;

            when X"E"&'0' =>
              -- A+B=>A
              aRegR(startRR) <= bcdDigitYR;

            when X"F"&'0' =>
              -- A+C=>A
              aRegR(startRR) <= bcdDigitYR;

            when X"0"&'1' =>
              -- 0->B[ws]
              -- Do: B - B => B (or C - C => B, ...)
              bRegR(startRR) <= bcdDigitYR;

            when X"1"&'1' =>
              -- if C[ws]>=1 carry<=0 else carry<=1
              -- Do: C - 0 - C1    (C1 == carry set to one)
              -- Only the carry out is generated for this instruction

            when X"2"&'1' =>
              -- 0-C=>C
              cRegR(startRR) <= bcdDigitYR;

            when X"3"&'1' =>
              -- 0-C-1=>C
              cRegR(startRR) <= bcdDigitYR;

            when X"4"&'1' =>
              -- A->B[ws]
              -- Do: A + 0 => B
              bRegR(startRR) <= bcdDigitYR;
              
            when X"5"&'1' =>
              -- C - 1 => C
              -- Do: C - 0 - C1 => C    (C1 == carry set to one)
              cRegR(startRR) <= bcdDigitYR;

            when X"6"&'1' =>
              -- if C[ws]=0 carry<=0 else carry<=1
              -- Do: 0 - C 
              -- Only the carry out is generated for this instruction

            when X"7"&'1' =>
              -- C + 1 => C
              -- Do: C + 0 + C1 => C    (C1 == carry set to one)
              cRegR(startRR) <= bcdDigitYR;
            
            when X"8"&'1' =>
              -- exchange B and C[ws]
              cRegR(startRR) <= t0RegR(startRR);
              bRegR(startRR) <= t1RegR(startRR);
              carryR         <= '0';    -- keep carry cleared
        
            when X"9"&'1' =>
              -- if A[ws]>=1 carry<=0 else carry<=1
              -- Do: A - 0 - C1    (C1 == carry set to one)
              -- Only the carry out is generated for this instruction

            when X"A"&'1' =>
              -- C + C => C
              cRegR(startRR) <= bcdDigitYR;
            
            when X"B"&'1' =>
              -- 0->A[ws]
              -- Do: A - A => A (or C - C => A, ...)
              aRegR(startRR) <= bcdDigitYR;

            when X"C"&'1' =>
              -- exchange A and B[ws]
              bRegR(startRR) <= t0RegR(startRR);
              aRegR(startRR) <= t1RegR(startRR);
              carryR         <= '0';    -- keep carry cleared

            when X"D"&'1' =>
              -- A - 1 => A
              -- Do: A - 0 - C1 => A    (C1 == carry set to one)
              aRegR(startRR) <= bcdDigitYR;

            when X"E"&'1' =>
              -- exchange A and C[ws]
              cRegR(startRR) <= t0RegR(startRR);
              aRegR(startRR) <= t1RegR(startRR);
              carryR         <= '0';    -- keep carry cleared

            when X"F"&'1' =>
              -- A + 1 => A
              -- Do: A + 0 + C1 => A    (C1 == carry set to one)
              aRegR(startRR) <= bcdDigitYR;

            when others =>
          end case;
          
        when others =>
        
      end case;
    end if;
  end process execFsm_proc;
  
  -- Setup the inputs to the ALU
  bcdDigitA <= t0RegR(startR);
  bcdDigitB <= t1RegR(startR);
  carry     <= carryOutR when execFsmStateR = EXECUTE else carryInR;
  -- The ALU. There are two versions RTL and LUT.  The LUT version uses a BRAM
  -- as a large look up table to perform the BCD math.  Depending on the FPGA
  -- and the max clock rate, one may be better than the other.
  --bcdALU : entity work.bcd_alu(lut)
  bcdALU : entity work.bcd_alu(rtl)
    port map (
        clk_i       => clk_i,
        rst_i       => rst_i,
        a_i         => bcdDigitA,
        b_i         => bcdDigitB,
        carry_i     => carry,
        subAddLow_i => subAddLowR,
        y_o         => bcdDigitYR,
        carray_o    => carryOutR
    );

end rtl;
-- Its been nice but the end is here.

