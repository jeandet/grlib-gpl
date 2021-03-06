-- megafunction wizard: %ALTIOBUF%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: altiobuf_out 

-- ============================================================
-- File Name: output_dqs_iobuf_inst.vhd
-- Megafunction Name(s):
-- 			altiobuf_out
--
-- Simulation Library Files(s):
-- 			stratixiii
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
--
-- 8.0 Build 231 07/10/2008 SP 1 SJ Full Version
-- ************************************************************


--Copyright (C) 1991-2008 Altera Corporation
--Your use of Altera Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files from any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Altera Program License 
--Subscription Agreement, Altera MegaCore Function License 
--Agreement, or other applicable license agreement, including, 
--without limitation, that your use is for the sole purpose of 
--programming logic devices manufactured by Altera and sold by 
--Altera or its authorized distributors.  Please refer to the 
--applicable agreement for further details.


--altiobuf_out CBX_AUTO_BLACKBOX="ALL" DEVICE_FAMILY="Stratix III" ENABLE_BUS_HOLD="FALSE" NUMBER_OF_CHANNELS=1 OPEN_DRAIN_OUTPUT="FALSE" PSEUDO_DIFFERENTIAL_MODE="TRUE" USE_DIFFERENTIAL_MODE="TRUE" USE_OE="TRUE" USE_TERMINATION_CONTROL="FALSE" datain dataout dataout_b oe
--VERSION_BEGIN 8.0SP1 cbx_altiobuf_in 2008:06:02:292401 cbx_mgl 2008:06:02:292401 cbx_stratixiii 2008:06:18:296807  VERSION_END

 LIBRARY stratixiii;
 USE stratixiii.all;

--synthesis_resources = stratixiii_io_obuf 2 stratixiii_pseudo_diff_out 1 
 LIBRARY ieee;
 USE ieee.std_logic_1164.all;

 ENTITY  output_dqs_iobuf_inst_iobuf_out_sdp IS 
	 PORT 
	 ( 
		 datain	:	IN  STD_LOGIC_VECTOR (0 DOWNTO 0);
		 dataout	:	OUT  STD_LOGIC_VECTOR (0 DOWNTO 0);
		 dataout_b	:	OUT  STD_LOGIC_VECTOR (0 DOWNTO 0);
		 oe	:	IN  STD_LOGIC_VECTOR (0 DOWNTO 0) := (OTHERS => '1');
		 oe_b	:	IN  STD_LOGIC_VECTOR (0 DOWNTO 0) := (OTHERS => '1')
	 ); 
 END output_dqs_iobuf_inst_iobuf_out_sdp;

 ARCHITECTURE RTL OF output_dqs_iobuf_inst_iobuf_out_sdp IS

--	 ATTRIBUTE synthesis_clearbox : boolean;
--	 ATTRIBUTE synthesis_clearbox OF RTL : ARCHITECTURE IS true;
	 SIGNAL  wire_obuf_ba_o	:	STD_LOGIC;
	 SIGNAL  wire_obufa_o	:	STD_LOGIC;
	 SIGNAL  wire_pseudo_diffa_o	:	STD_LOGIC;
	 SIGNAL  wire_pseudo_diffa_obar	:	STD_LOGIC;
	 --SIGNAL  oe_b	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 COMPONENT  stratixiii_io_obuf
	 GENERIC 
	 (
		bus_hold	:	STRING := "false";
		open_drain_output	:	STRING := "false";
		shift_series_termination_control	:	STRING := "false";
		sim_dynamic_termination_control_is_connected	:	STRING := "false";
		lpm_type	:	STRING := "stratixiii_io_obuf"
	 );
	 PORT
	 ( 
		dynamicterminationcontrol	:	IN STD_LOGIC := '0';
		i	:	IN STD_LOGIC := '0';
		o	:	OUT STD_LOGIC;
		obar	:	OUT STD_LOGIC;
		oe	:	IN STD_LOGIC := '1';
		parallelterminationcontrol	:	IN STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
		seriesterminationcontrol	:	IN STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0')
	 ); 
	 END COMPONENT;
	 COMPONENT  stratixiii_pseudo_diff_out
	 PORT
	 ( 
		i	:	IN STD_LOGIC := '0';
		o	:	OUT STD_LOGIC;
		obar	:	OUT STD_LOGIC
	 ); 
	 END COMPONENT;
 BEGIN

	dataout(0) <= wire_obufa_o;
	dataout_b(0) <= wire_obuf_ba_o;
	--oe_b <= (OTHERS => '1');
	obuf_ba :  stratixiii_io_obuf
	  GENERIC MAP (
		bus_hold => "false",
		open_drain_output => "false"
	  )
	  PORT MAP ( 
		i => wire_pseudo_diffa_obar,
		o => wire_obuf_ba_o,
		oe => oe_b(0)
	  );
	obufa :  stratixiii_io_obuf
	  GENERIC MAP (
		bus_hold => "false",
		open_drain_output => "false"
	  )
	  PORT MAP ( 
		i => wire_pseudo_diffa_o,
		o => wire_obufa_o,
		oe => oe(0)
	  );
	pseudo_diffa :  stratixiii_pseudo_diff_out
	  PORT MAP ( 
		i => datain(0),
		o => wire_pseudo_diffa_o,
		obar => wire_pseudo_diffa_obar
	  );

 END RTL; --output_dqs_iobuf_inst_iobuf_out_sdp
--VALID FILE


LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY output_dqs_iobuf_inst IS
	PORT
	(
		datain		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		oe		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		oe_b		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		dataout		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		dataout_b		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
	);
END output_dqs_iobuf_inst;


ARCHITECTURE RTL OF output_dqs_iobuf_inst IS

--	ATTRIBUTE synthesis_clearbox: boolean;
--	ATTRIBUTE synthesis_clearbox OF RTL: ARCHITECTURE IS TRUE;
	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (0 DOWNTO 0);
	SIGNAL sub_wire1	: STD_LOGIC_VECTOR (0 DOWNTO 0);



	COMPONENT output_dqs_iobuf_inst_iobuf_out_sdp
	PORT (
			dataout	: OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
			datain	: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
			dataout_b	: OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
			oe	: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
			oe_b	: IN STD_LOGIC_VECTOR (0 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	dataout    <= sub_wire0(0 DOWNTO 0);
	dataout_b    <= sub_wire1(0 DOWNTO 0);

	output_dqs_iobuf_inst_iobuf_out_sdp_component : output_dqs_iobuf_inst_iobuf_out_sdp
	PORT MAP (
		datain => datain,
		oe => oe,
		oe_b => oe_b,
		dataout => sub_wire0,
		dataout_b => sub_wire1
	);



END RTL;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Stratix III"
-- Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
-- Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
-- Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Stratix III"
-- Retrieval info: CONSTANT: enable_bus_hold STRING "FALSE"
-- Retrieval info: CONSTANT: number_of_channels NUMERIC "1"
-- Retrieval info: CONSTANT: open_drain_output STRING "FALSE"
-- Retrieval info: CONSTANT: pseudo_differential_mode STRING "TRUE"
-- Retrieval info: CONSTANT: use_differential_mode STRING "TRUE"
-- Retrieval info: CONSTANT: use_oe STRING "TRUE"
-- Retrieval info: CONSTANT: use_termination_control STRING "FALSE"
-- Retrieval info: USED_PORT: datain 0 0 1 0 INPUT NODEFVAL "datain[0..0]"
-- Retrieval info: USED_PORT: dataout 0 0 1 0 OUTPUT NODEFVAL "dataout[0..0]"
-- Retrieval info: USED_PORT: dataout_b 0 0 1 0 OUTPUT NODEFVAL "dataout_b[0..0]"
-- Retrieval info: USED_PORT: oe 0 0 1 0 INPUT NODEFVAL "oe[0..0]"
-- Retrieval info: CONNECT: @datain 0 0 1 0 datain 0 0 1 0
-- Retrieval info: CONNECT: dataout_b 0 0 1 0 @dataout_b 0 0 1 0
-- Retrieval info: CONNECT: @oe 0 0 1 0 oe 0 0 1 0
-- Retrieval info: CONNECT: dataout 0 0 1 0 @dataout 0 0 1 0
-- Retrieval info: GEN_FILE: TYPE_NORMAL output_dqs_iobuf_inst.vhd TRUE FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL output_dqs_iobuf_inst.inc FALSE FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL output_dqs_iobuf_inst.cmp FALSE FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL output_dqs_iobuf_inst.bsf FALSE FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL output_dqs_iobuf_inst_inst.vhd FALSE FALSE
-- Retrieval info: LIB_FILE: stratixiii

