/*
PROBLEM SET: Sound Fundamentals
----------------------------------
NAME:Christine Jin
ID: B20855407
HOURS TO COMPLETE: 4hrs
KEY: 0x12AE1824
*/

/*
WARMUP
*/
s.boot;
// Warmup 3

(
{SinOsc.ar([400, 800], [0, pi], 0.2)}.play
)

/*
EXERCISES
*/

// Exercise 3

/* Write a function called ~thirdPartials that takes a fundamental
 * frequency and produces every third partial starting with the fundamental.
 * Each nth partial should have an amplitude of 1/n times the amplitude of
 * the fundamental frequency.
 *
 * This function accepts three arguments:
 *   1st arg: fundFreq -> the fundamental frequency
 *   2nd arg: numPartials -> an integer specifying the total number of partials
 *   3rd arg: amp -> the amplitude of the fundamental frequency
 *
 * For example, a call to ~thirdPartials.value(400, 3, 0.2) will produce the
 * 1st, 4th and 7th partials where 400Hz is the fundamental frequency.  The amplitude
 * for the 1st partial should be 0.2.  The amplitude for the 4th partial should be
 * 0.2/4.  The amplitude for the 7th partial should be 0.2/7.  If the second argument
 * is less than 1, no sound is produced.  You may assume all provided frequencies
 * are between 20-20,000Hz, the audible frequency spectrum for human hearing, and that
 * the amplitude for the third argument is between 0 and 1.
 */

(
~thirdPartials = {
	arg fundFreq, numPartials, amp;
	i=0;
	while({(numPartials-i) > 0}, {
		{SinOsc.ar(fundFreq*(1+(3*i)), 0, amp/(1+(3*i)))}.play; i = i+1 });
}
)

~thirdPartials.value(400, 3, 0.2);
~thirdPartials.value(400, 10, 0.2);
s.scope;
FreqScope.new; // Open a window to see your frequencies charted live!

// Exercise 4d
(
~freq = {
	// Your code here
}
)

~freq.value(400, 12); // Should produce a number very close to 800
~freq.value(400, 7); // Should produce the frequency a P5 above 400Hz (i.e., 600Hz)
