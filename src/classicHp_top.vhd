----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Brian Nemetz
-- 
-- Create Date:    08:18:42 10/26/2012 
-- Design Name: 
-- Module Name:    classicHp_top - rtl 
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
library ieee;   use ieee.std_logic_1164.all;
                use ieee.numeric_std.all;

                use work.classic_pack.all;
                use work.ps2_keyboard_pack.all;
                use work.rom_pack.all;
                use work.tm16xxFonts.all;


entity classichp_top is
    generic (
          UART_TYPE : string     := "TX_RX";  -- Should be: "NONE", "TX", "RX", or "TX_RX"
          CALC_NAME : string     := "HP55"    -- Should be: "HP55", "HP45", or "HP35"
    );
    port ( clk_i       : in    std_logic;
           rst_i       : in    std_logic;
           ps2_clk_i   : in    std_logic;
           ps2_data_i  : in    std_logic;
           uart_rx_i   : in    std_logic;
           dis_clk_o   :   out std_logic;
           dis_data_o  :   out std_logic;
           uart_tx_o   :   out std_logic;
           leds_o      :   out std_logic_vector (3 downto 0)
           );
end classichp_top;

architecture rtl of classichp_top is
  -- Configure for the calculator desired:
  constant HP35        : boolean     := CALC_NAME="HP35";
  constant HP45        : boolean     := CALC_NAME="HP45";
  constant HP55        : boolean     := CALC_NAME="HP55";
  constant CALC_ROM    : RomType     := IIF(HP55, ROM_55,       IIF(HP45, ROM_45,       ROM_35));
  constant KEY_LUT     : keyLutType  := IIF(HP55, KEY_LUT_HP55, IIF(HP45, KEY_LUT_HP45, KEY_LUT_HP35));

  -- Configure for UART type desired:
  constant UART_TX     : boolean := UART_TYPE="TX" or UART_TYPE="TX_RX";
  constant UART_RX     : boolean := UART_TYPE="RX" or UART_TYPE="TX_RX";

--  constant CLK_FREQ    : natural     := 7000000;  -- sysClk Rate  
  constant CLK_FREQ    : natural     := 84000000;  -- sysClk Rate  
  constant CLK_EN_CNT  : natural     := CLK_FREQ/1000000;   -- CLK_EN_CNT is how many sysClk periods in 1us

  -- definition for "HP-x5" where x is 3, 4, or 5 (padded out to 14 chars)
  constant LED_SIGNON : ledFontRomType := (
    LED_SPACE,
    LED_MINUS,
    LED_MINUS,
    LED_SPACE,
    LED_H, -- 'H'
    LED_P, -- 'P'
    LED_DASH, -- '-'
    IIF(HP55, LED_5, IIF(HP45, LED_4, LED_3)), -- '3', '4', or '5' 
    LED_5, -- '5'
    LED_SPACE,
    LED_MINUS,
    LED_MINUS,
    LED_SPACE,
    LED_SPACE
  );

  type     ledFsmType    is (IDLE, START, SEND1, SEND2, SEND3, END1, END2, END3, END4);
  type     disLedFsmType is (CMD1, CMD2, CMD2W, T0, T1, DIS_CMD1, DIS_CMD2, DIS_EX1,
                             DIS_EX2, ERROR_D, SIGNON_D, SIGNON_W);
  subtype  clkEnCntType  is natural range 0 to CLK_EN_CNT-1;
  type     byteArrayType is array (natural range <>) of std_logic_vector(7 downto 0);

  subtype  idxCntType    is natural range 0 to 13;
  subtype  ledCntType    is natural range 0 to 7;

  constant DELAY_100MS   : natural := 100000
                                    -- synthesis translate_off
                                    - 99996
                                    -- synthesis translate_on
                                     ; 
  constant DELAY_10MS   : natural := 10000
                                    -- synthesis translate_off
                                    - 9996
                                    -- synthesis translate_on
                                     ; 
  constant DELAY_5MS   : natural := 5000
                                    -- synthesis translate_off
                                    - 4996
                                    -- synthesis translate_on
                                     ; 
  constant DELAY_200US : natural := 200
                                    -- synthesis translate_off
                                    - 198
                                    -- synthesis translate_on
                                     ;

  constant DELAY_10US : natural := 10
                                    -- synthesis translate_off
                                    - 8
                                    -- synthesis translate_on
                                     ;

  -- delay for creating real timing of the original HP-55 => 3500 instructions per sec
  --    ex: if sysClk is 7MHz: 7Mhz/3500 = 2000
  constant DELAY_INST  : natural := CLK_FREQ/3500
                                    -- synthesis translate_off
                                    - (CLK_FREQ/3500 - 10)
                                    -- synthesis translate_on
                                     ;
                                     
  subtype  delayCntType is natural range 0 to DELAY_5MS-1;
  subtype  keyCntType   is natural range 0 to DELAY_10MS-1;
  subtype  pCntType     is natural range 0 to DELAY_100MS-1;
  subtype  instCntType  is natural range 0 to DELAY_INST-1;

  signal sysRst        : std_logic;
  signal sysRstLow     : std_logic;
  signal sysClk        : std_logic;
  signal error         : std_logic;
  signal update        : std_logic;
  signal status        : std_logic_vector(11 downto 0);
  signal flagsR        : std_logic_vector(11 downto 0);
  signal xreg          : std_logic_vector(55 downto 0);
  signal mask          : std_logic_vector(55 downto 0);
  signal clkEnR        : std_logic;
  signal clkEnCntR     : clkEnCntType;

  signal ledFsmR       : ledFsmType;
  signal ledSendR      : std_logic;
  signal ledStartR     : std_logic;
  signal ledEndR       : std_logic;
  signal ledDoneR      : std_logic;
  signal ledClkR       : std_logic;
  signal ledDataR      : std_logic;
  signal ledSendDataR  : std_logic_vector(7 downto 0);
  signal ledBrightR    : unsigned(2 downto 0);
  signal ledCntR       : ledCntType;

  signal xregLedR      : std_logic_vector(55 downto 0);
  signal maskLedR      : std_logic_vector(55 downto 0);

  signal ps2ClkR       : std_logic;
  signal ps2ClkRR      : std_logic;
  signal ps2ClkRRR     : std_logic;
  signal keyRdyR       : std_logic;
  signal keyRdyLongR   : std_logic;
  signal keyRdy        : std_logic;
  signal keyData       : std_logic_vector(7 downto 0);
  signal keyDataR      : std_logic_vector(7 downto 0);

  signal uartKeyRdyR   : std_logic;
  signal uartKeyDataR  : std_logic_vector(7 downto 0);
  signal ps2KeyRdy     : std_logic;
  signal ps2KeyData    : std_logic_vector(7 downto 0);

  signal disLedFsmR    : disLedFsmType;
  signal indexLedR     : idxCntType;

  signal ledFirstR     : std_logic;
  signal ledExDigit1R  : std_logic_vector(7 downto 0);
  signal ledExDigit2R  : std_logic_vector(7 downto 0);
  signal keyCntR       : keyCntType;
  signal instCntR      : instCntType;
  signal instEnR       : std_logic;
  signal realSpeedEnR  : std_logic;
  signal displayEn     : std_logic;

begin
  -- test outputs  
  leds_o(0) <= uart_rx_i;
  leds_o(1) <= '0';
  leds_o(2) <= clkEnR;
  leds_o(3) <= '0';

  -- Xilinx DCM primitive is within this component.
  -- This is one thing that has to change if targetting a different FPGA.
  dcm : entity work.sys_dcm(behavioral)
    port map (
      CLKIN_IN        => clk_i,
      RST_IN          => rst_i,
      CLKFX_OUT       => sysClk,
      CLKIN_IBUFG_OUT => open,
      CLK0_OUT        => open,
      LOCKED_OUT      => sysRstLow
      );
  sysRst <= not sysRstLow;
 
  hpCore: entity work.classic(rtl)
      generic map (
          CALC_NAME => CALC_NAME,
          ROM       => CALC_ROM
      )
      PORT MAP (
          clk_i        => sysClk,
          rst_i        => sysRst,
          inst_en_i    => instEnR,
          flags_i      => flagsR,
          keycode_i    => keyDataR,
          keyvalid_i   => keyRdyLongR,
          display_en_o => displayEn,
          error_o      => error,
          xreg_o       => xreg,
          mask_o       => mask,
          status_o     => status,
          update_o     => update
        );

  -- This is the PS/2 interface and will return calculator keycodes (plus a few
  -- special codes).
  ps2 : entity work.ps2_keyboard(rtl)
  generic map (KEY_LUT => KEY_LUT)
  port map(
    rst_i      => sysRst,
    clk_i      => sysClk,            -- needs to be faster than ps2_clk_i
    ps2_data_i => ps2_data_i,
    ps2_clk_i  => ps2_clk_i,
    key_rdy_o  => ps2KeyRdy,         -- one clock cycle pulse, notify a new byte has arrived
    key_data_o => ps2KeyData
    );

  -- choose between UART and PS/2 keyboard input
  keyRdy  <= ps2KeyRdy or uartKeyRdyR;
  keyData <= ps2KeyData when ps2KeyRdy='1' else uartKeyDataR;

  -- Create a clock enable pulse every 1us. This is for general timing of
  -- slower things.
  clk_en : process (sysClk, sysRst)
  begin
    if sysRst = '1' then
      clkEnCntR <= 0;
      clkEnR    <= '0';
    elsif rising_edge(sysClk) then
      if clkEnCntR = CLK_EN_CNT-1 then
        clkEnR    <= '1';
        clkEnCntR <= 0;
      else
        clkEnR    <= '0';
        clkEnCntR <= clkEnCntR+1;
      end if;
    end if;
  end process clk_en;

  -- Create an enable pulse every micro-instruction execution time.
  -- For slowing down the core to the same speed as the original HP-55.
  inst_en : process (sysClk, sysRst)
  begin
    if sysRst = '1' then
      instCntR <= 0;
      instEnR  <= '1';
    elsif rising_edge(sysClk) then
      if realSpeedEnR /= '1' or instCntR = instCntType'high then
        instEnR  <= '1';
        instCntR <= 0;
      else
        instEnR  <= '0';
        instCntR <= instCntR+1;
      end if;
    end if;
  end process inst_en;

  -- We need to create a stretched key ready signal for the core on each new
  -- keyboard input.  This is needed since the calculator micro-code is still
  -- doing key debouncing. We hold each key active for 10ms -- this should be
  -- long enough for the core to "see" the key press (in real or turbo speed
  -- mode). 
  key_stretch : process (sysClk, sysRst)
  begin
    if sysRst = '1' then
      keyCntR     <= 0;
      keyRdyLongR <= '0';
    elsif rising_edge(sysClk) then
      if keyRdyLongR = '0' and keyRdyR = '1' then
        keyRdyLongR <= '1';
        keyCntR     <= 0;
      end if;
      if clkEnR = '1' and keyRdyLongR = '1' then
        if keyCntR = keyCntType'high then 
          keyRdyLongR <= '0';
        else
          keyCntR <= keyCntR+1;
        end if;
      end if;
    end if;
  end process key_stretch;

  -- clock process for sync'ing FFs for the PS/2 clock input.  This input
  -- is async to the internal FPGA clock.
  -- (The underlying PS/2 module does not seem to do this.)
  clk_proc : process (sysClk, sysRst)
  begin
    if sysRst = '1' then
      ps2ClkR   <= '0';
      ps2ClkRR  <= '0';
      ps2ClkRR  <= '0';
    elsif rising_edge(sysClk) then
      ps2ClkR   <= ps2_clk_i;
      ps2ClkRR  <= ps2ClkR;
      ps2ClkRRR <= ps2ClkRR;
    end if;
  end process clk_proc;


  -- Handle new key presses.
  keypress : process (sysClk, sysRst)
  begin
    if sysRst = '1' then
      keyDataR     <= (others => '0');
      flagsR       <= (others => '0');
      keyRdyR      <= '0';
      realSpeedEnR <= '0';
      ledBrightR   <= "100";
    elsif rising_edge(sysClk) then
      if keyRdy = '1' then  keyDataR  <= keyData; end if;
      -- Key codes with the lower three bits set are special keys and are not
      -- sent to the calculator core. 
      if keyRdy = '1' and keyData(2 downto 0) /= "111" then keyRdyR <= '1'; else keyRdyR <= '0'; end if;
      if keyRdy = '1' and keyData(2 downto 0) = "111" then 
        if keyData = x"3F" then
          -- change the brighness of the LED display
          if ledBrightR = "000" then
            ledBrightR <= (others => '1');
          else
            ledBrightR <= ledBrightR - 1;
          end if;
        elsif keyData = x"27" then
          -- Fast speed
          if HP55 then
            if flagsR(11) /= '1' then
              -- only allow fast speed when not in timer mode
              realSpeedEnR <= '0';
            end if;
          else
            realSpeedEnR <= '0';
          end if;
        elsif keyData = x"1F" then
          -- RealSpeed
          realSpeedEnR <= '1';
        elsif keyData = x"07" and HP55 then
          flagsR    <= (others => '0'); -- Switch in RUN mode
        elsif keyData = x"0F" and HP55 then
          flagsR    <= (others => '0');
          flagsR(3) <= '1';             -- Switch in PROG mode
        elsif keyData = x"17" and HP55 then
          flagsR       <= (others => '0');
          flagsR(11)   <= '1';             -- Switch in TIMER mode
          realSpeedEnR <= '1';             -- need to be in realspeed mode for timer to be correct
        end if;
      end if;
    end if;
  end process keypress;

  -----------------------------------------
  -- Start of the UART driver
  -----------------------------------------
  UART_YES : if UART_TX or UART_RX generate
  begin
    RX_YES : if UART_RX generate
      constant KEY_PREFIX : std_logic_vector(7 downto 0) := x"0F";
      constant CMD_PREFIX : std_logic_vector(7 downto 0) := x"F0";
      type fsmType is (IDLE, GET_KEY, GET_CMD);
      signal fsmR      : fsmType;
      signal dataRcv   : std_logic_vector(7 downto 0);
      signal rxSerial  : std_logic;
      signal rxDataAv  : std_logic;
    begin
      uut_rx: entity work.uart_rx(rtl)
      generic map (
        CLK_HZ => CLK_FREQ,
        BAUD   => 115200
      )
      port map (
        clk_i  => sysClk,
        rst_i  => sysRst,
        rx_i   => rxSerial,
        data_o => dataRcv,
        val_o  => rxDataAv
      );
      rxSerial <= uart_rx_i;
      rx_fsm : process (sysClk, sysRst)
      begin
        if sysRst = '1' then
          fsmR         <= IDLE;
          uartKeyRdyR  <= '0';
          uartKeyDataR <= (others => '0');
        elsif rising_edge(sysClk) then
          uartKeyRdyR  <= '0';
          case fsmR is
            when IDLE    =>
              if rxDataAv = '1' and dataRcv = KEY_PREFIX then
                -- A keycode is being received
                fsmR <= GET_KEY;
              elsif rxDataAv = '1' and dataRcv = CMD_PREFIX then
                -- A command is being received
                fsmR <= GET_CMD;
              end if;

            when GET_KEY =>
              if rxDataAv = '1' then
                uartKeyRdyR  <= '1';
                uartKeyDataR <= dataRcv;
                fsmR         <= IDLE;
              end if;

            when GET_CMD =>
              if rxDataAv = '1' then
                uartKeyRdyR  <= '1';
                uartKeyDataR <= dataRcv;
                fsmR         <= IDLE;
              end if;
            
          end case;
        end if;
      end process rx_fsm;
    end generate RX_YES;

    RX_NO : if not UART_RX generate
    begin
      uartKeyRdyR  <= '0';
      uartKeyDataR <= (others => '0');
    end generate RX_NO;

    TX_YES : if UART_TX generate
      constant PREFIX  : std_logic_vector(7 downto 0)  := x"FA";
      constant BYTES   : natural                       := WSIZE/2;
      subtype  byteCntType is natural range 0 to BYTES-1;
      type fsmType is (IDLE, SEND_XREG, SEND_MASK, SEND_FLAGS);
      signal fsmR      : fsmType;
      signal dataSendR : std_logic_vector(7 downto 0);
      signal txSerial  : std_logic;
      signal txEot     : std_logic;
      signal txRdy     : std_logic;
      signal txWrEnR   : std_logic;
      signal cntR      : byteCntType;
      signal xregR     : std_logic_vector(55 downto 0);
      signal maskR     : std_logic_vector(55 downto 0);
      signal dcntR     : pCntType;
      signal pulseR    : std_logic;
      signal flags     : std_logic_vector(7 downto 0);
    begin
      uut_tx: entity work.uart_tx(rtl)
      generic map (
        CLK_HZ => CLK_FREQ,
        BAUD   => 115200
      )
      port map (
        clk_i  => sysClk,
        rst_i  => sysRst,
        data_i => dataSendR,
        wr_i   => txWrEnR,
        tx_o   => txSerial,
        rdy_o  => txRdy
      );

      uart_tx_o <= txSerial;

      timer : process (sysClk, sysRst)
      begin
        if sysRst = '1' then
          dcntR  <= 0;
          pulseR <= '0';
        elsif rising_edge(sysClk) then
          pulseR <= '0';
          if clkEnR = '1' then
            if dcntR = DELAY_100MS-1 then
              dcntR  <= 0;
              pulseR <= '1';
            else
              dcntR <= dcntR + 1;
            end if;
          end if;
        end if;
      end process timer;
      
      flags <= "0001" & realSpeedEnR & flagsR(11) & status(6) & status(4) when HP55 else
               "0010" & realSpeedEnR & "00" & status(10) when HP45 else
               "0100" & realSpeedEnR & "00" & status(10);
      
      tx_fsm : process (sysClk, sysRst)
      begin
        if sysRst = '1' then
          fsmR       <= IDLE;
          cntR       <= 0;
          txWrEnR    <= '0';
          maskR      <= (others => '0');
          xregR      <= (others => '0');
          dataSendR  <= (others => '0');
        elsif rising_edge(sysClk) then
          txWrEnR  <= '0';
          case fsmR is
            when IDLE =>
              dataSendR  <= PREFIX;
              cntR       <= 0;
              maskR      <= mask;
              xregR      <= xreg;
--              if txRdy = '1' and (maskR /= mask or xregR /= xreg) then
              if txRdy = '1' and pulseR = '1' then
                maskR    <= mask;
                xregR    <= xreg;
                txWrEnR  <= '1';
                fsmR     <= SEND_XREG;
              end if;
            
            when SEND_XREG =>
              dataSendR <= xregR(xregR'left downto xregR'left-7);
              if txRdy = '1' then
                txWrEnR  <= '1';
                xregR    <= xregR(xregR'left-8 downto 0) & xregR(xregR'left downto xregR'left-7);
                if cntR = BYTES-1 then
                  cntR <= 0;
                  fsmR <= SEND_MASK;
                else
                  cntR <= cntR + 1;
                end if;
              end if;

            when SEND_MASK =>
              dataSendR <= maskR(maskR'left downto maskR'left-7);
              if txRdy = '1' then
                txWrEnR  <= '1';
                maskR    <= maskR(maskR'left-8 downto 0) & maskR(maskR'left downto maskR'left-7);
                if cntR = BYTES-1 then
                  fsmR <= SEND_FLAGS;
                else
                  cntR <= cntR + 1;
                end if;
              end if;

            when SEND_FLAGS =>
              dataSendR <= flags;
              if txRdy = '1' then
                txWrEnR  <= '1';
                fsmR     <= IDLE;
              end if;
          end case;
        end if;
      end process tx_fsm;
    end generate TX_YES;

    TX_NO : if not UART_TX generate
    begin
    end generate TX_NO;
    

  end generate UART_YES;

  UART_NO : if not(UART_TX or UART_RX) generate
  begin
    uart_tx_o    <= '1';
    uartKeyRdyR  <= '0';
    uartKeyDataR <= (others => '0');
  end generate UART_NO;
  -----------------------------------------
  -- End of the UART driver
  -----------------------------------------

  -----------------------------------------
  -- Start of the LED Display Module driver
  -----------------------------------------
  -- The led process is a low level driver for the LED display.
  -- It will send one byte to the display.
  -- Inputs:
  --    ledSendR     : pulse high to start sending byte to the display
  --    ledStartR    : should a start bit be sent first?
  --    ledSendDataR : 8-bit data to send to the display
  -- Output:
  --    ledDoneR     : pulses high when data has been sent
  --
  led : process (sysClk, sysRst)
  begin
    if sysRst = '1' then
      ledFsmR    <= IDLE;
      ledDoneR   <= '0';
      ledClkR    <= '1';
      ledDataR   <= '1';
      ledCntR    <= 0;
    elsif rising_edge(sysClk) then
      if clkEnR='1' then
        ledDoneR    <= '0';
        case ledFsmR is
          when IDLE =>
            ledCntR <= 0;
            if ledSendR = '1' then
              if ledStartR = '1' then
                ledFsmR <= START;
              else
                ledFsmR <= SEND1;
               end if;
            end if;

          when START =>
            -- Signal a "start" command: drive ledDataR low while ledClkR is high
            -- Note: ledClkR is assumed to be already high
            ledDataR <= '0';
            ledFsmR  <= SEND1;
          
          when SEND1 =>
            -- drive clock low (assumes it is high already)
            ledClkR <= '0';
            ledFsmR <= SEND2;

          when SEND2 =>
            -- drive data
            ledDataR <= ledSendDataR(ledCntR);
            ledFsmR <= SEND3;
            
          when SEND3 =>
            -- drive clock back high
            ledClkR <= '1';
            if ledCntR = 7 then
              if ledEndR = '1' then
                ledFsmR <= END1;
              else
                ledDoneR <= '1';
                ledFsmR  <= IDLE;
              end if;
            else
              ledCntR <= ledCntR + 1;
              ledFsmR <= SEND1;
            end if;

          when END1 =>
            ledClkR <= '0';
            ledFsmR <= END2;
            
          when END2 =>
            ledDataR <= '0';
            ledFsmR  <= END3;

          when END3 =>
            ledClkR <= '1';
            ledFsmR <= END4;

          when END4 =>
            ledDoneR <= '1';
            ledDataR <= '1';
            ledFsmR  <= IDLE;

        end case;
      end if;
    end if;
  end process led;

  dis_clk_o  <= ledClkR;
  dis_data_o <= ledDataR;

  -- there are two extra digits on the LED display that are not used to
  -- dispaly calculator output.  These two extra digits can display additiona
  -- info.  The first extra digit is not used, yet. The second digit is used
  -- to display "shift" key status.  The "shift" key status varies for each
  -- calculator type.
  HP35_DIS : if HP35 generate
    -- The HP-35 only shift key to do arc-sin, arc-cos, and arc-tan
    -- status bit indicates this.
    ledExDigit1R <= LED_SPACE;
    fShift : process (sysClk, sysRst)
    begin
      if sysRst = '1' then
        ledExDigit2R <= LED_SPACE;
      elsif rising_edge(sysClk) then
        if status(10) = '1' then
          ledExDigit2R <= LED_A;
        else
          ledExDigit2R <= LED_SPACE;
        end if;
      end if;
    end process fShift;
  end generate HP35_DIS;
  
  HP45_DIS : if HP45 generate
    -- The HP-45 has one shift key. Status
    -- bit 10 indicates its state.
    ledExDigit1R <= LED_SPACE;
    fShift : process (sysClk, sysRst)
    begin
      if sysRst = '1' then
        ledExDigit2R <= LED_SPACE;
      elsif rising_edge(sysClk) then
        if status(10) = '1' then
          ledExDigit2R <= LED_F;
        else
          ledExDigit2R <= LED_SPACE;
        end if;
      end if;
    end process fShift;
  end generate HP45_DIS;
  
  HP55_DIS : if HP55 generate
    -- The HP-45 has two shift keys.  Status bits 4, 6, and 11
    -- need to be looked at to determine the shift key states.
    ledExDigit1R <= LED_SPACE;
    fgShift : process (sysClk, sysRst)
    begin
      if sysRst = '1' then
        ledExDigit2R <= LED_SPACE;
      elsif rising_edge(sysClk) then
        -- Note: When in timer mode (flagsR(11) is set) status(6)
        --       indicates if the timer is stopped (status(6)=1 if timer is stopped)
        if status(6) = '1' and flagsR(11) /= '1' then
          ledExDigit2R <= LED_F;
        elsif status(4) = '1' then
          ledExDigit2R <= LED_G;
        else
          ledExDigit2R <= LED_SPACE;
        end if;
        ledExDigit2R(7) <= realSpeedEnR;
      end if;
    end process fgShift;
  end generate HP55_DIS;
  
  -- The ledDisplay process is the higher level LED display
  -- driver.  It displays the current value of the X register,
  -- the sign-on message or the error message.
  ledDisplay : process (sysClk, sysRst, xregLedR, maskLedR)
    variable bcd  : std_logic_vector(3 downto 0);
    variable dMask: std_logic_vector(3 downto 0);
  begin
    bcd   := xregLedR(55 downto 52);
    dMask := maskLedR(55 downto 52);

    if sysRst = '1' then
      disLedFsmR  <= CMD1;
      indexLedR   <= 0;
      ledStartR   <= '0';
      ledEndR     <= '0';
      ledSendR    <= '0';
      ledFirstR   <= '1';   -- flag for the first time throught the FSM (for Sign On message)
      ledSendDataR<= (others => '0');
      maskLedR    <= (others => '0');
      xregLedR    <= (others => '0');
    elsif rising_edge(sysClk) then
      if clkEnR='1' then
        ledSendR  <= '0';
        case disLedFsmR is
          when CMD1 =>
            maskLedR <= mask;
            xregLedR <= xreg;

            indexLedR     <= 0;
            ledSendDataR  <= "01000000"; -- Data Mode: Address Auto + 1
            ledSendR      <= '1';
            ledEndR       <= '1';
--            if realSpeedEnR /= '1' or displayEn = '1' then
            if ledFirstR = '1' or error = '1' or displayEn = '1' then
              ledStartR     <= '1';
              disLedFsmR    <= CMD2;
            end if;
            
          when CMD2 =>
            if ledDoneR = '1' then
              ledSendDataR <= x"C0" or x"00";    -- set address
              ledStartR    <= '1';
              ledSendR     <= '1';
              ledEndR      <= '0';
              if ledFirstR = '1' then
                disLedFsmR   <= SIGNON_D;
              elsif error = '1' then
                disLedFsmR   <= ERROR_D;
              else
                disLedFsmR   <= CMD2W;
              end if;
            end if;

          when SIGNON_D =>
            if ledDoneR = '1' then
              ledSendDataR <= LED_SIGNON(indexLedR);
              ledStartR    <= '0';
              ledSendR     <= '1';
              if indexLedR = 13 then
                ledEndR    <= '0';
                disLedFsmR <= DIS_EX1;
              else
                indexLedR  <= indexLedR + 1;
                ledEndR    <= '0';
              end if;
            end if;

          when ERROR_D =>
            if ledDoneR = '1' then
              ledSendDataR <= LED_ERROR(indexLedR);
              ledStartR    <= '0';
              ledSendR     <= '1';
              if indexLedR = 13 then
                ledEndR    <= '0';
                disLedFsmR <= DIS_EX1;
              else
                indexLedR  <= indexLedR + 1;
                ledEndR    <= '0';
              end if;
            end if;

          when CMD2W =>
            if ledDoneR = '1' then
              disLedFsmR   <= T0;
            end if;

          when T0 =>
            if dMask = "1001" then
              ledSendDataR <= LED_SPACE;   -- space
            else
              if indexLedR=11 or indexLedR=0 then  -- the two sign positions
                if bcd = "1001" then
                  if dMask = "0000" then
                    ledSendDataR <= LED_MINUS;   -- '-'
                  else
                    ledSendDataR <= LED_MINUS or LED_DP;   -- '-.'
                  end if;
                else
                  if dMask = "0000" then
                    ledSendDataR <= LED_SPACE;   -- space
                  else
                    ledSendDataR <= LED_0 or LED_DP;   -- space
                  end if;
                end if;
              elsif dMask = "0000" then
                ledSendDataR <= LED_HEX_FONT(to_integer(unsigned(bcd)));
              else 
                ledSendDataR <= LED_HEX_FONT(to_integer(unsigned(bcd))) or LED_DP;
              end if;
            end if;
            ledStartR   <= '0';
            ledSendR    <= '1';
            if indexLedR = 13 then
              ledEndR    <= '0';
              disLedFsmR <= DIS_EX1;
            else
              ledEndR    <= '0';
              disLedFsmR <= T1;
            end if;

          when T1 =>
            if ledDoneR = '1' then
              indexLedR  <= indexLedR + 1;
              maskLedR   <= maskLedR(51 downto 0) & "0000";
              xregLedR   <= xregLedR(51 downto 0) & "0000";
              disLedFsmR <= T0;
            end if;
          
          when DIS_EX1 =>
            if ledDoneR = '1' then
              ledSendDataR <= ledExDigit1R;
              ledStartR    <= '0';
              ledSendR     <= '1';
              ledEndR      <= '0';
              disLedFsmR   <= DIS_EX2;
            end if;

          when DIS_EX2 =>
            if ledDoneR = '1' then
              ledSendDataR <= ledExDigit2R;
              ledStartR    <= '0';
              ledSendR     <= '1';
              ledEndR      <= '1';
              disLedFsmR   <= DIS_CMD1;
            end if;

          when DIS_CMD1 =>
            if ledDoneR = '1' then
              ledSendDataR <= x"80" or x"08" or "00000"&std_logic_vector(ledBrightR);    -- Display Command: On & full brighness
              ledStartR    <= '1';
              ledSendR     <= '1';
              ledEndR      <= '1';
              disLedFsmR   <= DIS_CMD2;
            end if;

          when DIS_CMD2 =>
            if ledDoneR = '1' then
              if ledFirstR = '1' then
                disLedFsmR   <= SIGNON_W;
              else
                disLedFsmR   <= CMD1;
              end if;
            end if;
          
          when SIGNON_W =>
            -- wait for keyboard activity
            ledFirstR <= '0';     -- reset first flag
            if (ps2ClkRRR='0' and  ps2ClkRR = '1') or keyRdyLongR = '1' then
              disLedFsmR   <= CMD1;
            end if;
            
        end case;
      end if;
    end if;
  end process ledDisplay;

  -----------------------------------------
  -- End of the LED Display Module driver
  -----------------------------------------

end rtl;

