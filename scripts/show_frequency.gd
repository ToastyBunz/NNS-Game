#extends Node2D
#var record_bus_index: int
#var samples = []
#var spectrum_instance: AudioEffectSpectrumAnalyzerInstance = null
#var spectrum
#
#var vu_count = 50
#var freq_max = 44100.0
#var Min_db = 60
#
 ##Called when the node enters the scene tree for the first time.
#func _ready():
	#record_bus_index = AudioServer.get_bus_index('Freqout')
	#var spectrum = AudioServer.get_bus_effect_instance(record_bus_index,1)
	#
	##sample rate for referance
	##var sample_rate = AudioServer.get_mix_rate()
	##print("Sample rate:", sample_rate)
	#
	## Set up a timer to trigger harmonic_product_spectrum 10 times per second
	##var timer = Timer.new()
	##timer.wait_time = 0.5  # 0.1 seconds for 10 Hz analysis rate
	##timer.one_shot = false
	##timer.connect("timeout", Callable(self, "harmonic_product_spectrum"))
	##add_child(timer)
	##timer.start()
	#
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func harmonic_product_spectrum():
	#var frequency_bins = []
	#var frequency_step = 100  # Step in Hz, adjust as needed
#
	## Collect original spectrum data
	#for freq in range(20, 20000, frequency_step):
		#var magnitude = spectrum.get_magnitude_for_frequency_range(freq, freq + frequency_step).x
		#frequency_bins.append(magnitude)
	#
	#print(frequency_bins)
#
	## Downsample and multiply spectra
	#var hps_spectrum = frequency_bins.duplicate()
	#for downsample_factor in range(2, 5):  # 2nd to 4th harmonics
		#var downsampled_bins = []
		#for i in range(0, frequency_bins.size(), downsample_factor):
			#downsampled_bins.append(frequency_bins[i])
#
		## Multiply downsampled spectrum with the HPS spectrum
		#for j in range(downsampled_bins.size()):
			#hps_spectrum[j] *= downsampled_bins[j]
#
	## Find the peak frequency after HPS
	#var peak_index = 0
	#var max_value = -INF
	#for i in range(hps_spectrum.size()):
		#if hps_spectrum[i] > max_value:
			#max_value = hps_spectrum[i]
			#peak_index = i
#
	## Calculate the frequency of the peak
	#var peak_frequency = peak_index * frequency_step
	#print("Peak frequency:", peak_frequency)
			#
	##frequency_bins.sort_custom(_compare_magnitude)
	##print("Major frequencies:", frequency_bins)
#
## Helper function to sort by magnitude
#func _compare_magnitude(a, b):
	#return b["magnitude"] - a["magnitude"]  # Sort in descending order
#
#func _process(delta: float):
	#@warning_ignore("integer_division")
	#pass
	##find_maor_frequencise()
	##harmonic_product_spectrum()
	
extends Node

var record_bus_index
var spectrum
var note_strings = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
var frequency_buffer = []
const SMOOTHING_BUFFER_SIZE = 10
const MIN_DECIBEL_THRESHOLD = 0.00005
const FFT_SIZE = 2048  # Set FFT size manually


func _ready():	
	record_bus_index = AudioServer.get_bus_index("Freqout")
	spectrum = AudioServer.get_bus_effect_instance(record_bus_index, 1)
	spectrum.set("fft_size", FFT_SIZE)  # Manually set the FFT size

	var timer = Timer.new()
	timer.wait_time = 0.5  # 10 Hz analysis rate
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "analyze_audio"))
	add_child(timer)
	timer.start()
	
func generate_logarithmic_steps(start_freq = 27.5, end_freq = 4186.0):
	var frequencies = []
	var ratio = pow(2, 1.0 / 12)  # 12th root of 2 for equal temperament
	var current_freq = start_freq

	while current_freq <= end_freq:
		frequencies.append(current_freq)
		current_freq *= ratio  # Multiply by the ratio to get the next frequency step

	return frequencies

func analyze_audio():
	var frequencies = generate_logarithmic_steps()
	var data_array = []
	var step_size = 3  # Frequency step size
	#var start_freq = 20
	#var end_freq = 20000

	# Collect magnitude data for each frequency range
	for i in range(frequencies.size() - 1):
		var start_freq = frequencies[i]
		var end_freq = frequencies[i + 1]
		var magnitude = spectrum.get_magnitude_for_frequency_range(start_freq, end_freq)
		data_array.append(magnitude.x)  # Use magnitude.x for left channel

	# Calculate signal strength (RMS)
	var rms = 0.0
	for val in data_array:
		rms += val * val
	rms = sqrt(rms / data_array.size())
	#print('rms value', rms)
	if rms < MIN_DECIBEL_THRESHOLD:
		#print('signal too weak')
		return  # Signal too weak

	# Apply autocorrelation to detect pitch
	var frequency = auto_correlate(data_array, AudioServer.get_mix_rate())
	if frequency == -1:
		print('no pitch detection')
		return  # No pitch detected

	# Smooth the detected frequency
	if frequency_buffer.size() >= SMOOTHING_BUFFER_SIZE:
		frequency_buffer.pop_front()
	frequency_buffer.push_back(frequency)

	var average_frequency = 0.0
	for freq in frequency_buffer:
		average_frequency += freq
	average_frequency /= frequency_buffer.size()

	# Detect note and display information
	var detected_note = frequency_to_note(average_frequency)
	print("Detected Note: ", detected_note)
	print("Current Frequency: ", average_frequency)

func auto_correlate(buf, sample_rate):
	var SIZE = buf.size()
	var rms = 0.0

	# Calculate RMS
	for val in buf:
		rms += val * val
	rms = sqrt(rms / SIZE)
	if rms < 0.0005:
		print("RMS too low:", rms)
		return -1  # Not enough signal

	# Define signal range
	var r1 = 0
	var r2 = SIZE - 1
	var thres = 0.2
	for i in range(SIZE / 2):
		if abs(buf[i]) < thres:
			r1 = i
			break
	for i in range(SIZE / 2):
		if abs(buf[SIZE - i - 1]) < thres:
			r2 = SIZE - i - 1
			break

	print("Trimmed signal range:", r1, r2)
	buf = buf.slice(r1, r2)
	SIZE = buf.size()

	# Autocorrelation
	var c = []
	for i in range(SIZE):
		var sum = 0.0
		for j in range(SIZE - i):
			sum += buf[j] * buf[j + i]
		c.append(sum)

	# Find the first peak
	var d = 0
	while d < SIZE - 1 and c[d] > c[d + 1]:
		d += 1

	var maxval = -1
	var maxpos = -1
	for i in range(d, SIZE):
		if c[i] > maxval:
			maxval = c[i]
			maxpos = i
	if maxpos == -1:
		print("No clear peak found in autocorrelation.")
		return -1

	print("Peak detected at:", maxpos, "with value:", maxval)
	var T0 = maxpos

	# Parabolic interpolation for better precision
	var x1 = c[T0 - 1]
	var x2 = c[T0]
	var x3 = c[T0 + 1]
	var a = (x1 + x3 - 2 * x2) / 2
	var b = (x3 - x1) / 2
	if a != 0:
		T0 = T0 - b / (2 * a)

	var detected_frequency = sample_rate / T0
	print("Detected frequency:", detected_frequency)
	return detected_frequency


func frequency_to_note(frequency):
	var note = round(12 * log(frequency / 440.0) / log(2)) + 69
	var note_index = int(note) % 12
	var scale = int(floor(note / 12)) - 1
	return note_strings[note_index] + str(scale)





