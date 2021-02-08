import pandas as pd
import soundfile as sf

def convert_to_wav(path):
    df = pd.read_csv(path)
    data = df.values.astype('int16')
    sf.write(path+'.wav', data, sample_rate_hz)

sample_rate_hz = 48000
convert_to_wav("square.csv")
convert_to_wav("saw.csv")
convert_to_wav("synthesizer_song.csv")
# convert_to_wav("synthesizer_sweeps.csv")
# convert_to_wav("polyphony.csv")
# convert_to_wav("polyphony_sweeps.csv")
