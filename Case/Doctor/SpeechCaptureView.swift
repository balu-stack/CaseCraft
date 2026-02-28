//
//  SpeechCaptureView.swift
//  Case
//
//  Created by SAIL L1 on 25/02/26.
//


import SwiftUI

struct SpeechCaptureView: View {

    @StateObject private var asr = SpeechRecognizer()

    var body: some View {
        VStack(spacing: 14) {

            Button {
                Task {
                    if asr.isRecording {
                        await asr.stop()
                    } else {
                        await asr.start()
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "waveform")
                    Text(asr.isRecording ? "Stop Recording" : "Start Recording")
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.accentColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            // Live transcript
            Text(asr.transcript.isEmpty ? "Speak now…" : asr.transcript)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            if let err = asr.errorMessage {
                Text(err)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Spacer()
        }
        .padding()
    }
}