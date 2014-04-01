----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:50:53 10/29/2012 
-- Design Name: 
-- Module Name:    ps2_keyboard - rtl 
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
use work.ps2_keyboard_pack.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ps2_keyboard is
    generic (KEY_LUT  : keyLutType);
    port ( clk_i      : in    std_logic;
           rst_i      : in    std_logic;
           ps2_clk_i  : in    std_logic;
           ps2_data_i : in    std_logic;
           key_rdy_o  :   out std_logic;
           key_data_o :   out std_logic_vector (7 downto 0));
end ps2_keyboard;

architecture rtl of ps2_keyboard is
  type FsmType    is (IDLE, BREAK);
  signal lutDataR    : keyCodeType;
  signal lutAddr     : unsigned(10 downto 0);
  signal keyData     : std_logic_vector(7 downto 0);
  signal keyDataR    : std_logic_vector(7 downto 0);
  signal keyRdyR     : std_logic;
  signal keyRdyOutR  : std_logic;
  signal keyRdy      : std_logic;
  signal extR        : std_logic;
  signal breakR      : std_logic;
  signal lShR        : std_logic;
  signal rShR        : std_logic;
  signal lCntlR      : std_logic;
  signal rCntlR      : std_logic;
  signal fsmR        : FsmType;
  
begin

  lut_proc : process(clk_i)
  begin
    if rising_edge(clk_i) then
      lutDataR <= KEY_LUT(to_integer(lutAddr));
    end if;
  end process lut_proc;

  key_rdy_o  <= keyRdyOutR;
  key_data_o <= keyDataR;
  lutAddr    <= (lCntlR or rCntlR) & (lShR or rShR) & extR & unsigned(keyData);
   
  fsm_proc : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      fsmR        <= IDLE;
      keyRdyR     <= '0';
      keyRdyOutR  <= '0';
      extR        <= '0';
      breakR      <= '0';
      lShR        <= '0';
      rShR        <= '0';
      lCntlR      <= '0';
      rCntlR      <= '0';
      keyDataR    <= (others => '0');
    elsif rising_edge(clk_i) then
      keyRdyR    <= keyRdy;
      keyRdyOutR <= '0';
      case fsmR is
        when IDLE =>
          if keyRdyR = '1' then
            if lutDataR(8) = '0' then
              -- normal key
              if breakR /= '1' then
                keyRdyOutR <= '1';
              end if;
              keyDataR   <= lutDataR(keyDataR'range);
              extR       <= '0';
              breakR     <= '0';
            else
              -- special key
              if lutDataR = EXTENDED then
                extR   <= '1';
              elsif lutDataR = KEY_BREAK then
                breakR <= '1';
              elsif lutDataR = L_SHIFT_KEY then
                if breakR = '1' then
                  lShR <= '0';
                else
                  lShR <= '1';
                end if;
                extR       <= '0';
                breakR     <= '0';
              elsif lutDataR = R_SHIFT_KEY then
                if breakR = '1' then
                  rShR <= '0';
                else
                  rShR <= '1';
                end if;
                extR       <= '0';
                breakR     <= '0';
              elsif lutDataR = L_CONTROL_KEY then
                if breakR = '1' then
                  lCntlR <= '0';
                else
                  lCntlR <= '1';
                end if;
                extR       <= '0';
                breakR     <= '0';
              elsif lutDataR = R_CONTROL_KEY then
                if breakR = '1' then
                  rCntlR <= '0';
                else
                  rCntlR <= '1';
                end if;
                extR       <= '0';
                breakR     <= '0';
              else
                extR       <= '0';
                breakR     <= '0';
              end if;
            end if;
          end if;
        
        when others =>
        
      end case;
    end if;
  end process fsm_proc;
  
 ps2 : entity work.interface_ps2(behavioral)
  port map(
    reset    => rst_i,
    clk      => clk_i,              -- faster than kbclk
    kbdata   => ps2_data_i,
    kbclk    => ps2_clk_i,
    newdata  => keyRdy,             -- one clock cycle pulse, notify a new byte has arrived
    do       => keyData
    );

end rtl;

