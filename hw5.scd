/*
PROBLEM SET FIVE
--------------------------------------------------
NAME: Christine Jin and Azalea Sun
ID:B 20855407 and B20859088
HOURS TO COMPLETE: 8
KEY: 0x54EFEA14
*/

/***********
 * WARMUPS *
 ***********/

/*
 * WARMUP 3: Create an octavizer that takes some frequency and produces a sine wave
 * of that frequency and a sine wave of twice that frequency.  You must use ring
 * modulation to arrive at your answer.
 */

(
 SynthDef(\octavizer, {
     arg out = 0, freq = 440, amp = 0.1;
     Out.ar(out, (SinOsc.ar(freq) + SinOsc.ar(freq*2) * amp) ! 2);
 }).add;
 )

(
SynthDef(\octavizer, {
	arg out = 0, freq = 440, amp = 0.1;
	Out.ar(out, amp*SinOsc.ar(freq/2*3)*2*SinOsc.ar(freq/2)! 2);
}).add;
)

FreqScope.new;
~oct = Synth(\octavizer, [\freq, 440]);
~oct.set(\freq, 300);

/*************
 * EXERCISES *
 *************/

/*
 * EXERCISE 1: Connect the synthDef you implement called richSaw which simulates
 * a digital string sound and passes it to an effects synth called \pingPong
 * which has been implemented for you. See the assignment description for more
 * details.
 */

(
SynthDef(\richSaw, {
	arg out = 0, amp = 0.1, freq = 600, atkTime = 0.5, susTime = 1, relTime = 3;
	var env, sig, freqs;
	env = Env.linen(atkTime, susTime, relTime, 1.0, 'sine');
	env = EnvGen.kr(env, doneAction: 2);
	sig = Saw.ar(freq, amp);
	freqs = Array.rand(10, freq, freq*1.01);
	freqs.do({
		|item, index|
		sig = sig + Saw.ar(item, amp);
	});
	Out.ar(out, sig*env);
}).add;
)

// Test to make sure \richSaw works
Synth(\richSaw); // should only hear out of left speaker

(
SynthDef(\pingPong, {
	arg in, out = 0;
	var sig = In.ar(in, 1);
	sig = Pan2.ar(sig, SinOsc.kr(0.75, 0, 0.6));
	Out.ar(out, sig);
}).add;
)

// 1) Create an effects bus
// 2) Create a synth that creates effects
// 3) Create a synth that plays the rich saw and passes it into the effects
// and make sure it is instantiated before the effects synth.  Use s.plotTree;
// to check
(
// Your code here
~effectsBus = Bus.audio(s, 2);
~effectsSynth = Synth(\richSaw, [\out, ~effectsBus, \freq, 400]);
~sawSynth = Synth(\pingPong, [\in, ~effectsBus], ~effectsSynth, 'addAfter');
)

s.plotTree;

// Free sounds
(
~effectsSynth.free;
~effectsBus.free;
)

/*
 * EXERCISE 3: Create Synths that use the \fm SynthDef below to produce a bell, clarinet
 * and triangle sound.  See problem set description for more information.
 */

(
SynthDef(\fm, {
	arg out = 0, freq_c = 200, modIndex = 0.5, harmRatio = 2.35, atk = 0.4, dec = 0.5, sus =0,
    susLvl = 0.2, rel = 7, amp = 0.6, curve = 1;
    var car, mod, freq_m, env;
    freq_m = harmRatio * freq_c;
    mod = (modIndex * freq_m) * SinOsc.ar(freq_m, 0, 1);
    car = SinOsc.ar(freq_c + mod, 0, 1);
	env = Env([0, amp, susLvl, susLvl, 0], [atk, dec, sus, rel], curve);
    env = EnvGen.kr(env, doneAction: 2);
    Out.ar(out, car * env ! 2);
}).add;
)

~oct = Synth(\fm);

// Bell
(
~bell = Synth(\fm, [
	\freq_c, 200,
	\modIndex, 0.5,
	\harmRatio, 1.37,
	\atk, 0.2,
	\dec, 1,
	\sus, 1.5,
	\susLvl, 0.6,
	\rel, 5,
	\amp, 1,
	\curve, 1.75,
]);
)

// Clarinet
(
~clarinet = Synth(\fm, [
	\freq_c, 300,
	\modIndex, 2.2,
	\harmRatio, 2,
	\atk, 0.001,
	\dec, 0.002,
	\sus, 3.5,
	\susLvl, 0.7,
	\rel, 4.5,
	\amp, 1,
	\curve, 1,
]);
)

// Triangle
(
~triangle = Synth(\fm, [
	\freq_c, 10000,
	\modIndex, 1.5,
	\harmRatio,1.29,
	\atk, 0.001,
	\dec, 0.275,
	\sus, 0,
	\susLvl, 0.275,
	\rel, 2.7,
	\amp, 0.55,
	\curve, 1.75,
]);
)

/*
 * EXERCISE 5: use frequency modulation to create a ramp up effect.  See problem
 * set description for more details.
 */

(
SynthDef(\rampUp, {
	arg out = 0, freq_c = 440, amp = 0.1, freq_m = 0.5;
	// Your code here
	var sig = SinOsc.ar(freq_c + (freq_c * LFSaw.ar(freq_m)), amp);
	Out.ar(out, sig ! 2);

}).add;
)



x = Synth(\rampUp, [\freq_c, 880, \freq_m, 2]);
x.set(\freq_m, 2);
x.set(\freq_c, 880);
s.meter;

(
SynthDef(\randRamp, {
	arg out = 0, amp = 0.1;
	// Your code here
}).add;
)

Synth(\randRamp);

/*************
 * CHALLENGE *
 *************/

(
SynthDef(\berlinBass, {
	arg out = 0, freq_c = 103.8, amp = 0.6;
	// Your code here

}).add;
)

(
SynthDef(\effects, {
	arg out = 0, in = 0;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig, 0.25, 0.3, 0.5);
	Out.ar(out, sig);
}).add;
)

// Run just once when your MIDI keyboard is plugged in
(
MIDIClient.init;
MIDIIn.connectAll;
)

// Test the synth with a MIDI keyboard
(
~effectsBus = Bus.audio(s, 2);
~effects = Synth(\effects, [\in, ~effectsBus]);

~notesDict = Dictionary.new;
~soundDef = \berlinBass;

MIDIdef.noteOn(\adsrOn, {
	|vel, num, chan, src|
	var synth = Synth(~soundDef, [
		\freq_c, num.midicps.postln,
		\amp, (vel.linexp(0, 127, 1.3, 1.5) - 1).postln,
		\out, ~effectsBus
	], ~effects, 'addBefore');
	~notesDict.put(num, synth);
});

MIDIdef.noteOff(\adsrOff, {
	|vel, num, chan, src|
	var synth = ~notesDict.at(num);
	synth.set(\gate, 0);
	~notesDict.removeAt(num);
});
)

440/3