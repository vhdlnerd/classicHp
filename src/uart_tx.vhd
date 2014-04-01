
library ieee;   use ieee.std_logic_1164.all;
                use ieee.std_logic_unsigned.all;
                use ieee.math_real.all;

entity uart_tx is
generic (
  CLK_HZ : natural := 10000000;       -- in Hz
  BAUD   : natural := 115200          -- Baud rate
);
port(
    clk_i   : in    std_logic;
    rst_i   : in    std_logic;
    data_i  : in    std_logic_vector(7 downto 0);   -- Tx Parallel Data
    wr_i    : in    std_logic;                      -- Write enable (command to send data)
    tx_o    :   out std_logic;                      -- Tx serial output
    rdy_o   :   out std_logic                       -- Tx Ready for new data
    );
end uart_tx;

architecture rtl of uart_tx  is
  constant BAUD_CNT_MAX : natural := natural(round(real(CLK_HZ)/real(BAUD)));
  subtype BaudCntType is natural range 0 to BAUD_CNT_MAX-1;
  subtype BitCntType  is natural range 0 to data_i'left;
  type    FsmType is (IDLE, SEND, STOP);
  
  signal baudCntR : BaudCntType;
  signal dataR    : std_logic_vector(data_i'length downto 0);
  signal fsmR     : FsmType;
  signal startR   : std_logic;
  signal clkEnR   : std_logic;
  signal bitCntR  : BitCntType;

begin
  baud_gen : process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      baudCntR <= 0;
      clkEnR   <= '0';
    elsif rising_edge(clk_i) then
      clkEnR   <= '0';
      if baudCntR = BAUD_CNT_MAX-1 then
        baudCntR <= 0;
        clkEnR   <= '1';
      else
        baudCntR <= baudCntR + 1;
      end if;
    end if;
  end process baud_gen;
  
  tx_o  <= dataR(0);
  rdy_o <= (not startR) and (not wr_i) when fsmR=IDLE else '0';

  fsm : process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      fsmR     <= IDLE;
      startR   <= '0';
      bitCntR  <= 0;
      dataR    <= (others => '1');
    elsif rising_edge(clk_i) then
      if wr_i = '1' and startR = '0' then
        dataR(dataR'left downto 1)  <= data_i;
        startR <= '1';
      end if;

      if clkEnR = '1' then
        case fsmR is
          when IDLE  =>
            bitCntR  <= 0;
            if startR = '1' then
              -- send the start bit
              dataR(0) <= '0';
              fsmR <= SEND;
            end if;

          when SEND  =>
            dataR <= '1' & dataR(dataR'left downto 1);
            if bitCntR = data_i'left then
              fsmR <= STOP;
            else
              bitCntR <= bitCntR + 1;
            end if;

          when STOP  =>
              -- stop bit (dataR(0) will be a '1' after this shift)
              dataR  <= '1' & dataR(dataR'left downto 1);
              startR <= '0';
              fsmR   <= IDLE;
        end case;
      end if;
    end if;
  end process fsm;
end architecture rtl;
