(
/*-------------------------------------------*/
/*================LOAD=======================*/
/*-------------------------------------------*/
var path;

path = thisProcess.nowExecutingPath.dirname;

// Load helpers
["binSelect", "parseRt", "dnaStrand", "getOrganism", "morseToDur"].do({
	arg function;
	(path +/+ "composer_functions/" ++ function ++ ".scd").load;
})
)

// ~me_a = ~me_a.morseselect("TT", zeroMultiplier: 2);

(
// GET ME
~me_a = ~dnaStrand.value(scale: Scale.major, chord_size: 2, chord_interval: 10);
~me_b = ~dnaStrand.value(scale: Scale.minorPentatonic, chord_size: 4, chord_interval: 4);

~me_a = 7.collect({
	arg i;
	~me_a.morseselect("Tallis", (("Tallis".morse2bin.size * i) % ~me_a.size), zeroMultiplier: 2)
}).flatten;

~me_b = 7.collect({
	arg i;
	~me_a.morseselect("Tallis", (("Tallis".morse2bin.size * i + 3) % ~me_a.size), zeroMultiplier: 2)
}).flatten

/*~me_a = ~me_a.collect({
	arg chord, count;
	~binSelect.value("TT", ~me_a, offset: count, mode: "morse");
}).flatten;

~me_b = ~me_b.collect({
	arg chord, count;
	~binSelect.value("Danny", ~me_b, offset: count, mode: "morse")
}).flatten;*/

~me = ~getInterleaved.value(~me_a, ~me_b);
~me.size;
)

~me_a.size

~me_a = ~me_a.morseselect("TT", zeroMultiplier: 0);

~me_a.do({
	arg item;
	item.postln
});

~me_a.size
"TT".morse2bin.size;

/*-------------------------------------------*/
/*================PLAYBACK===================*/
/*-------------------------------------------*/
(
// MIDI setup
MIDIClient.init;

m = MIDIOut.new(0);
m.latency(0);
)

(
r = Routine.new({
	a = Pbind(
		\type, \midi,
		\midiout, m,
		\chan, 0,
		\midicmd, \noteOn,
		\midinote, Pseq(~me, 1),
		\legato, 1,
		\amp, 0.6,
		\dur, 1,
	).asStream;

	8.wait;

	b = Pbind(
		\type, \midi,
		\midiout, m,
		\chan, 1,
		\midicmd, \noteOn,
		\midinote, Pseq(~me, 1),
		\legato, 1,
		\amp, 0.6,
		\dur, 2/3,
	).asStream;

}).asStream
)

r.next
~me_a
(
a = Pbind(
	\type, \midi,
	\midiout, m,
	\chan, 0,
	\midicmd, \noteOn,
	\midinote, Pseq(~me_a, 1),
	\legato, 1,
	\amp, 0.4,
	\dur, 1
).asStream;

b = Pbind(
	\type, \midi,
	\midiout, m,
	\chan, 1,
	\midicmd, \noteOn,
	\midinote, Pseq(~me_a + 12, 1),
	\legato, 1,
	\amp, 0.3,
	\dur, 1
).asStream;

c = Pbind(
	\type, \midi,
	\midiout, m,
	\chan, 2,
	\midicmd, \noteOn,
	\midinote, Pseq(~me_b + 12, 1),
	\legato, 1,
	\amp, 0.25,
	\dur, 1
).asStream;

d = Pbind(
	\type, \midi,
	\midiout, m,
	\chan, 3,
	\midicmd, \noteOn,
	\midinote, Pseq(~me_b, 1),
	\legato, 1,
	\amp, 0.2,
	\dur, 1
).asStream;
)

(
e = CircleStruct.new(a, 128);
f = CircleStruct.new(b, 128);
g = CircleStruct.new(c, 128);
h = CircleStruct.new(d, 128);
)

// Why does this come apart? I should post the abs_onsets into a file to compare?

b.calculate_position(1).convertArray.do({
	arg event;
	event.abs_onset.postln
})

e.calculate_position(0).asEventStreamPlayer.play

c.calculate_position

(
x = Routine({

	e.calculate_position(0).asEventStreamPlayer.play;
	2.wait;
	f.calculate_position(2).asEventStreamPlayer.play;
	2.wait;
	g.calculate_position(3).asEventStreamPlayer.play;
	2.wait;
	h.calculate_position(4).asEventStreamPlayer.play;
	/*g.calculate_position(2).asEventStreamPlayer.play;
	h.calculate_position(3).asEventStreamPlayer.play;*/

	/*c.calculate_position(8).asEventStreamPlayer.play;
	d.calculate_position(12).asEventStreamPlayer.play;*/
	/*2.do({
		arg i;
		b.calculate_position(i).asEventStreamPlayer.play;
		4.wait
	})*/
}).play
)

e.calculate_position(0).next.play

(
~me_a_one = ~me_a.collect({
	arg item;
	if (item.class != Integer, {item[0]}, {0})
});
~me_a_two = ~me_a.collect({
	arg item;
	if (item.class != Integer, {item[1]}, {0})
});
)


(
a.pause;
b.pause;
)

(
a.play;
b.play;
)

