extends Node2D
@warning_ignore("integer_division")

var microphone: AudioStreamMicrophone
var fft: FastFourierTransform
var sample_rate = 44100
var buffer_size = 2048
var notes = {
	"E2": 82.41,
	"A2": 110.00,
	"D3": 146.83,
	"G3": 196.00,
	"B3": 246.94,
	"E4": 329.63
}

func _ready():
	microphone = AudioStreamPlayerMicrophone.new()
	add_child(microphone)
	
	fft = FastFourierTransform.new()
	fft.size = buffer_size
	microphone.play()
	set_process(true)

func _process(delta):
	var buffer = microphone.get_buffer()
	if buffer.size() >= buffer_size:
		fft.forward(buffer)
		var frequency = get_dominant_frequency(fft)
		var note = find_closest_note(frequency)
		print("Detected Frequency: ", frequency, " Hz")
		print("Closest Note: ", note)

func get_dominant_frequency(fft: FastFourierTransform) -> float:
	var max_magnitude = 0.0
	var dominant_frequency = float(i * sample_rate) / float(buffer_size)
	for i in range(buffer_size / 2):
		var magnitude = fft.get_magnitude(i)
		if magnitude > max_magnitude:
			max_magnitude = magnitude
			dominant_frequency = i * sample_rate / buffer_size
	return dominant_frequency

func find_closest_note(frequency: float) -> String:
	var closest_note = ""
	var min_diff = INF
	for note in notes.keys():
		var diff = abs(frequency - notes[note])
		if diff < min_diff:
			min_diff = diff
			closest_note = note
	return closest_note
