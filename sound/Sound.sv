//============================================================================
//  Arcade: Zaxxon
//
//  Port to MiSTer
//  Copyright (C) 2017 Sorgelig
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================

module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [45:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        VGA_CLK,

	//Multiple resolutions are supported using different VGA_CE rates.
	//Must be based on CLK_VIDEO
	output        VGA_CE,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,

	//Base video clock. Usually equals to CLK_SYS.
	output        HDMI_CLK,

	//Multiple resolutions are supported using different HDMI_CE rates.
	//Must be based on CLK_VIDEO
	output        HDMI_CE,

	output  [7:0] HDMI_R,
	output  [7:0] HDMI_G,
	output  [7:0] HDMI_B,
	output        HDMI_HS,
	output        HDMI_VS,
	output        HDMI_DE,   // = ~(VBlank | HBlank)
	output  [1:0] HDMI_SL,   // scanlines fx

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	output  [7:0] HDMI_ARX,
	output  [7:0] HDMI_ARY,

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S,    // 1 - signed audio samples, 0 - unsigned

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..6 - USR2..USR6
	// Set USER_OUT to 1 to read from USER_IN.
	input   [6:0] USER_IN,
	output  [6:0] USER_OUT
);

	assign VGA_F1    = 0;
	assign USER_OUT  = '1;
	assign LED_USER  = disk_light;//ioctl_download;
	assign LED_DISK  = disk_light;
	assign LED_POWER = 0;
	wire disk_light;

	assign HDMI_ARX = status[1] ? 8'd16 : 8'd4;
	assign HDMI_ARY = status[1] ? 8'd9  : 8'd3;


	`include "build_id.v" 
	localparam CONF_STR = {
		"SOUND;;",
		"F,rom;",
		"H0O1,Aspect Ratio,Original,Wide;",
		"H0O2,Orientation,Vert,Horz;",
		"O35,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
		"-;",
		"R0,Reset;",
		"J1,Fire,Start 1P,Start 2P,Coin,Cheat;",
		"jn,A,Start,Select,R,L;",
		"V,v",`BUILD_DATE
	};

	////////////////////   CLOCKS   ///////////////////

	wire clk_sys, clk_audio, clk_48;
	wire pll_locked;

	pll pll
	(
		.refclk(CLK_50M),
		.rst(0),
		.outclk_0(clk_48),
		.outclk_1(clk_audio), // 0.96
		.outclk_2(clk_sys),  //24
		.locked(pll_locked)
	);


	///////////////////////////////////////////////////

	wire [31:0] status;
	wire  [1:0] buttons;
	wire        forced_scandoubler;
	wire        direct_video;

	wire        ioctl_download;
	wire  [7:0] ioctl_index;
	wire        ioctl_wr;
	wire [24:0] ioctl_addr;
	wire  [7:0] ioctl_dout;

	wire [10:0] ps2_key;

	wire [15:0] joy1 =  (joy1a | joy2a);
	wire [15:0] joy2 =  (joy1a | joy2a);
	wire [15:0] joy1a;
	wire [15:0] joy2a;

	wire [21:0] gamma_bus;

	hps_io #(.STRLEN($size(CONF_STR)>>3), .WIDE(0)) hps_io
	(
		.clk_sys(clk_sys),
		.HPS_BUS(HPS_BUS),

		.conf_str(CONF_STR),

		.buttons(buttons),
		.status(status),
		.status_menumask(direct_video),
		.forced_scandoubler(forced_scandoubler),
		.gamma_bus(gamma_bus),
		.direct_video(direct_video),

		.ioctl_download(ioctl_download),
		.ioctl_wr(ioctl_wr),
		.ioctl_addr(ioctl_addr),
		.ioctl_dout(ioctl_dout),
		.ioctl_index(ioctl_index),

		.joystick_0(joy1a),
		.joystick_1(joy2a),
		.ps2_key(ps2_key)
	);

	wire no_rotate = status[2];
	wire hblank, vblank;
	wire ohblank, ovblank;
	wire hs, vs;
	wire ohs, ovs;
	wire [7:0] r,g;
	wire [7:0] b;
	wire [7:0] outr,outg;
	wire [7:0] outb;

	// should be 1.5MHZ
	reg ce_pix;
	always @(posedge clk_48) begin
			  reg [2:0] div;
			  div <= div + 1'd1;
			  ce_pix <= !div;
	end


	arcade_video #(256,224,24) arcade_video
	(
		.*,

		.clk_video(clk_48),

		.RGB_in({outr,outg,outb}),
		.HBlank(ohblank),
		.VBlank(ovblank),
		.HSync(ohs),
		.VSync(ovs),

		.forced_scandoubler(0),
		.no_rotate(1),
		.rotate_ccw(0),
		.fx(status[5:3])
	);


	wire [15:0] audio;
	assign AUDIO_L = audio;
	assign AUDIO_R = audio;
	assign AUDIO_S = 1; 

	reg [9:0] difficulty = 2'b01;

	wire de;

	ovo #(.COLS(2), .LINES(2), .RGB(24'hFF00FF)) diff (
			  .i_r(r),
			  .i_g(g),
			  .i_b(b),
			  .i_hs(~hs),
			  .i_vs(~vs),
			  .i_de(de),
			  .i_hblank(hblank),
			  .i_vblank(vblank),
			  .i_en(ce_pix),
			  .i_clk(clk_48),

			  .o_r(outr),
			  .o_g(outg),
			  .o_b(outb),
			  .o_hs(ohs),
			  .o_vs(ovs),
			  .o_de(ode),
			  .o_hblank(ohblank),
			  .o_vblank(ovblank),

			  .ena(1'b1),

			  .in0(difficulty),
			  .in1(difficulty-1)
	);


	soc soc(
		.pixel_clock(ce_pix), // wrong
		.reset(reset), // wrong
		.SDRAM_nCS(junk),
		.VGA_HS(hs),
		.VGA_VS(vs),
		.VGA_R(r),
		.VGA_G(g),
		.VGA_B(b),
		.VGA_HBLANK(hblank),
		.VGA_VBLANK(vblank),
		.VGA_DE(de)
	);

	wire reset = status[0] | buttons[1] |ioctl_download; 

	wire[31:0] frequencies[7:0];
	wire[31:0] voice_volumes[7:0];

	Keyboard keyboard(
		.clk(clk_audio),
		.ps2_key(ps2_key),
		.frequencies(frequencies), 
		.voice_volumes(voice_volumes)
	);

	Synthesizer synth(
		.clk(clk_audio),
		.clock_speed(48000),
		.cutoff(4),
		.voice_volumes(voice_volumes),
		.frequencies(frequencies),
		.out(audio)
	);

endmodule
