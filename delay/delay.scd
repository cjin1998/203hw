~cwd = thisProcess.nowExecutingPath.dirname;
~cwd;

~glassHitBuf = Buffer.read(s, ~cwd ++ "/glassHit.aiff");
s.plotTree;

// Feedforward comb filtering
(
SynthDef(\play, {
	arg out = 0, bufnum;
	Out.ar(out, PlayBuf.ar(2, bufnum, doneAction: 2));
}).add;
)

~playGlass = Synth(\play, [\bufnum, ~glassHitBuf]);

(
SynthDef(\simpleDelay, {
	// Outputs a stereo signal
	arg out = 0, delayTime = 0.5, delayAmp = 0.4, in;
	var sig, sigDelayed;
	sig = In.ar(in, 2).poll;
	sigDelayed = DelayN.ar(sig, 1, delayTime, delayAmp);
	Out.ar(out, sig + sigDelayed);
}).add;
)

(
~delayBus = Bus.audio(s, 2);
~delay = Synth(\simpleDelay, [\in, ~delayBus]);
~playGlass = Synth(\play, [\bufnum, ~glassHitBuf, \out, ~delayBus]);
)

(
~delayBus.free;
~delay.free;
)

// Complex delays

(
SynthDef(\multiDelay, {
	// Outputs a stereo signal
	arg out = 0, delayTime = 0.4, delayAmp = 0.4, in;
	var sig, sigDelayed;
	sig = In.ar(in, 2);
	sigDelayed = 0;
	10.do({
		arg index;
		sigDelayed = sigDelayed + DelayN.ar(sig, 1, (0.3 * (index/2)), delayAmp/(index + 1));
	});
	Out.ar(out, sigDelayed);
}).add;
)

// UGens like DelayN use dynamically allocated buffers to store data to be played back later
// as is typical for a delay.  If you plan to use a lot of DelayN's or other UGens that use
// such memory allocation, then I strongly recommend increasing the server's memory storage
// for such UGens.  This is a common case for the error "exception in real time: alloc failed".
(
s.options.memSize_(2.pow(16));
s.reboot;
)

(
~delayMultiBus = Bus.audio(s, 2);
~delayMulti = Synth(\multiDelay, [\in, ~delayMultiBus]);
~playGlass = Synth(\play, [\bufnum, ~glassHitBuf, \out, ~delayMultiBus]);
)

(
~delayMultiBus.free;
~delayMulti.free;
)

s.plotTree;
s.meter;

// Feedback comb filtering
(
SynthDef(\noise, {
	arg out = 0, amp = 0.2;
	Out.ar(out, WhiteNoise.ar(amp)!2);
}).add;
)

(
SynthDef(\fbComb, {
	arg out = 0, delayTime = 0.2, decayTime = 1, in;
	var sig, sigCombed;
	sig = In.ar(in, 2);
	sigCombed = CombN.ar(sig, 2, delayTime, decayTime);
	Out.ar(out, sigCombed);
}).add;
)

~noise = Synth(\noise);
~noise.free;

(
~combBus = Bus.audio(s, 2);
~noise = Synth(\noise, [\out, ~combBus]);
~comb = Synth(\fbComb, [\in, ~combBus], ~noise, \addAfter);
)

~comb.set(\delayTime, 0.02);

(
~combBus.free;
~noise.free;
~comb.free;
)

s.plotTree;