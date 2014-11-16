-----------------------------------------------------------------------------
--  LEON3 Demonstration design test bench
------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2013, Aeroflex Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
library gaisler;
use gaisler.libdcom.all;
use gaisler.sim.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library micron;
use micron.all;
library techmap;
use techmap.gencomp.all;
use work.debug.all;

use work.config.all;

entity testbench is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH;
    disas     : integer := CFG_DISAS;      -- Enable disassembly to console
    dbguart   : integer := CFG_DUART;      -- Print UART on console
    pclow     : integer := CFG_PCLOW;
    testahb   : boolean := true;
    USE_MIG_INTERFACE_MODEL : boolean := false

  );
end;

architecture behav of testbench is

-- DDR3 Simulation parameters
constant SIM_BYPASS_INIT_CAL : string := "FAST";
          -- # = "OFF" -  Complete memory init &
          --               calibration sequence
          -- # = "SKIP" - Not supported
          -- # = "FAST" - Complete memory init & use
          --              abbreviated calib sequence

constant SIMULATION          : string := "TRUE";
          -- Should be TRUE during design simulations and
          -- FALSE during implementations


constant promfile      : string := "prom.srec";  -- rom contents
constant sramfile      : string := "sram.srec";  -- ram contents
constant sdramfile     : string := "sdram.srec"; -- sdram contents

signal clk             : std_logic := '0';
signal Rst             : std_logic := '0';

signal address         : std_logic_vector(25 downto 0);
signal data            : std_logic_vector(15 downto 0);
signal button          : std_logic_vector(3 downto 0) := "0000";
signal genio           : std_logic_vector(59 downto 0);
signal romsn           : std_logic;
signal oen             : std_ulogic;
signal writen          : std_ulogic;
signal adv             : std_logic;

signal GND             : std_ulogic := '0';
signal VCC             : std_ulogic := '1';
signal NC              : std_ulogic := 'Z';

signal txd1  , rxd1  , dsurx   : std_logic;
signal txd2  , rxd2  , dsutx   : std_logic;
signal ctsn1 , rtsn1 , dsuctsn : std_ulogic;
signal ctsn2 , rtsn2 , dsurtsn : std_ulogic;

signal phy_mii_data    : std_logic;
signal phy_tx_clk      : std_ulogic;
signal phy_rx_clk      : std_ulogic;
signal phy_rx_data     : std_logic_vector(7 downto 0);
signal phy_dv          : std_ulogic;
signal phy_rx_er       : std_ulogic;
signal phy_col         : std_ulogic;
signal phy_crs         : std_ulogic;
signal phy_tx_data     : std_logic_vector(7 downto 0);
signal phy_tx_en       : std_ulogic;
signal phy_tx_er       : std_ulogic;
signal phy_mii_clk     : std_ulogic;
signal phy_rst_n       : std_ulogic;
signal phy_gtx_clk     : std_ulogic;
signal phy_mii_int_n   : std_ulogic;

signal clk27           : std_ulogic := '0';
signal clk200p         : std_ulogic := '0';
signal clk200n         : std_ulogic := '1';
signal clk33           : std_ulogic := '0';
signal clkethp         : std_ulogic := '0';
signal clkethn         : std_ulogic := '1';
signal txp1             : std_logic;
signal txn             : std_logic;
signal rxp             : std_logic := '1';
signal rxn             : std_logic := '0';


signal iic_scl         : std_ulogic;
signal iic_sda         : std_ulogic;
signal ddc_scl         : std_ulogic;
signal ddc_sda         : std_ulogic;
signal dvi_iic_scl     : std_logic;
signal dvi_iic_sda     : std_logic;

signal tft_lcd_data    : std_logic_vector(11 downto 0);
signal tft_lcd_clk_p   : std_ulogic;
signal tft_lcd_clk_n   : std_ulogic;
signal tft_lcd_hsync   : std_ulogic;
signal tft_lcd_vsync   : std_ulogic;
signal tft_lcd_de      : std_ulogic;
signal tft_lcd_reset_b : std_ulogic;

-- DDR3 memory
signal ddr3_dq         : std_logic_vector(63 downto 0);
signal ddr3_dqs_p      : std_logic_vector(7 downto 0);
signal ddr3_dqs_n      : std_logic_vector(7 downto 0);
signal ddr3_addr       : std_logic_vector(13 downto 0);
signal ddr3_ba         : std_logic_vector(2 downto 0);
signal ddr3_ras_n      : std_logic;
signal ddr3_cas_n      : std_logic;
signal ddr3_we_n       : std_logic;
signal ddr3_reset_n    : std_logic;
signal ddr3_ck_p       : std_logic_vector(0 downto 0);
signal ddr3_ck_n       : std_logic_vector(0 downto 0);
signal ddr3_cke        : std_logic_vector(0 downto 0);
signal ddr3_cs_n       : std_logic_vector(0 downto 0);
signal ddr3_dm         : std_logic_vector(7 downto 0);
signal ddr3_odt        : std_logic_vector(0 downto 0);

-- SPI flash
signal spi_sel_n       : std_ulogic;
signal spi_clk         : std_ulogic;
signal spi_mosi        : std_ulogic;

signal dsurst          : std_ulogic;
signal errorn          : std_logic;

signal switch          : std_logic_vector(4 downto 0);    -- I/O port
signal led             : std_logic_vector(6 downto 0);    -- I/O port
constant lresp         : boolean := false;

signal tdqs_n : std_logic;

signal gmii_tx_clk     : std_logic;
signal gmii_rx_clk     : std_logic;
signal gmii_txd        : std_logic_vector(7 downto 0);
signal gmii_tx_en      : std_logic;
signal gmii_tx_er      : std_logic;
signal gmii_rxd        : std_logic_vector(7 downto 0);
signal gmii_rx_dv      : std_logic;
signal gmii_rx_er      : std_logic;

signal configuration_finished : boolean;
signal speed_is_10_100        : std_logic;
signal speed_is_100           : std_logic;

signal usb_clkout      : std_logic := '0';
signal usb_d           : std_logic_vector(7 downto 0);
signal usb_resetn      : std_ulogic;
signal usb_nxt         : std_ulogic;
signal usb_stp         : std_ulogic;
signal usb_dir         : std_ulogic;

-- GRUSB_DCL test signals
signal ddelay          : std_ulogic := '0';
signal dstart          : std_ulogic := '0';
signal drw             : std_ulogic;
signal daddr           : std_logic_vector(31 downto 0);
signal dlen            : std_logic_vector(14 downto 0);
signal ddi             : grusb_dcl_debug_data;
signal ddone           : std_ulogic;
signal ddo             : grusb_dcl_debug_data;

component leon3mp is
  generic (
    fabtech             : integer := CFG_FABTECH;
    memtech             : integer := CFG_MEMTECH;
    padtech             : integer := CFG_PADTECH;
    clktech             : integer := CFG_CLKTECH;
    disas               : integer := CFG_DISAS;   -- Enable disassembly to console
    dbguart             : integer := CFG_DUART;   -- Print UART on console
    pclow               : integer := CFG_PCLOW;
    testahb             : boolean := false;
    SIM_BYPASS_INIT_CAL : string := "OFF";
    SIMULATION          : string := "FALSE";
    USE_MIG_INTERFACE_MODEL : boolean := false;
    autonegotiation     : integer := 1
  );
  port (
    reset           : in    std_ulogic;
    clk200p         : in    std_ulogic;       -- 200 MHz clock
    clk200n         : in    std_ulogic;       -- 200 MHz clock
    address         : out   std_logic_vector(25 downto 0);
    data            : inout std_logic_vector(15 downto 0);
    oen             : out   std_ulogic;
    writen          : out   std_ulogic;
    romsn           : out   std_logic;
    adv             : out   std_logic;
    ddr3_dq         : inout std_logic_vector(63 downto 0);
    ddr3_dqs_p      : inout std_logic_vector(7 downto 0);
    ddr3_dqs_n      : inout std_logic_vector(7 downto 0);
    ddr3_addr       : out   std_logic_vector(13 downto 0);
    ddr3_ba         : out   std_logic_vector(2 downto 0);
    ddr3_ras_n      : out   std_logic;
    ddr3_cas_n      : out   std_logic;
    ddr3_we_n       : out   std_logic;
    ddr3_reset_n    : out   std_logic;
    ddr3_ck_p       : out   std_logic_vector(0 downto 0);
    ddr3_ck_n       : out   std_logic_vector(0 downto 0);
    ddr3_cke        : out   std_logic_vector(0 downto 0);
    ddr3_cs_n       : out   std_logic_vector(0 downto 0);
    ddr3_dm         : out   std_logic_vector(7 downto 0);
    ddr3_odt        : out   std_logic_vector(0 downto 0);
    dsurx           : in    std_ulogic;
    dsutx           : out   std_ulogic;
    dsuctsn         : in    std_ulogic;
    dsurtsn         : out   std_ulogic;
    button          : in    std_logic_vector(3 downto 0);
    switch          : inout std_logic_vector(4 downto 0);
    led             : out   std_logic_vector(6 downto 0);
    iic_scl         : inout std_ulogic;
    iic_sda         : inout std_ulogic;
    usb_refclk_opt  : in    std_logic;
    usb_clkout      : in    std_logic;
    usb_d           : inout std_logic_vector(7 downto 0);
    usb_nxt         : in    std_logic;
    usb_stp         : out   std_logic;
    usb_dir         : in    std_logic;
    usb_resetn      : out   std_ulogic;
    gtrefclk_p      : in    std_logic;
    gtrefclk_n      : in    std_logic;
    txp             : out   std_logic;
    txn             : out   std_logic;
    rxp             : in    std_logic;
    rxn             : in    std_logic;
    emdio           : inout std_logic;
    emdc            : out   std_ulogic;
    eint            : in    std_ulogic;
    erst            : out   std_ulogic;
    can_txd         : out   std_logic_vector(0 to CFG_CAN_NUM-1);
    can_rxd         : in    std_logic_vector(0 to CFG_CAN_NUM-1);
    spi_data_out    : in    std_logic;
    spi_data_in     : out   std_ulogic;
    spi_data_cs_b   : out   std_ulogic;
    spi_clk         : out   std_ulogic
   );
end component;

component ddr3_model
  generic(
    ADDR_BITS : integer := 14;
    BA_BITS : integer := 3;
    DM_BITS : integer := 1;
    DQ_BITS : integer := 8;
    DQS_BITS : integer := 1
  );
  port(
    rst_n : in std_logic;
    ck : in std_logic;
    ck_n : in std_logic;
    cke : in std_logic;
    cs_n : in std_logic;
    ras_n : in std_logic;
    cas_n : in std_logic;
    we_n : in std_logic;
    dm_tdqs : inout std_logic_vector(DM_BITS-1 to 0);
    ba : in std_logic_vector(BA_BITS-1 to 0);
    addr : in std_logic_vector(ADDR_BITS-1 to 0);
    dq : inout std_logic_vector(DQ_BITS-1 to 0);
    dqs : inout std_logic_vector(DQS_BITS-1 to 0);
    dqs_n : inout std_logic_vector(DQS_BITS-1 to 0);
    tdqs_n : out std_logic_vector(DQS_BITS-1 to 0);
    odt : in std_logic
  );
end component;

signal temp1 : std_logic_vector(0 downto 0);
signal temp2 : std_logic_vector(0 downto 0);
signal temp3 : std_logic_vector(0 downto 0);

begin

  -- clock and reset
  clk200p <= not clk200p after 2.5 ns;
  clk200n <= not clk200n after 2.5 ns;
  clkethp <= not clkethp after 4 ns;
  clkethn <= not clkethp after 4 ns;

  rst <= not dsurst;
  rxd1 <= 'H'; ctsn1 <= '0';
  rxd2 <= 'H'; ctsn2 <= '0';
  button <= "0000";
  switch(3 downto 0) <= "0000";

  cpu : leon3mp
      generic map (
       fabtech              => fabtech,
       memtech              => memtech,
       padtech              => padtech,
       clktech              => clktech,
       disas                => disas,
       dbguart              => dbguart,
       pclow                => pclow,
       testahb              => testahb,
       SIM_BYPASS_INIT_CAL  => SIM_BYPASS_INIT_CAL,
       SIMULATION           => SIMULATION,
       USE_MIG_INTERFACE_MODEL => USE_MIG_INTERFACE_MODEL,
       autonegotiation      => 0
   )
      port map (
       reset           => rst,
       clk200p         => clk200p,
       clk200n         => clk200n,
       address         => address,
       data            => data,
       oen             => oen,
       writen          => writen,
       romsn           => romsn,
       adv             => adv,
       ddr3_dq         => ddr3_dq,
       ddr3_dqs_p      => ddr3_dqs_p,
       ddr3_dqs_n      => ddr3_dqs_n,
       ddr3_addr       => ddr3_addr,
       ddr3_ba         => ddr3_ba,
       ddr3_ras_n      => ddr3_ras_n,
       ddr3_cas_n      => ddr3_cas_n,
       ddr3_we_n       => ddr3_we_n,
       ddr3_reset_n    => ddr3_reset_n,
       ddr3_ck_p       => ddr3_ck_p,
       ddr3_ck_n       => ddr3_ck_n,
       ddr3_cke        => ddr3_cke,
       ddr3_cs_n       => ddr3_cs_n,
       ddr3_dm         => ddr3_dm,
       ddr3_odt        => ddr3_odt,
       dsurx           => dsurx,
       dsutx           => dsutx,
       dsuctsn         => dsuctsn,
       dsurtsn         => dsurtsn,
       button          => button,
       switch          => switch,
       led             => led,
       iic_scl         => iic_scl,
       iic_sda         => iic_sda,
       usb_refclk_opt  => '0',
       usb_clkout      => usb_clkout,
       usb_d           => usb_d,
       usb_nxt         => usb_nxt,
       usb_stp         => usb_stp,
       usb_dir         => usb_dir,
       usb_resetn      => usb_resetn,
       gtrefclk_p      => clkethp,
       gtrefclk_n      => clkethn,
       txp             => txp1,
       txn             => txn,
       rxp             => rxp'delayed(1 ns),
       rxn             => rxn'delayed(1 ns),
       emdio           => phy_mii_data,
       emdc            => phy_mii_clk,
       eint            => '0',
       erst            => phy_rst_n,
       can_txd         => OPEN,
       can_rxd         => "0",
       spi_data_out    => '0',
       spi_data_in     => OPEN,
       spi_data_cs_b   => OPEN,
       spi_clk         => OPEN
      );

  prom0 : for i in 0 to 1 generate
      sr0 : sram generic map (index => i+4, abits => 26, fname => promfile)
        port map (address(25 downto 0), data(15-i*8 downto 8-i*8), romsn,
                  writen, oen);
  end generate;

  -- Memory Models instantiations
  gen_mem_model : if (USE_MIG_INTERFACE_MODEL /= true) generate
   ddr3mem : if (CFG_MIG_SERIES7 = 1) generate
    gen_mem: for i in 0 to 7 generate

      temp1(0) <= ddr3_dm(i);
      temp2(0) <= ddr3_dqs_p(i);
      temp3(0) <= ddr3_dqs_n(i);

      u1: ddr3_model
        generic map(
        ADDR_BITS => 14,
        BA_BITS   => 3,
        DM_BITS   => 1,
        DQ_BITS   => 8,
        DQS_BITS  => 1
        )
        port map (
        rst_n   => ddr3_reset_n,
        ck      => ddr3_ck_p(0),
        ck_n    => ddr3_ck_n(0),
        cke     => ddr3_cke(0),
        cs_n    => ddr3_cs_n(0),
        ras_n   => ddr3_ras_n,
        cas_n   => ddr3_cas_n,
        we_n    => ddr3_we_n,
        dm_tdqs => temp1,
        ba      => ddr3_ba,
        addr    => ddr3_addr,
        dq      => ddr3_dq((8*i+7) downto (8*i)),
        dqs     => temp2,
        dqs_n   => temp3,
        tdqs_n  => OPEN,
        odt     => ddr3_odt(0)
        );
    end generate gen_mem;
   end generate ddr3mem;
  end generate gen_mem_model;

  mig_mem_model : if (USE_MIG_INTERFACE_MODEL = true) generate
    ddr3_dq    <= (others => 'Z');
    ddr3_dqs_p <= (others => 'Z');
    ddr3_dqs_n <= (others => 'Z');
  end generate mig_mem_model;

  errorn <= led(1);
  errorn <= 'H'; -- ERROR pull-up

  -- SGMII simulation model is not yet complete!
  phy0 : if (CFG_GRETH = 1) generate

    phy_mii_data <= 'H';
    p0: phy
      generic map (address => 7)
      port map(
          phy_rst_n, phy_mii_data,
          open, phy_rx_clk,
          phy_rx_data,
          phy_dv,
          phy_rx_er,
          phy_col,
          phy_crs,
          phy_tx_data,
          phy_tx_en,
          phy_tx_er,
          phy_mii_clk,
          phy_tx_clk
         );

    p1 : phy_sgmii
      port map (
          txp                    => txp1,
          txn                    => txn,
          rxp                    => rxp,
          rxn                    => rxn,
          gmii_tx_clk            => phy_tx_clk,
          gmii_rx_clk            => phy_rx_clk,
          gmii_txd               => phy_tx_data,
          gmii_tx_en             => phy_tx_en,
          gmii_tx_er             => phy_tx_er,
          gmii_rxd               => phy_rx_data,
          gmii_rx_dv             => phy_dv,
          gmii_rx_er             => phy_rx_er,
          speed_is_10_100        => speed_is_10_100,
          speed_is_100           => speed_is_100,
          configuration_finished => configuration_finished,
          tx_monitor_finished    => open,
          rx_monitor_finished    => open
         );

     sgmii_configuration : process
     begin
      configuration_finished <= false;
      gmii_rx_clk <= '0';
      gmii_rxd    <= (others => '0');
      gmii_rx_dv  <= '0';
      gmii_rx_er  <= '0';
      speed_is_10_100 <= '0';
      speed_is_100    <= '0';
      wait on led(3);
      wait for 50 us; -- Should really wait for Status[0] to be high!
      wait for 1200 us;
      configuration_finished <= true;
      wait;
     end process;

  end generate;

  usbtr: if (CFG_GRUSBHC = 1) generate
    u0: ulpi
      port map (usb_clkout, usb_d, usb_nxt, usb_stp, usb_dir, usb_resetn);
  end generate usbtr;

  usbdevsim: if (CFG_GRUSBDC = 1) generate
    u0: grusbdcsim
      generic map (functm => 0, keepclk => 1)
      port map (usb_resetn, usb_clkout, usb_d, usb_nxt, usb_stp, usb_dir);
  end generate usbdevsim;

  usb_dclsim: if (CFG_GRUSB_DCL = 1) generate
    u0: grusb_dclsim
      generic map (functm => 0, keepclk => 1)
      port map (usb_resetn, usb_clkout, usb_d, usb_nxt, usb_stp, usb_dir,
                ddelay, dstart, drw, daddr, dlen, ddi, ddone, ddo);

    usb_dcl_proc : process
    begin
      wait for 10 ns;
      Print("GRUSB_DCL test started");

      wait until rising_edge(ddone);

      -- Write 128 bytes to memory
      daddr <= X"40000000";
      dlen  <= conv_std_logic_vector(32,15);
      for i in 0 to 127 loop
        ddi(i) <= conv_std_logic_vector(i+8,8);
      end loop;  -- i
      grusb_dcl_write(usb_clkout, drw, dstart, ddone);

      -- Read back written data
      grusb_dcl_read(usb_clkout, drw, dstart, ddone);

      -- Compare data
      for i in 0 to 127 loop
        if ddo(i) /= ddi(i) then
          Print("ERROR: Data mismatch using GRUSB_DCL");
        end if;
      end loop;

      Print("GRUSB_DCL test finished");

      wait;
    end process;
  end generate usb_dclsim;

   iuerr : process
   begin
     wait for 210 us; -- This is for proper DDR3 behaviour durign init phase not needed durin simulation
     wait on led(3);  -- DDR3 Memory Init ready
     wait for 5000 ns;
     if to_x01(errorn) = '1' then wait on errorn; end if;
     assert (to_x01(errorn) = '1')
       report "*** IU in error mode, simulation halted ***"
          severity failure ; -- this should be a failure
   end process;

  data <= buskeep(data) after 5 ns;

  dsucom : process
    procedure dsucfg(signal dsurx : in std_ulogic; signal dsutx : out std_ulogic) is
    variable w32 : std_logic_vector(31 downto 0);
    variable c8  : std_logic_vector(7 downto 0);
    constant txp : time := 320 * 1 ns;
    begin
    dsutx <= '1';
    dsurst <= '0';
    switch(4) <= '0';
    wait for 2500 ns;
    wait for 210 us; -- This is for proper DDR3 behaviour durign init phase not needed durin simulation
    dsurst <= '1';
    switch(4) <= '1';
    if (USE_MIG_INTERFACE_MODEL /= true) then
       wait on led(3);  -- Wait for DDR3 Memory Init ready
    end if;
    report "Start DSU transfer";
    wait for 5000 ns;
    txc(dsutx, 16#55#, txp);      -- sync uart

    -- Reads from memory and DSU register to mimic GRMON during simulation
    l1 : loop
     txc(dsutx, 16#80#, txp);
     txa(dsutx, 16#40#, 16#00#, 16#00#, 16#04#, txp);
     rxi(dsurx, w32, txp, lresp);
     --report "DSU read memory " & tost(w32);
     txc(dsutx, 16#80#, txp);
     txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
     rxi(dsurx, w32, txp, lresp);
     --report "DSU Break and Single Step register" & tost(w32);
    end loop l1;

    wait;

    -- ** This is only kept for reference --

    -- do test read and writes to DDR3 to check status
    -- Write
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#01#, 16#23#, 16#45#, 16#67#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#04#, txp);
    txa(dsutx, 16#89#, 16#AB#, 16#CD#, 16#EF#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#08#, txp);
    txa(dsutx, 16#08#, 16#19#, 16#2A#, 16#3B#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#0C#, txp);
    txa(dsutx, 16#4C#, 16#5D#, 16#6E#, 16#7F#, txp);
    txc(dsutx, 16#80#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#00#, txp);
    rxi(dsurx, w32, txp, lresp);
    txc(dsutx, 16#80#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#04#, txp);
    rxi(dsurx, w32, txp, lresp);
    report "* Read " & tost(w32);
    txc(dsutx, 16#a0#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#08#, txp);
    rxi(dsurx, w32, txp, lresp);
    txc(dsutx, 16#a0#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#0C#, txp);
    rxi(dsurx, w32, txp, lresp);
    wait;

    -- Register 0x90000000 (DSU Control Register)
    -- Data 0x0000202e (b0010 0000 0010 1110)
    -- [0] - Trace Enable
    -- [1] - Break On Error
    -- [2] - Break on IU watchpoint
    -- [3] - Break on s/w break points
    --
    -- [4] - (Break on trap)
    -- [5] - Break on error traps
    -- [6] - Debug mode (Read mode only)
    -- [7] - DSUEN (read mode)
    --
    -- [8] - DSUBRE (read mode)
    -- [9] - Processor mode error (clears error)
    -- [10] - processor halt (returns 1 if processor halted)
    -- [11] - power down mode (return 1 if processor in power down mode)
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#80#, 16#02#, txp);
    wait;
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#20#, 16#2e#, txp);

    wait for 25000 ns;
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#01#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#24#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#0D#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#70#, 16#11#, 16#78#, txp);
    txa(dsutx, 16#91#, 16#00#, 16#00#, 16#0D#, txp);

    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#44#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#20#, 16#00#, txp);

    txc(dsutx, 16#80#, txp);
    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#44#, txp);

    wait;

   end;

   begin
    dsuctsn <= '0';
    dsucfg(dsutx, dsurx);
    wait;
  end process;
end ;
