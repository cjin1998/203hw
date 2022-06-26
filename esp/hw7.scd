/*
PROBLEM SET SEVEN: EVENTS, STREAMS, AND PATTERNS
------------------------------------------------
NAME:Azalea Christine
ID:
KEY: 0x0936812A3
*/

/***********
 * Warmups *
 ***********/

// Question 1 - Routines

// Write a routine that produces the powers of 2 starting at 1 one at a time.
(
Array.fill(51, { arg i; i * 2 });

)
(
~r1 = Routine({
	var i = -1;
	{
		i = i+1;
		(2**i).yield;}.loop
});
)

~r1.next;
~r1.reset;

// Write a routine that yields the first 30 harmonics including a fundamental of 400Hz
// one at a time.  Subsequent calls should yield nil.

(
~r2 = Routine({
	var freq = 0;
	30.do{
		freq = freq+400;
		freq.yield;}
});
)

~r2.next;
~r2.reset;

// Question 2 - Time from System Clock

// Schedule a function on the SystemClock to print out the current time of the SystemClock in seconds.
// The function should not reschedule itself.

(
SystemClock.sched(0.0, {
	arg time;
	var hour, min, sec, result;
	hour = time.div(3600);
	min = (time-(hour*3600)).div(60);
	sec = ((time -(time%1))-(hour*3600)-(min*60)).div(1);
	result = hour+":"+min+":"+sec;
	result.postln;
});
)

// Question 3 - Patterns

// Define the following patterns by assigning the pattern variable to the correct pattern.
// You can execute the code block to test if your pattern produced the correct values.

// Define an infinite pattern that starts at 0 and decreases by 2.
(
var pattern, stream;

pattern = Pseries.new(0, -2, inf);

stream = pattern.asStream;
50.do({stream.next.postln;});
)

// Define an infinite pattern that 50% of the time produces -1 and the other 50%
// of the time randomly chooses from the numbers 100, 200, and 300
(
var pattern, stream;

pattern = Pseq.new([-1,Prand.new([100,200,300], 1)],inf);

stream = pattern.asStream;
50.do({stream.next.postln;});
)

// Define a pattern that produces a random even number from 0 to 100 inclusive
// and exhausts (i.e., will produce nil) after 10 repeats.
(
var pattern, stream;

pattern = Prand.new(Array.fill(51, { arg i; i * 2 }), 10);

stream = pattern.asStream;
50.do({stream.next.postln});
)

/**************
 * EXERCISE 1 *
 **************/

(

SynthDef(\longSine, {
	arg out = 0, freq, amp, dur, pan;
	var env, sig;
	sig = SinOsc.ar(freq + SinOsc.kr(0.25, 0, 1)); // slight detuning
	env = EnvGen.kr(Env.sine(dur, amp), doneAction: 2);
	sig = Pan2.ar(sig * env, pan);
	Out.ar(out, sig);
}).add;
)

// Test what longSine sounds like
Synth(\longSine, [\freq, 138.59, \amp, 0.9, \dur, 10, \pan, 0.5]);


// Play the routine of notes with another routine
s.plotTree;


// Routine that generates notes from an Eb natural minor scale
(
	~noteRoutine = Routine({
	{
		if (0.4.coin, {51.yield;},
			{if (0.7.coin,{
				51.yield;
				52.yield;
				53.yield;
				55.yield;
				57.yield;
				59.yield;
				61.yield;
		});

		});

		//2
		rrand(1, 3).do({#[75, 76, 77, 79, 81, 83, 85].choose.yield});

	   //3
		#[63, 64, 65, 67, 69, 71, 73].choose.yield;

	   //4
		rrand(2, 4).do({#[99, 100, 101, 103, 105, 107, 109].choose.yield});

	}.loop;

});

)


(
  ~playRoutine = Routine({
	var dur = 9/10;
	{
		Synth(\longSine,
			[
				\freq, ~noteRoutine.next.midicps,
				\amp, -0.005172* ~noteRoutine.next + 0.6138,
				\dur, rrand(5,10),
				\pan, rrand(-0.6, 0.6),

			]);
		dur.yield;
	}.loop;
});

~playRoutine.play;
)


s.meter;
s.plotTree;
~playRoutine.stop;

/**************
 * EXERCISE 2 *
 **************/

// Place sounds in a dictionary of buffers - make sure to execute this block of code once
(
~soundsFolder = PathName(thisProcess.nowExecutingPath.dirname ++ "/sounds/");
~soundsDictionary = Dictionary.new;
~addSounds = {
	arg pathName, soundsDictionary;
	if (pathName.isFile, {
		pathName.postln;
		soundsDictionary.put(pathName.fileName, Buffer.read(s, pathName.fullPath));
	});
	if (pathName.isFolder, {
		var entries = pathName.entries, index = 0;
		while({index < entries.size}, {
			~addSounds.value(entries[index], soundsDictionary);
			index = index + 1;
		});
	});
};
~addSounds.value(~soundsFolder, ~soundsDictionary);
)

~soundsDictionary // Check the dictionary of sounds for each file

// Starter Code SynthDef and Pattern - modify these below to create
// a more interesting pattern/sound!
(
SynthDef(\play, {
	arg out = 0, bufnum, amp = 1, rate;
	var sig, sigDelayed, env;
	env = EnvGen.kr(Env.perc, levelScale: 0.3, doneAction: 2);
	sig = amp * PlayBuf.ar(2, bufnum, rate*2, doneAction: 2) ;
	sig = sig + amp * PlayBuf.ar(2, bufnum, rate* 0.75, doneAction: 2);
	4.do({ sig = AllpassN.ar(sig, 0.05, [0.05.rand, 0.05.rand], 4) });
	sigDelayed = DelayL.ar(sig, 0.2, SinOsc.kr(1/5, 0, 1), amp);
	Out.ar(out, sig + sigDelayed);
}).add;
)

(
Pbind(
	\instrument, \play,
	\bufnum, Pfunc({~soundsDictionary.choose}),
    \rate, 1,
	\amp, Pwhite(0.5, 0.9),
	\dur, Pseq.new([0.1, 0.22, 0.3, 0.4], inf);
).play;
)

