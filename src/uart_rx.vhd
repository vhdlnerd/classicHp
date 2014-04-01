library ieee;   use ieee.std_logic_1164.all;
                use ieee.std_logic_unsigned.all;
                use ieee.math_real.all;

entity uart_rx is
generic (
  CLK_HZ : natural := 10000000;       -- in Hz
  BAUD   : natural := 115200          -- Baud rate
);
port(
    clk_i  : in    std_logic;
    rst_i  : in    std_logic;
    rx_i   : in    std_logic;                      -- Rx serial input
    data_o :   out std_logic_vector(7 downto 0);   -- Rx Parallel Data
    val_o  :   out std_logic                       -- Rx data valid
    );
end uart_rx;

architecture rtl of uart_rx  is
  constant BAUD_CNT_MAX  : natural := natural(round(real(CLK_HZ)/real(BAUD)));
  constant BAUD_CNT_HALF : natural := natural(round(real(CLK_HZ)/real(BAUD)/2.0));
  subtype BaudCntType is natural range 0 to BAUD_CNT_MAX-1;
  subtype BitCntType  is natural range 0 to data_o'left;
  type    FsmType is (IDLE, START, DATA, STOP);
  
  signal baudCntR : BaudCntType;
  signal dataR    : std_logic_vector(data_o'length-1 downto 0);
  signal fsmR     : FsmType;
  signal startR   : std_logic;
--  signal clkEnR   : std_logic;
  signal bitCntR  : BitCntType;
  signal rxVecR   : std_logic_vector(3 downto 0);
  signal fEdgeR   : std_logic;
  signal sampleR  : std_logic;
  signal searchR  : std_logic;
  
begin
  rx_input : process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      rxVecR <= (others => '1');
      fEdgeR <= '0';
    elsif rising_edge(clk_i) then
      fEdgeR <= '0';
      rxVecR <= rx_i & rxVecR(rxVecR'left downto 1);
      if rxVecR(0) = '1' and rxVecR(1) = '0' then
        -- detect falling edge of serial input
        --   used to detect the beginning of the start bit
        fEdgeR <= '1';
      end if;
    end if;
  end process rx_input;

  baud_gen : process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      baudCntR <= 0;
      sampleR  <= '0';
    elsif rising_edge(clk_i) then
      sampleR  <= '0';
      if baudCntR = BAUD_CNT_MAX-1 or searchR = '1' then
        baudCntR <= 0;
      else
        if baudCntR = BAUD_CNT_HALF-2 then
          sampleR <= '1';
        end if;
        baudCntR <= baudCntR + 1;
      end if;
    end if;
  end process baud_gen;

  fsm : process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      fsmR     <= IDLE;
      searchR  <= '1';
      dataR    <= (others => '1');
      bitCntR  <= 0;
      data_o   <= (others => '0');
      val_o    <= '0';
    elsif rising_edge(clk_i) then
      val_o    <= '0';
      case fsmR is
        when IDLE =>
          -- search for the beginning of the start bit
          searchR  <= '1';
          if fEdgeR = '1' then
            searchR <= '0';
            fsmR    <= START;
          end if;

        when START =>
          bitCntR  <= 0;
          -- "collect" start bit
          if sampleR = '1' then
            fsmR    <= DATA;
          end if;

        when DATA =>
          if sampleR = '1' then
            dataR <= rxVecR(0) & dataR(dataR'left downto 1);
            if bitCntR = data_o'left then
              fsmR    <= STOP;
            else
              bitCntR <= bitCntR + 1;
            end if;
          end if;
          
        when STOP =>
          if sampleR = '1' then
            searchR <= '1';
            data_o  <= dataR;
            val_o   <= '1';
            fsmR    <= IDLE;
          end if;

      end case;
    end if;
  end process fsm;

end architecture rtl;