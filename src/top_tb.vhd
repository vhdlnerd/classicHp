--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:56:50 10/16/2012
-- Design Name:   
-- Module Name:   F:/hwHP/classicHp/top_tb.vhd
-- Project Name:  classicHp
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: classic
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY top_tb IS
END top_tb;
 
ARCHITECTURE behavior OF top_tb IS 
 
--    -- Component Declaration for the Unit Under Test (UUT)
-- 
--    COMPONENT classic
--    PORT(
--         clk_i : IN  std_logic;
--         rst_i : IN  std_logic;
--         keycode_i : IN  std_logic_vector(7 downto 0);
--         keyvalid_i : IN  std_logic;
--         error_o : OUT  std_logic;
--         xreg_o : OUT  std_logic_vector(55 downto 0);
--         mask_o : OUT  std_logic_vector(55 downto 0);
--         update_o : OUT  std_logic
--        );
--    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal rst_i : std_logic := '0';
   signal keycode_i : std_logic_vector(7 downto 0) := (others => '0');
   signal keyvalid_i : std_logic := '0';

 	--Outputs
   signal error_o : std_logic;
   signal xreg_o : std_logic_vector(55 downto 0);
   signal mask_o : std_logic_vector(55 downto 0);
   signal update_o : std_logic;

  signal display : string(1 to 15);
  
   -- Clock period definitions
   constant clk_i_period : time := 5 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.classic(rtl)
      PORT MAP (
          clk_i => clk_i,
          rst_i => rst_i,
          keycode_i => keycode_i,
          keyvalid_i => keyvalid_i,
          error_o => error_o,
          xreg_o => xreg_o,
          mask_o => mask_o,
          update_o => update_o
        );

   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;
 
  dis_proc : process(clk_i)
  function bcd2char(bcd : std_logic_vector(3 downto 0)) return character is
  begin
    case bcd is
      when "0000" => return '0';
      when "0001" => return '1';
      when "0010" => return '2';
      when "0011" => return '3';
      when "0100" => return '4';
      when "0101" => return '5';
      when "0110" => return '6';
      when "0111" => return '7';
      when "1000" => return '8';
      when "1001" => return '9';
      when others => return '?';
    end case;
    
  end function bcd2char;
  
  variable bcd  : std_logic_vector(3 downto 0);
  variable mask : std_logic_vector(3 downto 0);
  variable n    : natural;
  variable flag : boolean;
  begin
    if rising_edge(clk_i) then
      n := 15;
      flag := false;
      for i in 0 to 13 loop
        bcd  := xreg_o((i+1)*4-1 downto i*4);
        mask := mask_o((i+1)*4-1 downto i*4);
        if mask = "1001" then
          display(n) <= ' ';
          n := n - 1;
        else
          if mask = "0000" and (i=2 or i=13) then
            if bcd = "1001" then
              display(n) <= '-';
            else
              display(n) <= ' ';
            end if;
            n := n - 1;
          elsif mask = "0000" then
            display(n) <= bcd2char(bcd);
            n := n - 1;
          else 
            if flag = false then
              display(n) <= '.';
              n := n - 1;
            end if;
            flag := true;
            display(n) <= bcd2char(bcd);
            n := n - 1;
          end if;
        end if;
      end loop;
    end if;
  end process dis_proc;

   -- Stimulus process
   stim_proc: process
   begin
      keycode_i  <= X"00";
      keyvalid_i <= '0';
      -- hold reset state for 100 ns.
      rst_i <= '1';
      wait for 30 ns;
      rst_i <= '0';

--      wait for clk_i_period*10;
      wait for 2 us;
      keycode_i <= X"13";  -- 5
      wait until rising_edge(clk_i);
      keyvalid_i <= '1';
      wait until rising_edge(clk_i);
      keyvalid_i <= '0';

      wait for 4 us;
      keycode_i <= "00" & O"76"; -- enter
      wait until rising_edge(clk_i);
      keyvalid_i <= '1';
      wait until rising_edge(clk_i);
      keyvalid_i <= '0';

      wait for 4 us;
      keycode_i <= X"12"; -- 6
      wait until rising_edge(clk_i);
      keyvalid_i <= '1';
      wait until rising_edge(clk_i);
      keyvalid_i <= '0';

      wait for 4 us;
      keycode_i <= "00" & O"26"; -- +
      wait until rising_edge(clk_i);
      keyvalid_i <= '1';
      wait until rising_edge(clk_i);
      keyvalid_i <= '0';

      -- insert stimulus here 

      wait;
   end process;

END;
