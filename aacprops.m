@import AudioToolbox;
@import Foundation;

static int channels[] = {
	1, 2, 5, 7
};

static AudioFormatID formats[] = {
	kAudioFormatMPEG4AAC,
	kAudioFormatMPEG4AAC_HE,
	kAudioFormatMPEG4AAC_HE_V2
};

static char * formatNames[] = {
	"AAC", "AAC HE", "AAC HEv2"
};

#define arraySize( x ) (sizeof(x) / sizeof(*x))

int main ( )
{
	for (int chanIdx = 0; chanIdx < arraySize(channels); chanIdx++) {
		for (int fmtIdx = 0; fmtIdx < arraySize(formats); fmtIdx++) {

			AudioStreamBasicDescription inFmt = {
				.mSampleRate = 48000,
				.mFormatID = kAudioFormatLinearPCM,
				.mFormatFlags = kAudioFormatFlagIsSignedInteger
								| kAudioFormatFlagIsPacked,
				.mFramesPerPacket = 1,
				.mChannelsPerFrame = channels[chanIdx],
				.mBitsPerChannel = 16
			};

			int bytes = (inFmt.mBitsPerChannel / 8) * inFmt.mChannelsPerFrame;
			inFmt.mBytesPerFrame = bytes;
			inFmt.mBytesPerPacket = bytes;

			AudioStreamBasicDescription outFmt = {
				.mSampleRate = 48000,
				.mFormatID = formats[fmtIdx],
				.mChannelsPerFrame = channels[chanIdx]
			};

			AudioConverterRef converter;
			AudioConverterNew(&inFmt, &outFmt, &converter);


			UInt32 size = 0;
			OSStatus err = AudioConverterGetPropertyInfo(
				converter,
				kAudioConverterApplicableEncodeBitRates,
				&size, NULL);

			if (err) continue;

			printf("==================================\n");
			printf("Format: %s\n", formatNames[fmtIdx]);
			printf("Channels: %d\n", channels[chanIdx]);
			printf("Supported Sample Rates:\n");

			AudioValueRange *ranges = malloc(size);

			AudioConverterGetProperty(converter,
				kAudioConverterApplicableEncodeBitRates,
				&size, ranges);

			int count = size / sizeof(AudioValueRange);
			for (int i = 0; i < count; i++) {
				AudioValueRange * range = &ranges[i];
				if (range->mMaximum == range->mMinimum) {
					printf("%f\n", range->mMinimum);
				} else {
					printf("%f to  %f\n", range->mMinimum, range->mMaximum);
				}
			}
			printf("\n\n");
		}
	}
}
