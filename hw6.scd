/*
PROBLEM SET SIX: FREQUENCY, DELAY, REVERB
--------------------------------------------------
NAME: christine Jin and Azalea Sun
ID:
KEY: 0x0EF2AE34
*/

/*************
 * EXERCISES *
 *************/

// EXERCISE 1: Build a Flanger

// Sound source: White Noise
(
SynthDef(\whiteNoise, {
	arg out = 0;
	var sig;
	sig = WhiteNoise.ar(0.1);
	Out.ar(out, sig)
}).add;
)

// Test white noise
Synth(\whiteNoise);

// Sound source: Guitar riff
(
var path = thisProcess.nowExecutingPath.dirname ++ "/track1.wav";
path.postln;
~guitarBuf = Buffer.read(s, path);
SynthDef(\play, {
	arg out = 0, bufnum, amp = 0.7;
	var sig;
	sig = PlayBuf.ar(2, bufnum, doneAction: 2) * amp;
	Out.ar(out, sig);
}).add;
)

// Test guitar noise
Synth(\play, [\bufnum, ~guitarBuf]);

// Build the flanger here
(
SynthDef(\flanger, {
	arg in, out = 0, depth = 0.05, rate = 0.05, sweep = 0.0005, centerDelay = 0.01, amp = 1;
	var sig, sigDelayed;
	sig = In.ar(in, 2).poll;
	sigDelayed = DelayL.ar(sig, 0.2, sweep*SinOsc.kr(1/rate, 0, 1)+centerDelay, amp);
	Out.ar(out, (sig + (depth * sigDelayed))*amp);
}).add;
)

// Establish a bus to route incoming sound into the flanger
(
~flangBus = Bus.audio(s, 1);
~flang = Synth(\flanger, [\in, ~flangBus]);
)

// Pass the white noise into the flanger
~wn = Synth(\whiteNoise, [\out, ~flangBus], ~flang, 'addBefore');
~wn.free;

// Pass the guitar into the flanger
(
~guitar = Synth(\play, [\bufnum, ~guitarBuf, \out, ~flangBus], ~flang, 'addBefore');
~flang.set(\depth, 0.5);
~flang.set(\rate, 0.25);
)

// EXERCISE 3: Cavernous Reverb

// A single ping
(
SynthDef(\ping, {
	arg out = 0;
	var sig;
	sig = Impulse.ar(0, 0, 0.3);
	sig = Ringz.ar(sig, 2000, 1);
	DetectSilence.ar(sig, doneAction: 2); // Frees once silence occurs
	Out.ar(out, sig ! 2);
}).add;
)

// Test the single ping
Synth(\ping);

// A series of infinite pings
(
SynthDef(\pings, {
	arg out = 0;
	var sig;
	sig = Impulse.ar(1, 0, 0.3);
	sig = Ringz.ar(sig, 2000, LFTri.kr(1/8, 0, 1, 2.2));
	sig = Pan2.ar(sig, SinOsc.kr(0.25, 0, 0.5));
	Out.ar(out, sig);
}).add;
)

// Test the stream of pings
x = Synth(\pings);

// Define a reverb
(
SynthDef(\cavernousReverb, {
	arg in, out = 0, reverbGain = 0.2;
	var input, predelay, earlyRef, lateRef;

	input = In.ar(in, 1);

	predelay = DelayN.ar(input, 0.048);

	earlyRef = Mix.fill(5, {CombL.ar(predelay, 0.15, LFNoise1.kr(0.1.rand, 0.04, 0.05), 3)});

	lateRef = earlyRef;
	8.do({lateRef = AllpassN.ar(lateRef, 0.050, [0.050.rand, 0.050.rand], 0.7)});

	lateRef = LPF.ar(lateRef, 1600);

	Out.ar(out, input + (reverbGain * lateRef));

}).add;
)
(
SynthDef(\reverb, {
	arg out, in, dec=2, lpf=1500;
	var sig;
	sig = In.ar(in, 2).sum; // Condense to single channel
	sig = DelayN.ar(sig, 0.05, 0.05); // Predelay
	sig = CombN.ar(sig, 0.1, {Rand(0.05,0.13)} ! 20, dec);
	sig = SplayAz.ar(2, sig); // Condense to stereo channel
	5.do({sig = AllpassN.ar(sig, 0.1, {Rand(0.01,0.03)}!2, 3)}); // 5 All pass filters in series
	sig = LPF.ar(sig, lpf); // LPF to eliminate high frequency ringing
	sig = LeakDC.ar(sig); // Probably not necessary
	Out.ar(out, sig);
}).add;
)

// Create Reverb Bus
~caveVerbBus = Bus.audio(s, 2);

// Instantiate Reverb
~caveVerb = Synth(\reverb, [\in, ~caveVerbBus]);

// Play Ping or Pings
~ping = Synth(\ping, [\out, ~caveVerbBus], ~caveVerb, \addBefore);
~pings = Synth(\pings, [\out, ~caveVerbBus], ~caveVerb, \addBefore);
~pings.free;

s.meter;

/*************
 * CHALLENGE *
 *************/

// Flanger with Feedback
// Note that we rely on the two sound sources from Exercise 1
// so make sure those SynthDefs are defined
(
SynthDef(\flangerFeedback, {
	arg in, out=0, depth=1, feedback = 0.1, rate = 0.5, sweep = 0.0045,
	centerDelay = 0.005, amp = 1;
	// Your code here

}).add;
)

// Establish an audio bus and instantiate the flanger
(
~flangFeedBus = Bus.audio(s, 1);
~flangFeed = Synth(\flangerFeedback, [\in, ~flangFeedBus]);
)

// Play white noise through the feedback flanger
~wn = Synth(\whiteNoise, [\out, ~flangFeedBus], ~flangFeed, 'addBefore');
~wn.free;

// Change settings on the flanger
(
~flangFeed.set(
	\depth, 1,
	\feedback, 0.8,
	\rate, 0.5,
	\sweep, 0.0045,
	\centerDelay, 0.006,
	\amp, 0.6
);
)

// Play the guitar riff through the feedback flanger
(
~guitar = Synth(\play, [\bufnum, ~guitarBuf, \out, ~flangFeedBus], ~flangFeed, 'addBefore');
// Set some initial parameters
~flangFeed.set(
	\depth, 0.5,
	\feedback, 0.1,
	\rate, 0.25,
	\sweep, 0.0045,
	\centerDelay, 0.005,
	\amp, 1
);
)

// Change settings on the flanger
(
~flangFeed.set(
	\depth, 0.5,
	\feedback, 0.98,
	\rate, 0.25,
	\sweep, 0.0045,
	\centerDelay, 0.005,
	\amp, 1
);
)