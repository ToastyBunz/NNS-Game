extends Node2D


const VU_COUNT = 50
const FREQ_MAX = 11050.0

const WIDTH = 400
const HEIGHT = 100

const MIN_DB = 60

var spectrum

var frame_count = 0

var spectrum_instance: AudioEffectSpectrumAnalyzerInstance = null
var sample_rate: float = 44100.0  # Assume a standard sample rate

func _ready():
	spectrum = AudioServer.get_bus_effect_instance(1,1)

func print_max():
	@warning_ignore("integer_division")
	#var magnitude: float = spectrum.get_magnitudes_for_frequency_range(0, 1000).length()
	#var hertzies: float = spectrum.get_frequency(0, 1000).length()
	#print(magnitude)
	#print(hertzies)
	#print('hello')
	#var effect_slot = 0  # The slot where you added the AudioEffectSpectrumAnalyzer
	
	#if spectrum:
		## Get the spectrum data for the range 0 Hz to 1000 Hz
		#var spectrum = spectrum.get_magnitude_for_frequency_range(0, 1000, 512)
			#
		## Find the index of the maximum magnitude
		#var max_magnitude = -INF
		#var max_index = -1
		#for i in range(spectrum.size()):
			#if spectrum[i] > max_magnitude:
				#max_magnitude = spectrum[i]
				#max_index = i
#
		## Convert the index to frequency in Hz
		#var frequency_resolution = sample_rate / 2 / spectrum.size()
		#var dominant_frequency = max_index * frequency_resolution
		#
		#print("Dominant frequency: ", dominant_frequency, " Hz, Magnitude: ", max_magnitude)
		
		

# Get the spectrum data for the range 20 Hz to 20000 Hz
	var spectrum = spectrum.get_magnitude_for_frequency_range(20, 20000, 512)
	
	print('length', spectrum)
	

	#if spectrum.length() > 0:
		## Find the index of the maximum magnitude
		#var max_magnitude = -INF
		#var max_index = -1
		#for i in range(spectrum.length()):
			#if spectrum[i] > max_magnitude:
				#max_magnitude = spectrum[i]
				#max_index = i
#
## Convert the index to frequency in Hz
		#var frequency_resolution = (sample_rate / 2.0) / float(spectrum.length())
		#var dominant_frequency = float(max_index) * frequency_resolution
#
		#print("Dominant frequency: ", dominant_frequency, " Hz, Magnitude: ", max_magnitude)



func _process(_delta):
	queue_redraw()
	if frame_count == 30:
		frame_count = 0
		print_max()
		
	frame_count +=1

func _draw():
	@warning_ignore("integer_division")
	var w = WIDTH / VU_COUNT
	var prev_hz = 0
	for i in range(1, VU_COUNT+1):
		var hz = i * FREQ_MAX / VU_COUNT;
		var magnitude: float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		print(magnitude)
		var energy = clamp((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		var height = energy * HEIGHT
		draw_rect(Rect2(w * i, HEIGHT - height, w, height), Color.WHITE)
		
		
		prev_hz = hz




