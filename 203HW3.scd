/*
CATCHING A WAVE
--------------------------------------------------
NAME: Christine Jin and Azalea Sun
ID: B20855407 and B20859088
KEY: 0xAE41290F
*/

// Question 1

(
~sawRampUp = {
	arg freq = 300, funAmp = 0.6;
	var sig = {
		|i| // One less than the harmonic num which are one indexed (not zero)
		if (((i+1)%2==1), {SinOsc.ar(freq * (i + 1), 0, funAmp/(i + 1)) ;}, {SinOsc.ar(freq * (i + 1), pi, funAmp/(i + 1));})
		// Freq and amp come from harmonic number
	}.dup(30).sum; // 30 represents the number of harmonics
	sig ! 2;
};
)

~sawRampUp.plot;
~sawRampUp.play;
~sawRampUp.play(args: [\freq, 40, \fundAmp, 0.5]) // Choose different parameters

// Question 5

(
~pulse = {
	arg freq=440, dcycle=0.5, amp=0.2;
	var sig = LFSaw.ar(freq, 0, amp/2) - LFSaw.ar(freq, 2*dcycle, amp/2);
	sig!2;
};
)

~pulse.plot;
~pulse.play;

~pulse.play(args: [\freq, 50, \dcycle, 0.4, \amp, 0.5]); // Choose different parameters
~pulse.plot(args: [\freq, 50, \dcycle, 0.4, \amp, 0.5]);