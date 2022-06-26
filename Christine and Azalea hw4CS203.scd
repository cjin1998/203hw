/*
PROBLEM SET FOUR
--------------------------------------------------
NAME: Azalea Sun and Christine Jin
ID: B20859088 and B20855407
KEY: 0x4259AE32
*/

/**************
 * EXERCISE 1 *
 **************/

{SinOsc.ar([400, 400], 0, 0.1)}.play;

// Part a - Find a frequency between 44100/2 and 44100 that produces the same sine
// wave of 400Hz as above.

(
var testFreq = 43700; // Enter your new frequency here
{SinOsc.ar([testFreq, testFreq], 0, 0.1)}.play;
)

// Part b - Find a frequency greater than 44100 the produces the same sine wave
// of 400Hz above.

(
var testFreq = 87800; // Enter your new frequency here
{SinOsc.ar([testFreq, testFreq], 0, 0.1)}.play;
)

/**************
 * EXERCISE 2 *
 **************/

(
var testFreq = 22050; // Write your answer here
{SinOsc.ar(testFreq, 0, 1) ! 2}.play;
)

s.meter // Check the output here - it should be zero

/**************
 * EXERCISE 4 *
 **************/

// Place your code for exercise 4 below
(
 ~size = 1024;

{   var sig, low = 30, high = 200;
	var level = Array.rand(10, 0.02, 1);
	var time = Array.linrand(8, 1, 10);
	~env2 = Env.new(level, time, curve: 'lin').asSignal(~size);
	~envBuf = Buffer.alloc(s, ~size * 2);
	~envBuf.loadCollection(~env2.asWavetable);

   sig = Osc.ar(~envBuf.bufnum, MouseX.kr(low, high, 1), mul: 0.2) ! 2;
   sig = sig + Osc.ar(~envBuf.bufnum, MouseX.kr(low*2+0.5, high*2+0.5, 1), mul: 0.2) ! 2;

   sig = LeakDC.ar(sig);

   sig}.play;

)


/**************
 * EXERCISE 5 *
 **************/

// Place your code for exercise 5 below.
(
var amps;
~size = 128;

	amps = ([0.15] ++ {
	   |i|
	   var harmNum = i + 1;
	   [0, 0.05.exprand(0.5)/harmNum.sqrt].wchoose([0.4, 0.6]); // Choose zero 20% of the time
   }.dup(31)).postln;

   ~randSig = Signal.sineFill(
	   ~size,
	   amps,
	   Array.rand(8, 0.2, 0.7);
   );
)


(
{  var sig, freq = 300, amp = 0.2, osc;
   ~envBuf = Buffer.alloc(s, ~size * 2);
   ~envBuf.loadCollection(~randSig.asWavetable);

	sig = Osc.ar(~envBuf.bufnum, freq, mul: 0.2);
	sig = sig +Saw.ar(freq+SinOsc.kr(0.25, 0, 30), 0, amp/2);
	sig = sig * SinOsc.ar(freq*2+0.5, 0, amp/3);
	sig = sig +LFTri.ar(freq+SinOsc.kr(0.1, 0, 100), 0, amp/2);
	osc = Osc.ar(~envBuf.bufnum, freq.rrand(freq * 1.007) + (Array.series(5, 0, 1).choose * freq), 0, 0.15);
	osc = Pan2.ar(osc, -0.4.rrand(0.4));
	sig = sig + osc;
	sig = sig!2;
	sig = LeakDC.ar(sig);
	sig
}.play;
)

/**/

/**************
 * EXERCISE 6 *
 **************/

// Place your code for exercise 6 below.

(
   var  amps, level, time, newamps;
   ~size = 1024;

   amps = ([0.15] ++ {
	   |i|
	   var harmNum = i + 1;
	   [0, 0.05.exprand(0.5)/harmNum.sqrt].wchoose([0.4, 0.6]); // Choose zero 20% of the time
   }.dup(31)).postln;

   ~wav1 = Signal.sineFill(
	   ~size,
	   amps,
	   Array.rand(8, 0.2, 0.7);
   );


   level = Array.rand(10, 0.02, 1);
   time = Array.linrand(8, 1, 10);
   ~wav2 = Env.new(level, time, curve: 'lin').asSignal(~size);


   ~wav3 = Signal.sineFill(~size, [1,0.05,2], [0,1,3]);


   newamps = ([0.2] ++ {
	   |i|
	   var harmNum = i + 1;
	   [0, 0.05.exprand(0.5)/harmNum.sqrt].wchoose([0.2, 0.8]); // Choose zero 20% of the time
   }.dup(31)).postln; // Duplicate for an array of amplitudes

   ~wav4 = Signal.sineFill(
	   ~size,
	   newamps,
	   Array.rand(10, 0.0, 0.6);
   );

   ~wav5 = Signal.sineFill(~size, 1.0/[1, 2, 3, 4, 5, 6]);


)


(
{   var sig;

	~bufs = Buffer.allocConsecutive(5,s,2048, 1);

	~bufs[0].loadCollection(~wav1.asWavetable);
	~bufs[1].loadCollection(~wav2.asWavetable);
	~bufs[2].loadCollection(~wav3.asWavetable);
	~bufs[3].loadCollection(~wav4.asWavetable);
	~bufs[4].loadCollection(~wav5.asWavetable);

	sig = VOsc.ar(2+SinOsc.ar(0.2,0,2),300,0,1);
	sig = sig + VOsc.ar(2+SinOsc.ar(0.2,0,1),400,0,1);
	sig = sig + VOsc.ar(2+SinOsc.ar(0.2,0,2),600.5,0,1);

	sig

}.play;
)

